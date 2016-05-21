
open NeuralNetwork


let make_new_population breeding mutation population_size population =
    let rec make parents children nb =
        if nb < population_size then
            match parents with
                | mother :: father :: tl ->
                    let c1, c2 = breeding mother father in
                    mutation c1;
                    mutation c2;
                    make tl (mother :: father :: c1 :: c2 :: children) (nb + 4)
                | _ -> children
        else
            children
    in
    make population [] 0

let rec genetic fitness select breeding mutation finished population_size population =
    let population =
        population
        |> List.map (fun indiv -> indiv, fitness indiv)
        |> List.sort (fun (_, fit1) (_, fit2) -> compare fit1 fit2)
    in
    if finished population then
        population
    else
        population
        |> select population_size
        |> make_new_population breeding mutation population_size
        |> genetic fitness select breeding mutation finished population_size


let train network randomize fitness select breeding mutation finished population_size =
    let population = Utils.list_apply (fun _ -> copy_network network) population_size in
    List.iter randomize population;
    genetic fitness select breeding mutation finished population_size population

