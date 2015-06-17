open Core.Std

let rec read_accu accum = 
  let line = In_channel.input_line In_channel.stdin in
  match line with
  | None -> accum
  | Some x -> read_accu (accum +. Float.of_string x)

let () = 
  printf "Total: %F\n" (read_accu 0.)