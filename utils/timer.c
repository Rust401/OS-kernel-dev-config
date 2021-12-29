#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <signal.h>

#define RAVG_WINDOW_SIZE 20000

int sleep_time = 0; //us
int run_time = 0; //ms
int time_interval = 1000;
int sched_ravg_window = RAVG_WINDOW_SIZE;

void dude_handler()
{
    printf("get SIGALARM\n");
    sleep_time += time_interval;
    if (sleep_time > sched_ravg_window) {
        sleep_time = sched_ravg_window;
    }
    run_time = (sched_ravg_window - sleep_time) / 1000;
    printf("sleep time change to %d us\n", sleep_time);
    printf("run time change to %d us\n", run_time * 1000);
    usleep(sleep_time);
}

struct itimerval tick;
void init_timer(struct itimerval *tick)
{
    memset(tick, 0, sizeof(*tick));

    tick->it_value.tv_sec = 0;
    tick->it_value.tv_usec = 20000;

    tick->it_interval.tv_sec = 0;
    tick->it_interval.tv_usec = 20000;
}

void dude_loop(int runtime)
{
    clock_t before = clock();
    clock_t delta;
    int cum_run_time;

    do {
        delta = clock() - before;
        cum_run_time = delta * 1000 / CLOCKS_PER_SEC;
    } while (cum_run_time < runtime);
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
