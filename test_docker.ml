(**
   Test the docker module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.27
**)



let docker_uri = "http://128.232.65.27:2375"
let uri = "http://128.232.65.27:2375"

let format_output json =
  print_endline (String.make 60 '=');
  print_endline (Yojson.Basic.pretty_to_string json);;

format_output ( Docker.info docker_uri );;
format_output ( Docker.version docker_uri );;
format_output ( Docker.Container.containers docker_uri );;
format_output ( Docker.Image.images uri ~all:true);;


