
(** This module implements many common genetic operators. *)


open NeuralNetwork


(** Genetic operators to randomize individuals. *)
module Randomizer =
struct

    (** Randomize each weights of the network. *)
    let weights_randomizer indiv =
        let randomize_weights neuron =
            Hashtbl.iter
                (fun id _ -> Hashtbl.replace neuron.weights id (Utils.random_uniform 1.0))
                neuron.weights
        in
        Hashtbl.iter (fun _ n -> randomize_weights n) indiv.neurons

    (** TODO: topology randomizer, topology + weights randomizer *)

end


(** Genetic operators to compute the fitness of individuals. *)
module Fitness =
struct

    (** Apply the trainset, compute the errors for each entry of the trainset
       and return the greatest one. *)
    let greatest_error trainset indiv =
        trainset
        |> List.map (fun (inputs, target) ->
            let _, result = List.hd (feedforward indiv [0; 1] inputs) in
            abs_float (result -. target))
        |> List.sort (fun f1 f2 -> compare f1 f2 * -1)
        |> List.hd

    (** Return the sum of the errors. *)
    let error_sum trainset indiv =
        List.fold_left
            (fun acc (inputs, target) ->
                let _, result = List.hd (feedforward indiv [0; 1] inputs) in
                abs_float (result -. target) +. acc)
            trainset

end


(** Genetic operators to select individuals for the next population. *)
module Selection =
struct

    (** Get the half of the best individuals of the population. *)
    let simple_select population_size population =
        population
        |> Utils.list_take (population_size / 2)
        |> List.map (fun (indiv, _) -> indiv)

    (** TODO: tournament selection, fitness proportionate selection *)

end


(** Genetic operators for the breeding. *)
module Breeding =
struct

    (** Simple one point crossover between two individuals. *)
    let one_point_crossover mother father =
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
        [c1; c2]

    (** TODO: cut and splice, uniform crossover *)

end


(** Genetic operators for mutations. *)
module Mutation =
struct

    (** Random mutations on the weights of the network.
       @param rate the rate of mutation *)
    let weights_random_mutation rate indiv =
        let mutate_weights neuron input value =
            if Random.float 1.0 <= rate then
                Hashtbl.replace neuron.weights input (Utils.random_uniform 10.0 +. value)
        in
        let mutate_neuron neuron =
            Hashtbl.iter (mutate_weights neuron) neuron.weights
        in
        Hashtbl.iter (fun _ n -> mutate_neuron n) indiv.neurons

    (** TODO: random topology mutation, weights + topology mutation *)

end

(** Collection of "finished" function. *)
module Finished =
struct

    (** Stop the genetic algorithm when a limit is reached. *)
    let finished limit population =
        let _, fitness = List.hd population in
        fitness <= limit

end

module Population =
struct

    (** Just call the breeding function and add children + parents in the new population. *)
    let make_new_population breeding mutation population_size population =
        let rec make parents children nb =
            if nb < population_size then
                match parents with
                    | mother :: father :: tl ->
                        let new_children = breeding mother father in
                        List.iter mutation new_children;
                        make tl ((mother :: father :: new_children) @ children) (nb + 4)
                    | _ -> children
            else
                children
        in
        make population [] 0

    (** TODO: implementation of other new population making strategy *)

end


let rec genetic fitness select breeding mutation make_population finished population_size population =
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
        |> make_population breeding mutation population_size
        |> genetic fitness select breeding mutation make_population finished population_size


let train network randomize fitness select breeding mutation make_population finished population_size =
    let population = Utils.list_apply (fun _ -> copy_network network) population_size in
    List.iter randomize population;
    genetic fitness select breeding mutation make_population finished population_size population


