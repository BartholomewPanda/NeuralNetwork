
let random_uniform x =
    if Random.int 2 = 0 then
        Random.float x
    else
        Random.float (-. x)

let list_apply f nb =
    let rec apply i result =
        if i >= nb then result
        else apply (i + 1) (f i :: result)
    in
    apply 0 []

let rec list_take nb l =
    (* TODO: tail recursive *)
    let rec take nb l =
        if nb <= 0 then []
        else match l with
            | [] -> []
            | hd :: tl -> hd :: (take (nb - 1) tl)
    in
    take nb l

let sigmoid x =
    1.0 /. (1.0 +. exp(-. x))

let sigmoid' x =
    x *. (1.0 -. x)

