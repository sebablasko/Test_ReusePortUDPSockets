#!/bin/bash

echo "Compilando..."
make all
echo "Done"

MAX_PACKS=1000000
total_sockets="1 2 4 8 16 24 32 48 64"
total_num_threads_per_socket="1 2 4 8 16 24"
total_clients=4
num_port=1820
repetitions=20


for num_threads_per_socket in $total_num_threads_per_socket
do

	salida="reuseport_sockets_stress_SOSched_"$num_threads_per_socket"Threads_per_socket.csv"

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		linea=$num_sockets";"
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida


	salida="reuseport_sockets_stress_EquitativeSched_"$num_threads_per_socket"Threads_per_socket.csv"

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		linea=$num_sockets";"
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --scheduler dummySched --setcpu $(($k%$(nproc))) --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida


	salida="reuseport_sockets_stress_All0Sched_"$num_threads_per_socket"Threads_per_socket.csv"

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		linea=$num_sockets";"
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --scheduler dummySched --setcpu 0 --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida

done

make clean

