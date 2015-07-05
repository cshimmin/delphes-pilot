#!/bin/bash

# defaults
ncores=2
quiet=0
recurse=0
partition=atlas_all

show_help() {
	echo "Submit pythia/delphes jobs to the slurm cluster."
	echo "Usage: $0 [options] input_file [input_file ...]"
	echo "Options:"
	echo "  -t TAG_NAME     A prefix tag for output files (e.g. <TAG_NAME>_delphes.root)."
	echo "  -c N_CORES      Number of cores to request per job. (Default: $ncores)"
	echo "  -p PARTITION    The slurm partition to submit to. (Default: $partition)"
	echo "  -q              Squelch slurm logs."
}

# parse CLI
while getopts ":h?t:c:p:q" opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    t)  tag=$OPTARG
        ;;
    c)  ncores=$OPTARG
        ;;
    p)  partition=$OPTARG
        ;;
    q)  quiet=1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
	show_help
	exit 1
	;;
    :)
        echo "Option: -$OPTARG requires argument." >&2
	show_help
	exit 1
	;;
    esac
done

input_file=$1
total_jobs=$2
output_dir=$3

# add a tag to the input filename, if requested.
output_name=delphes
if [ ! -z "$tag" ]; then
	output_name=${tag}_${output_name}
fi

# setup options to sbatch command
SLURM_OPTS="-c $ncores -p $partition -t 120"

if [ "$quiet" == "1" ]; then
	SLURM_OPTS+=" -o /dev/null"
fi

#madgraph gridpacks 
run="0"
while [ $run -lt $total_jobs ] 
do 

    sbatch $SLURM_OPTS ./madgraph.sh -r $run $input_file $output_dir
    run=$[$run+1]
    
done

user=$(whoami)

while [[ -n $(squeue -u $user -t PD,R,CG -h -o %t) ]]
do
    echo "Waiting for madgraph jobs to finish"
    sleep 5
done

sleep 10

# schedule a job f	or each run
delphes_run="0"	
while [ $delphes_run -lt $total_jobs ]
do	
    	
    input=${output_dir}/run_test_${delphes_run}/unweighted_events.lhe.gz
    sbatch $SLURM_OPTS ./run.sh -n ${output_name}.root -r $delphes_run -o ${output_dir}/run_test_${delphes_run} $input
    delphes_run=$[$delphes_run+1]
    
done

