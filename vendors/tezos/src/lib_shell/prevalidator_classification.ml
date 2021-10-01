(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2021 Nomadic Labs, <contact@nomadic-labs.com>               *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

module Event = struct
  let section = ["prevalidator_classification"]

  include Internal_event.Simple

  let predecessor_less_block =
    declare_1
      ~section
      ~name:"predecessor_less_block"
      ~msg:"Observing that a parent of block {blk_h} has no predecessor"
      ~level:Warning
      ("blk_h", Block_hash.encoding)
end

type classification =
  [ `Applied
  | `Branch_delayed of tztrace
  | `Branch_refused of tztrace
  | `Refused of tztrace ]

(** This type wraps together:

    - a bounded ring of keys (size book-keeping)
    - a regular (unbounded) map of key/values (efficient read)

    All operations must maintain integrity between the 2!
*)
type bounded_map = {
  ring : Operation_hash.t Ringo.Ring.t;
  mutable map : (Operation.t * error list) Operation_hash.Map.t;
}

let map bounded_map = bounded_map.map

(** [mk_empty_bounded_map ring_size] returns a {!bounded_map} whose ring
    holds at most [ring_size] values. {!Invalid_argument} is raised
    if [ring_size <= 0]. *)
let mk_empty_bounded_map ring_size =
  {ring = Ringo.Ring.create ring_size; map = Operation_hash.Map.empty}

type parameters = {
  map_size_limit : int;
  on_discarded_operation : Operation_hash.t -> unit;
}

(** Note that [applied] and [in_mempool] are intentionally unbounded.
    See the mli for detailed documentation.
    All operations must maintain the invariant about [in_mempool]
    described in the mli. *)
type t = {
  parameters : parameters;
  refused : bounded_map;
  branch_refused : bounded_map;
  branch_delayed : bounded_map;
  mutable applied_rev : (Operation_hash.t * Operation.t) list;
  mutable in_mempool : Operation_hash.Set.t;
}

let create parameters =
  {
    parameters;
    refused = mk_empty_bounded_map parameters.map_size_limit;
    branch_refused = mk_empty_bounded_map parameters.map_size_limit;
    branch_delayed = mk_empty_bounded_map parameters.map_size_limit;
    in_mempool = Operation_hash.Set.empty;
    applied_rev = [];
  }

let set_of_bounded_map bounded_map =
  Operation_hash.Map.fold
    (fun oph _ acc -> Operation_hash.Set.add oph acc)
    bounded_map.map
    Operation_hash.Set.empty

let flush (classes : t) ~handle_branch_refused =
  if handle_branch_refused then (
    Ringo.Ring.clear classes.branch_refused.ring ;
    classes.branch_refused.map <- Operation_hash.Map.empty) ;
  Ringo.Ring.clear classes.branch_delayed.ring ;
  classes.branch_delayed.map <- Operation_hash.Map.empty ;
  classes.applied_rev <- [] ;
  classes.in_mempool <-
    Operation_hash.Set.union
      (set_of_bounded_map classes.refused)
      (set_of_bounded_map classes.branch_refused)

let is_in_mempool oph classes = Operation_hash.Set.mem oph classes.in_mempool

let is_applied oph classes =
  List.exists (fun (h, _) -> Operation_hash.equal h oph) classes.applied_rev

(* Removing an operation is currently used for operations which are
   banned (this can only be achieved by the adminstrator of the
   node). However, removing an operation which is applied invalidates
   the classification of all the operations. Hence, the
   classifications of all the operations should be reset. Currently,
   this is not enforced by the function and has to be done by the
   caller.

   Later on, it would be probably better if this function returns a
   set of pending operations instead. *)
let remove oph classes =
  classes.refused.map <- Operation_hash.Map.remove oph classes.refused.map ;
  classes.branch_refused.map <-
    Operation_hash.Map.remove oph classes.branch_refused.map ;
  classes.branch_delayed.map <-
    Operation_hash.Map.remove oph classes.branch_delayed.map ;
  classes.in_mempool <- Operation_hash.Set.remove oph classes.in_mempool ;
  classes.applied_rev <-
    List.filter (fun (op, _) -> Operation_hash.(op <> oph)) classes.applied_rev

let handle_applied oph op classes =
  classes.applied_rev <- (oph, op) :: classes.applied_rev ;
  classes.in_mempool <- Operation_hash.Set.add oph classes.in_mempool

(* 1. Add the operation to the ring underlying the corresponding
   error map class.

    2a. If the ring is full, remove the discarded operation from the
   map and the [in_mempool] set, and calls the callback with the
   discarded operation.

    2b. If the operation is [Refused], call the callback with it, as
   the operation is discarded. In this case it means the operation
   should not be propagated. It is still stored in a bounded map for
   the [pending_operations] RPC.

    3. Add the operation to the underlying map.

    4. Add the operation to the [in_mempool] set. *)
let handle_error oph op classification classes =
  let (bounded_map, tztrace) =
    match classification with
    | `Branch_refused tztrace -> (classes.branch_refused, tztrace)
    | `Branch_delayed tztrace -> (classes.branch_delayed, tztrace)
    | `Refused tztrace -> (classes.refused, tztrace)
  in
  Ringo.Ring.add_and_return_erased bounded_map.ring oph
  |> Option.iter (fun e ->
         bounded_map.map <- Operation_hash.Map.remove e bounded_map.map ;
         classes.parameters.on_discarded_operation e ;
         classes.in_mempool <- Operation_hash.Set.remove e classes.in_mempool) ;
  (match classification with
  | `Refused _ -> classes.parameters.on_discarded_operation oph
  | _ -> ()) ;
  bounded_map.map <- Operation_hash.Map.add oph (op, tztrace) bounded_map.map ;
  classes.in_mempool <- Operation_hash.Set.add oph classes.in_mempool

