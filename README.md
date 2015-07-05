# delphes-pilot

Simple driver scripts to run MG5+pythia+delphes quickly in an isolated staging environment.
Especially useful for iterative testing or to parallelize processing outside of madevent.

---
**TL;DR:** You can do this:
```
./submit.sh /path_to_gridpack/grid_pack_name.tar.gz number_of_10k_jobs output_directory
```
on your madgraph gridpack tarball to fast-sim all parton events in parallel. Steps to create a madgraph gridpack can be found here: https://cp3.irmp.ucl.ac.be/projects/madgraph/wiki/GridDevelopment

After ./bin/clean4grid step, make sure you repackage madevent directory and the run.sh script together (tar -cvzf name.tar.gz run.sh madevent)

---

Running in local mode, the script will setup a directory in `/tmp` to process the file.
When running on the cluster, the `.lhe` input is copied to a directory in `/scratch/<username>/` and processed from there.

## Setup
Edit `config.sh` to point at your installation of pythia and Delphes.
If you're using the madgraph-provided versions, you can just set `MG_DIR` in the example config provided.

If you want to modify the pythia/Delphes cards used during the processing, either edit the default ones in `Cards/`, or symlink them to your own.

## Use
To run locally, simply do:
```
./madgraph.sh /path/to/some/gridpack_name.tar.gz /path/to/output/directory
./run.sh /path/to/some/file.lhe(.gz)	
```

Unless otherwise specified, the processed delphes output will be saved to your //gdata/atlas/user directory, under the name `delphes.root`.
Have a look at `./run.sh -h` for more options.

If you want to process multiple files on the slurm cluster, use the submit script provided:
```
./submit.sh /path/to/some/gridpack_name.tar.gz number_of_10k_jobs
```						
Have a look at `./submit.sh -h` for more options.
