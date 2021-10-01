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

open Prevalidator_classification

let add_if_not_present classification oph op t =
  Prevalidator_classification.(
    if not (is_in_mempool oph t) then add classification oph op t)

let string_gen = QCheck.Gen.string ?gen:None

let operation_hash_gen : Operation_hash.t QCheck.Gen.t =
  let open QCheck.Gen in
  let+ key = opt (string_size (0 -- 64))
  and+ path = list_size (0 -- 100) string_gen in
  Operation_hash.hash_string ?key path

let block_hash_gen : Block_hash.t QCheck.Gen.t =
  let open QCheck.Gen in
  let+ key = opt (string_size (0 -- 64))
  and+ path = list_size (0 -- 100) string_gen in
  Block_hash.hash_string ?key path

(** Operations don't contain "valid" proto bytes but we don't care
   *  as far as [Prevalidator_classification] is concerned. *)
let operation_gen : Operation.t QCheck.Gen.t =
  let open QCheck.Gen in
  let+ branch = block_hash_gen
  and+ proto = string_gen >|= Bytes.unsafe_of_string in
  Operation.{shell = {branch}; proto}

(** Do we need richer errors? If so, how to generate those? *)
let classification_gen : classification QCheck.Gen.t =
  QCheck.Gen.oneofa
    [|`Applied; `Branch_delayed []; `Branch_refused []; `Refused []|]

let unrefused_classification_gen : classification QCheck.Gen.t =
  QCheck.Gen.oneofa [|`Applied; `Branch_delayed []; `Branch_refused []|]

let parameters_gen : parameters QCheck.Gen.t =
  let open QCheck.Gen in
  let+ map_size_limit = 1 -- 100 in
  let on_discarded_operation _ = () in
  {map_size_limit; on_discarded_operation}

let t_gen ?(can_be_full = true) () : t QCheck.Gen.t =
  let open QCheck.Gen in
  let* parameters = parameters_gen in
  let+ inputs =
    let limit = parameters.map_size_limit - if can_be_full then 0 else 1 in
    list_size
      (0 -- limit)
      (triple classification_gen operation_hash_gen operation_gen)
  in
  let t = Prevalidator_classification.create parameters in
  List.iter
    (fun (classification, operation_hash, operation) ->
      add_if_not_present classification operation_hash operation t)
    inputs ;
  t

(* With probability 1/2, we take an operation hash already present in the
   classification. This operation is taken uniformly among the
   different classes. *)
let with_t_operation_gen : t -> (Operation_hash.t * Operation.t) QCheck.Gen.t =
  let module Classification = Prevalidator_classification in
  let open QCheck.Gen in
  fun t ->
    let to_ops map =
      Operation_hash.Map.bindings map
      |> List.map (fun (oph, (op, _)) -> (oph, op))
    in
    (* If map is empty, it cannot be used as a generator *)
    let freq_of_map map = if Operation_hash.Map.is_empty map then 0 else 1 in
    (* If list is empty, it cannot be used as a generator *)
    let freq_of_list = function [] -> 0 | _ -> 1 in
    (* If map is not empty, take one of its elements *)
    let freq_and_gen_of_map map = (freq_of_map map, oneofl (to_ops map)) in
    (* If list is not empty, take one of its elements *)
    let freq_and_gen_of_list list = (freq_of_list list, oneofl list) in
    (* We use max to ensure the ponderation is strictly greater than 0. *)
    let freq_fresh t =
      max
        1
        (freq_of_list t.applied_rev
        + freq_of_map (Classification.map t.branch_refused)
        + freq_of_map (Classification.map t.branch_delayed)
        + freq_of_map (Classification.map t.refused))
    in
    frequency
      [
        freq_and_gen_of_list t.applied_rev;
        freq_and_gen_of_map (Classification.map t.branch_refused);
        freq_and_gen_of_map (Classification.map t.branch_delayed);
        freq_and_gen_of_map (Classification.map t.refused);
        (freq_fresh t, pair operation_hash_gen operation_gen);
      ]

let t_with_operation_gen ?can_be_full () :
    (t * (Operation_hash.t * Operation.t)) QCheck.Gen.t =
  let open QCheck.Gen in
  t_gen ?can_be_full () >>= fun t -> pair (return t) (with_t_operation_gen t)
