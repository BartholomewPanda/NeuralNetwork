
type neuron

type network

(** Make a new empty network. *)
val make_network : unit -> network

(** Add a new neuron in the network. *)
val add_neuron : network -> int
(** The new neuron has no default connections, weights, etc. *)

(** Make a new unidirectionnal connection between two neurons. *)
val connect : network -> int -> int -> unit
(** [connect network 0 2] will make a new connection from the neuron 0 to the neuron 2 *)

(** Run the network on a input vector. *)
val feedforward : network -> int list -> float list -> (int * float) list
(** [feedforward network [0, 1] [1.0; 13.52]] will set the inputs neurons 0 and 1 to the values
   1.0 and 13.52 and run the rest of the network. I'm wondering if I will keep these two last
   arguments or if I will change to something like [feedforward network [(0, 1.0); (1, 13.52)]]. *)

(** Train the neural network with the backpropagation algorithm *)
val train : network -> (float list * float list) list -> int list -> int list -> unit
(** [train [(inputs, expected outputs); ...] input_neuron_ids output_neurons_ids] will train the network
   by using the backpropagation algorithm in order to aproximate the expected outputs.
   WARNING: the order of the inputs of the trainset and the ids of the input_neuron_ids is important!*)

(* helper functions *)

(** Add several new neuron to a network. *)
val add_neurons : network -> int -> int list

(** Add several layers to a network. *)
val add_layers : network -> int list -> unit
(** A layer is just a collection of neurons. It doesn't really exist in the core of this
   library. [add_layers network [2; 4; 1]] will add 3 layers into the network. The first will
   contains 2 neurons, the second 4 and the last 1. The 2 neurons of the first layer will between
   connected to the 4 neurons of the second layer. Similarly for the second layer and the last one. *)

(** Make a new network and add new neurons inside *)
val make_layered_network : int list -> network
(** This function is equivalent to call [make_network ()] then [add_layers [...]]. *)

