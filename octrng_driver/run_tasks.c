/*#include "timeout.c"
#include "octrng_simpl.c"*/

#define TIMEOUT 100
#define MAX_QUEUE 100

#define OCTRNG_ENTROPY_REG 0
#define OCTRNG_CONTROL_ADDR 0x0001180040000000ULL
#define OCTRNG_RESET  (1UL << 3)
#define OCTRNG_ENABLE_OUTPUT (1UL << 1)
#define OCTRNG_ENABLE_ENTROPY  (1UL << 0)

#define RNG_ATTACH 1
#define RNG_RND 2
#define IDLE 3

unsigned long rand_value;

static struct reg {
  unsigned long control_addr;
} rng_regs;

static unsigned long timer;
static unsigned int running_tasks;
static unsigned int current_task;

typedef struct {
	int timeout;
	unsigned long long start;
	int timeout_fun;
} Task;

Task queue[MAX_QUEUE];

unsigned long 
get_time(void)
{
	return timer;
}

void 
idle(void)
{
	timer+=1;
}

int 
get_running_tasks(void)
{
	return running_tasks;
}

void 
add_task(int t_fun, int t)
{
	if (running_tasks < MAX_QUEUE)
	{
		queue[current_task].start = get_time();
		queue[current_task].timeout = t;
		queue[current_task].timeout_fun = t_fun;
		running_tasks++;
		current_task = (current_task + 1) % MAX_QUEUE;
	}
}

void call_function(int fid);

void 
run_task(int task_id)
{
	call_function(queue[task_id].timeout_fun);
	queue[task_id].timeout_fun = 0;
	running_tasks--;
}

void 
timeout_add_sec(Task* t, unsigned long long sec)
{
	t->timeout += sec;
}

void 
timeout_add_msec(Task* t, unsigned long long msec)
{
	unsigned long long sec = msec * 1000;
	timeout_add_sec(t, sec);
}

static void 
set_register(unsigned long long reg, unsigned long  value) 
{
  switch(reg) {
    case OCTRNG_CONTROL_ADDR:
      rng_regs.control_addr = value;
      break;
    default:
      rng_regs.control_addr = 0;                   
      break;
  }
}

static unsigned long 
get_register(unsigned long long reg) 
{
  switch(reg) {
    case OCTRNG_ENTROPY_REG:
      if ((rng_regs.control_addr&OCTRNG_ENABLE_OUTPUT) &&
        (rng_regs.control_addr&OCTRNG_ENABLE_ENTROPY))
         return get_time();
      break;
    case OCTRNG_CONTROL_ADDR:
      return rng_regs.control_addr;
    default:
      break;
  }
  return 0;
}

void
octrng_rnd(void)
{
	unsigned int value;

	rand_value = get_register(OCTRNG_ENTROPY_REG);
    add_task(RNG_RND, 10);
}

void
octrng_attach(void)
{
	unsigned long control_reg;

	control_reg = get_register(OCTRNG_CONTROL_ADDR);
	control_reg |= (OCTRNG_ENABLE_OUTPUT | OCTRNG_ENABLE_ENTROPY);
	set_register(OCTRNG_CONTROL_ADDR,control_reg);

  add_task(RNG_RND, 5);
}

void 
call_function(int fid)
{
	switch(fid)
	{
		case RNG_ATTACH:
			octrng_attach();
			break;
		case RNG_RND:
			octrng_rnd();
			break;
		case IDLE:
			idle();
			break;
		default:
			break;
	}
}

int main(void)
{
	int i;

	//add_task(RNG_ATTACH, 1);

	while (get_time() < TIMEOUT)
	{
		/*for (i = 0; i < MAX_QUEUE; i++)
		{
			if(queue[i].timeout_fun != 0 &&
				queue[i].timeout <= get_time() - queue[i].start)
			{
				run_task(i);
			}
		}*/
		idle();
	}
	return 0;
}