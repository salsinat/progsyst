#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <time.h>

int main(int argc, char *argv[])
{
    // Vérifier le nombre d'arguments
    if (argc > 2) {
        fprintf(stderr, "Usage: %s <logfile>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    FILE *logfile = NULL;

    // Ouvrir le fichier de log si fourni
    if (argc == 2) {
        FILE *logfile = fopen(argv[1], "a");
    } else { //sinon création d'un fichier de log par défaut
        FILE *logfile = fopen("log_linux.txt", "w");
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
            exit(rand() % 3);
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
                if (logfile) {
                    fprintf(logfile, "[%s] PID %d terminé avec code %d\n", timestamp, child_pid, exit_code);
                    fflush(logfile); // S'assurer que les données sont écrites immédiatement
                }
            }
            relance_count++;
        }
    }

    if (logfile) {
        fclose(logfile);
    }
    printf("Nombre maximal de relances atteint.\n");
    return 0;
}

// Écrire un programme C nommé surveillance.c qui :
// Crée un processus enfant à l'aide de fork()
// L'enfant dort pendant 3 secondes puis se termine avec un code aléatoire (exit(0 à 2))
// Le parent attend sa fin avec wait() et récupère son code de retour
// Après la fin de chaque enfant :
// Afficher dans le terminal : "[timestamp] PID X terminé avec code Y"
// Écrire cette ligne dans un fichier log_linux.txt
// Ajouter un compteur de relances :
// Le parent ne relance que 5 fois maximum
// Après la 5] relance, le programme affiche "Nombre maximal de relances atteint." et termine