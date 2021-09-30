(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2021 Nomadic Labs. <contact@nomadic-labs.com>               *)
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

(** Testing
    -------
    Component:    Shell (Prevalidator)
    Invocation:   dune exec src/lib_shell/test/test_prevalidator_classification_handle_operations.exe
    Subject:      Unit tests [Prevalidator_classification.Internal_for_tests.handle_live_operations]
*)

open Lib_test.Qcheck_helpers
module Op_map = Operation_hash.Map
module Classification = Prevalidator_classification

(** Various functions about {!list} *)
module List_extra = struct
  (** [common_elem [0; 2; 3] [3; 2]] returns [Some 2]
      [common_elem [0; 2; 3] [2; 3]] returns [Some 3]
      [common_elem [0; 2; 3] [4]] returns [Nothing] *)
  let rec common_elem ~(equal : 'a -> 'a -> bool) (l1 : 'a list) (l2 : 'a list)
      =
    match (l1, l2) with
    | ([], _) -> None
    | (e1 :: rest1, _) ->
        if List.exists (equal e1) l2 then Some e1
        else common_elem ~equal rest1 l2

  (** [take_until_if_found ((=) 2)  [0; 3; 2; 4; 2]] returns [Some [0; 3]]
      [take_until_if_found ((=) -1) [0; 3; 2; 4; 2]] returns [None]
      [take_until_if_found ((=) 0)  [0]]             returns [Some []] *)
  let rec take_until_if_found ~(pred : 'a -> bool) (l : 'a list) =
    match l with
    | [] -> None
    | fst :: _ when pred fst -> Some []
    | fst :: rest_l -> (
        match take_until_if_found ~pred rest_l with
        | None -> None
        | Some tail -> Some (fst :: tail))
end

