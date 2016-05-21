
open NeuralNetwork
open Genetic


let trainset =
    [
        [0.0; 0.0], 0.0;
        [0.0; 1.0], 1.0;
        [1.0; 0.0], 1.0;
        [1.0; 1.0], 0.0
    ]

let randomize indiv =
    let randomize_weights neuron =
        Hashtbl.iter (fun id _ -> Hashtbl.replace neuron.weights id (Utils.random_uniform 1.0)) neuron.weights
    in
    Hashtbl.iter (fun _ n -> randomize_weights n) indiv.neurons

let fitness indiv =
    trainset
    |> List.map (fun (inputs, target) ->
        let _, result = List.hd (feedforward indiv [0; 1] inputs) in
        abs_float (result -. target))
    |> List.sort (fun f1 f2 -> compare f1 f2 * -1)
    |> List.hd

let select population_size population =
    population
    |> Utils.list_take (population_size / 2)
    |> List.map (fun (indiv, _) -> indiv)

let breeding mother father =
    let c1, c2 = copy_network mother, copy_network father in
    let point  = Random.int (Hashtbl.length mother.neurons) in
    let rec switch_neurons i =
        if i < point then
        begin
            Hashtbl.replace c1.neurons i (Hashtbl.find father.neurons i);
            Hashtbl.replace c2.neurons i (Hashtbl.find mother.neurons i);
        end
    in
    switch_neurons 0;
    (c1, c2)

let mutation indiv =
    let mutate_weights neuron input value =
        if Random.int 3 = 0 then
            Hashtbl.replace neuron.weights input (Utils.random_uniform 10.0 +. value)
    in
    let mutate_neuron neuron =
        Hashtbl.iter (mutate_weights neuron) neuron.weights
    in
    Hashtbl.iter (fun _ n -> mutate_neuron n) indiv.neurons

let finished population =
    let indiv, fitness = List.hd population in
    Printf.printf "fitness: %f\n" fitness;
    flush stdout;
    fitness < 0.01


let test =
begin
    Random.self_init ();

    let network    = make_layered_network [2; 4; 1] in
    let population = train network randomize fitness select breeding mutation finished 100 in
    let best, _    = List.hd population in

    Printf.printf "XOR function computed by the best individual:\n";
    List.iter
        (fun (inputs, target) ->
            let _, result  = List.hd (feedforward best [0; 1] inputs) in
            let [in1; in2] = inputs in
            Printf.printf "%f ^ %f = %f (target: %f)\n" in1 in2 result target)
        trainset

end
