
(* Here is a simple example of the XOR learning by using the backpropagation algorithm *)


open NeuralNetwork
open Backpropagation


(* The trainset contains a list of (inputs, expected output) of the XOR function *)
let trainset =
    [
        [0.0; 0.0], [0.0];
        [0.0; 1.0], [0.0];
        [1.0; 0.0], [0.0];
        [1.0; 1.0], [1.0]
    ]


let test =
begin
    Random.init 24;

    (* We use the make_layered_network helper function that allows to easily make a multi layered network *)
    let network = make_layered_network [2; 4; 1] in
    (* The network will contain 2 input neurons (the neurons 0 and 1) and 1 output neuron (the neuron 6) *)

    (* LEARN MY LITTLE BRAIN! *)
    for i = 0 to 500 do
        (* [0; 1] are the id of input neurons and [6] the id of the output neuron *)
        train network trainset [0; 1] [6] 0.8
    done;

    (* Get the neural network results of each combinaison of inputs. Remember that the result is a list of
     * tuple (id of the output neuron, value of the neuron). Because there is only one output neuron, we get
     * the head of the list. And, because we don't need the id of the output neuron, we ignore it.
     * (feedforward network [id of the input neurons] [values of each input neurons])
     *)
    let _, result_0_0 = List.hd (feedforward network [0; 1] [0.0; 0.0]) in
    let _, result_1_0 = List.hd (feedforward network [0; 1] [1.0; 0.0]) in
    let _, result_0_1 = List.hd (feedforward network [0; 1] [0.0; 1.0]) in
    let _, result_1_1 = List.hd (feedforward network [0; 1] [1.0; 1.0]) in

    (* Display the results. *)
    Printf.printf "XOR function:\n";
    Printf.printf "0 ^ 0 = %f\n" result_0_0;
    Printf.printf "1 ^ 0 = %f\n" result_1_0;
    Printf.printf "0 ^ 1 = %f\n" result_0_1;
    Printf.printf "1 ^ 1 = %f\n" result_1_1;

end
