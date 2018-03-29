#!/bin/bash

#metrics=("L2" "L3" "TLB_DATA" "L3CACHE" "ENERGY" "L2CACHE" "BRANCH" "CYCLE_ACTIVITY" "CLOCK" "DATA" "ICACHE")

metrics=("L2" "L3" "ENERGY" "BRANCH" "CLOCK" "DATA")


#Selectivity from 0 to 1.0, by 0.1
for i in `seq 1 9`;
do
	selectivity=$((i*10))
	# echo "------------------------------------------"
	# echo "Selectivity ${selectivity}"
	# echo "------------------------------------------"

	echo "Making directories..."
	#Makes the .dat folder needed for the plots
	DAT_DIR="/home/flav/mestrado/MHaJoL/methods/lik/gnu/filterBuckets/_${selectivity}"
	if [ ! -d "$DAT_DIR" ]
	then
		mkdir "$DAT_DIR"
	fi

	#Makes the .out folder needed for the plots
	OUT_DIR="/home/flav/mestrado/MHaJoL/methods/lik/out/filterBucketsResults/_${selectivity}"
	if [ ! -d "$OUT_DIR" ]
	then
		mkdir "$OUT_DIR"
	fi

	#Makes the folder to hold temporary tbl
	TEMP_DIR="/home/flav/mestrado/MHaJoL/tbl/temp"
	if [ ! -d "$TEMP_DIR" ]
	then
		mkdir "$TEMP_DIR"
	fi

	echo "Generation orders table..."
	#Generates orders table and prints it to file
	psql bloom bloom -c "select * from generate_sample_by_selectivity(${selectivity});" &>> ${TEMP_DIR}/ORDERS_${selectivity}.tbl

	#Transforms file into a real tbl file to be read by the program
	cat ${TEMP_DIR}/ORDERS_${selectivity}.tbl | sed '1,2d' | sed '/o_/d' | sed '/function/d' | sed '/^\s*$/d' | sed '/-----/d' | sed '/row/d' | tr -d '\t' | sed -e 's/[ \t]*//' | sed 's/$/|/' &>> /home/flav/mestrado/MHaJoL/tbl/orders_${selectivity}.tbl

	echo "Running all the joins..."
	for m in "${metrics[@]}";
	do

		#Runs the join with no parameter variation 
		outputName="${OUT_DIR}/all.out"
		likwid-perfctr -m -C S0:0 -g  ${m} /home/flav/mestrado/MHaJoL/methods/lik/bloomConfig/bloomConfig ${selectivity} &>> ${outputName}

		#Runs the join with variation
		#Loop over 2^5 to 2^20 varying the number of hash functions to discover the best fit for the selectivity
		echo "Runs the BloomFilter with buckets and functions variation..."
		for k in `seq 14 22`;
		do
			bucketsSize=$((2**k))
			for j in `seq 0 4`;
			do
				echo "		${bucketsSize} buckets ${k}+1 hash functions"
				outputName="${OUT_DIR}/_${k}_${bucketsSize}_${j}.out"
				likwid-perfctr -m -C S0:0 -g ${m} /home/flav/mestrado/MHaJoL/methods/lik/bloomConfig/bloomConfig ${selectivity} ${bucketsSize} ${j} &>> ${outputName}
			done
		done
	done

	echo "Generating .dat files to plot the data..."
	#The number of registers returned by the nested loop join
	nRegNestedLoop=$(cat ${OUT_DIR}/all.out | grep -m 1 "linhas" | cut -d " " -f1)
	echo $nRegNestedLoop

	#Generates the dat files
	# index=0.557142857
	# control=-1
	# for file in ${OUT_DIR}/*;
	# do
	# 	nBuckets=$(echo $file | cut -d "_" -f3)
	# 	nHash=$(cat $file | grep -m 1 "Buckets" | cut -d " " -f3)

	# 	execTime=$(tac $file | grep -m 1 "ms" | cut -d " " -f1)
	# 	nRegisters=$(cat $file | grep -m 1 "linhas" | cut -d " " -f1)
	# 	nRegistersPerc=$(echo "(${nRegisters}/${nRegNestedLoop})*100" | bc -l)

	# 	outputFile="${DAT_DIR}/_${nHash}.dat"
	# 	outputFile2="${DAT_DIR}/time.dat"

	# 	nBucketsNew=""
	# 	for char in $(echo "${nBuckets}" | fold -w1);
	# 	do
	# 		nBucketsNew="${nBucketsNew}^${char}"
	# 	done

	# 	index=$(echo "${index}+0.142857143"| bc -l)
	# 	if [ "$control" -lt "4" ];
	# 	then
	# 		control=$((control+1))
	# 	else
	# 		control=0
	# 		index=$(echo "${index}+0.142857143+0.142857143"| bc -l)
	# 	fi;

	# 	echo "2${nBucketsNew}	${nHash}	${nRegistersPerc}	${execTime}" &>> ${outputFile}
	# 	echo "${index}	${execTime}" &>> ${outputFile2}
	# done

done

#Clean
rm -rf ${TEMP_DIR}
rm -rf /home/flav/mestrado/MHaJoL/tbl/orders_*