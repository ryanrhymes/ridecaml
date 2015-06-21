open Printf;;

let add x y = x + y

let add_one x = add x 1

let multi (x:int) : int = 3 * x

let x = 5;;
let y = add_one x;;

printf "hello world\n";;
printf "the value is %i\n" y;;
printf "the value is %i\n" (multi (add_one y));;

