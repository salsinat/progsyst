#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <time.h>
#include <string.h>

int main(int argc, char *argv[])
{
    // Vérifier le nombre d'arguments
    if (argc > 2) {
        fprintf(stderr, "Usage: %s <logfile>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    FILE *logfile;
    char *logfile_name = "log_linux.txt";
    
    // Ouvrir le fichier de log si fourni
    if (argc == 2) { logfile_name = argv[1]; }
    if (access(logfile_name, F_OK) == 0) {
        logfile = fopen(logfile_name, "a");
    } else {
        logfile = fopen(logfile_name, "w");
    }

    if (logfile == NULL) {
        perror("Erreur d'ouverture du fichier de log");
        exit(EXIT_FAILURE);
    }
    
    int relance_count = 0;
    const int max_relances = 5;

    while (relance_count < max_relances) {
        pid_t pid = fork();
        if (pid < 0) {
            perror("Erreur de fork");
            exit(EXIT_FAILURE);
        } else if (pid == 0) {
            sleep(3);
            srand(time(NULL) * getpid());
            int random_exit_code = rand() % 3; // Générer un code de sortie aléatoire entre 0 et 2
            exit(random_exit_code);
        } else {
            int status;
            pid_t child_pid = wait(&status);
            if (child_pid < 0) {
                perror("Erreur de wait");
                exit(EXIT_FAILURE);
            }
            if (WIFEXITED(status)) { // Vérifier si le processus enfant s'est terminé normalement, renvoie 0 si le processus s'est terminé sans exit

                int exit_code = WEXITSTATUS(status); // Récupérer le code de retour
                time_t now = time(NULL);
                char *timestamp = ctime(&now);
                timestamp[strlen(timestamp) - 1] = '\0'; // Enlever le saut de ligne

                printf("[%s] PID %d terminé avec code %d\n", timestamp, child_pid, exit_code);
                
                // Écrire dans le fichier de log
                fprintf(logfile, "[%s] PID %d terminé avec code %d\n", timestamp, child_pid, exit_code);
                fflush(logfile); // S'assurer que les données sont écrites immédiatement
            }
            relance_count++;
        }
    }

    fclose(logfile);

    printf("Nombre maximal de relances atteint.\n");
    return 0;
}

//