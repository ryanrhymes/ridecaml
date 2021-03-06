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

let get_data ?(data="") ~operation uri =
  let meth = match operation with
    | "GET" -> Client.get (Uri.of_string uri)
    | "POST" -> Client.post ~body:(Cohttp_lwt_body.of_string data) (Uri.of_string uri)
    | "DELETE" -> Client.delete (Uri.of_string uri)
    | _ -> Client.get (Uri.of_string uri) in
  ( meth >>= fun (resp, body) -> Cohttp_lwt_body.to_string body )
  |> Lwt_main.run

let get_data2 ?(headers=["Content-Type","application/json"]) ?(data="") ~operation uri =
  let headers = Header.of_list headers in
  let meth = match operation with
    | "GET" -> Client.get (Uri.of_string uri)
    | "POST" -> Client.post ~headers:headers ~body:(Cohttp_lwt_body.of_string data) (Uri.of_string uri)
    | "DELETE" -> Client.delete (Uri.of_string uri)
    | _ -> Client.get (Uri.of_string uri) in
  ( meth >>= fun (resp, body) -> Cohttp_lwt_body.to_string body )
  |> Lwt_main.run

let get_stream ?(data="") ~operation uri = 
  let meth = match operation with
    | "GET" -> Client.get (Uri.of_string uri)
    | "POST" -> Client.post ~body:(Cohttp_lwt_body.of_string data) (Uri.of_string uri)
    | "DELETE" -> Client.delete (Uri.of_string uri)
    | _ -> Client.get (Uri.of_string uri) in
  meth >>= fun (res, body) ->
  return ( Cohttp_lwt_body.to_stream body )

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
    get_data "GET" q

  let copy ~data ~id uri =
    (** not done yet **)
    let q = uri ^ "/containers/" ^ id ^ "/copy" in
    get_data ~data ~operation:"POST" q

  let create ?image ?cmd ?hostname ?domainname ?user ?attachstdin ?attachstdout ?attachstderr ?tty ?openstdin ?stdinonce
      ?env ?entrypoint ?labels ?volumes ?networkdisabled ?macaddress ?exposedports
      ?binds ?links ?lxcconf ?memory ?memoryswap ?cpushares ?cpuperiod ?cpusetcpus ?cpusetmems ?blkioweight ?oomkilldisable
      ?portbindings ?publishAllPorts ?privileged ?readonlyRootfs ?dns ?dnsSearch ?extraHosts ?volumesFrom ?capAdd ?capDrop
      ?restartPolicy ?networkMode ?devices ?ulimits ?logConfig ?securityOpt ?cgroupParent uri =
    let open Yojson in
    let p = match image with None -> [] | Some x -> [ "Image", `String x ] in
    let p = match hostname with None -> p | Some x -> p @ [ "HostName", `String x ] in
    let p = match domainname with None -> p | Some x -> p @ [ "DomainName", `String x ] in
    let p = match cmd with None -> p | Some x -> p @ [ "Cmd", `List (List.map (fun v -> `String v) x) ] in
    let p = match user with None -> p | Some x -> p @ [ "User", `String x ] in
    let p = match attachstdin with None -> p | Some x -> p @ [ "AttachStdin", `Bool x ] in
    let p = match attachstdout with None -> p | Some x -> p @ [ "AttachStdout", `Bool x ] in
    let p = match attachstderr with None -> p | Some x -> p @ [ "AttachStderr", `Bool x ] in
    let p = match tty with None -> p | Some x -> p @ [ "Tty", `Bool x ] in
    let p = match openstdin with None -> p | Some x -> p @ [ "OpenStdin", `Bool x ] in
    let p = match env with None -> p | Some x -> p @ [ "Env", `Assoc (List.map (fun (k,v) -> (k,`String v)) x) ] in
    let p = match stdinonce with None -> p | Some x -> p @ [ "StdinOnce", `Bool x ] in
    let p = match entrypoint with None -> p | Some x -> p @ [ "EntryPoint", `String x ] in
    let p = match labels with None -> p | Some x -> p @ [ "Labels", `Assoc (List.map (fun (k,v) -> (k,`String v)) x) ] in
    let p = match volumes with None -> p | Some x -> p @ [ "Volumes", `List (List.map (fun v -> `String v) x) ] in
    let p = match networkdisabled with None -> p | Some x -> p @ [ "NetworkDisabled", `Bool x ] in
    let p = match macaddress with None -> p | Some x -> p @ [ "MacAddress", `String x ] in
    let p = match exposedports with None -> p | Some x -> p @ [ "ExposedPorts", `List (List.map (fun v -> `String v) x) ] in
    (** build HostConfig **)
    let r = match binds with None -> [] | Some x -> [ "Binds", `List (List.map (fun v -> `String v) x) ] in
    let r = match links with None -> r | Some x -> r @ [ "Links", `List (List.map (fun v -> `String v) x) ] in
    let r = match lxcconf with None -> r | Some x -> r @ [ "LxcConf", `Assoc (List.map (fun (k,v) -> (k,`String v)) x) ] in
    let r = match memory with None -> r | Some x -> r @ [ "Memory", `Int x ] in
    let r = match memoryswap with None -> r | Some x -> r @ [ "MemorySwap", `Int x ] in
    let r = match cpushares with None -> r | Some x -> r @ [ "CpuShares", `Int x ] in
    let r = match cpuperiod with None -> r | Some x -> r @ [ "CpuPeriod", `Int x ] in
    let r = match cpusetcpus with None -> r | Some x -> r @ [ "CpusetCpus", `String x ] in
    let r = match cpusetmems with None -> r | Some x -> r @ [ "CpusetMems", `String x ] in
    let r = match blkioweight with None -> r | Some x -> r @ [ "BlkioWeight", `Int x ] in
    let r = match oomkilldisable with None -> r | Some x -> r @ [ "OomKillDisable", `Bool x ] in
    (** combine conf then submit **)
    print_endline (pretty_to_string (`Assoc (p @ [ "HostConfig", `Assoc r ])));
    let p = to_string (`Assoc (p @ [ "HostConfig", `Assoc r ])) in
    let q = uri ^ "/containers/create" in
    get_data2 ~operation:"POST" ~data:p q


  let changes ~id uri =
    (** return values: 0:modify; 1:add; 2:delete; **)
    let q = uri ^ "/containers/" ^ id ^ "/changes" in
    get_data "GET" q

  let export ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/export" in
    get_data "GET" q

  let inspect ~id uri = 
    let q = uri ^ "/containers/" ^ id ^ "/json" in
    get_data "GET" q

  let kill ?(signal="SIGKILL") ~id uri =
    let p = build_query_string [ "signal", signal ] in
    let q = uri ^ "/containers/" ^ id ^ "/kill?" ^p  in
    get_data "POST" q

  let logs ?(tail=1024) ?(timestamp=false) ?(since=0.) ?(stderr=false) ?(stdout=false) ?(follow=false) ~id uri = 
    (** return stream or string **)
    let p = build_query_string ["follow", string_of_bool follow; "stdout", string_of_bool stdout; 
				"stderr", string_of_bool stderr; "since", string_of_float since; 
				"timestamp", string_of_bool timestamp; "tail", string_of_int tail ] in
    let q = uri ^ "/containers/" ^ id ^ "/logs?" ^ p in
    get_stream "GET" q

  let pause ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/pause" in
    get_data "POST" q

  let remove ?(force=false) ?(v=false) ~id uri = 
    (** gets block if using force=true **)
    let p = build_query_string [ "force", string_of_bool force; "v", string_of_bool v ] in
    let q = uri ^ "/containers/" ^ id ^ "?" ^ p in
    get_data "DELETE" q

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
    let p = build_query_string [ "stream", string_of_bool stream ] in
    let q = uri ^ "/containers/" ^ id ^ "/stats?" ^ p in
    get_stream "GET" q

  let stop ?(t=0) ~id uri =
    let p = build_query_string [ "t", string_of_int t ] in
    let q = uri ^ "/containers/" ^ id ^ "/stop?" ^ p in
    get_data "POST" q

  let top ?ps_args ~id uri = 
    let p = match ps_args with None -> [] | Some x -> [ "ps_args", x ] in
    let p = build_query_string p in
    let q = uri ^ "/containers/" ^ id ^ "/top?" ^ p in
    get_data "GET" q

  let unpause ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/unpause" in
    get_data "POST" q

  let wait ~id uri =
    let q = uri ^ "/containers/" ^ id ^ "/wait" in
    get_data "POST" q

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
    get_data "GET" q

  let images ?filters ?all uri = 
    let p = match all with None -> ["all", "false"] | Some x -> [ "all", string_of_bool x ] in
    let p = match filters with None -> p | Some x -> p @ [ "filters", x ] in
    let p = build_query_string p in
    let q = uri ^ "/images/json?" ^ p in
    get_data "GET" q

  let import_from_file ~fname uri =
    (** need more test ... need to add repo and tag ... **)
    let q = uri ^ "/images/load" in
    get_data ~data:(read_from fname) ~operation:"POST" q

  let inspect ~id uri =
    let q = uri ^ "/images/" ^ id ^ "/json" in
    get_data "GET" q

  let pull ~id uri = 
    (** not done yet **)
    let p = build_query_string ["fromImage", id ] in
    let q = uri ^ "/images/create?" ^ p in
    get_data "POST" q

  let push ?(tag="latest") ~id uri =
    (** not done yet **)
    let p = build_query_string ["tag", tag ] in
    let q = uri ^ "/images/" ^ id ^ "/push?" ^ p in
    get_data "POST" q

  let search ~term uri =
    let p = build_query_string ["term", term ] in
    let q = uri ^ "/images/search?" ^ p in
    get_data "GET" q

  let tag ?(force=false) ~repo ~tags ~id uri =
    let p = build_query_string ["repo", repo; "tag", tags; "force", string_of_bool force] in
    let q = uri ^ "/images/" ^ id ^ "/tag?" ^ p in
    get_data "POST" q

  let remove ?(noprune=false) ?(force=false) ~id uri =
  let p = build_query_string ["noprune", string_of_bool noprune; "force", string_of_bool force] in
    let q = uri ^ "/images/" ^ id ^ "?" ^ p in
    get_data "DELETE" q

end


(** API to mist functions. **)

let login ~username ~password ~email ~registry ~reauth ~cfg_path uri = 0
  (** not tested yet **)

let commit = 0

let events ?(since=Unix.gettimeofday () -. 3600.) ?(until=Unix.gettimeofday ()) uri =
  let p = build_query_string ["since", string_of_float since; "until", string_of_float until] in
  let q = uri ^ "/events?" ^ p in
  get_stream "GET" q

let exec_create uri = 0

let exec_start uri = 0

let exec_resize uri = 0

let exec_inspect uri = 0

let info uri = 
  let q = uri ^ "/info" in
  get_data "GET" q

let ping uri =
  let q = uri ^ "/_ping" in
  get_data "GET" q

let version uri = 
  let q = uri ^ "/version" in
  get_data "GET" q

let show_headers h =
  Cohttp.Header.iter (fun k v -> List.iter (Printf.eprintf "%s: %s\n%!" k) v) h

let print_info s = 
  print_endline s;
  print_endline "=======>"