let add classification oph op classes =
  match classification with
  | `Applied -> handle_applied oph op classes
  | (`Branch_refused _ | `Branch_delayed _ | `Refused _) as classification ->
      handle_error oph op classification classes

let to_map ~applied ~branch_delayed ~branch_refused ~refused classes =
  let module Map = Operation_hash.Map in
  let ( +> ) accum to_add =
    let merge_fun _k accum_v_opt to_add_v_opt =
      match (accum_v_opt, to_add_v_opt) with
      | (Some accum_v, None) -> Some accum_v
      | (None, Some (to_add_v, _err)) -> Some to_add_v
      | (Some _accum_v, Some (to_add_v, _err)) ->
          (* This case should not happen, because the different classes
             should be disjoint. However, if this invariant is broken,
             it is not critical, hence we do not raise an error.
             Because such part of the code is quite technical and
             the invariant is not critical,
             we don't advertise the node administrator either (no log). *)
          Some to_add_v
      | (None, None) -> None
    in
    Map.merge merge_fun accum to_add
  in
  (if applied then Map.of_seq @@ List.to_seq classes.applied_rev else Map.empty)
  +> (if branch_delayed then classes.branch_delayed.map else Map.empty)
  +> (if branch_refused then classes.branch_refused.map else Map.empty)
  +> if refused then classes.refused.map else Map.empty

type 'block block_tools = {
  hash : 'block -> Block_hash.t;
  operations : 'block -> Operation.t list list;
  all_operation_hashes : 'block -> Operation_hash.t list list;
}

type 'block chain_tools = {
  clear_or_cancel : Operation_hash.t -> unit;
  inject_operation : Operation_hash.t -> Operation.t -> unit Lwt.t;
  new_blocks :
    from_block:'block -> to_block:'block -> ('block * 'block list) Lwt.t;
  read_predecessor_opt : 'block -> 'block option Lwt.t;
}

