(**
   Docker API in Ocaml.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.25
**)

open Lwt
open Cohttp
open Cohttp_async
open Cohttp_lwt_unix


let test1 uri = 
  let headers = Cohttp.Header.of_list ["connection","close"] in
  let s = Client.call ~headers `GET (Uri.of_string uri) >>= fun (res, body) ->
  Lwt_stream.iter_s (fun s -> return ()) (Cohttp_lwt_body.to_stream body)
  in Lwt_main.run s



(** These are common functions. **)

let build_query_string params = 
  let l = List.map (fun (k,v) -> k ^ "=" ^ v) params in
  String.concat "&" l

let docker_daemon_get uri =
  Client.get (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_post ~data uri =
  Client.post ~body:(Cohttp_lwt_body.of_string data) (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let docker_daemon_delete uri =
  Client.delete (Uri.of_string uri) 
  >>= fun (resp, body) -> Cohttp_lwt_body.to_string body

let get_data ?(data="") ~operation query =
  let s = match operation with
    | "GET" -> docker_daemon_get query
    | "POST" -> docker_daemon_post ~data query
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

  let copy ~data ~id uri =
    (** not done yet **)
    let q = uri ^ "/containers/" ^ id ^ "/copy" in
    get_data ~data ~operation:"POST" q

  let create uri = 0

  let changes ~id uri =
    (** return values: 0:modify; 1:add; 2:delete; **)
    let q = uri ^ "/containers/" ^ id ^ "/changes" in
    get_json "GET" q

  let export ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/export" in
    get_data "GET" q

  let inspect ~id uri = 
    let q = uri ^ "/containers/" ^ id ^ "/json" in
    get_json "GET" q

  let kill ?(signal="SIGKILL") ~id uri =
    let p = build_query_string [ "signal", signal ] in
    let q = uri ^ "/containers/" ^ id ^ "/kill?" ^p  in
    get_data "POST" q

  let logs ?(tail=1024) ?(timestamp=false) ?(since=0.) ?(stderr=false) ?(stdout=false) ?(follow=false) ~id uri = 
    (** stream, follow not working **)
    let p = build_query_string ["follow", string_of_bool follow; "stdout", string_of_bool stdout; 
				"stderr", string_of_bool stderr; "since", string_of_float since; 
				"timestamp", string_of_bool timestamp; "tail", string_of_int tail ] in
    let q = uri ^ "/containers/" ^ id ^ "/logs?" ^ p in
    get_data "GET" q

  let logs2 ?(tail=1024) ?(timestamp=false) ?(since=0.) ?(stderr=false) ?(stdout=false) ?(follow=false) ~id uri = 
    (** stream, follow not working **)
    let p = build_query_string ["follow", string_of_bool follow; "stdout", string_of_bool stdout; 
				"stderr", string_of_bool stderr; "since", string_of_float since; 
				"timestamp", string_of_bool timestamp; "tail", string_of_int tail ] in
    let q = uri ^ "/containers/" ^ id ^ "/logs?" ^ p in
    let s = docker_daemon_get q in
    while true do
      Unix.sleep 1;
      print_endline "heatbeat ...";
      print_endline (Lwt_main.run s)
    done;
    Lwt_main.run s

  let pause ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/pause" in
    get_data "POST" q

  let remove ?(force=false) ?(v=false) ~id uri = 
    (** gets block if using force=true **)
    let p = build_query_string [ "force", string_of_bool force; "v", string_of_bool v ] in
    let q = uri ^ "/containers/" ^ id ^ "?" ^ p in
    get_json "DELETE" q

  let rename ~name ~id uri =
    let p = build_query_string [ "name", name ] in
    let q = uri ^ "/containers/" ^ id ^ "/rename?" ^ p in
    get_data "POST" q

  let resize ~w ~h ~id uri =
    let p = build_query_string [ "w", string_of_int w; "h", string_of_int h ] in
    let q = uri ^ "/containers/" ^ id ^ "/resize?" ^ p in
    get_data "POST" q

  let restart ?(t=0) ~id uri =
    let p = build_query_string [ "t", string_of_int t ] in
    let q = uri ^ "/containers/" ^ id ^ "/restart?" ^ p in
    get_data "POST" q

  let start uri = 0

  let stats ?(stream=false) ~id uri =
    (** not really working ... **)
    let p = build_query_string [ "stream", string_of_bool stream ] in
    let q = uri ^ "/containers/" ^ id ^ "/stats?" ^ p in
    get_data "GET" q

  let stop ?(t=0) ~id uri =
    let p = build_query_string [ "t", string_of_int t ] in
    let q = uri ^ "/containers/" ^ id ^ "/stop?" ^ p in
    get_data "POST" q

  let top ?ps_args ~id uri = 
    let p = match ps_args with None -> [] | Some x -> [ "ps_args", x ] in
    let p = build_query_string p in
    let q = uri ^ "/containers/" ^ id ^ "/top?" ^ p in
    get_json "GET" q

  let unpause ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/unpause" in
    get_data "POST" q

  let wait ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/wait" in
    get_json "POST" q

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

let login ~username ~password ~email ~registry ~reauth ~cfg_path  uri =
  (** not tested yet **)
  0
  

let commit = 0

let events ?(since=Unix.gettimeofday () -. 3600.) ?(until=Unix.gettimeofday ()) uri =
  (** not done yet **)
  let p = build_query_string ["since", string_of_float since; "until", string_of_float until] in
  let q = uri ^ "/events?" ^ p in
  get_data "GET" q

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
