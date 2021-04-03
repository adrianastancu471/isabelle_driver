
## Octrng driver verification

This folder contains driver adaptation for octrng driver and some dummy functions to simulate tasks timeout.

Each .c file has a corresponding .thy file with Isabelle representation of C code.

### Repository Overview

  * `octrng.c` and `octrng.h`: driver adaptation for C-to-Isabelle parser
  * `timeout.c` and `timeout.h`: dummy driver to simulate a timer for running delayed tasks
  * `run_tasks.c`: main loop
  * `Run_Tasks.thy`: theory file containing proofs for all the included C files (the input file is run_tasks.c_pp, see bellow the command to generate it)

### Theory file structure

Each theory file has the following structure:

```Isabelle
theory Foo
  imports
    "AutoCorres.AutoCorres"
begin

(* Specify C file to be parsed *)
external_file "foo.c" 
(* Call C-to-Isabelle parser to obtain SIMPL representation of C functions *)
install_C_file "foo.c" 

(* Call AutoCorres on the parsed file *)
autocorres "foo.c"

context foo begin

(* By default C function bar() will be represented as: *)
thm bar_body_def

(* BY default C function bar() after AutoCorres simplification will be named: *)
thm bar'_def


(* Lemmas about functions found in foo.c *)

end
```


### Compile & Run C code

To compile the C implementation run the following commands from the `octrng_driver` directory:

	cmake .
	make
	./Octrng 

### Isabelle theory verification

To run Isabelle on a certain file just open the Jedit editor giving the theory file as argument.

First the preprocesor output file has to be prepared, it will be used as input file for C-to-Isabelle parser.
From the `octrng_driver` directory, run:

	gcc -DINCLUDE_C_FILES -E -CC run_tasks.c > run_tasks.c_pp


Then open Jedit with theory file, this have to be run from `verification\l4v` directory:

	./isabelle/bin/isabelle jedit -d . -l CParser /PATH_TO_REPOSITORY/octrng_driver/Run_Tasks.thy 
