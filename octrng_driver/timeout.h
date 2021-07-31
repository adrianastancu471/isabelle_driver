#ifndef TIMEOUT_H
#define TIMEOUT_H
#define MAX_QUEUE 100

static unsigned long timer;
static unsigned int running_tasks;
static unsigned int current_task;


typedef struct {
	int timeout;
	unsigned long start;
	/** MODIFIES: rand_value rng_regs timer */
	void (*timeout_fun)(void);
} Task;

Task queue[MAX_QUEUE];

void add_task(void(*t_fun)(void), int t);

void timeout_add_sec(Task* t, unsigned long sec);
void timeout_add_msec(Task* t, unsigned long msec);

void timeout_set(Task* t, void(*f)(void));

unsigned long get_time(void);
void idle(void);
int get_running_tasks(void);
void run_task(int task_id);

#endif