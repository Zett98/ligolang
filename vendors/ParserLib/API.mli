(* Making parsers from a variety of input using Menhir. *)

(* Vendor dependencies *)

module Region = Simple_utils.Region

(* Generic signature of tokens *)

module type TOKEN =
  sig
    type token
    type t = token

    val to_lexeme : token -> string
    val to_string : offsets:bool -> [`Byte | `Point] -> token -> string
    val to_region : token -> Region.t
    val is_eof    : token -> bool
    val mk_eof    : Region.t -> token
  end

(* Generic signature of input lexers *)

module type LEXER =
  sig
    module Token : TOKEN
    type token = Token.t

    type message = string Region.reg

    val scan : Lexing.lexbuf -> (token, message) Stdlib.result

    type window = <
      last_token    : token option;
      current_token : token           (* Including EOF *)
    >

    val get_window : unit -> window option
  end

(* The signature generated by Menhir with an additional type
   definition for [tree]. *)

module type PARSER =
  sig
    type token
    type tree

    (* The monolithic API. *)

    exception Error

    val main : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> tree

    (* The incremental API. *)

    module MenhirInterpreter :
      sig
        include MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE
                with type token = token
      end

    module Incremental :
      sig
        val main :
          Lexing.position -> tree MenhirInterpreter.checkpoint
      end
  end

(* Mappimg from error states in the LR automaton generated by Menhir
   to error messages (incremental API of Menhir) *)

module type PAR_ERR =
  sig
    val message : int -> string
  end

(* The functor integrating the parser with its errors *)

module Make (Lexer  : LEXER)
            (Parser : PARSER with type token = Lexer.token) :
  sig
    type token = Lexer.token

    type message = string Region.reg

    type 'src parser =
      'src -> (Parser.tree, message) Stdlib.result

    val get_window : unit -> Lexer.window

    (* Monolithic API of Menhir *)

    type file_path = string

    val mono_from_lexbuf  : Lexing.lexbuf parser
    val mono_from_channel : in_channel    parser
    val mono_from_string  : string        parser
    val mono_from_file    : file_path     parser

    (* Incremental API of Menhir *)

    val incr_from_lexbuf  : (module PAR_ERR) -> Lexing.lexbuf parser
    val incr_from_channel : (module PAR_ERR) -> in_channel    parser
    val incr_from_string  : (module PAR_ERR) -> string        parser
    val incr_from_file    : (module PAR_ERR) -> file_path     parser
  end
