export PATH="$HOME/miniconda2/bin:$PATH"

echo "#############################"
pwd
ls
cd conda-recipes
cd vendor
git clone https://github.com/gipit/gippy
git clone https://github.com/flupke/pypotrace
cd ..
conda update -n root conda-build -y
#conda update --all -y
conda build agg
conda config --add channels local
conda build pypotrace
conda build gippy
echo
ls ~/miniconda2/conda-bld
