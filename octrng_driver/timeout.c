
static unsigned long long timer;
void(*timeout_fun)(void);

void 
timeout_add_sec(unsigned long long sec)
{
  if(timer+sec > timer)
    timer += sec;
  else
    timer = sec;
  //timeout_fun();
}


void 
timeout_add_msec(unsigned long long msec)
{
  unsigned long long sec = msec*1000;
  timeout_add_sec(sec);
  //timeout_fun();
}


void 
timeout_set(void(*f)(void))
{
  timeout_fun = f;
}