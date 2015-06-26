(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_lwt_unix

let d_uri = "http://128.232.65.27:2375/images/json"

let test =
  Client.get (Uri.of_string d_uri) >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  Printf.printf "Response code: %d\n" code;
  (**Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);**)
  body |> Cohttp_lwt_body.to_string >|= fun body ->
  Printf.printf "Body of length: %d\n" (String.length body);
  body

let () =
  print_endline ("Docker OCaml API @ " ^ d_uri);;
  let x = Lwt_main.run test in
  print_endline ("Received body\n" ^ x)
