
## Octrng driver verification

This folder contains driver adaptation for octrng driver and some dummy functions to simulate tasks timeout.

Each .c file has a corresponding .thy file with Isabelle representation of C code.

### Repository Overview

  * `octrng.c` and `octrng.h`: driver adaptation for C-to-Isabelle parser
  * `Octrng.thy`: theory file containing lemmas for octrng.c driver functions
  * `timeout.c` and `timeout.h`: dummy driver to simulate a timer for running delayed tasks
  * `Timeout.thy`: theory file containing lemmas for timeout.c driver functions
  * `run_tasks.c`: main loop
  * `Run_task.thy`: TODO

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