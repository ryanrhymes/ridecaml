(**
   Cache module for service caching.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.24
**)

type service = {
  id : int;
  uri : string;
  timestamp : float;
  size : int;
}

let service_cache = Hashtbl.create 1024;;

let add s = Hashtbl.add service_cache s.id s;;

let remove sid = Hashtbl.remove service_cache sid;;

let find sid = Hashtbl.find service_cache sid;;

let touch sid = 
  let s = find sid in
  s.timestamp = Unix.gettimeofday ();;

let print sid = 
  let s = find sid in
  Printf.printf "{ id = %i; uri = %s; time = %f size = %i }\n" s.id s.uri s.timestamp s.size;;

let debug c = Hashtbl.iter (fun k v -> print k) c;;

