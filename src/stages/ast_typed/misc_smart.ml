open Trace
open Types
open Combinators
open Misc
open Stage_common.Types

let program_to_main : program -> string -> lambda result = fun p s ->
  let%bind (main , input_type , _) =
    let pred = fun d ->
      match d with
      | Declaration_constant (d , _, _) when d.name = Var.of_name s -> Some d.annotated_expression
      | Declaration_constant _ -> None
    in
    let%bind main =
      trace_option (simple_error "no main with given name") @@
      List.find_map (Function.compose pred Location.unwrap) p in
    let%bind (input_ty , output_ty) =
      match (get_type' @@ get_type_annotation main) with
      | T_arrow (i , o) -> ok (i , o)
      | _ -> simple_fail "program main isn't a function" in
    ok (main , input_ty , output_ty)
  in
  let env =
    let aux = fun _ d ->
      match d with
      | Declaration_constant (_ , _, (_ , post_env)) -> post_env in
    List.fold_left aux Environment.full_empty (List.map Location.unwrap p) in
  let binder = Var.of_name "@contract_input" in
  let body =
    let input_expr = e_a_variable binder input_type env in
    let main_expr = e_a_variable (Var.of_name s) (get_type_annotation main) env in
    e_a_application main_expr input_expr env in
  ok {
    binder ;
    body ;
  }

module Captured_variables = struct

  type bindings = expression_variable list
  let mem : expression_variable -> bindings -> bool = List.mem
  let singleton : expression_variable -> bindings = fun s -> [ s ]
  let union : bindings -> bindings -> bindings = (@)
  let unions : bindings list -> bindings = List.concat
  let empty : bindings = []
  let of_list : expression_variable list -> bindings = fun x -> x

  let rec annotated_expression : bindings -> annotated_expression -> bindings result = fun b ae ->
    let self = annotated_expression b in
    match ae.expression with
    | E_lambda l -> ok @@ Free_variables.lambda empty l
    | E_literal _ -> ok empty
    | E_constant (_ , lst) ->
      let%bind lst' = bind_map_list self lst in
      ok @@ unions lst'
    | E_variable name -> (
        let%bind env_element =
          trace_option (simple_error "missing var in env") @@
          Environment.get_opt name ae.environment in
        match env_element.definition with
        | ED_binder -> ok empty
        | ED_declaration (_ , _) -> simple_fail "todo"
      )
    | E_application (a, b) ->
      let%bind lst' = bind_map_list self [ a ; b ] in
      ok @@ unions lst'
    | E_tuple lst ->
      let%bind lst' = bind_map_list self lst in
      ok @@ unions lst'
    | E_constructor (_ , a) -> self a
    | E_record m ->
      let%bind lst' = bind_map_list self @@ LMap.to_list m in
      ok @@ unions lst'
    | E_record_accessor (a, _) -> self a
    | E_record_update (r,ups) -> 
      let%bind r = self r in
      let aux (_, e) =
        let%bind e = self e in
        ok e
      in
      let%bind lst = bind_map_list aux ups in
      ok @@ union r @@ unions lst
    | E_tuple_accessor (a, _) -> self a
    | E_list lst ->
      let%bind lst' = bind_map_list self lst in
      ok @@ unions lst'
    | E_set lst ->
      let%bind lst' = bind_map_list self lst in
      ok @@ unions lst'
    | (E_map m | E_big_map m) ->
      let%bind lst' = bind_map_list self @@ List.concat @@ List.map (fun (a, b) -> [ a ; b ]) m in
      ok @@ unions lst'
    | E_look_up (a , b) ->
      let%bind lst' = bind_map_list self [ a ; b ] in
      ok @@ unions lst'
    | E_matching (a , cs) ->
      let%bind a' = self a in
      let%bind cs' = matching_expression b cs in
      ok @@ union a' cs'
    | E_sequence (_ , b) -> self b
    | E_loop (expr , body) ->
      let%bind lst' = bind_map_list self [ expr ; body ] in
      ok @@ unions lst'
    | E_assign (_ , _ , expr) -> self expr
    | E_let_in li ->
      let b' = union (singleton li.binder) b in
      annotated_expression b' li.result

  and matching_variant_case : type a . (bindings -> a -> bindings result) -> bindings -> ((constructor * expression_variable) * a) -> bindings result  = fun f b ((_,n),c) ->
    f (union (singleton n) b) c

  and matching : type a . (bindings -> a -> bindings result) -> bindings -> (a, 'tv) matching -> bindings result = fun f b m ->
    match m with
    | Match_bool { match_true = t ; match_false = fa } ->
      let%bind t' = f b t in
      let%bind fa' = f b fa in
      ok @@ union t' fa'
    | Match_list { match_nil = n ; match_cons = (hd, tl, c, _) } ->
      let%bind n' = f b n in
      let%bind c' = f (union (of_list [hd ; tl]) b) c in
      ok @@ union n' c'
    | Match_option { match_none = n ; match_some = (opt, s, _) } ->
      let%bind n' = f b n in
      let%bind s' = f (union (singleton opt) b) s in
      ok @@ union n' s'
    | Match_tuple ((lst , a),_) ->
      f (union (of_list lst) b) a
    | Match_variant (lst , _) ->
      let%bind lst' = bind_map_list (matching_variant_case f b) lst in
      ok @@ unions lst'

  and matching_expression = fun x -> matching annotated_expression x

end
