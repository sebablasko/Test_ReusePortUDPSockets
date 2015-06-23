#!/bin/bash

echo "Compilando..."
make all
echo "Done"

salida=reuseport_sockets_stress.csv

MAX_PACKS=1000000
total_sockets="1 2 4 8"
num_threads_per_socket=1
total_clients=4
num_port=1820
repetitions=5

echo "Ejecutando Prueba..."
for num_sockets in $total_sockets
do

	linea=$num_sockets";"
	echo "sockets: $num_sockets"

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		echo "Repeticion $i"
		echo "" > aux
		for ((k=1 ; $k<=$num_sockets ; k++))
		{
			./server --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
		}

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			./client --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
		}

		wait $(pgrep 'server')

		linea="$linea$(cat aux)"
	}
	echo $linea
	echo "$linea" >> $salida
	echo ""
	rm aux
done

make clean