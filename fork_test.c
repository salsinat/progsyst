#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main() {
	pid_t pid = fork();
	if (pid == 0) {
		printf("Je suis l'enfant, PID : %d\n", getpid());
	} else if (pid > 0) {
		wait(NULL);
		printf("Je suis le parent, PID : %d, mon enfant est : %d\n", getpid(), pid);
	} else {
		perror("fork échoué");
	}
	return 0;
}