(* There's detailed documentation in the mli *)
let handle_live_operations ~(block_store : 'block block_tools)
    ~(chain : 'block chain_tools) ~(from_branch : 'block) ~(to_branch : 'block)
    ~(is_branch_alive : Block_hash.t -> bool) old_mempool =
  let rec pop_block ancestor (block : 'block) mempool =
    let hash = block_store.hash block in
    if Block_hash.equal hash ancestor then Lwt.return mempool
    else
      let operations = block_store.operations block in
      List.fold_left_s
        (List.fold_left_s (fun mempool op ->
             let h = Operation.hash op in
             chain.inject_operation h op >|= fun () ->
             Operation_hash.Map.add h op mempool))
        mempool
        operations
      >>= fun mempool ->
      chain.read_predecessor_opt block >>= function
      | None ->
          (* Can this happen? If yes, there's nothing more to pop anyway,
             so returning the accumulator. It's not the mempool that
             should crash, should this case happen. *)
          Event.(emit predecessor_less_block ancestor) >|= fun () -> mempool
      | Some predecessor ->
          (* This is a tailcall, which is nice; that is why we annotate
             here. But it is not required for the code to be correct.
             Given the maximum size of possible reorgs, even if the call
             was not tail recursive; we wouldn't reach the runtime's stack
             limit. *)
          (pop_block [@tailcall]) ancestor predecessor mempool
  in
  let push_block mempool block =
    let operations = block_store.all_operation_hashes block in
    List.iter (List.iter chain.clear_or_cancel) operations ;
    List.fold_left
      (List.fold_left (fun mempool h -> Operation_hash.Map.remove h mempool))
      mempool
      operations
  in
  chain.new_blocks ~from_block:from_branch ~to_block:to_branch
  >>= fun (ancestor, path) ->
  pop_block (block_store.hash ancestor) from_branch old_mempool
  >>= fun mempool ->
  let new_mempool = List.fold_left push_block mempool path in
  let (new_mempool, outdated) =
    Operation_hash.Map.partition
      (fun _oph op -> is_branch_alive op.Operation.shell.branch)
      new_mempool
  in
  Operation_hash.Map.iter (fun oph _op -> chain.clear_or_cancel oph) outdated ;
  Lwt.return new_mempool

let recycle_operations ~from_branch ~to_branch ~live_blocks ~classification
    ~pending ~(block_store : 'block block_tools) ~(chain : 'block chain_tools)
    ~handle_branch_refused =
  handle_live_operations
    ~block_store
    ~chain
    ~from_branch
    ~to_branch
    ~is_branch_alive:(fun branch -> Block_hash.Set.mem branch live_blocks)
    (Operation_hash.Map.union
       (fun _key v _ -> Some v)
       (to_map
          ~applied:true
          ~branch_delayed:true
          ~branch_refused:handle_branch_refused
          ~refused:false
          classification)
       pending)
  >>= fun pending ->
  flush classification ~handle_branch_refused ;
  Lwt.return pending

module Internal_for_tests = struct
  (** [copy_bounded_map bm] returns a deep copy of [bm] *)
  let copy_bounded_map (bm : bounded_map) : bounded_map =
    let copy_ring (ring : Operation_hash.t Ringo.Ring.t) =
      let result = Ringo.Ring.capacity ring |> Ringo.Ring.create in
      List.iter (Ringo.Ring.add result) (Ringo.Ring.elements ring) ;
      result
    in
    {map = bm.map; ring = copy_ring bm.ring}

  let copy (t : t) : t =
    (* Code could be shorter by doing a functional update thanks to
       the 'with' keyword. We rather list all the fields, so that
       the compiler emits a warning when a field is added. *)
    {
      parameters = t.parameters;
      refused = copy_bounded_map t.refused;
      branch_refused = copy_bounded_map t.branch_refused;
      branch_delayed = copy_bounded_map t.branch_delayed;
      applied_rev = t.applied_rev;
      in_mempool = t.in_mempool;
    }

  let[@coverage off] bounded_map_pp ppf bounded_map =
    bounded_map.map |> Operation_hash.Map.bindings
    |> List.map (fun (key, _value) -> key)
    |> Format.fprintf ppf "%a" (Format.pp_print_list Operation_hash.pp)

  let[@coverage off] pp ppf
      {
        parameters;
        refused;
        branch_refused;
        branch_delayed;
        applied_rev;
        in_mempool;
      } =
    let applied_pp ppf applied =
      applied
      |> List.map (fun (key, _value) -> key)
      |> Format.fprintf ppf "%a" (Format.pp_print_list Operation_hash.pp)
    in
    let in_mempool_pp ppf in_mempool =
      in_mempool |> Operation_hash.Set.elements
      |> Format.fprintf ppf "%a" (Format.pp_print_list Operation_hash.pp)
    in
    Format.fprintf
      ppf
      "Map_size_limit:@.%i@.On discarded operation: \
       <function>@.Refused:%a@.Branch refused:@.%a@.Branch \
       delayed:@.%a@.Applied:@.%a@.In Mempool:@.%a"
      parameters.map_size_limit
      bounded_map_pp
      refused
      bounded_map_pp
      branch_refused
      bounded_map_pp
      branch_delayed
      applied_pp
      applied_rev
      in_mempool_pp
      in_mempool

  let set_of_bounded_map = set_of_bounded_map

  let[@coverage off] pp_t_sizes pp t =
    let show_bounded_map name bounded_map =
      Format.sprintf
        "%s map: %d, %s ring: %d"
        name
        (Operation_hash.Map.cardinal bounded_map.map)
        name
        (List.length (Ringo.Ring.elements bounded_map.ring))
    in
    Format.fprintf
      pp
      "map_size_limit: %d\n%s\n%s\n%s\napplied_rev: %d\nin_mempool: %d"
      t.parameters.map_size_limit
      (show_bounded_map "refused" t.refused)
      (show_bounded_map "branch_refused" t.branch_refused)
      (show_bounded_map "branch_delayed" t.branch_delayed)
      (List.length t.applied_rev)
      (Operation_hash.Set.cardinal t.in_mempool)

  let to_map = to_map

  let handle_live_operations = handle_live_operations
end
