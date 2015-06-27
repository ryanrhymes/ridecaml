(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_lwt_unix

(** These are common functions. **)

let docker_daemon uri =
  Client.get (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let get_json query =
  Lwt_main.run (docker_daemon query) |> Yojson.Basic.from_string

(** API to container functions. **)

module Container = struct

  let attach uri = 0

  let attach_ws uri = 0

  let containers ?param uri = 
    let q = uri ^ "/containers/json" in
    get_json q

  let copy uri = 0

  let create uri = 0

  let changes uri = 0

  let export uri = 0

  let inspect uri cid = 
    let q = uri ^ "/containers/" ^ cid ^ "/json" in
    get_json q

  let kill uri = 0

  let logs uri cid = 
    let q = uri ^ "/containers/" ^ cid ^ "/logs" in
    get_json q

  let pause uri = 0

  let ping uri =
    let q = uri ^ "/_ping" in
    Lwt_main.run (docker_daemon q)

  let port uri = 0

  let pull uri = 0

  let push uri = 0

  let remove uri = 0

  let rename uri = 0

  let resize uri = 0

  let restart uri = 0

  let start uri = 0

  let stats uri = 0

  let stop uri = 0

  let top uri cid = 
    let q = uri ^ "/containers/" ^ cid ^ "/top" in
    get_json q

  let unpause uri = 0

  let wait uri = 0

end

(** API to Image functions. **)

module Image = struct

  let images uri = 
    let q = uri ^ "/images/json" in
    get_json q

end

(** API to mist functions. **)

let info uri = 
  let q = uri ^ "/info" in
  get_json q

let version uri = 
  let q = uri ^ "/version" in
  get_json q

