wd=`pwd`
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels file://$wd/channel
conda install numpy -y
conda install potrace -y
conda install pypotrace -y
conda install pillow -y
conda install pyproj -y
conda install libagg=2.5.0 -y
conda install fiona=1.7.4 -y
conda install gippy -y
pip install eyed3
rm -rf channel
python shape/shape.py -v
