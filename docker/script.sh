#!/bin/bash

export PATH="$HOME/miniconda2/bin:$PATH"

#cd share
#conda env create -f environment.yml
#rm environment.yml
#cp -a ~/miniconda2/pkgs/* .
#rm *.tar.bz2
#rm -rf cache
#rm urls && rm urls.txt

ls share
mv share/bfalg-shape .
mv share/fortify .
echo foobar
ls share

cd bfalg-shape
conda env create -f environment.yml -q
source activate bfalg-shape
python bfalg_shape/shape.py --version
conda list
cd ..

pythonPath=`python -c "import sys;print ':'.join(sys.path)"`
echo $pythonPath
fortify/bin/sourceanalyzer bfalg-shape/{*.py,**/*.py} -python-path $pythonPath
fortify/bin/sourceanalyzer -scan -Xmx1G -f fortifyResults.fpr
ls

rm -rf fortify
rm -rf bfalg-shape

cd ~/miniconda2/pkgs
cp -a !(*.tar.bz2) /root/share
