(**
   Test the docker module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.27
**)



let docker_uri = "http://128.232.65.27:2375"

let test_fn fn =
  let json = fn docker_uri in
  print_endline (String.make 60 '=');
  print_endline (Yojson.Basic.pretty_to_string json);;

test_fn Docker.info;;
test_fn Docker.version;;
test_fn Docker.Image.images;;
test_fn Docker.Container.containers;;
