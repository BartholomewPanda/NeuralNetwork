
let random_uniform x =
    if Random.int 2 = 0 then
        Random.float x
    else
        Random.float (-. x)

let sigmoid x =
    1.0 /. (1.0 +. exp(-. x))

let sigmoid' x =
    x *. (1.0 -. x)

