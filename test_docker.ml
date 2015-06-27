(**
   Test the docker module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.27
**)



let docker_uri = "http://128.232.65.27:2375"

let () =
  let json = Docker.info docker_uri in
  print_endline (Yojson.Basic.pretty_to_string json);
  let json = Docker.images docker_uri in
  print_endline (Yojson.Basic.pretty_to_string json);
