#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <signal.h>

#define DUDE_DEBUG 1
#define CONFIG_RUNTIME_CHANGE 1

/*
 * use ms for these dudes
 */
#define USEC_PER_MSEC 1000
#define RUNTIME_DELTA 1000
#define RAVG_WINDOW_SIZE 20000

const int time_interval = RUNTIME_DELTA;
const int sched_ravg_window = RAVG_WINDOW_SIZE;

int sleep_time = 20000;
int run_time = 0;

void change_runtime()
{
	sleep_time -= time_interval;
	if (sleep_time < 0) {
		sleep_time = 0;
	}
	run_time = sched_ravg_window -sleep_time;

	if (DUDE_DEBUG) {
		printf("sleep time change to %d us\n", sleep_time);
		printf("run time change to %d us\n", run_time);
	}
}

void dude_handler()
{
	if (DUDE_DEBUG)
		printf("get SIGALARM\n");

	if (CONFIG_RUNTIME_CHANGE)
		change_runtime();

	usleep(sleep_time);
}

struct itimerval tick;
void init_timer(struct itimerval *tick)
{
	memset(tick, 0, sizeof(*tick));

	tick->it_value.tv_sec = 0;
	tick->it_value.tv_usec = RAVG_WINDOW_SIZE;

	tick->it_interval.tv_sec = 0;
	tick->it_interval.tv_usec = RAVG_WINDOW_SIZE;
}

void dude_loop(int runtime)
{
	clock_t before = clock();
	clock_t delta;
	int cum_run_time;

	do {
		delta = clock() - before;
		cum_run_time = delta * 1000 / CLOCKS_PER_SEC;
	} while (cum_run_time < runtime / USEC_PER_MSEC);

	if (DUDE_DEBUG) {
		printf("runtime for this loop is %d\n", cum_run_time);
	}
}

int main()
{
	signal(SIGALRM, dude_handler);
	init_timer(&tick);
	if(setitimer(ITIMER_REAL, &tick, NULL) < 0) {
		printf("settimer failed!");
	}

	while(1) {
		dude_loop(run_time);
		pause();
	}

	return 0;
}
