#define _GNU_SOURCE

#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../ssocket/ssocket.h"

#include <getopt.h>

//Definiciones
#define BUF_SIZE 10
#define FIRST_PORT 1820

//Variables
int first_pack = 0;
struct timeval dateInicio, dateFin;
char buf[BUF_SIZE];
char* IP_DEST = "";
int mostrarInfo = 0;
int MAX_PACKS = 0;
int DESTINATION_PORT = FIRST_PORT;
double segundos;

void print_usage(){
    printf("Uso: ./client [verbose] --packets <num> --ip <ip-address> --port <num>\n");
}

void print_config(){
    printf("Detalles de la prueba:\n");
    printf("\tPaquetes a enviar:\t%d\n", MAX_PACKS);
    printf("\tIP de destino:\t%s\n", IP_DEST);
    printf("\tPuerto a enviar:\t%d\n", DESTINATION_PORT);
}

int main(int argc, char **argv) {

	// Parsear argumentos
	int c;
	int digit_optind = 0;
	while (1){

		int this_option_optind = optind ? optind : 1;
        int option_index = 0;

		static struct option long_options[] = {
			{"packets", required_argument, 0, 'd'},
			{"ip", required_argument, 0, 'i'},
			{"port", required_argument, 0, 'p'},
			{"verbose", no_argument, 0, 'v'},
			{0, 0, 0, 0}
		};

         c = getopt_long (argc, argv, "cvd:t:p:",
         long_options, &option_index);
 
         if (c == -1)
         	break; 

         switch (c){

			case 'v':
				printf ("Modo Verboso\n");
				mostrarInfo = 1;
				break;

			case 'd':
				MAX_PACKS = atoi(optarg);
				break;

			case 'i':
				IP_DEST = optarg;
				break;

			case 'p':
				DESTINATION_PORT = atoi(optarg);
				break;

			default:
				printf("Error: La función getopt_long ha retornado un carácter desconocido. El carácter es = %c\n", c);
				print_usage();
				exit(1);
         }
	}

	// Validar Parametros necesarios para operar
	if(MAX_PACKS < 1 || strlen(IP_DEST)==0) {
		printf("Error en el ingreso de parametros\n");
		print_usage();
		exit(1);
	}

	if(mostrarInfo)	print_config();

	/* Llenar de datos el buffer a enviar */
	int i;
	for(i = 0; i < BUF_SIZE; i++)
		buf[i] = 'p'+i;

	//Crear Socket
	int socket_fd;
	char ports[10];
	sprintf(ports, "%d", DESTINATION_PORT);
	socket_fd = udp_connect(IP_DEST, ports);
	if(socket_fd < 0) {
		fprintf(stderr, "connection refused\n");
		exit(1);
	}


	//Medir Inicio
	gettimeofday(&dateInicio, NULL);

	for(i = 0; i < MAX_PACKS; i++){
		if(write(socket_fd, buf, BUF_SIZE) != BUF_SIZE) {
			gettimeofday(&dateFin, NULL);
			segundos = (dateFin.tv_sec+dateFin.tv_usec/1000000.)-(dateInicio.tv_sec*1.0+dateInicio.tv_usec/1000000.);
			//fprintf(stderr, "Falla el write al servidor, envio %d paquetes\n", i);
			//fprintf(stderr, "total time = %g\n", segundos);
			break;
		}
	}

	//Medir Fin
	gettimeofday(&dateFin, NULL);

	segundos=(dateFin.tv_sec*1.0+dateFin.tv_usec/1000000.)-(dateInicio.tv_sec*1.0+dateInicio.tv_usec/1000000.);
	if(mostrarInfo){
		printf("Tiempo Total = %g\n", segundos);
		printf("QPS = %g\n", MAX_PACKS*1.0/segundos);
	}else{
		printf("%g \n", segundos);
	}
	exit(0);
	return 0;
}