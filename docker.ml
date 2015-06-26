(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_lwt_unix

let d_uri = "http://128.232.65.27:2375/images/json"

let docker_deamon uri =
  Client.get (Uri.of_string uri) >>= fun (resp, body) ->
  body |> Cohttp_lwt_body.to_string

let () =
  print_endline ("Docker OCaml API @ " ^ d_uri);;
  let x = Lwt_main.run docker_deamon d_uri in
  print_endline ("Received body\n" ^ x)
