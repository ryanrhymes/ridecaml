(**
   Test the docker module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.27
**)

let uri = "http://128.232.65.27:2375"

let format_output json =
  print_endline (String.make 60 '=');
  print_endline (Yojson.Basic.pretty_to_string json);;

print_endline ( Docker.ping uri );;
format_output ( Docker.info uri );;
format_output ( Docker.version uri );;
format_output ( Docker.Container.containers uri );;

format_output ( Docker.Image.search uri ~term:"ryanrhymes");;

(**
Docker.Image.pull uri ~id:"hello-world" ;;
format_output ( Docker.Image.images uri ~all:false);;
format_output ( Docker.Image.inspect uri ~id:"91c95931e552");;
format_output ( Docker.Image.history uri ~id:"91c95931e552");;
format_output ( Docker.Image.remove uri ~id:"91c95931e552");;
Docker.Image.pull uri ~id:"hello-world" ;;
Docker.save_to ~fname:"abc.tar" ~data:(Docker.Image.get_image uri ~id:"91c95931e552")
**)
