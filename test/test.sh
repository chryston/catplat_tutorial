#/bin/bash
# Exit on any error
set -e


project=test_wgs
if [[ $(hostname) == stratus ]]
then
    source /apps/anaconda3-individual-edition/install/etc/profile.d/conda.sh
elif [[ $(hostname) == pluto ]]
then
    source /apps/anaconda3-individual-edition/2020.11/etc/profile.d/conda.sh
else
    echo "Unknown host $(hostname)"
    exit
fi

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

catplat config project --name $project --calc-path wgs_project/calc --db-path mysql://wgsuser:wgspassword@127.0.0.1:3306/wgs
catplat config project --name $project --calc-path wgs_project/calc --db-path wgs_project/db
catplat config show


catplat calculate --project $project --test
catplat calculate -p $project --test

# request for more nodes for single job
catplat calculate --project $project --num-nodes 4 --test
catplat calculate -p $project -n 4 --test

# request for parallel running of 4 jobs of using a single node
catplat calculate --project $project --num-job-run-slots 4 --test
catplat calculate -p $project -N 4 --test

catplat calculate -p $project --bulk-atoms Cu-bulk --test

# from file path
catplat calculate -p $project --bulk-atoms ../examples/Cu-bulk.POSCAR --test


catplat calculate -p $project --bulk-atoms Cu-bulk --test

catplat calculate -p $project --chemsys Cu --e-above-hull "<0.01" --test
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --test

# returns 2 bulk structures with spacegroup of 194
catplat calculate -p $project --chemsys Cu --spacegroup 194 --test
catplat calculate -p $project --chemsys Ag-Pt --test

# returns 1 bulk alloy structure of Ag-pt
catplat calculate -p $project --chemsys Ag-Pt --bulk-formula AgPt3 --test


# Slab structures can be specified via file paths
catplat calculate -p $project --slab-atoms ../examples/Pt111.POSCAR --test

# Alternatively, for slab structures that will likely be reused multiple times, it may be more conveninent to place them in ~/.autopy/slab directory with the format <name>.<suffix>. They can then be accessed by their <name>
catplat calculate -p $project --slab-atoms Pt111 --test

catplat calculate -p $project --bulk-atoms Cu-bulk --miller-index 1 0 0 --unitcell-size 4 4 --test

# example to continue slab workflow from Material Project bulk structure
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 0 0 --unitcell-size 4 4 --test

# Due to uneven z-positions of the 211 slab atoms, we would need be required to specify
# 3 times the number of --num-layers and --num-fixed-layers.
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 2 1 1 --unitcell-size 1 3 \
 --num-layers 12 --num-fixed-layers 6 --test

# Rutile
catplat calculate -p $project --chemsys O-Ti --bulk-formula TiO2 --spacegroup 136 --e-above-hull "<0.04" \
 --miller-index 1 1 0 --unitcell-size 4 2 --test

# hcp(0001) surface
catplat calculate -p $project --chemsys Co --e-above-hull "0" --miller-index 0 0 1 --unitcell-size 4 4 --test

catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 1 1 --unitcell-size 4 4 \
--num-fixed-layers 1 --test

catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 1 1 --unitcell-size 4 4 \
--vacuum 5.0 --test

catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 1 1 --unitcell-size 4 4 \
--overlayer Rh --test

# filters alloy slabs with Cu termination
catplat calculate -p $project --chemsys Cu-Pd --bulk-formula CuPd --e-above-hull "0" --miller-index 1 0 0 \
--unitcell-size 4 4 --termination Cu --test

catplat adsorbate --name CO
catplat surface --file valid_slab

# top site
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 0 0 --unitcell-size 4 4 \
--adsorbate-atoms H --connectivity "[1]" --test

# binds to slab through carbon
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 0 0 --unitcell-size 4 4 \
--adsorbate-atoms CO --bonds "[0]" --test

# binds to slab through oxygen
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 0 0 --unitcell-size 4 4 \
--adsorbate-atoms CO --bonds "[1]" --test

# returns 2 complex structures
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 2 1 1 --unitcell-size 1 3 \
--num-layers 12 --num-fixed-layers 6 --adsorbate-atoms H --avg-coord-num "[7]" --test

# further narrow down using connectivity + avg-coord-num
# using these 2 filters, we can select the specific sites of interest
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 2 1 1 --unitcell-size 1 3 \
--num-layers 12 --num-fixed-layers 6 --adsorbate-atoms H --avg-coord-num "[7]" --connectivity "[1]" --test

# CH3 rotated by 30°
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 1 1 --unitcell-size 4 4 \
--adsorbate-atoms CH3 --connectivity "[1]" --rotation 30 --test

# top-top binding of O2 on Cu 100 slab
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 1 0 0 --unitcell-size 4 4 \
--adsorbate-atoms O2 --bonds "[0,1]" --connectivity "[1,1]" --test

# top-top binding on the step-edge of the Cu 211 slab
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 2 1 1 --unitcell-size 1 3 --num-layers 12 \
--num-fixed-layers 6 --adsorbate-atoms O2  --bonds "[0,1]" --connectivity "[1,1]" --avg-coord-num "[7,7]" --test

# using comparator strings for bidenate avg coord num
catplat calculate -p $project --chemsys Cu --e-above-hull "0" --miller-index 2 1 1 --unitcell-size 1 3 --num-layers 12 \
--num-fixed-layers 6 --adsorbate-atoms O2  --bonds "[0,1]" --avg-coord-num "['<=8','<=8']" --test

catplat retrieve -p $project --miller-index 1 0 0 --chemsys Cu

# get bulk structure from materials project
catplat get-bulk --chemsys Cu --e-above-hull "<0.01" --spacegroup 225

# create 211 slab structure from bulk structure
catplat slab-builder --file POSCAR_BULK_Cu_0 --miller-index 1 0 0 --unitcell-size 4 4

# writes the complex structure of H top site binding
catplat adsorb -f POSCAR_Cu_100_4x4 --adsorbate H --adsorbate H connectivity 1 --rotation 0

# creates Cu 100 4x4 slab using catplat slab-builder
catplat slab-builder -f POSCAR_Cu_bulk --miller-index 1 0 0 --unitcell-size 4 4


echo "Test successfully completed"
