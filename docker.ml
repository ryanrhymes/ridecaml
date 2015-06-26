(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_lwt_unix

let docker_uri = "http://128.232.65.27:2375"

let docker_daemon uri =
  Client.get (Uri.of_string uri) >>= fun (resp, body) ->
  body |> Cohttp_lwt_body.to_string

let containers ?param uri = 
  let q = uri ^ "/containers/json" in
  Lwt_main.run (docker_daemon q)

let images uri = 
  let q = uri ^ "/images/json" in
  Lwt_main.run (docker_daemon q)

let info uri = 
  let q = uri ^ "/info" in
  Lwt_main.run (docker_daemon q)

let inspect uri cid = 
  let q = uri ^ "/containers/" ^ cid ^ "/json" in
  Lwt_main.run (docker_daemon q)

let ping uri =
  let q = uri ^ "/_ping" in
  Lwt_main.run (docker_daemon q)

let port uri = 0

let pull uri = 0

let push uri = 0

let () =
  let s = info docker_uri in
  let json = Yojson.Basic.from_string s in
  print_endline (Yojson.Basic.pretty_to_string json)

