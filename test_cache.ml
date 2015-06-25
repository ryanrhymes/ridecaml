(**
   Test the cache module.

   Liang Wang @ Computer Lab, Cambridge University, UK
   2015.06.24
**)

print_endline "Testing cache module --> 1 ..."
let s1 : Cache.service = {id = 1; uri = "wwww.google.com"; timestamp = 0.; size = 12345;}
let s2 : Cache.service = {id = 2; uri = "wwww.yahoo.com"; timestamp = 0.; size = 78901;};;
Cache.add s1;;
Cache.add s2;;
Cache.debug Cache.service_cache;;

print_endline "Test caching module --> 2 ...";;
for i = 3 to 30 do
  let s : Cache.service = {id = i; uri = "my_uri_" ^ string_of_int i; timestamp = 0.1; size = i * 10;} in
  Cache.add s;
  Cache.touch s.id
done;;
Cache.debug Cache.service_cache;;

print_endline "Test caching module --> 3 ...";;
let s = Cache.remove_oldest Cache.service_cache;;
Cache.print s;;
