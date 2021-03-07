theory Timeout
  imports "AutoCorres.AutoCorres"
begin
external_file "timeout.c" 
install_C_file "timeout.c" 

autocorres [
  heap_abs_syntax
] "timeout.c"

context timeout begin

thm timeout_add_sec'_def
thm timeout_add_msec'_def
thm timeout_set'_def

lemma timeout_add_no_overflow: "\<lbrace>\<lambda>s. timer_'' s = a \<and> a + b > a\<rbrace> 
  timeout_add_sec' b 
  \<lbrace>\<lambda>_s. timer_'' s = a + b \<rbrace>" 
    unfolding timeout_add_sec'_def
    apply wp 
    apply auto
  done

end