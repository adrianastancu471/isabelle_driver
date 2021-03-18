#include "timeout.h"
#include "octrng_simpl.h"

int main()
{
	add_task(octrng_attach, 1);
	add_task(octrng_rnd, 5);

	int current_task = 0;

	while (get_running_tasks()) 
	{
		if(queue[current_task].timeout_fun != 0)
		{
			if (queue[current_task].timeout <= get_time() - queue[current_task].start)
			{
				run_task(current_task);
			}
		}
		current_task++;

		if(current_task == MAX_QUEUE)
		{
			current_task = 0;
			idle();
		}
	}
	return 0;
}