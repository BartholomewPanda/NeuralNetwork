Details
=======

The `xor.ml` example shows how to make a multi layered neural network and how to train it with the backpropagation algorithm.

The `xor_genetic.ml` shows how to train a neural network by using a genetic algorithm.


How to compile these examples
=============================

In order to compile these examples, install the library and use ocamlbuild:

```
ocamlbuild -use-ocamlfind -pkg neural-network xor_genetic.native
```

