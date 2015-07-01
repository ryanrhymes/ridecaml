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

let build_query_string params = 
  let l = List.map (fun (k,v) -> k ^ "=" ^ v) params in
  String.concat "&" l

let docker_daemon_get uri =
  Client.get (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_post uri =
  Client.post (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_post2 ~data uri =
  Client.post ~body:(Cohttp_lwt_body.of_string data) (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_delete uri =
  Client.delete (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let get_data ?(data="") ~operation query =
  let s = match operation with
    | "GET" -> docker_daemon_get query
    | "POST" -> docker_daemon_post2 ~data query
    | "DELETE" -> docker_daemon_delete query
    | _ -> return "error"
  in Lwt_main.run s

let get_json ~operation query =
  get_data operation query |> Yojson.Basic.from_string

let save_to ~fname ~data =
  let open Core.Std in
  Out_channel.write_all fname ~data

let read_from ~fname = 
  let open Core.Std in
  In_channel.read_all fname



(** API to container functions. **)

module Container = struct

  let attach uri = 0

  let attach_ws uri = 0

  let containers ?filters ?size ?before ?since ?limit ?all uri = 
    let p = match all with None -> ["all", "false"] | Some x -> [ "all", string_of_bool x ] in
    let p = match limit with None -> p | Some x -> p @ [ "limit", string_of_int x ] in
    let p = match since with None -> p | Some x -> p @ [ "since", x ] in
    let p = match before with None -> p | Some x -> p @ [ "before", x ] in
    let p = match size with None -> p | Some x -> p @ [ "size", string_of_bool x ] in
    let p = match filters with None -> p | Some x -> p @ [ "filters", x ] in
    let p = build_query_string p in
    let q = uri ^ "/containers/json?" ^ p in
    get_json "GET" q

  let copy uri = 0

  let create uri = 0

  let changes uri = 0

  let export uri = 0

  let inspect ~id uri = 
    let q = uri ^ "/containers/" ^ id ^ "/json" in
    get_json "GET" q

  let kill uri = 0

  let logs ?(tail=1024) ?(timestamp=false) ?(since=0.) ?(stderr=false) ?(stdout=false) ?(follow=false) ~id uri = 
    (** stream, follow not working **)
    let p = build_query_string ["follow", string_of_bool follow; "stdout", string_of_bool stdout; 
				"stderr", string_of_bool stderr; "since", string_of_float since; 
				"timestamp", string_of_bool timestamp; "tail", string_of_int tail ] in
    let q = uri ^ "/containers/" ^ id ^ "/logs?" ^ p in
    get_data "GET" q

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

  let top ?ps_args ~id uri = 
    let p = match ps_args with None -> [] | Some x -> [ "ps_args", x ] in
    let p = build_query_string p in
    let q = uri ^ "/containers/" ^ id ^ "/top?" ^ p in
    get_json "GET" q

  let unpause uri = 0

  let wait uri = 0

end


(** API to Image functions. **)

module Image = struct

  let create uri = 0

  let build uri = 0

  let get_image ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/get" in
    get_data "GET" q

  let history ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/history" in
    get_json "GET" q

  let images ?filters ?all uri = 
    let p = match all with None -> ["all", "false"] | Some x -> [ "all", string_of_bool x ] in
    let p = match filters with None -> p | Some x -> p @ [ "filters", x ] in
    let p = build_query_string p in
    let q = uri ^ "/images/json?" ^ p in
    get_json "GET" q

  let import_from_file ~fname uri =
    (** need more test ... need to add repo and tag ... **)
    let q = uri ^ "/images/load" in
    get_data ~data:(read_from fname) ~operation:"POST" q

  let inspect ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/json" in
    get_json "GET" q

  let pull ~id uri = 
    (** not done yet **)
    let p = build_query_string ["fromImage", id ] in
    let q = uri ^ "/images/create?" ^ p in
    get_json "POST" q

  let push ?(tag="latest") ~id uri =
    (** not done yet **)
    let p = build_query_string ["tag", tag ] in
    let q = uri ^ "/images/" ^ id ^ "/push?" ^ p in
    get_json "POST" q

  let search ~term uri =
    let p = build_query_string ["term", term ] in
    let q = uri ^ "/images/search?" ^ p in
    get_json "GET" q

  let tag ?(force=false) ~repo ~tags ~id uri =
    let p = build_query_string ["repo", repo; "tag", tags; "force", string_of_bool force] in
    let q = uri ^ "/images/" ^ id ^ "/tag?" ^ p in
    get_data "POST" q

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
