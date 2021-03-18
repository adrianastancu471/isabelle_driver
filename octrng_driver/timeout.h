#ifndef TIMEOUT_H
#define TIMEOUT_H

#define MAX_QUEUE 100

typedef struct {
	int timeout;
	unsigned long long start;
	void(*timeout_fun)(void);
} Task;

Task queue[MAX_QUEUE];

void add_task(void(*t_fun)(void), int t);

void timeout_add_sec(Task* t, unsigned long long sec);
void timeout_add_msec(Task* t, unsigned long long msec);

void timeout_set(Task* t, void(*f)(void));

unsigned long long get_time(void);
void idle(void);
int get_running_tasks(void);
void run_task(int task_id);

#endif