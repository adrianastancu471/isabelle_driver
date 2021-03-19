#include "timeout.h"
#include "octrng_simpl.h"

#define TIMEOUT 100

int main()
{
	int i;

	add_task(octrng_attach, 1);

	while (get_time() < TIMEOUT)
	{
		for (i = 0; i < MAX_QUEUE; i++)
		{
			if(queue[i].timeout_fun != 0 &&
				queue[i].timeout <= get_time() - queue[i].start)
			{
				run_task(i);
			}
		}
		idle();
	}
	return 0;
}