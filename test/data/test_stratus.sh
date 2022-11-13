#!/bin/bash

source /apps/anaconda3-individual-edition/install/etc/profile.d/conda.sh
conda activate ~chenwjb/miniconda3/envs/catplat

# Assuming run from catplat_tutorial/test
mkdir ../scratch
cd ../scratch || exit

cp ../examples/project.yaml wgs.yaml
pyatoms config vasp-project --yaml-file wgs.yaml

mkdir wgs_project/calc
mkdir wgs_project/db


catplat config project --name wgs --calc-path wgs_project/calc --db-path wgs_project/db
catplat config project --name wgs --calc-path  wgs_project/calc --db-path mysql://wgsuser:wgspassword@127.0.0.1:3306/wgs
catplat config show


catplat calculate --project wgs --test
catplat calculate -p wgs --test

# request for more nodes for single job
catplat calculate --project wgs --num-nodes 4 --test
catplat calculate -p wgs -n 4 --test

# request for parallel running of 4 jobs of using a single node
catplat calculate --project wgs -num-job-run-slots 4 --test
catplat calculate --p wgs -N 4 --test

catplat calculate -p wgs --bulk-atoms Cu-bulk --test

# from file path
catplat calculate -p wgs --bulk-atoms /path/to/structure/file/POSCAR_Cu_bulk --test


catplat calculate -p wgs --bulk-atoms Cu-bulk --test
