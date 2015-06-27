(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_lwt_unix

let docker_daemon uri =
  Client.get (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let get_json query =
  Lwt_main.run (docker_daemon query) |> Yojson.Basic.from_string

let containers ?param uri = 
  let q = uri ^ "/containers/json" in
  get_json q

let images uri = 
  let q = uri ^ "/images/json" in
  get_json q

let info uri = 
  let q = uri ^ "/info" in
  get_json q

let inspect uri cid = 
  let q = uri ^ "/containers/" ^ cid ^ "/json" in
  get_json q

let logs uri cid = 
  let q = uri ^ "/containers/" ^ cid ^ "/logs" in
  get_json q

let ping uri =
  let q = uri ^ "/_ping" in
  Lwt_main.run (docker_daemon q)

let port uri = 0

let pull uri = 0

let push uri = 0

let top uri cid = 
  let q = uri ^ "/containers/" ^ cid ^ "/top" in
  get_json q

let version uri = 
  let q = uri ^ "/version" in
  get_json q
