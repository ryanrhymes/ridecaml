(**
   Test the docker module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.27
**)

open Lwt
open Cohttp
open Cohttp_async
open Cohttp_lwt_unix

let uri = "http://128.232.65.27:2375"

let format_output json =
  print_endline (String.make 60 '=');
  print_endline (Yojson.Basic.pretty_to_string json);;

(**
print_endline ( Docker.ping uri );;
format_output ( Docker.info uri );;
format_output ( Docker.version uri );;

format_output ( Docker.Image.search uri ~term:"ryanrhymes");;
print_endline ( Docker.Image.import_from_file uri ~fname:"zzz.tar");;
**)

(** format_output ( Docker.Image.push uri ~id:"hello2" ~tag:"new");; **)
(**
Docker.Image.pull uri ~id:"hello-world" ;;
format_output ( Docker.Image.images uri ~all:false);;
format_output ( Docker.Image.inspect uri ~id:"91c95931e552");;
format_output ( Docker.Image.history uri ~id:"91c95931e552");;
format_output ( Docker.Image.remove uri ~id:"91c95931e552");;
Docker.Image.pull uri ~id:"hello-world" ;;
print_endline ( Docker.Image.tag uri ~id:"91c95931e552" ~tags:"new" ~repo:"hello2");;
Docker.save_to ~fname:"zzz.tar" ~data:(Docker.Image.get_image uri ~id:"91c95931e552")
**)

(**
format_output ( Docker.Container.containers uri );;
print_endline ( Docker.Container.stop ~t: 10 uri ~id:"a59ccd25a2cd");;

print_endline ( Docker.Container.rename uri ~name:"liang" ~id:"beed0abbab13" );;
print_endline ( Docker.Container.kill uri ~id:"56982a434760" );;
format_output ( Docker.Container.changes uri ~id:"beed0abbab13");;
**)

(** print_endline ( Docker.Container.copy ~data:"Content-Type: application/json\n" ~id:"56982a434760" uri );; **)
(** debug: format_output ( Docker.Container.remove uri ~id:"56982a434760" ~force:true );; **)
(** print_endline ( Docker.Container.logs2 uri ~stdout:true ~id:"d9b914429bdf" ~follow:false );; **)


(** print_endline ( Docker.events uri ) **)

(**
let s = Docker.events uri >>= fun x ->
Lwt_stream.iter_s (fun y -> Docker.print_info y; return ()) x;
in Lwt_main.run s

let s = Docker.Container.logs uri ~stdout:true ~id:"c93792d12ad2" ~follow:false >>= fun x ->
Lwt_stream.iter_s (fun y -> print_endline y; return ()) x;
in Lwt_main.run s
**)

print_endline (Docker.info uri);;

let s = Docker.Container.stats uri ~id:"c93792d12ad2" ~stream:true >>= fun x ->
Lwt_stream.iter_s (fun y -> print_endline y; return ()) x;
in Lwt_main.run s
