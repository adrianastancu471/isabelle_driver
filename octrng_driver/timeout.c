
#include "timeout.h"

unsigned long 
get_time(void)
{
	return timer;
}

void 
idle(void)
{
	timer++;
}

int 
get_running_tasks(void)
{
	return running_tasks;
}

void 
add_task(void(*t_fun)(void), int t)
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

/**
  DONT_TRANSLATE
  */
void 
run_task(int task_id)
{
	queue[task_id].timeout_fun();
	queue[task_id].timeout_fun = 0;
	running_tasks--;
}

void 
timeout_add_sec(Task* t, unsigned long  sec)
{
	t->timeout += sec;
}


void 
timeout_add_msec(Task* t, unsigned long  msec)
{
	unsigned long  sec = msec * 1000;
	timeout_add_sec(t, sec);
}


void 
timeout_set(Task* t, void(*f)(void))
{
	t->timeout_fun = f;
}

