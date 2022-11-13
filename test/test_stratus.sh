#!/bin/bash

# Exit on any error
set -e


project=test_wgs

source /apps/anaconda3-individual-edition/install/etc/profile.d/conda.sh
conda activate ~chenwjb/miniconda3/envs/catplat

# Assuming run from catplat_tutorial/test
rm -rf ../test_scratch
mkdir ../test_scratch
cd ../test_scratch || exit

# 
rm -rf $HOME/.pyatoms/vasp/$project.yaml
cp ../examples/project.yaml $project.yaml
pyatoms config vasp-project --yaml-file $project.yaml

mkdir -p wgs_project/calc
mkdir -p wgs_project/db

catplat config project --name $project --calc-path wgs_project/calc --db-path wgs_project/db
catplat config project --name $project --calc-path wgs_project/calc --db-path mysql://wgsuser:wgspassword@127.0.0.1:3306/wgs
catplat config show

: '

catplat calculate --project $project --test
catplat calculate -p $project --test

# request for more nodes for single job
catplat calculate --project $project --num-nodes 4 --test
catplat calculate -p $project -n 4 --test

# request for parallel running of 4 jobs of using a single node
catplat calculate --project $project --num-job-run-slots 4 --test
catplat calculate -p $project -N 4 --test

catplat calculate -p $project --bulk-atoms Cu-bulk --test
'

# from file path
catplat calculate -p $project --bulk-atoms ../examples/Cu-bulk.POSCAR --test


catplat calculate -p $project --bulk-atoms Cu-bulk --test

echo "Test successfully completed!"
