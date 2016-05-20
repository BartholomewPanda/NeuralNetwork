
open NeuralNetwork


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
let update network lr =
    let new_weight neuron id src =
        let weight = Hashtbl.find neuron.weights src in
        let output = (get_neuron network src).output in
        weight +. (lr *. neuron.error *. Utils.sigmoid' neuron.output) *. output
    in
    let update_weights id neuron =
        List.iter (fun src -> Hashtbl.replace neuron.weights src (new_weight neuron id src)) neuron.inputs
    in
    Hashtbl.iter update_weights network.neurons

(** Train a network by using the backpropagation algorithm.
   @param trainset a list of training example [(inputs, expected output); ...]
   @param in_layer a list of the input neurons ids
   @param out_layer a list of the output neurons ids
   @param lr the learning rate *)
let train network trainset in_layer out_layer lr =
    let train (inputs, outputs) =
        ignore (feedforward network in_layer inputs);
        backpropagation network out_layer outputs;
        update network lr
    in
    List.iter train trainset


