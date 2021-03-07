theory Octrng
  imports
    "Timeout" 
    "AutoCorres.AutoCorres"
    "HOL-Library.Boolean_Algebra"
begin

external_file "octrng_simpl.c" 
install_C_file "octrng_simpl.c" 

autocorres [
  heap_abs_syntax,
  function_name_suffix="'",
  lifted_globals_field_suffix="_''"
] "octrng_simpl.c"

context octrng_simpl begin

(* C-to-Isabelle *)
thm set_register_body_def
thm get_register_body_def

thm octrng_attach_body_def
thm octrng_rnd_body_def

(* AutoCorres *)
thm set_register'_def
thm get_register'_def

thm octrng_attach'_def
thm octrng_rnd'_def

(* register definitions *)
definition "OCTRNG_ENTROPY_REG \<equiv> 0 :: word64" 
definition "OCTRNG_CONTROL_ADDR \<equiv> 0x0001180040000000 :: word64"
definition "OCTRNG_RESET  \<equiv> (1 << 3) :: word32"
definition "OCTRNG_ENABLE_OUTPUT \<equiv> (1 << 1) :: word32"
definition "OCTRNG_ENABLE_ENTROPY  \<equiv> (1 << 0) :: word32"

find_theorems update 
find_theorems condition
find_theorems modify
thm fun_upd_apply


(* set_register with global var *)
lemma set_reg_control_variable [simp]: "\<lbrace> \<lambda>s. True \<rbrace>
  set_register' OCTRNG_CONTROL_ADDR a 
  \<lbrace>\<lambda>_s. control_addr2_'' s = a \<rbrace>!"
    unfolding set_register'_def
    unfolding condition_def
    unfolding OCTRNG_CONTROL_ADDR_def
    apply (clarsimp simp: fun_upd_apply)
    apply wp 
    apply auto 
  done


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
  control_addr_C (rng_regs_'' s) && OCTRNG_ENABLE_ENTROPY \<noteq> 0 \<rbrace>
  get_register' OCTRNG_ENTROPY_REG
  \<lbrace>\<lambda>r s. r = 13 \<rbrace>"
    unfolding get_register'_def
    apply (clarsimp simp:fun_upd_apply)
    apply wp
    unfolding OCTRNG_ENTROPY_REG_def OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    apply auto
  done


thm timeout_add_msec'_def

(* octrng_attach sets registers *)
lemma octrng_attach [simp]: "\<lbrace> \<lambda>s. True\<rbrace> 
  octrng_attach' 
  \<lbrace> \<lambda>_s. control_addr_C (rng_regs_'' s) && (OCTRNG_ENABLE_OUTPUT || OCTRNG_ENABLE_ENTROPY) \<noteq> 0 \<rbrace> "
    unfolding octrng_attach'_def
    unfolding octrng_rnd'_def
    unfolding get_register'_def
    unfolding set_register'_def
    unfolding timeout_add_msec'_def
    unfolding timeout_add_sec'_def
    apply (clarsimp simp:fun_upd_apply)
    apply wp
    apply auto
    unfolding OCTRNG_ENABLE_OUTPUT_def OCTRNG_ENABLE_ENTROPY_def
    apply auto
  done


(* octrng_rnd gets 13 *)
lemma octrng_rnd: "\<lbrace> \<lambda>s. True \<rbrace> octrng_rnd' \<lbrace> \<lambda>_s. rand_value_'' s = 13 \<rbrace>!"
  unfolding octrng_rnd'_def
  unfolding octrng_attach'_def
  unfolding get_register'_def
  unfolding set_register'_def
  unfolding timeout_add_msec'_def
  unfolding timeout_add_sec'_def
    apply (clarsimp simp:fun_upd_apply)
    apply wp
    apply auto
    apply word_bitwise
    apply word_bitwise
  done

end