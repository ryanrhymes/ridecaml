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

let get_json resp =
  Lwt_main.run (docker_daemon resp) |> Yojson.Basic.from_string

let build_query_string params = 
  let l = List.map (fun (k,v) -> k ^ "=" ^ v) params in
  String.concat "&" l


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

  let create uri = 0

  let build uri = 0

  let get_image uri = 0

  let history uri = 0

  let images ?(filters="") ?(all=false) uri = 
    let p = build_query_string ["all", string_of_bool all; "filter", ""] in
    let q = uri ^ "/images/json?" ^ p in
    get_json q

  let inspect uri = 0

  let load uri = 0

  let push uri = 0

  let search uri = 0

  let tag uri = 0

  let remove uri = 0

end

(** API to mist functions. **)

let auth uri = 0

let commit uri = 0

let events ?(since=Unix.gettimeofday ()) ?(until=Unix.gettimeofday () +. 10.) uri =
  (** not done yet **)
  let p = build_query_string ["since", string_of_float since; "until", string_of_float until] in
  let q = uri ^ "/events" ^ p in
  get_json q

let exec_create uri = 0

let exec_start uri = 0

let exec_resize uri = 0

let exec_inspect uri = 0

let info uri = 
  let q = uri ^ "/info" in
  get_json q

let ping uri =
  let q = uri ^ "/_ping" in
  Lwt_main.run (docker_daemon q)

let version uri = 
  let q = uri ^ "/version" in
  get_json q
