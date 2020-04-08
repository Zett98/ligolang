open Trace
module I = Ast_core
module O = Ast_typed
open O.Combinators
module Environment = O.Environment
module Solver = Solver
type environment = Environment.t
module Errors = Errors
open Errors

open Todo_use_fold_generator

(*
  Extract pairs of (name,type) in the declaration and add it to the environment
*)
let rec type_declaration env state : I.declaration -> (environment * Solver.state * O.declaration option) result = function
  | Declaration_type (type_name , type_expression) ->
    let%bind tv = evaluate_type env type_expression in
    let env' = Environment.add_type (type_name) tv env in
    ok (env', state , None)
  | Declaration_constant (binder , tv_opt , inline, expression) -> (
    (*
      Determine the type of the expression and add it to the environment
    *)
      let%bind tv'_opt = bind_map_option (evaluate_type env) tv_opt in
      let%bind (expr , state') =
        trace (constant_declaration_error binder expression tv'_opt) @@
        type_expression env state expression in
      let post_env = Environment.add_ez_ae binder expr env in
      ok (post_env, state' , Some (O.Declaration_constant { binder ; expr ; inline ; post_env} ))
    )

and type_match : environment -> Solver.state -> O.type_expression -> I.matching_expr -> I.expression -> Location.t -> (O.matching_expr * Solver.state) result =
  fun e state t i ae loc -> match i with
    | Match_bool {match_true ; match_false} ->
      let%bind _ =
        trace_strong (match_error ~expected:i ~actual:t loc)
        @@ get_t_bool t in
      let%bind (match_true , state') = type_expression e state match_true in
      let%bind (match_false , state'') = type_expression e state' match_false in
      ok (O.Match_bool {match_true ; match_false} , state'')
    | Match_option {match_none ; match_some} ->
      let%bind tv =
        trace_strong (match_error ~expected:i ~actual:t loc)
        @@ get_t_option t in
      let%bind (match_none , state') = type_expression e state match_none in
      let (opt, b, _) = match_some in
      let e' = Environment.add_ez_binder opt tv e in
      let%bind (body , state'') = type_expression e' state' b in
      ok (O.Match_option {match_none ; match_some = { opt; body; tv}} , state'')
    | Match_list {match_nil ; match_cons} ->
      let%bind t_elt =
        trace_strong (match_error ~expected:i ~actual:t loc)
        @@ get_t_list t in
      let%bind (match_nil , state') = type_expression e state match_nil in
      let (hd, tl, b, _) = match_cons in
      let e' = Environment.add_ez_binder hd t_elt e in
      let e' = Environment.add_ez_binder tl t e' in
      let%bind (body , state'') = type_expression e' state' b in
      ok (O.Match_list {match_nil ; match_cons = {hd; tl; body;tv=t}} , state'')
    | Match_tuple ((vars, b),_) ->
      let%bind tvs =
        trace_strong (match_error ~expected:i ~actual:t loc)
        @@ get_t_tuple t in
      let%bind lst' =
        generic_try (match_tuple_wrong_arity tvs vars loc)
        @@ (fun () -> List.combine vars tvs) in
      let aux prev (name, tv) = Environment.add_ez_binder name tv prev in
      let e' = List.fold_left aux e lst' in
      let%bind (body , state') = type_expression e' state b in
      ok (O.Match_tuple {vars ; body ; tvs} , state')
    | Match_variant (lst,_) ->
      let%bind variant_opt =
        let aux acc ((constructor_name , _) , _) =
          let%bind (_ , variant) =
            trace_option (unbound_constructor e constructor_name loc) @@
            Environment.get_constructor constructor_name e in
          let%bind acc = match acc with
            | None -> ok (Some variant)
            | Some variant' -> (
                trace (type_error
                         ~msg:"in match variant"
                         ~expected:variant
                         ~actual:variant'
                         ~expression:ae
                         loc
                      ) @@
                Ast_typed.assert_type_expression_eq (variant , variant') >>? fun () ->
                ok (Some variant)
              ) in
          ok acc in
        trace (simple_info "in match variant") @@
        bind_fold_list aux None lst in
      let%bind variant =
        trace_option (match_empty_variant i loc) @@
        variant_opt in
      let%bind () =
        let%bind variant_cases' =
          trace (match_error ~expected:i ~actual:t loc)
          @@ Ast_typed.Combinators.get_t_sum variant in
        let variant_cases = List.map fst @@ O.CMap.to_kv_list variant_cases' in
        let match_cases = List.map (fun x -> convert_constructor' @@ fst @@ fst x) lst in
        let test_case = fun c ->
          Assert.assert_true (List.mem c match_cases)
        in
        let%bind () =
          trace_strong (match_missing_case i loc) @@
          bind_iter_list test_case variant_cases in
        let%bind () =
          trace_strong (match_redundant_case i loc) @@
          Assert.assert_true List.(length variant_cases = length match_cases) in
        ok ()
      in
      let%bind (state'' , cases) =
        let aux state ((constructor_name , pattern) , b) =
          let%bind (constructor , _) =
            trace_option (unbound_constructor e constructor_name loc) @@
            Environment.get_constructor constructor_name e in
          let e' = Environment.add_ez_binder pattern constructor e in
          let%bind (body , state') = type_expression e' state b in
          let constructor = convert_constructor' constructor_name in
          ok (state' , ({constructor ; pattern ; body = body} : O.matching_content_case))
        in
        bind_fold_map_list aux state lst in
      ok (O.Match_variant {cases ; tv=variant } , state'')

(*
  Recursively search the type_expression and return a result containing the
  type_value at the leaves
*)
and evaluate_type (e:environment) (t:I.type_expression) : O.type_expression result =
  let return tv' = ok (make_t tv' (Some t)) in
  match t.type_content with
  | T_arrow {type1;type2} ->
    let%bind type1 = evaluate_type e type1 in
    let%bind type2 = evaluate_type e type2 in
    return (T_arrow {type1;type2})
  | T_sum m ->
    let aux k v prev =
      let%bind prev' = prev in
      let%bind v' = evaluate_type e v in
      ok @@ O.CMap.add (convert_constructor' k) v' prev'
    in
    let%bind m = I.CMap.fold aux m (ok O.CMap.empty) in
    return (T_sum m)
  | T_record m ->
    let aux k v prev =
      let%bind prev' = prev in
      let%bind v' = evaluate_type e v in
      ok @@ O.LMap.add (convert_label k) v' prev'
    in
    let%bind m = I.LMap.fold aux m (ok O.LMap.empty) in
    return (T_record m)
  | T_variable name ->
    let%bind tv =
      trace_option (unbound_type_variable e name)
      @@ Environment.get_type_opt (name) e in
    ok tv
  | T_constant cst ->
      return (T_constant (convert_type_constant cst))
  | T_operator opt ->
      let%bind opt = match opt with
        | TC_set s ->
            let%bind s = evaluate_type e s in
            ok @@ O.TC_set (s)
        | TC_option o ->
            let%bind o = evaluate_type e o in
            ok @@ O.TC_option (o)
        | TC_list l ->
            let%bind l = evaluate_type e l in
            ok @@ O.TC_list (l)
        | TC_map (k,v) ->
            let%bind k = evaluate_type e k in
            let%bind v = evaluate_type e v in
            ok @@ O.TC_map {k;v}
        | TC_big_map (k,v) ->
            let%bind k = evaluate_type e k in
            let%bind v = evaluate_type e v in
            ok @@ O.TC_big_map {k;v}
        | TC_map_or_big_map (k,v) ->
            let%bind k = evaluate_type e k in
            let%bind v = evaluate_type e v in
            ok @@ O.TC_map_or_big_map {k;v}
        | TC_michelson_or (l,r) ->
            let%bind l = evaluate_type e l in 
            let%bind r = evaluate_type e r in 
            ok @@ O.TC_michelson_or {l;r} 
        | TC_contract c ->
            let%bind c = evaluate_type e c in
            ok @@ O.TC_contract c
        | TC_arrow ( arg , ret ) ->
           let%bind arg' = evaluate_type e arg in
           let%bind ret' = evaluate_type e ret in
           ok @@ O.TC_arrow { type1=arg' ; type2=ret' }
        in
      return (T_operator (opt))

and type_expression : environment -> Solver.state -> ?tv_opt:O.type_expression -> I.expression -> (O.expression * Solver.state) result = fun e state ?tv_opt ae ->
  let () = ignore tv_opt in     (* For compatibility with the old typer's API, this argument can be removed once the new typer is used. *)
  let open Solver in
  let module L = Logger.Stateful() in
  let return : _ -> Solver.state -> _ -> _ (* return of type_expression *) = fun expr state constraints type_name ->
    let%bind new_state = aggregate_constraints state constraints in
    let tv = t_variable type_name () in
    let location = ae.location in
    let expr' = make_e ~location expr tv e in
    ok @@ (expr' , new_state) in
  let return_wrapped expr state (constraints , expr_type) = return expr state constraints expr_type in
  let main_error =
    let title () = "typing expression" in
    let content () = "" in
    let data = [
      ("expression" , fun () -> Format.asprintf "%a" I.PP.expression ae) ;
      ("location" , fun () -> Format.asprintf "%a" Location.pp @@ ae.location) ;
      ("misc" , fun () -> L.get ()) ;
    ] in
    error ~data title content in
  trace main_error @@
  match ae.expression_content with

  (* TODO: this file should take care only of the order in which program fragments
     are translated by Wrap.xyz

     TODO: produce an ordered list of sub-fragments, and use a common piece of code
     to actually perform the recursive calls *)

  (* Basic *)
  | E_variable name -> (
      let name'= name in
      let%bind (tv' : Environment.element) =
        trace_option (unbound_variable e name ae.location)
        @@ Environment.get_opt name' e in
      let (constraints , expr_type) = Wrap.variable name tv'.type_value in
      let expr' = e_variable name' in
      return expr' state constraints expr_type
    )

  | E_literal (Literal_bool b) -> (
      return_wrapped (e_bool b) state @@ Wrap.literal (t_bool ())
    )
  | E_literal (Literal_string s) -> (
      return_wrapped (e_string s) state @@ Wrap.literal (t_string ())
    )
  | E_literal (Literal_signature s) -> (
      return_wrapped (e_signature s) state @@ Wrap.literal (t_signature ())
    )
  | E_literal (Literal_key s) -> (
      return_wrapped (e_key s) state @@ Wrap.literal (t_key ())
    )
  | E_literal (Literal_key_hash s) -> (
      return_wrapped (e_key_hash s) state @@ Wrap.literal (t_key_hash ())
    )
  | E_literal (Literal_chain_id s) -> (
      return_wrapped (e_chain_id s) state @@ Wrap.literal (t_chain_id ())
    )
  | E_literal (Literal_bytes b) -> (
      return_wrapped (e_bytes b) state @@ Wrap.literal (t_bytes ())
    )
  | E_literal (Literal_int i) -> (
      return_wrapped (e_int i) state @@ Wrap.literal (t_int ())
    )
  | E_literal (Literal_nat n) -> (
      return_wrapped (e_nat n) state @@ Wrap.literal (t_nat ())
    )
  | E_literal (Literal_mutez t) -> (
      return_wrapped (e_mutez t) state @@ Wrap.literal (t_mutez ())
    )
  | E_literal (Literal_address a) -> (
      return_wrapped (e_address a) state @@ Wrap.literal (t_address ())
    )
  | E_literal (Literal_timestamp t) -> (
      return_wrapped (e_timestamp t) state @@ Wrap.literal (t_timestamp ())
    )
  | E_literal (Literal_operation o) -> (
      return_wrapped (e_operation o) state @@ Wrap.literal (t_operation ())
    )
  | E_literal (Literal_unit) -> (
      return_wrapped (e_unit ()) state @@ Wrap.literal (t_unit ())
    )
  | E_literal (Literal_void) -> (
      failwith "TODO: missing implementation for literal void"
    )

  | E_record_accessor {record;path} -> (
      let%bind (base' , state') = type_expression e state record in
      let path = convert_label path in
      let wrapped = Wrap.access_label ~base:base'.type_expression ~label:path in
      return_wrapped (E_record_accessor {record=base';path}) state' wrapped
    )

  (* Sum *)
  | E_constructor {constructor;element} ->
    let%bind (c_tv, sum_tv) =
      let error =
        let title () = "no such constructor" in
        let content () =
          Format.asprintf "%a in:\n%a\n"
            Stage_common.PP.constructor constructor
            O.Environment.PP.full_environment e
        in
        error title content in
      trace_option error @@
      Environment.get_constructor constructor e in
    let%bind (expr' , state') = type_expression e state element in
    let%bind _assert = O.assert_type_expression_eq (expr'.type_expression, c_tv) in
    let wrapped = Wrap.constructor expr'.type_expression c_tv sum_tv in
    let constructor = convert_constructor' constructor in
    return_wrapped (E_constructor {constructor; element=expr'}) state' wrapped

  (* Record *)
  | E_record m ->
    let aux (acc, state) k expr =
      let%bind (expr' , state') = type_expression e state expr in
      ok (O.LMap.add (convert_label k) expr' acc , state')
    in
    let%bind (m' , state') = Stage_common.Helpers.bind_fold_lmap aux (ok (O.LMap.empty , state)) m in
    let wrapped = Wrap.record (O.LMap.map get_type_expression m') in
    return_wrapped (E_record m') state' wrapped
  | E_record_update {record; path; update} ->
    let%bind (record, state) = type_expression e state record in
    let%bind (update,state) = type_expression e state update in
    let wrapped = get_type_expression record in
    let path = convert_label path in
    let%bind (wrapped,tv) = 
      match wrapped.type_content with 
      | T_record record -> (
          let field_op = O.LMap.find_opt path record in
          match field_op with
          | Some tv -> ok (record,tv)
          | None -> failwith @@ Format.asprintf "field %a is not part of record" O.PP.label path
      )
      | _ -> failwith "Update an expression which is not a record"
    in
    let%bind () = O.assert_type_expression_eq (tv, get_type_expression update) in
    return_wrapped (E_record_update {record; path; update}) state (Wrap.record wrapped)
  (* Data-structure *)
  | E_application {lamb;args} ->
    let%bind (f' , state') = type_expression e state lamb in
    let%bind (args , state'') = type_expression e state' args in
    let wrapped = Wrap.application f'.type_expression args.type_expression in
    return_wrapped (E_application {lamb=f';args}) state'' wrapped

  (* Advanced *)
  | E_let_in {let_binder ; rhs ; let_result; inline} ->
    let%bind rhs_tv_opt = bind_map_option (evaluate_type e) (snd let_binder) in
    (* TODO: the binder annotation should just be an annotation node *)
    let%bind (rhs , state') = type_expression e state rhs in
    let let_binder = fst let_binder in 
    let e' = Environment.add_ez_declaration (let_binder) rhs e in
    let%bind (let_result , state'') = type_expression e' state' let_result in
    let wrapped =
      Wrap.let_in rhs.type_expression rhs_tv_opt let_result.type_expression in
    return_wrapped (E_let_in {let_binder; rhs; let_result; inline}) state'' wrapped

  | E_ascription {anno_expr;type_annotation} ->
    let%bind tv = evaluate_type e type_annotation in
    let%bind (expr' , state') = type_expression e state anno_expr in
    let wrapped = Wrap.annotation expr'.type_expression tv
    (* TODO: we're probably discarding too much by using expr'.expression.
       Previously: {expr' with type_annotation = the_explicit_type_annotation}
       but then this case is not like the others and doesn't call return_wrapped,
       which might do some necessary work *)
    in return_wrapped expr'.expression_content state' wrapped

  | E_matching {matchee;cases} -> (
      let%bind (ex' , state') = type_expression e state matchee in
      let%bind (m' , state'') = type_match e state' ex'.type_expression cases ae ae.location in
      let tvs =
        let aux (cur : O.matching_expr) =
          match cur with
          | Match_bool { match_true ; match_false } -> [ match_true ; match_false ]
          | Match_list { match_nil ; match_cons = { hd=_ ; tl=_ ; body ; tv=_} } -> [ match_nil ; body ]
          | Match_option { match_none ; match_some = {opt=_; body; tv=_} } -> [ match_none ; body ]
          | Match_tuple { vars=_ ; body ; tvs=_ } -> [ body ]
          | Match_variant { cases ; tv=_ } -> List.map (fun ({constructor=_; pattern=_; body} : O.matching_content_case) -> body) cases in
        List.map get_type_expression @@ aux m' in
      let%bind () = match tvs with
          [] -> fail @@ match_empty_variant cases ae.location
        | _ -> ok () in
      (* constraints:
         all the items of tvs should be equal to the first one
         result = first item of tvs
      *)
      let wrapped = Wrap.matching tvs in
      return_wrapped (O.E_matching {matchee=ex';cases=m'}) state'' wrapped
    )

  | E_lambda lambda -> 
    let%bind (lambda,state',wrapped) = type_lambda e state lambda in
    return_wrapped (E_lambda lambda) (* TODO: is the type of the entire lambda enough to access the input_type=fresh; ? *)
        state' wrapped

  | E_recursive {fun_name;fun_type;lambda} ->
    let%bind fun_type = evaluate_type e fun_type in
    let e = Environment.add_ez_binder fun_name fun_type e in
    let%bind (lambda,state,_) = type_lambda e state lambda in
    let wrapped = Wrap.recursive fun_type in
    return_wrapped (E_recursive {fun_name;fun_type;lambda}) state wrapped

  | E_constant {cons_name=name; arguments=lst} ->
    let name = convert_constant' name in
    let%bind t = Operators.Typer.Operators_types.constant_type name in
    let aux acc expr =
      let (lst , state) = acc in
      let%bind (expr, state') = type_expression e state expr in
      ok (expr::lst , state') in
    let%bind (lst , state') = bind_fold_list aux ([], state) lst in
    let lst_annot = List.map (fun (x : O.expression) -> x.type_expression) lst in
    let wrapped = Wrap.constant t lst_annot in
    return_wrapped
      (E_constant {cons_name=name;arguments=lst})
      state' wrapped
      (*
      let%bind lst' = bind_list @@ List.map (type_expression e) lst in
      let tv_lst = List.map get_type_annotation lst' in
      let%bind (name', tv) =
        type_constant name tv_lst tv_opt ae.location in
      return (E_constant (name' , lst')) tv
    *)

and type_lambda e state {
      binder ;
      input_type ;
      output_type ;
      result ;
    } =
      let%bind input_type' = bind_map_option (evaluate_type e) input_type in
      let%bind output_type' = bind_map_option (evaluate_type e) output_type in

      let fresh : O.type_expression = t_variable (Solver.Wrap.fresh_binder ()) () in
      let e' = Environment.add_ez_binder (binder) fresh e in

      let%bind (result , state') = type_expression e' state result in
      let () = Printf.printf "this does not make use of the typed body, this code sounds buggy." in
      let wrapped = Solver.Wrap.lambda fresh input_type' output_type' in
      ok (({binder;result}:O.lambda),state',wrapped)

and type_constant (name:I.constant') (lst:O.type_expression list) (tv_opt:O.type_expression option) : (O.constant' * O.type_expression) result =
  let name = convert_constant' name in
  let%bind typer = Operators.Typer.constant_typers name in
  let%bind tv = typer lst tv_opt in
  ok(name, tv)

(* Apply type_declaration on every node of the AST_core from the root p *)
let type_program_returns_state ((env, state, p) : environment * Solver.state * I.program) : (environment * Solver.state * O.program) result =
  let aux ((e : environment), (s : Solver.state) , (ds : O.declaration Location.wrap list)) (d:I.declaration Location.wrap) =
    let%bind (e' , s' , d'_opt) = type_declaration e s (Location.unwrap d) in
    let ds' = match d'_opt with
      | None -> ds
      | Some d' -> ds @ [Location.wrap ~loc:(Location.get_location d) d'] (* take O(n) insted of O(1) *)
    in
    ok (e' , s' , ds')
  in
  let%bind (env' , state' , declarations) =
    trace (fun () -> program_error p ()) @@
    bind_fold_list aux (env , state , []) p in
  let () = ignore (env' , state') in
  ok (env', state', declarations)

let type_and_subst_xyz (env_state_node : environment * Solver.state * 'a) (apply_substs : 'b Typesystem.Misc.Substitution.Pattern.w) (type_xyz_returns_state : (environment * Solver.state * 'a) -> (environment * Solver.state * 'b) Trace.result) : ('b * Solver.state) result =
  let%bind (env, state, program) = type_xyz_returns_state env_state_node in
  let subst_all =
    let aliases = state.structured_dbs.aliases in
    let assignments = state.structured_dbs.assignments in
    let substs : variable: I.type_variable -> _ = fun ~variable ->
      to_option @@
      let%bind root =
        trace_option (simple_error (Format.asprintf "can't find alias root of variable %a" Var.pp variable)) @@
          (* TODO: after upgrading UnionFind, this will be an option, not an exception. *)
          try Some (Solver.UF.repr variable aliases) with Not_found -> None in
      let%bind assignment =
        trace_option (simple_error (Format.asprintf "can't find assignment for root %a" Var.pp root)) @@
          (Solver.TypeVariableMap.find_opt root assignments) in
      let Solver.{ tv ; c_tag ; tv_list } = assignment in
      let () = ignore tv (* I think there is an issue where the tv is stored twice (as a key and in the element itself) *) in
      let%bind (expr : O.type_content) = Typesystem.Core.type_expression'_of_simple_c_constant (c_tag , (List.map (fun s -> O.{ type_content = T_variable s ; type_meta = None }) tv_list)) in
      ok @@ expr
    in
    let p = apply_substs ~substs program in
    p in
  let%bind program = subst_all in
  let () = ignore env in        (* TODO: shouldn't we use the `env` somewhere? *)
  ok (program, state)

let type_program (p : I.program) : (O.program * Solver.state) result =
  let empty_env = Ast_typed.Environment.full_empty in
  let empty_state = Solver.initial_state in
  type_and_subst_xyz (empty_env , empty_state , p) Typesystem.Misc.Substitution.Pattern.s_program type_program_returns_state

let type_expression_returns_state : (environment * Solver.state * I.expression) -> (environment * Solver.state * O.expression) Trace.result =
  fun (env, state, e) ->
  let%bind (e , state) = type_expression env state e in
  ok (env, state, e)

let type_expression_subst (env : environment) (state : Solver.state) ?(tv_opt : O.type_expression option) (e : I.expression) : (O.expression * Solver.state) result =
  let () = ignore tv_opt in     (* For compatibility with the old typer's API, this argument can be removed once the new typer is used. *)
  type_and_subst_xyz (env , state , e) Typesystem.Misc.Substitution.Pattern.s_expression type_expression_returns_state

(* TODO: Similar to type_program but use a fold_map_list and List.fold_left and add element to the left or the list which gives a better complexity *)
let type_program' : I.program -> O.program result = fun p ->
  let initial_state = Solver.initial_state in
  let initial_env = Environment.full_empty in
  let aux (env, state) (statement : I.declaration Location.wrap) =
    let statement' = statement.wrap_content in (* TODO *)
    let%bind (env' , state' , declaration') = type_declaration env state statement' in
    let declaration'' = match declaration' with
        None -> None
      | Some x -> Some (Location.wrap ~loc:Location.(statement.location) x) in
    ok ((env' , state') , declaration'')
  in
  let%bind ((env' , state') , p') = bind_fold_map_list aux (initial_env, initial_state) p in
  let p' = List.fold_left (fun l e -> match e with None -> l | Some x -> x :: l) [] p' in

  (* here, maybe ensure that there are no invalid things in env' and state' ? *)
  let () = ignore (env' , state') in
  ok p'

let untype_type_expression  = Untyper.untype_type_expression
let untype_expression       = Untyper.untype_expression

(* These aliases are just here for quick navigation during debug, and can safely be removed later *)
let [@warning "-32"] (*rec*) type_declaration _env _state : I.declaration -> (environment * Solver.state * O.declaration option) result = type_declaration _env _state
and [@warning "-32"] type_match : environment -> Solver.state -> O.type_expression -> I.matching_expr -> I.expression -> Location.t -> (O.matching_expr * Solver.state) result = type_match
and [@warning "-32"] evaluate_type (e:environment) (t:I.type_expression) : O.type_expression result = evaluate_type e t
and [@warning "-32"] type_expression : environment -> Solver.state -> ?tv_opt:O.type_expression -> I.expression -> (O.expression * Solver.state) result = type_expression
and [@warning "-32"] type_lambda e state lam = type_lambda e state lam
and [@warning "-32"] type_constant (name:I.constant') (lst:O.type_expression list) (tv_opt:O.type_expression option) : (O.constant' * O.type_expression) result = type_constant name lst tv_opt
let [@warning "-32"] type_program_returns_state ((env, state, p) : environment * Solver.state * I.program) : (environment * Solver.state * O.program) result = type_program_returns_state (env, state, p)
let [@warning "-32"] type_and_subst_xyz (env_state_node : environment * Solver.state * 'a) (apply_substs : 'b Typesystem.Misc.Substitution.Pattern.w) (type_xyz_returns_state : (environment * Solver.state * 'a) -> (environment * Solver.state * 'b) Trace.result) : ('b * Solver.state) result = type_and_subst_xyz env_state_node apply_substs type_xyz_returns_state
let [@warning "-32"] type_program (p : I.program) : (O.program * Solver.state) result = type_program p
let [@warning "-32"] type_expression_returns_state : (environment * Solver.state * I.expression) -> (environment * Solver.state * O.expression) Trace.result = type_expression_returns_state
let [@warning "-32"] type_expression_subst (env : environment) (state : Solver.state) ?(tv_opt : O.type_expression option) (e : I.expression) : (O.expression * Solver.state) result = type_expression_subst env state ?tv_opt e
let [@warning "-32"] type_program' : I.program -> O.program result = type_program'