module Tree = struct
  (** Trees representing the shape of the chain. The root is the common
      ancestor of all blocks, like this:

                      head3
                        /
         head1  head2  .
            \       \ /
             .       .
              \     /
              ancestor
  *)
  type 'a tree =
    | Leaf of 'a
    | Node1 of ('a * 'a tree)
    | Node2 of ('a * 'a tree * 'a tree)

  (* Note that I intentionally do not use {!Format} as automatic
     line cutting makes reading the output (when debugging) harder. *)
  let rec to_string elem_to_string t indent =
    match t with
    | Leaf e -> indent ^ elem_to_string e
    | Node1 (e, subt) ->
        let indentpp = indent ^ "  " in
        Printf.sprintf
          "%s%s\n%s"
          indent
          (elem_to_string e)
          (to_string elem_to_string subt indentpp)
    | Node2 (e, t1, t2) ->
        let indentpp = indent ^ "  " in
        Printf.sprintf
          "%s%s\n%s\n%s"
          indent
          (elem_to_string e)
          (to_string elem_to_string t1 indentpp)
          (to_string elem_to_string t2 indentpp)

  let to_string elem_to_string t = to_string elem_to_string t ""

  let rec depth = function
    | Leaf _ -> 1
    | Node1 (_, t1) -> 1 + depth t1
    | Node2 (_, t1, t2) -> 1 + max (depth t1) (depth t2)

  (** The root value of a tree *)
  let value : 'a tree -> 'a = function
    | Leaf a -> a
    | Node1 (a, _) -> a
    | Node2 (a, _, _) -> a

  let rec values : 'a tree -> 'a list = function
    | Leaf a -> [a]
    | Node1 (a, t1) -> a :: values t1
    | Node2 (a, t1, t2) -> a :: values t1 @ values t2

  (** Predicate to check that all values are different. We want
      this property for trees of blocks. If generation of block
      were to repeat a block, this property could get broken. I have
      not witnessed it, but being safe. *)
  let well_formed (type a) (compare : a -> a -> int) (t : a tree) =
    let module Ord = struct
      type t = a

      let compare = compare
    end in
    let module Set = Set.Make (Ord) in
    let values_list = values t in
    let values_set = Set.of_list values_list in
    List.length values_list = Set.cardinal values_set

  (** Given a tree of values, returns an association list from a value to
      its parent (i.e. predecessor) in the tree. I.e. given :

             c1   c2  c3
              \    \ /
               b0   b1
                \  /
                 a0

      return: [(b0, a0); (c1, b0); (b1, a0); (c2, b1); (c3; b1)]
  *)
  let rec predecessor_pairs (tree : 'a tree) : ('a * 'a) list =
    match tree with
    | Leaf _ -> []
    | Node1 (e, subtree) ->
        let child = value subtree in
        (child, e) :: predecessor_pairs subtree
    | Node2 (e, subtree1, subtree2) ->
        let child1 = value subtree1 in
        let child2 = value subtree2 in
        (child1, e) :: (child2, e) :: predecessor_pairs subtree1
        @ predecessor_pairs subtree2

  (** Returns the predecessors of a tree node. I.e., given
      such a tree:

             c1   c2  c3
              \    \ /
               b0   b1
                \  /
                 a0

      [predecessors [c1]] is [b0; a0]
      [predecessors [a0]] is []
      [predecessors [b1]] is [a0]
  *)
  let predecessors ~(equal : 'a -> 'a -> bool) (tree : 'a tree) (e : 'a) =
    let predecessor_pairs = predecessor_pairs tree in
    let rec main (x : 'a) =
      match List.assoc ~equal x predecessor_pairs with
      | None -> []
      | Some parent -> parent :: main parent
    in
    main e

  let predecessors ~(equal : 'a -> 'a -> bool) (tree : 'a tree) (e : 'a) =
    let res = predecessors ~equal tree e in
    (* If this assertion breaks, the tree is illformed *)
    assert (not (List.mem ~equal e res)) ;
    res

  (** [elems t] returns all values within [t] *)
  let rec elems : 'a tree -> 'a list = function
    | Leaf a -> [a]
    | Node1 (a, t1) -> a :: elems t1
    | Node2 (a, t1, t2) -> a :: elems t1 @ elems t2

  (** [find_ancestor tree e1 e2] returns the common ancestor of [e1] and [e2]
      in [tree], if any *)
  let find_ancestor ~(equal : 'a -> 'a -> bool) (tree : 'a tree) (e1 : 'a)
      (e2 : 'a) : 'a option =
    let parents1 = predecessors ~equal tree e1 in
    let parents2 = predecessors ~equal tree e2 in
    if List.mem ~equal e1 parents2 then Some e1
    else if List.mem ~equal e2 parents1 then Some e2
    else List_extra.common_elem ~equal parents1 parents2
end

(** Module concerning the type with which [Prevalidator.Internal_for_tests.block_tools]
    and [Prevalidator.Internal_for_tests.chain_tools] are instantiated *)
module Block = struct
  (** The block-like interface that suffices to test
      [Prevalidator.Internal_for_tests.handle_live_operations] *)
  type t = {
    hash : Block_hash.t;
    operations : (Operation_hash.t * Operation.t) list list;
  }

  let equal : t -> t -> bool =
    let lift_eqs (left_eq : 'a -> 'a -> bool) (right_eq : 'b -> 'b -> bool)
        ((l1, l2), (r1, r2)) =
      left_eq l1 r1 && right_eq l2 r2
    in
    let pair_eq = lift_eqs Operation_hash.equal Operation.equal in
    fun block1 block2 ->
      (* Note that we could use the assumption that block hash
         uniquely identifies a block. We don't do that, so that
         we don't have to be careful about honoring this property when
         generating random data. *)
      Block_hash.equal block1.hash block2.hash
      &&
      (* Note that we could use the assumption that an operation hash
         uniquely identifies  the operation. We don't do that, so that
         we don't have to be careful about honoring this property when
         generating random data. *)
      let left_ops = List.concat block1.operations in
      let right_ops = List.concat block2.operations in
      List.compare_lengths left_ops right_ops = 0
      &&
      let combined = List.combine_drop left_ops right_ops in
      List.for_all pair_eq combined

  let compare (t1 : t) (t2 : t) =
    let hash_diff = Block_hash.compare t1.hash t2.hash in
    if hash_diff <> 0 then hash_diff
    else
      let compare_pair (oph1, op1) (oph2, op2) =
        let hash_diff = Operation_hash.compare oph1 oph2 in
        if hash_diff <> 0 then hash_diff else Operation.compare op1 op2
      in
      List.compare (List.compare compare_pair) t1.operations t2.operations

  let tools : t Classification.block_tools =
    let hash block = block.hash in
    let operations block = List.map (List.map snd) block.operations in
    let all_operation_hashes block = List.map (List.map fst) block.operations in
    {hash; operations; all_operation_hashes}

  let to_string t =
    let ops_list_to_string ops =
      String.concat
        "|"
        (List.map Operation_hash.to_short_b58check (List.map fst ops))
    in
    let ops_string =
      List.fold_left
        (fun acc ops -> Format.sprintf "%s[%s]" acc (ops_list_to_string ops))
        ""
        t.operations
    in
    Format.asprintf "%a:[%s]" Block_hash.pp t.hash ops_string

  (** Pretty prints a list of {!t}, using [sep] as the separator *)
  let pp_list ~(sep : string) (ts : t list) =
    String.concat sep @@ List.map to_string ts
end

(** [QCheck] generators used in tests below *)
module Generators = struct
  let tree_gen gen =
    let open QCheck.Gen in
    (* Factor used to limit the depth of the tree. *)
    let max_depth_factor = 25 in
    let open Tree in
    fix
      (fun self current_depth_factor ->
        frequency
          [
            (max_depth_factor, map (fun elem -> Leaf elem) gen);
            ( current_depth_factor,
              map
                (fun (elem, tree) -> Node1 (elem, tree))
                (pair gen (self (current_depth_factor - 1))) );
            ( current_depth_factor,
              map
                (fun (elem, tree1, tree2) -> Node2 (elem, tree1, tree2))
                (triple
                   gen
                   (self (current_depth_factor - 1))
                   (self (current_depth_factor - 1))) );
          ])
      max_depth_factor

  module OpMapArb = MakeMapArb (Operation_hash.Map.Legacy)

  let op_map_gen : Operation.t Operation_hash.Map.t QCheck.Gen.t =
    OpMapArb.gen
      Prevalidator_generators.operation_hash_gen
      Prevalidator_generators.operation_gen

  let block_gen : Block.t QCheck.Gen.t =
    let open QCheck.Gen in
    let* hash = Prevalidator_generators.block_hash_gen in
    let* ops =
      let ops_list_gen =
        (* Having super long list of operations isn't necessary.
           In addition it slows everything down. *)
        list_size (int_range 0 10) Prevalidator_generators.operation_gen
      in
      (* In production these lists are exactly of size 4, being more general *)
      ops_list_gen |> list_size (int_range 0 8)
    in
    let ops_and_hashes =
      List.map (List.map (fun op -> (Operation.hash op, op))) ops
    in
    return Block.{hash; operations = ops_and_hashes}

  (** A generator for passing the last argument of
      [Prevalidator.handle_live_operations] *)
  let old_mempool_gen (tree : Block.t Tree.tree) :
      Operation.t Operation_hash.Map.t QCheck.Gen.t =
    let blocks = Tree.values tree in
    let pairs =
      List.map Block.tools.operations blocks |> List.concat |> List.concat
    in
    let elements =
      List.map (fun (op : Operation.t) -> (Operation.hash op, op)) pairs
    in
    if elements = [] then QCheck.Gen.return Operation_hash.Map.empty
    else
      let list_gen = QCheck.Gen.(oneofl elements |> list) in
      QCheck.Gen.map
        (fun l -> Operation_hash.Map.of_seq (List.to_seq l))
        list_gen

  (** Returns an instance of [block chain_tools] as well as:
      - the tree of blocks
      - a pair of blocks (that belong to the tree) and is
        fine for being passed as [(~from_branch, ~to_branch)]; i.e.
        the two blocks have a common ancestor.
      - a map of operations that is fine for being passed as the
        last argument of [handle_live_operations].
    *)
  let chain_tools_gen :
      (Block.t Classification.chain_tools
      * Block.t Tree.tree
      * (Block.t * Block.t) option
      * Operation.t Operation_hash.Map.t)
      QCheck.Gen.t =
    let open QCheck.Gen in
    let* tree = tree_gen block_gen in
    assert (Tree.well_formed Block.compare tree) ;
    let predecessor_pairs = Tree.predecessor_pairs tree in
    let equal = Block.equal in
    let not_equal x y = not @@ equal x y in
    (* Blocks that are leaves are blocks which aren't the predecessor
       of any other block *)
    let read_predecessor_opt (block : Block.t) : Block.t option Lwt.t =
      List.assoc ~equal block predecessor_pairs |> Lwt.return
    in
    let new_blocks ~from_block ~to_block =
      match Tree.find_ancestor ~equal tree from_block to_block with
      | None -> assert false (* Like the production implementation *)
      | Some ancestor -> (
          let to_parents = Tree.predecessors ~equal tree to_block in
          match
            ( to_parents,
              List_extra.take_until_if_found ~pred:(( = ) ancestor) to_parents
            )
          with
          | ([], _) ->
              (* This case is not supported, because the production
                 implementation of new_blocks doesn't support it either
                 (since it MUST return an ancestor, acccording to its return
                 type). If you end up here, this means generated
                 data is not constrained enough: this pair [(from_block,
                 to_block)] should NOT be tried. Ideally the return type
                 of new_blocks should allow this case, hereby allowing
                 a more general test. *)
              assert false
          | (_, None) ->
              (* Should not happen, because [ancestor]
                 is a member of [to_parents] *)
              assert false
          | (_, Some path) ->
              (* Because [to_block] must be included in new_blocks'
                 returned value. *)
              let path = to_block :: path in
              Lwt.return (ancestor, List.rev path))
    in
    let tree_elems : Block.t list = Tree.elems tree in
    (* Pairs of blocks that are valid for being ~from_block and ~to_block *)
    let heads_pairs : (Block.t * Block.t) list =
      List.product tree_elems tree_elems
      (* don't take from_block=to_block*)
      |> List.filter (fun (left, right) -> not_equal left right)
      (* keep only pairs of blocks that have a common ancestor *)
      |> List.filter (fun (left, right) ->
             Tree.find_ancestor ~equal tree left right |> function
             | None -> false (* We want an ancestor *)
             | Some ancestor ->
                 (* We don't want from_block to be the parent of to_block (or vice versa),
                    because it means the chain would rollback. This is not supported
                    (it hits an assert false in new_blocks, because its return type is
                    not general enough) *)
                 not_equal ancestor left && not_equal ancestor right)
    in
    let* chosen_pair =
      if heads_pairs = [] then return None
      else map Option.some (oneofl heads_pairs)
    in
    let* old_mempool = old_mempool_gen tree in
    let res : Block.t Classification.chain_tools =
      {
        clear_or_cancel = Fun.const ();
        inject_operation = (fun _ _ -> Lwt.return_unit);
        new_blocks;
        read_predecessor_opt;
      }
    in
    return (res, tree, chosen_pair, old_mempool)
end

module Arbitraries = struct
  let chain_tools_arb = QCheck.make Generators.chain_tools_gen
end

(** Function to unwrap an [option] when it MUST be a [Some] *)
let force_opt = function
  | Some x -> x
  | None -> QCheck.Test.fail_report "Unexpected None"

(* Values from [start] (included) to [ancestor] (excluded) *)
let values_from_to ~(equal : 'a -> 'a -> bool) (tree : 'a Tree.tree)
    (start : 'a) (ancestor : 'a) : 'a list =
  Tree.predecessors ~equal tree start
  |> List_extra.take_until_if_found ~pred:(( = ) ancestor)
  |> force_opt
  |> fun preds -> start :: preds

let op_set_pp fmt x =
  let set_to_list m = Operation_hash.Set.to_seq m |> List.of_seq in
  Format.fprintf
    fmt
    "%a"
    (Format.pp_print_list Operation_hash.pp)
    (set_to_list x)

let qcheck_cond ?pp ~cond e1 e2 () =
  if cond e1 e2 then true
  else
    match pp with
    | None ->
        QCheck.Test.fail_reportf
          "@[<h 0>The condition check failed, but no pretty printer was \
           provided.@]"
    | Some pp ->
        QCheck.Test.fail_reportf
          "@[<v 2>The condition check failed!@,\
           first element:@,\
           %a@,\
           second element:@,\
           %a@]"
          pp
          e1
          pp
          e2

(** Test that operations returned by [handle_live_operations] is
    a subset of the input mempool when [is_branch_alive] rules
    out all operations *)
let test_handle_live_operations_live_blocks_all_outdated =
  QCheck.Test.make
    ~name:
      "[handle_live_operations ~is_branch_alive:(Fun.const false)] is a subset \
       of its last argument"
    Arbitraries.chain_tools_arb
  @@ fun (chain, _tree, pair_blocks_opt, old_mempool) ->
  QCheck.assume @@ Option.is_some pair_blocks_opt ;
  let (from_branch, to_branch) = force_opt pair_blocks_opt in
  (* List of operation hashes coming from [old_mempool] *)
  let expected_superset : Operation_hash.Set.t =
    Op_map.bindings old_mempool |> List.map fst |> Operation_hash.Set.of_list
  in
  let actual : Operation_hash.Set.t =
    Classification.Internal_for_tests.handle_live_operations
      ~block_store:Block.tools
      ~chain
      ~from_branch
      ~to_branch
      ~is_branch_alive:(Fun.const false)
      old_mempool
    |> Lwt_main.run |> Op_map.bindings |> List.map fst
    |> Operation_hash.Set.of_list
  in
  qcheck_cond
    ~pp:op_set_pp
    ~cond:Operation_hash.Set.subset
    actual
    expected_superset
    ()

(** Test that operations returned by [handle_live_operations] is
    the union of operations in its last argument and operations on
    the "path" between [from_branch] and [to_branch] *)
let test_handle_live_operations_path_spec =
  QCheck.Test.make
    ~name:"[handle_live_operations] path specification"
    Arbitraries.chain_tools_arb
  @@ fun (chain, tree, pair_blocks_opt, _) ->
  QCheck.assume @@ Option.is_some pair_blocks_opt ;
  let (from_branch, to_branch) = force_opt pair_blocks_opt in
  let equal = Block.equal in
  let ancestor : Block.t =
    Tree.find_ancestor ~equal tree from_branch to_branch |> force_opt
  in
  let expected =
    List.map
      Block.tools.all_operation_hashes
      (values_from_to ~equal tree from_branch ancestor)
    |> List.concat |> List.concat |> Operation_hash.Set.of_list
  in
  let actual =
    Classification.Internal_for_tests.handle_live_operations
      ~block_store:Block.tools
      ~chain
      ~from_branch
      ~to_branch
      ~is_branch_alive:(Fun.const true)
      Operation_hash.Map.empty
    |> Lwt_main.run |> Op_map.bindings |> List.map fst
    |> Operation_hash.Set.of_list
  in
  qcheck_eq' ~pp:op_set_pp ~eq:Operation_hash.Set.equal ~expected ~actual ()

(** Test that operations cleared by [handle_live_operations]
    are operations on the path from [ancestor] to [to_branch] (when all
    operations are deemed up-to-date). *)
let test_handle_live_operations_clear =
  QCheck.Test.make
    ~name:"[handle_live_operations] clear approximation"
    Arbitraries.chain_tools_arb
  @@ fun (chain, tree, pair_blocks_opt, old_mempool) ->
  QCheck.assume @@ Option.is_some pair_blocks_opt ;
  let (from_branch, to_branch) = force_opt pair_blocks_opt in
  let cleared = ref Operation_hash.Set.empty in
  let clearer oph = cleared := Operation_hash.Set.add oph !cleared in
  let chain = {chain with clear_or_cancel = clearer} in
  let equal = Block.equal in
  let ancestor : Block.t =
    Tree.find_ancestor ~equal tree from_branch to_branch |> force_opt
  in
  let expected_superset =
    List.map
      Block.tools.all_operation_hashes
      (values_from_to ~equal tree to_branch ancestor)
    |> List.concat |> List.concat |> Operation_hash.Set.of_list
  in
  Classification.Internal_for_tests.handle_live_operations
    ~block_store:Block.tools
    ~chain
    ~from_branch
    ~to_branch
    ~is_branch_alive:(Fun.const true)
    old_mempool
  |> Lwt_main.run |> ignore ;
  qcheck_cond
    ~pp:op_set_pp
    ~cond:Operation_hash.Set.subset
    !cleared
    expected_superset
    ()

(** Test that operations injected by [handle_live_operations]
    are operations on the path from [ancestor] to [from_branch]. *)
let test_handle_live_operations_inject =
  QCheck.Test.make
    ~name:"[handle_live_operations] inject approximation"
    Arbitraries.chain_tools_arb
  @@ fun (chain, tree, pair_blocks_opt, old_mempool) ->
  QCheck.assume @@ Option.is_some pair_blocks_opt ;
  let (from_branch, to_branch) = force_opt pair_blocks_opt in
  let injected = ref Operation_hash.Set.empty in
  let inject_operation oph _op =
    injected := Operation_hash.Set.add oph !injected ;
    Lwt.return_unit
  in
  let chain = {chain with inject_operation} in
  let equal = Block.equal in
  let ancestor : Block.t =
    Tree.find_ancestor ~equal tree from_branch to_branch |> force_opt
  in
  let expected_superset =
    List.map
      Block.tools.all_operation_hashes
      (values_from_to ~equal tree from_branch ancestor)
    |> List.concat |> List.concat |> Operation_hash.Set.of_list
  in
  Classification.Internal_for_tests.handle_live_operations
    ~block_store:Block.tools
    ~chain
    ~from_branch
    ~to_branch
    ~is_branch_alive:(Fun.const true)
    old_mempool
  |> Lwt_main.run |> ignore ;
  qcheck_cond
    ~pp:op_set_pp
    ~cond:Operation_hash.Set.subset
    !injected
    expected_superset
    ()

let () =
  Alcotest.run
    "Prevalidator"
    [
      ( "",
        qcheck_wrap
          [
            test_handle_live_operations_live_blocks_all_outdated;
            test_handle_live_operations_path_spec;
            test_handle_live_operations_clear;
            test_handle_live_operations_inject;
          ] );
    ]
