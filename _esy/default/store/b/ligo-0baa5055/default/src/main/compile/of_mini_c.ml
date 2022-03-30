open Main_errors
open Mini_c
open Proto_alpha_utils
open Trace
open! Stacking
open Tezos_micheline
open Ligo_coq_ocaml.Micheline_wrapper

let dummy_locations : 'l 'p. ('l, 'p) Micheline.node -> (Location.t, 'p) Micheline.node =
  fun e ->
  Micheline.(inject_locations (fun _ -> Location.dummy) (strip_locations e))

let compile_contract ~raise : options:Compiler_options.t -> expression -> Stacking.compiled_expression  = fun ~options e ->
  let (input_ty , _) = trace ~raise self_mini_c_tracer @@ Self_mini_c.get_t_function e.type_expression in
  let contract : anon_function = trace ~raise self_mini_c_tracer @@ Self_mini_c.get_function_or_eta_expand e in
  let contract = { contract with body = Self_mini_c.all_expression ~raise contract.body} in
  let contract = trace ~raise self_mini_c_tracer @@ Self_mini_c.contract_check contract in
  let protocol_version = options.backend.protocol_version in
  let co_de_bruijn = Scoping.translate_closed_function contract input_ty in
  let co_de_bruijn = trace ~raise stacking_tracer @@ Stacking.Program.compile_function_body protocol_version co_de_bruijn in
  let expr = Self_michelson.optimize protocol_version co_de_bruijn in
  let expr_ty = Scoping.translate_type e.type_expression in
  let expr_ty = dummy_locations (forward expr_ty) in
  ({ expr_ty ; expr } : Stacking.Program.compiled_expression)

let compile_view ~raise : options:Compiler_options.t -> expression -> Stacking.compiled_expression  = fun ~options e ->
  let (input_ty , _) = trace ~raise self_mini_c_tracer @@ Self_mini_c.get_t_function e.type_expression in
  let view : anon_function = trace ~raise self_mini_c_tracer @@ Self_mini_c.get_function_or_eta_expand e in
  let view = { view with body = Self_mini_c.all_expression ~raise view.body} in
  let protocol_version = options.backend.protocol_version in
  let co_de_bruijn = Scoping.translate_closed_function view input_ty in
  let co_de_bruijn = trace ~raise stacking_tracer @@ Stacking.Program.compile_function_body protocol_version co_de_bruijn in
  let expr = Self_michelson.optimize protocol_version co_de_bruijn in
  let expr_ty = Scoping.translate_type e.type_expression in
  let expr_ty = dummy_locations (forward expr_ty) in
  ({ expr_ty ; expr } : Stacking.Program.compiled_expression)

let compile_expression ~raise : options:Compiler_options.t -> expression -> compiled_expression = fun ~options e ->
  let e = Self_mini_c.all_expression ~raise e in
  let (expr, _) = Scoping.translate_expression e [] in
  let protocol_version = options.backend.protocol_version in
  let expr = trace ~raise stacking_tracer @@ Stacking.Program.compile_expr protocol_version [] [] expr in
  let expr = Self_michelson.optimize protocol_version expr in
  let expr_ty = Scoping.translate_type e.type_expression in
  let expr_ty = dummy_locations (forward expr_ty) in
  ({ expr_ty ; expr } : Program.compiled_expression)

let compile_type = fun e ->
  let expr_ty = Scoping.translate_type e in
  dummy_locations (forward expr_ty)

let pretty_print program =
  Mini_c.PP.expression program
