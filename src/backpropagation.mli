
(** Train the neural network with the backpropagation algorithm *)
val train : NeuralNetwork.network -> (float list * float list) list -> int list -> int list -> float -> unit
(** [train [(inputs, expected outputs); ...] input_neuron_ids output_neurons_ids 0.8] will train the network
 *    by using the backpropagation algorithm in order to aproximate the expected outputs.
 *       WARNING: the order of the inputs of the trainset and the ids of the input_neuron_ids is important!*)

