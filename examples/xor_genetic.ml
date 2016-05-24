
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

    (** Here we make a new multi layered network with two inputs, four hidden neurons and one output. *)
    let network, _ = make_layered_network [2; 4; 1] in
    (** We call the train function from the Genetic module. This one allows to train a neural network by using
       a genetic algorithm. Each of its arguments is a function called by the algorithm. *)
    let population =
        train network
            (** The genetic algorithm use a population of network copies. So, before starting the genetic
               algorithm, the function below is call on each individual in order to randomize the population. *)
            Randomizer.weights_randomizer
            (** Below the fitness function use to know which individual is better that another one. *)
            (Fitness.greatest_error trainset)
            (** During the selection step, the training algorithm will call this function. This one is very
               simple. It keeps only the half population (pure elitism: only the best ones). *)
            Selection.simple_select
            (** For this example, we use a simple one point crossover. *)
            Breeding.one_point_crossover
            (** Each weight of children have 0.3 chance to be mutated: a simple small variation. *)
            (Mutation.weights_random_mutation 0.3)
            (** This function is called to make a new population. *)
            Population.make_new_population
            (** At each step, this function is called. If this one return true, the genetic algorithm
               continues. Otherwise, it stops and return the population. *)
            (debug (Finished.finished 0.0000001))
            (** Size of the population. *)
            100
    in
    (** get the best individual of the population. *)
    let best, _    = List.hd population in

    Printf.printf "XOR function computed by the best individual:\n";
    List.iter
        (fun (inputs, target) ->
            let _, result  = List.hd (feedforward best [0; 1] inputs) in
            let [in1; in2] = inputs in
            Printf.printf "%f ^ %f = %f (target: %f)\n" in1 in2 result target)
        trainset

end
