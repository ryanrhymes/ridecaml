(**
  Liang Wang @ Computer Lab, Cambridge University, UK
  2015.06.24
**)

type service = {
  id : string;
  size : int
}

let service_cache = Hashtbl.create 1024;;

let add s = Hashtbl.add service_cache s.id s;;

let remove sid = Hashtbl.remove service_cache sid;;

let find sid = Hashtbl.find service_cache sid;;
