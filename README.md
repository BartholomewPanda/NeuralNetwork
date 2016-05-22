# NeuralNetwork

NeuralNetwork is a simple OCaml library that I'm coding for the fun and to experiment some things. This one is not made to be fast or optimized! It allows to easily make network with different "topology": simple feedforward network, reccurent network, etc.


# How to build it

Just:

```bash
make && make install
```

# How to use it

## Make a new network by hand

The library allows you to make a new network, add new neurons inside and connect them by hand:

```ocaml
open NeuralNetwork

let network = make_network () in

(* Make and insert 3 new neurons. *)
let n1 = add_neuron network in
let n2 = add_neuron network in
let n3 = add_neuron network in

(* Connect the two first neurons to the last one. *)
connect network n1 n3;
connect network n2 n3;
```


## Make a new network and add layers

It is possible to add several layer to an existing neural network. For example, if we want to add 3 layers that have respectively 2, 4 and 1 neurons:

```ocaml
add_layers network [2; 4; 1]
```

Each neurons of the first layer will be automatically connected to the neurons of the second layer. The same for the neurons of the second layer and the last one.

Warning: the granularity of this library is the neuron, nothing else! So, a layer has no concrete existence in the network. In fact, this changes nothing.


## Make a new layered network

Rather than make a new network and call the function `add_layers`, you can call `make_layered_network`:

```ocaml
make_layered_network [2; 4; 1]
```

## How to use the backpropagation algorithm

To train your network, the library provides a simple implementation of the backpropagation algorithm in the module Backpropagation. Here is an example:

```ocaml
for i = 0 to 500 do
    Backpropagation.train network [[0.0; 0.0], [0.0]; [1.0; 1.0], [1.0]] [n1; n2] [n3]
done
```

The second argument is the trainingset. Its means that when n1 and n2 are 0.0, n3 must be 0.0. Otherwise, if n1 and n2 are 1.0, n3 must be 1.0.

The third argument is a list of the input neurons.

The fourth argument is a list of the output neurons (only one in the example).


## How to run the network on inputs

You can run the network on an input vector by using the `feedforward` function:

```ocaml
feedforward network [nx; ny; nz] [0.0; 1.0; 2.0]
```

The second argument is a list of the input neurons.

The third argument is a list of the value of each input neurons.

This function returns a list of tuple. These tuple contains two elements: the output neuron and its output value. For example, if we have two outputs neurons in the network (no1 and no2), the return value of the `feedforward` function might be:

```ocaml
[(no1, 3.45); (no2, 6.12)]
```


# Examples

For more example, you can go in the *examples* directory ;).


# Issues

- the library doesn't work on a simple perceptron (yeah...)
- a ton of issues


# In progress...

- try to make a generic genetic algorithm to train the network: you can see the code on the git branch *genetic*


# TODO

- look the code, work and remove the TODO in the code
- add oasis to easily make the project
- add new examples
- batch backpropagation
- give the possibility to use another function than sigmoid for each neuron
- optimize the code
- remove the `input` field of the neuron type (the weights hashtbl already store them)
- (insert many things here)


