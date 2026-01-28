# !/bin/bash
# This script will check for the installation of LAXPC software. If not already installed, it will install it in the working directory.

# Download the package
# extract the package in the lxpc_soft directory
# run ./install-lxp.sh

#########################
#v1.1 (01/07/2025): It also installs the as1bary
#########################

version='3.4.5'
date='16Jan2025'

printf "\n\n\n%%%%%%%%%% \t Installation of LAXPCSOFT version $version, Release $date\t%%%%%%%%%% \n \nThis script uses the package provided by TIFR \nOriginal package can be downloaded from \nhttps://www.tifr.res.in/~astrosat_laxpc/LaxpcSoft.html \n \n \nThis particular BASH script is written by :: Dr. Rahul Sharma \nAffiliation :: IUCAA, Pune \ncontact :: rahul.sharma@iucaa.in\n"

printf "Date modified : 01-07-2025 \nversion - 1.1\n"

printf "\n\n Disclaimer:\n This script does not have any warranty, please use this with caution. \n We are not responsible if you get correct results.\n If you find any bug, please report to rahul.sharma@iucaa.in\n Also, contact if you need any help.\n Please acknowledge the LAXPC Payload Operation Centre (POC) at TIFR-Mumbai.\n"

printf "\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"

echo "Press any key to proceed (or Ctrl+C to stop) :"
read proceed


if [ -d "laxpcsoft" ]; then 
	echo "laxpcsoft directory exists."
else
	echo "laxpcsoft directory does not exist; creating one...."
	mkdir laxpcsoft
	tar -zxvf laxpcsoft*.tar.gz -C laxpcsoft
	cd laxpcsoft
	cp makefile.gfortran makefile
	make laxpcl1
	make backshiftv3
	cd ..
fi

	

if [ -d "as1bary" ]; then 
	echo "as1bary directory exists."
else
	echo "as1bary directory does not exists; creating one...."
	tar -zxvf as1bary.tar.gz
	cd as1bary
	hmake
	cd ..
fi


if [ ! -d "rmf" ]; then 
	mkdir rmf
	tar -zxvf lx10resp.tar.gz -C rmf
	tar -zxvf lx20resp.tar.gz -C rmf
fi

echo "Do you want to remove tar files (y/n) ?"
read check

if [[ $check = 'y' ]] 
then 
rm *tar.gz
fi

echo " "

echo "AS1bary tool installed and can be used by invoking" `pwd`"/as1bary/as1bary"
`pwd`/as1bary/as1bary

echo " "
echo " "

echo "The laxpcsoft is ready to use. To extract science product such as lightcurve and spectrum, use laxpc_prod"

echo " "



