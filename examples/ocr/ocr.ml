
open NeuralNetwork
open Backpropagation


let list_split l nb =
    let rec split head tail nb =
        if nb <= 0 then
            (List.rev head, tail)
        else
            match tail with
                | []       -> (List.rev head, tail)
                | hd :: tl -> split (hd :: head) tl (nb - 1)
    in
    split [] l nb


let load_trainset path =
    let ichan = open_in path in
    let rec parse result =
        match input_line ichan with
            | exception End_of_file -> result
            | line                  ->
                let data = Str.split (Str.regexp " ") line in
                let data = List.map float_of_string (List.filter ((<>) "\x0d") data) in
                parse (list_split data 256 :: result)
    in
    parse []


let test =
begin
    let network, [in_layer; _; out_layer] = make_layered_network [256; 10; 10] in

    Printf.printf "Trainset loading...\n";
    flush stdout;
    let trainset = load_trainset "./semeion.data" in

    Printf.printf "Training in progress...\n";
    flush stdout;
    for i = 0 to 10 do
        Printf.printf "  - iteration number %d\n" i;
        flush stdout;
        train network trainset in_layer out_layer 0.8
    done;

    List.iter
        (fun (inputs, outputs) ->
            let result = feedforward network in_layer inputs in
            Printf.printf "Expected output:\n";
            List.iter (Printf.printf "  - %f\n") outputs;
            Printf.printf "Outputs neurons:\n";
            List.iter (fun (id, out) -> Printf.printf "  - %d: %f\n" id out) result)
        trainset
end

