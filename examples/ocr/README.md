Optical character recognition
=============================

Here is a simple example of an OCR. This one uses the backpropagation algorithm provided in the library.

**Warning :** the code is ugly (only this one? hihihi) and it is not yet finished.


How to compile it
=================

```
ocamlbuild -use-ocamlfind -pkgs str,neural-network ocr.native
```

How to run it
=============

Before running the program, you have to download the dataset: https://archive.ics.uci.edu/ml/machine-learning-databases/semeion/semeion.data .
This one contains 1593 handwritten digits from around 80 persons (for more information, please visit: https://archive.ics.uci.edu/ml/datasets/Semeion+Handwritten+Digit).


