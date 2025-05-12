#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void afficherSignal(int sig) {
	printf("\nSignal reçu : %d\n", sig);
}

int main() {
	signal(SIGINT, afficherSignal);
	printf("PID : %d - Appuyez sur Crtl+C\n", getpid());
	while(1)
		sleep(1);
	return 0;
}
