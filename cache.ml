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

let null_service = {id=0; uri=""; timestamp=0.; size=0;};;

let add s = Hashtbl.add service_cache s.id s;;

let remove sid = Hashtbl.remove service_cache sid;;

let find sid = Hashtbl.find service_cache sid;;

let remove_oldest c = 
  let s = Hashtbl.fold (fun _ v m -> if v.timestamp > m.timestamp then v else m) c null_service in
  remove s.id;
  s;;

let replace s t = remove s.id; add t;;

let print s = Printf.printf "{ id = %i; uri = %s; timestamp = %f size = %i }\n" s.id s.uri s.timestamp s.size;;

let touch sid = 
  let s = find sid in
  let t = { s with timestamp  = Unix.gettimeofday () } in
  replace s t;;

let debug c = Hashtbl.iter (fun _ v -> print v) c;;
