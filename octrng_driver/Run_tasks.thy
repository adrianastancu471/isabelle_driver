theory Run_tasks
imports
  "CParser.CTranslation"
  "AutoCorres.AutoCorres"
begin

declare [[populate_globals=true]]

(*external_file "timeout.c"
install_C_file "timeout.c"

autocorres [
  heap_abs_syntax,
  function_name_suffix="'",
  lifted_globals_field_suffix="_''" ] "timeout.c"

context timeout begin
thm timeout_add_msec_body_def
thm timeout_add_msec'_def
end*)

external_file "run_tasks.c"
install_C_file "run_tasks.c" 
autocorres [
  heap_abs_syntax,
  function_name_suffix="'",
  lifted_globals_field_suffix="_''",
  ts_force nondet = main 
 ] "run_tasks.c"

context run_tasks begin

definition "TIMEOUT \<equiv> 100 :: word64"
definition "MAX_QUEUE \<equiv> 100 :: word32"
definition "OCTRNG_ENTROPY_REG \<equiv> 0 :: word64"
definition "OCTRNG_CONTROL_ADDR \<equiv> 0x0001180040000000 :: word64"
definition "OCTRNG_RESET  \<equiv> (1 << 3) :: word32"
definition "OCTRNG_ENABLE_OUTPUT \<equiv> (1 << 1) :: word32"
definition "OCTRNG_ENABLE_ENTROPY  \<equiv> (1 << 0) :: word32"

definition "RNG_ATTACH \<equiv> 1 :: word32"
definition "RNG_RND \<equiv> 2 :: word32"
definition "IDLE \<equiv> 3 :: word32"

(* Timeout functions *)
thm get_time'_def
thm idle'_def
thm add_task'_def
thm get_running_tasks'_def
thm run_task'_def
thm call_function'_def
thm timeout_add_msec_body_def
thm timeout_add_msec'_def

(* Octrng functions *)
thm set_register'_def
thm get_register'_def
thm octrng_attach'_def
thm octrng_rnd'_def

(* Main function *)
thm main'_def



(* Timeout functions *)
(* get_time is correct *)
lemma get_time_correct [simp]: "\<lbrace>\<lambda>s. timer_'' s = a  \<rbrace> 
  get_time' 
  \<lbrace>\<lambda>r s.  r = a \<rbrace>!"
    unfolding get_time'_def
 oops 




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
    apply (clarsimp simp:fun_upd_apply)
    apply wp
    unfolding OCTRNG_ENTROPY_REG_def OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    unfolding get_time'_def
    apply auto
    done

(* octrng_attach sets registers *)
  thm octrng_attach'_def
lemma octrng_attach [simp]: "\<lbrace> \<lambda>s. True\<rbrace>
  octrng_attach' 
  \<lbrace> \<lambda>_s. control_addr_C (rng_regs_'' s) && (OCTRNG_ENABLE_OUTPUT || OCTRNG_ENABLE_ENTROPY) \<noteq> 0 \<rbrace> "
    unfolding octrng_attach'_def 
    unfolding get_register'_def set_register'_def
    unfolding add_task'_def
    apply (clarsimp simp:fun_upd_apply)
    apply wp
    apply auto
    unfolding OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    apply auto
  done


(* octrng_rnd gets current time *)
thm octrng_rnd'_def
lemma octrng_rnd: "
  \<lbrace> \<lambda>s. timer_'' s = a \<and> current_task_'' s <  MAX_QUEUE\<rbrace> 
  octrng_rnd' 
  \<lbrace> \<lambda>_s. rand_value_'' s = a\<rbrace>!"
  unfolding octrng_rnd'_def
  unfolding get_register'_def add_task'_def
  unfolding get_time'_def
  unfolding MAX_QUEUE_def
    apply (clarsimp simp:fun_upd_apply)
    apply wp
  apply auto
 (* additional lemma if registers not set \<rightarrow> timer_'' = 0 *)
  oops



(* Main function *)
lemma main_function: "\<lbrace>\<lambda>s. True\<rbrace> main' \<lbrace>\<lambda>_s. timer_'' s = 100\<rbrace>"
  unfolding main'_def get_time'_def add_task'_def idle'_def
    apply (clarsimp simp:fun_upd_apply)
  apply (subst whileLoop_add_inv
   [where I="\<lambda>_s.  0 \<le> timer_'' s \<and> timer_'' s \<le> TIMEOUT"
      and M="\<lambda>s. TIMEOUT - timer_'' s"])
  unfolding TIMEOUT_def 

 
  apply wp
    apply auto
 (* apply (subst whileLoop_add_inv
    [where I="\<lambda>(i') s. 0 \<le> i' \<and> i' \<le> 100"
        and M="\<lambda>((i'), s). MAX_QUEUE - i'"])*)
  done



end
