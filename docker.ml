(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_async
open Cohttp_lwt_unix


(** These are common functions. **)

let docker_daemon_get uri =
  Client.get (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_post uri =
  Client.post (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_delete uri =
  Client.delete (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let get_json operation query =
  match operation with
  | "GET" -> Lwt_main.run (docker_daemon_get query) |> Yojson.Basic.from_string
  | "POST" -> Lwt_main.run (docker_daemon_post query) |> Yojson.Basic.from_string
  | "DELETE" -> Lwt_main.run (docker_daemon_delete query) |> Yojson.Basic.from_string
  | _ ->  Yojson.Basic.from_string "error"

let build_query_string params = 
  let l = List.map (fun (k,v) -> k ^ "=" ^ v) params in
  String.concat "&" l

let docker_daemon_get_data uri =
  Lwt_main.run (docker_daemon_get uri)


(** API to container functions. **)

module Container = struct

  let attach uri = 0

  let attach_ws uri = 0

  let containers ?param uri = 
    (** not done yet **)
    let q = uri ^ "/containers/json" in
    get_json "GET" q

  let copy uri = 0

  let create uri = 0

  let changes uri = 0

  let export uri = 0

  let inspect ~id uri = 
    let q = uri ^ "/containers/" ^ id ^ "/json" in
    get_json "GET" q

  let kill uri = 0

  let logs id uri = 
    (** not done yet **)
    let q = uri ^ "/containers/" ^ id ^ "/logs" in
    get_json "GET" q

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
    (** not done yet **)
    let q = uri ^ "/containers/" ^ cid ^ "/top" in
    get_json "GET" q

  let unpause uri = 0

  let wait uri = 0

end


(** API to Image functions. **)

module Image = struct

  let create uri = 0

  let build uri = 0

  let get_image ~id uri =
    (** not done yet **)
    let q = uri ^ "/images/" ^ id ^ "/get" in
    docker_daemon_get_data q

  let history ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/history" in
    get_json "GET" q

  let images ?(filters="") ?(all=false) uri = 
    (** not done yet **)
    let p = build_query_string ["all", string_of_bool all; "filter", ""] in
    let q = uri ^ "/images/json?" ^ p in
    get_json "GET" q

  let inspect ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/json" in
    get_json "GET" q

  let load uri = 0

  let pull ~id uri = 
    (** not done yet **)
    let p = build_query_string ["fromImage", id ] in
    let q = uri ^ "/images/create?" ^ p in
    get_json "POST" q

  let push uri = 0

  let search uri = 0

  let tag uri = 0

  let remove ?(noprune=false) ?(force=false) ~id uri =
  let p = build_query_string ["noprune", string_of_bool noprune; "force", string_of_bool force] in
    let q = uri ^ "/images/" ^ id ^ "?" ^ p in
    get_json "DELETE" q

end


(** API to mist functions. **)

let auth uri = 0

let commit uri = 0

let events ?(since=Unix.gettimeofday () -. 3600.) ?(until=Unix.gettimeofday ()) uri =
  (** not done yet **)
  let p = build_query_string ["since", string_of_float since; "until", string_of_float until] in
  let q = uri ^ "/events?" ^ p in
  get_json "GET" q

let exec_create uri = 0

let exec_start uri = 0

let exec_resize uri = 0

let exec_inspect uri = 0

let info uri = 
  let q = uri ^ "/info" in
  get_json "GET" q

let ping uri =
  let q = uri ^ "/_ping" in
  Lwt_main.run (docker_daemon_get q)

let version uri = 
  let q = uri ^ "/version" in
  get_json "GET" q


(** Helper functions. **)

let save_to ~fname ~data =
  let channel = open_out fname in
  output_string channel data;
  close_out channel
