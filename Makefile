all: server client

prof: serverProfiling client

server: server.o ../ssocket/ssocket.o
	gcc -o3 server.o ../ssocket/ssocket.o -o serverTesis -lpthread

serverProfiling: server.o ../ssocket/ssocket.o
	gcc -g -o3 server.o ../ssocket/ssocket.o -o serverTesis -lpthread

rm_server:
	rm serverTesis server.o

client: client.o ../ssocket/ssocket.o
	gcc -o3 client.o ../ssocket/ssocket.o -o clientTesis -lpthread

rm_client:
	rm clientTesis client.o

clean: rm_client rm_server