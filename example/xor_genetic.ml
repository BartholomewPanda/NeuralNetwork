
open NeuralNetwork
open Genetic


let trainset =
    [
        [0.0; 0.0], 0.0;
        [0.0; 1.0], 1.0;
        [1.0; 0.0], 1.0;
        [1.0; 1.0], 0.0
    ]

(* TODO: find an other way and remove this ugly hack... *)
let debug f population =
    let _, fitness = List.hd population in
    Printf.printf "fitness: %f\n" fitness;
    flush stdout;
    f population

let test =
begin
    Random.self_init ();

    let network    = make_layered_network [2; 4; 1] in
    let population =
        train network
            Randomizer.weights_randomizer
            (Fitness.simple_fitness trainset)
            Selection.simple_select
            Breeding.one_point_crossover
            (Mutation.weights_random_mutation 0.3)
            (debug (Finished.finished 0.000001))
            100
    in
    let best, _    = List.hd population in

    Printf.printf "XOR function computed by the best individual:\n";
    List.iter
        (fun (inputs, target) ->
            let _, result  = List.hd (feedforward best [0; 1] inputs) in
            let [in1; in2] = inputs in
            Printf.printf "%f ^ %f = %f (target: %f)\n" in1 in2 result target)
        trainset

end
