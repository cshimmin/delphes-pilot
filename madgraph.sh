#!/bin/bash

run_name="local"

show_help() {
    echo "Setup staging area and run madgraph in isolation."
    echo "  -o OUTPUT_PATH    The destination path for output file. (Default: same path as input file)"
    echo "  -r OUTPUT_NAME    The run number. (Default: $output_name)"
}

while getopts ":h?r:" opt; do
    case "$opt" in
	h) show_help
	    exit 0
	    ;;
	r) run_name=$OPTARG
	    ;;
	\?) echo "Invalid option: -$OPTARG" >&2
	    show_help
	    exit 1
	    ;;
	:) echo "Option: -$OPTARG requires argument." >&2
	    show_help
	    exit 1
	    ;;
    esac
done


shift $((OPTIND-1))
input_file=$1
output_dir=$2

if [ $# -lt 1 ]; then
	echo "No input file provided! Abort." >&2
	show_help
	exit 1
fi

if [ ! -e "$input_file" ]; then
	echo "Cannot find input file. Abort." >&2
	exit 1
fi

cd $output_dir
rm -f -r run_test_${run_name}
mkdir run_test_${run_name}

scratchdir=/scratch/$(whoami)

cd $scratchdir

rm -f -r run_test_${run_name}
mkdir run_test_${run_name}
cd run_test_${run_name}
cp $input_file .
tar -zxvf $(basename $input_file)
rnd_num=$RANDOM
./run.sh 10000 $rnd_num
mv events.lhe.gz unweighted_events.lhe.gz
mv unweighted_events.lhe.gz ${output_dir}/run_test_${run_name}


