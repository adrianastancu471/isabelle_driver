theory Run_Tasks
  imports 
    "AutoCorres.AutoCorres" 
begin

declare [[quick_and_dirty = true]]
declare [[sorry_modifies_proofs = true]]

external_file "run_tasks.c_pp"
install_C_file "run_tasks.c_pp"

declare [[quick_and_dirty = false]]
-r
autocorres [
  heap_abs_syntax,
  function_name_suffix="'",
  lifted_globals_field_suffix="_''",
  ts_force nondet = main 
 ] "run_tasks.c_pp"

context run_tasks begin

definition "TIMEOUT \<equiv> 100 :: word32"
definition "MAX_QUEUE \<equiv> 100 :: word32"
definition "OCTRNG_ENTROPY_REG \<equiv> 0 :: word64"
definition "OCTRNG_CONTROL_ADDR \<equiv> 0x0001180040000000 :: word64"
definition "OCTRNG_RESET  \<equiv> (1 << 3) :: word32"
definition "OCTRNG_ENABLE_OUTPUT \<equiv> (1 << 1) :: word32"
definition "OCTRNG_ENABLE_ENTROPY  \<equiv> (1 << 0) :: word32"

(* Timeout functions *)
thm get_time'_def
thm idle'_def
thm add_task'_def
thm run_task'_def
thm timeout_add_sec'_def
thm timeout_add_msec'_def
thm get_running_tasks'_def

(* Octrng functions *)
thm set_register'_def
thm get_register'_def
thm octrng_attach'_def
thm octrng_rnd'_def

(* Main function *)
thm main'_def

(* Timeout functions *)

(* get_time is correct *)
thm get_time'_def
lemma get_time_correct [simp]: "get_time' \<equiv> timer_''"
  unfolding get_time'_def
  apply auto 
  done

(* idle increases time *)

lemma idle_increases [simp]: 
 "\<lbrace> \<lambda>s. timer_'' s = a \<rbrace> 
  idle'
 \<lbrace>\<lambda>_s. timer_'' s = a + 1\<rbrace> " 
  unfolding idle'_def
  apply wp 
  apply auto 
  done

(* Octrng functions *)

(* set_register with global struct *)
lemma set_reg_control_struct [simp]: "\<lbrace> \<lambda>s. True \<rbrace>
  set_register' OCTRNG_CONTROL_ADDR a 
  \<lbrace>\<lambda>_s. control_addr_C (rng_regs_'' s) = a \<rbrace>!"
    unfolding set_register'_def
    unfolding condition_def
    unfolding OCTRNG_CONTROL_ADDR_def
    apply (clarsimp simp: fun_upd_apply)
    apply wp 
    apply auto 
  done 

(* get_register on OCTRNG_CONTROL_ADDR *)
lemma get_reg_control [simp]: "\<lbrace>\<lambda>s. control_addr_C (rng_regs_'' s) = a \<rbrace>
  get_register' OCTRNG_CONTROL_ADDR
  \<lbrace>\<lambda>r s. r = a \<rbrace>" 
    unfolding get_register'_def
    unfolding condition_def
    unfolding OCTRNG_CONTROL_ADDR_def
    apply auto 
    apply wp 
  done

(* get_register on OCTRNG_ENTROPY_REG *)
lemma get_reg_entropy [simp]: "\<lbrace>\<lambda>s. 
  control_addr_C (rng_regs_'' s) && OCTRNG_ENABLE_OUTPUT \<noteq> 0 \<and>
  control_addr_C (rng_regs_'' s) && OCTRNG_ENABLE_ENTROPY \<noteq> 0 \<and>
  timer_'' s = a \<rbrace>
  get_register' OCTRNG_ENTROPY_REG
  \<lbrace>\<lambda>r s. r = a \<rbrace>"
    unfolding get_register'_def
    apply wp
    unfolding OCTRNG_ENTROPY_REG_def OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    unfolding get_time'_def
    apply auto
    done

(* octrng_attach sets registers *)
  thm octrng_attach'_def

lemma octrng_attach : "\<lbrace> \<lambda>s. True\<rbrace>
    octrng_attach' 
  \<lbrace> \<lambda>_s. 
    control_addr_C (rng_regs_'' s) && OCTRNG_ENABLE_OUTPUT \<noteq> 0 \<and>
    control_addr_C (rng_regs_'' s) && OCTRNG_ENABLE_ENTROPY \<noteq> 0 \<rbrace> "
    unfolding octrng_attach'_def 
    unfolding get_register'_def set_register'_def
    unfolding add_task'_def
    apply wp
    apply auto
    unfolding OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    apply word_bitwise+
  done

thm octrng_rnd'_def

(* octrng_rnd gets current time *)
lemma octrng_rnd: 
 "\<lbrace> 
   \<lambda>s. timer_'' s = a \<and> 
   running_tasks_'' s < MAX_QUEUE \<and> 
   current_task_'' s < MAX_QUEUE \<and>
   control_addr_C (rng_regs_'' s) && 
                OCTRNG_ENABLE_OUTPUT \<noteq> 0 \<and>
   control_addr_C (rng_regs_'' s) && 
                OCTRNG_ENABLE_ENTROPY \<noteq> 0 
  \<rbrace> 
  octrng_rnd' 
  \<lbrace> \<lambda>_s. rand_value_'' s = a\<rbrace>!"
  unfolding octrng_rnd'_def
  unfolding get_register'_def add_task'_def
  unfolding get_time'_def
  unfolding MAX_QUEUE_def
  unfolding OCTRNG_ENABLE_OUTPUT_def 
  unfolding OCTRNG_ENABLE_ENTROPY_def
  apply (wp; auto)+
  done


definition
  timer_limits_inv :: "word32 \<Rightarrow> 's lifted_globals_scheme \<Rightarrow> bool"
where
  "timer_limits_inv a s \<equiv>  a = timer_'' s \<and> 0 \<le> timer_'' s \<and> timer_'' s \<le> TIMEOUT	"

definition
  timer_limits_measure :: "'a \<Rightarrow> 's lifted_globals_scheme \<Rightarrow> word32"
where
  "timer_limits_measure a s \<equiv> TIMEOUT - timer_'' s "

(* Main function *)
(* Constraints: 
 - main function runs until timer reaches TIMEOUT value
 
*)

lemma main_function: 
  "\<lbrace> \<lambda>s. timer_'' s = 0 \<and> running_tasks_'' s = 0 \<rbrace>
   main' 
   \<lbrace>\<lambda>_s. timer_'' s = TIMEOUT\<rbrace>!"

  unfolding main'_def get_time'_def add_task'_def idle'_def
  unfolding TIMEOUT_def 
  apply (subst whileLoop_add_inv 
   [where I="\<lambda>(j)s. timer_limits_inv j s"
      and M="\<lambda>(j, s). timer_limits_measure j s"])
  apply wp 
  unfolding timer_limits_inv_def
    apply auto
    unfolding TIMEOUT_def 
    apply unat_arith
  unfolding timer_limits_measure_def
  unfolding TIMEOUT_def
    apply auto
    apply unat_arith
      apply (wp; auto)+
  done

end