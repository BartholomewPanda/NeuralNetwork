
type neuron =
    {
        mutable output  : float;
        mutable error   : float;
        mutable inputs  : int list;
        mutable outputs : int list;
        weights         : (int, float) Hashtbl.t;
    }

type network =
    {
        neurons         : (int, neuron) Hashtbl.t;
        mutable next_id : int;
    }

module IntSet = Set.Make
    (struct
        type t = int
        let compare = compare
    end)


(** Make a new neuron.
   @return a neuron
 *)
let make_neuron () =
    {output = 0.0; error = 0.0; inputs = []; outputs = []; weights = Hashtbl.create 100}

(** Make a new empty network.
   @return a network
 *)
let make_network () =
    {neurons = Hashtbl.create 10; next_id = 0}

(** Get a neuron by its id.
   @return a neuron
 *)
let get_neuron network =
    Hashtbl.find network.neurons

(** Get several neurons by its id.
   @return several neurons
 *)
let get_neurons network =
    List.map (get_neuron network)

(** Get the weight of the connection between two neurons (src->dst).
   @param dst the destination of the connection
   @param src the source of the connection
   @return the weight of the src->dst connection
 *)
let get_weight network dst src =
    Hashtbl.find (get_neuron network dst).weights src

(** Get the id of all input neurons.
   @return the id of each input neurons of the id neuron
 *)
let get_inputs network id =
    (Hashtbl.find network.neurons id).inputs

(** Get the id of all output neurons.
   @return the id of each output neurons of the id neuron
 *)
let get_outputs network id =
    (Hashtbl.find network.neurons id).outputs

(** Make a new neuron and insert it into the network.
   @return the id of the new neuron
 *)
let add_neuron network =
    let id = network.next_id in
    Hashtbl.add network.neurons id (make_neuron ());
    network.next_id <- network.next_id + 1;
    id

(** Add an unidirectional connection between two neurons.
   @param src the id of the src neuron
   @param dst the id of the dst neuron
 *)
let connect network src dst =
    let src_neuron = get_neuron network src in
    let dst_neuron = get_neuron network dst in
    dst_neuron.inputs <- src :: dst_neuron.inputs;
    src_neuron.outputs <- dst :: src_neuron.outputs;
    Hashtbl.replace dst_neuron.weights src (Utils.random_uniform 1.0)


(** Compute the output of a neuron.
   @param id the id of the neuron
   @return the computed value by the neuron
 *)
let execute network id =
    let neuron = get_neuron network id in
    neuron.output <-
        neuron.inputs
        |> List.map (fun src -> (get_neuron network src).output *. (Hashtbl.find neuron.weights src))
        |> List.fold_left (+.) 0.0
        |> Utils.sigmoid;
    neuron.output

(** Get the id of neurons of the next layer.
   @return the id of each neuron of the next layer
 *)
let next_layer network neurons =
    List.map (get_outputs network) neurons
    |> List.flatten
    |> IntSet.of_list
    |> IntSet.elements

(** Get the id of the neurons of the previous layer.
   @return the id of each neuron of the previous layer
 *)
let previous_layer network neurons =
    List.map (get_inputs network) neurons
    |> List.flatten
    |> IntSet.of_list
    |> IntSet.elements

(** Compute the output of a neural network.
   @param network
   @param inputs is a list of tuple (input neuron id, value of the neuron)
   @return a list that contains one or more tuple (output neuron id, value of the neuron)
 *)
let feedforward network inputs values =
    (* TODO: protection against loop for recurrent neural network *)
    let rec feedforward output = function
        | []    -> output
        | layer -> feedforward (List.map (fun id -> (id, execute network id)) layer) (next_layer network layer)
    in
    (* set the output value of each input neurons *)
    List.iter2 (fun id v -> (get_neuron network id).output <- v) inputs values;
    feedforward [] (next_layer network inputs)

(** Compute the error of a neuron for the backpropagation algorithm. *)
let compute_error network id =
    let neuron  = get_neuron network id in
    neuron.error <-
        neuron.outputs
        |> List.map (fun dst -> (get_weight network dst id) *. (get_neuron network dst).error)
        |> List.fold_left (+.) 0.0

(** Backpropagation algorithm.
   @param network
   @param outputs neurons of the output layer
   @param target the expected output
 *)
let backpropagation network outputs target =
    (* TODO: protection against loop for recurrent neural network *)
    let rec backpropagation l =
        let l = List.filter (fun id -> get_inputs network id <> []) l in
        match l with
        | []    -> ()
        | layer -> List.iter (compute_error network) layer;
                   backpropagation (previous_layer network layer)
    in
    (* set the output error *)
    List.iter2 (fun n t -> n.error <- t -. n.output) (get_neurons network outputs) target;
    backpropagation (previous_layer network outputs)

(** Update the weight of each neuron. *)
let update network =
    let new_weight neuron id src =
        let weight = Hashtbl.find neuron.weights src in
        let output = (get_neuron network src).output in
        weight +. (0.8 *. neuron.error *. Utils.sigmoid' neuron.output) *. output
    in
    let update_weights id neuron =
        List.iter (fun src -> Hashtbl.replace neuron.weights src (new_weight neuron id src)) neuron.inputs
    in
    Hashtbl.iter update_weights network.neurons

(** Train a network by using the backpropagation algorithm.
   @param trainset a list of training example [(inputs, expected output); ...]
   @in_layer a list of the input neurons ids
   @out_layer a list of the output neurons ids *)
let train network trainset in_layer out_layer =
    let train (inputs, outputs) =
        ignore (feedforward network in_layer inputs);
        backpropagation network out_layer outputs;
        update network
    in
    List.iter train trainset



(** Helper function that allows to make several new neurons and insert them
    into the network.
   @return a list of the neuron ids
 *)
let add_neurons network nb =
    let rec make nb result =
        if nb <= 0 then result
        else make (nb - 1) (add_neuron network :: result)
    in
    make nb []

(** Helper function that make new layers and interconnects each layer.
   @param layers a int list
   @return a list of the id of each new neurons
 *)
let add_layers network layers =
    let rec connect_layers = function
        | l1 :: (l2 :: tl as next_layers) ->
            List.iter (fun id1 -> List.iter (fun id2 -> connect network id1 id2) l2) l1;
            connect_layers next_layers
        | _ -> ()
    in
    connect_layers (List.map (add_neurons network) layers)

(** Helper function that make a new layered network.
   @param layers the description of each layer (the number of neuron)
   @return a new initialized network
 *)
let make_layered_network layers =
    let network = make_network () in
    add_layers network layers;
    network

