#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

int main()
{
    pid_t pid = fork();
    if (pid == 0) {
        printf("Enfant (PID %d) en pause\n", getpid());
        pause();
    }
    else {
        sleep(2);
        printf("Parent envoie SIGTERM à l'enfant (%d)\n", pid);
        kill(pid, SIGINT);
    }
    return 0;
}