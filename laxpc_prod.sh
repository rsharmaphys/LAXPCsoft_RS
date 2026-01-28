# !/bin/bash
# This script will extract the LAXPC lightcurve and spectrum. It will also correct LCs for the barycenter.

#########################
#v1.1 (01/07/2022): Extract of energy-resolved lightcurve
#########################
#v1.2 (06/07/2023): Updated with the extraction of spectrum
#########################

#########################
#Issue: If the observation is of Feb 2022, then the background selection needs to start with a different date. 
#v1.3 (25/04/2025): Corrected the Updatation with back4.inp. Above issue is resolved now.
#########################

#########################
#v1.4 (30/06/2025): Extract the event file by setting a variable "event=1"
#########################

#########################
#v1.5 (07/01/2026): Minor tweaks
#########################

inlxp=2			# 1 for LAXPC 10 and 2 for LAXPC 20 instrument
anode=0    		# 1 = Top layer data only, 0 = all layers
bin=1			# Bin size of light curve
event=0			# 1 - to extract the event file and bary-correct it, otherwise it will not extract

#Note
#set the path to the input directory (indir) and output directory (outdir). Please give the path in $indir up to level 1 data from home; e.g., /home/user/laxpcdata/
# obsid is the observation id (the last 4-5 digit, e.g., for obs-ID = 9000005318 give obsid=5318

source='SAXJ1808'
obsid=5318
indir=/home/rahulsharma/Downloads/SAXJ1808/2022_ASTROSAT/LAXPC
outdir=/home/rahulsharma/Downloads/SAXJ1808/2022_ASTROSAT/LAXPC/$obsid
ra=272.115195833
dec=-36.978861111

# For energy-resolved light curves, either create a file named energyinput with each line representing a range of energy or edit the line below with energy range separated by \n
printf "3 80\n3 30\n" > energyinput

#############################################################
#############################################################

version='3.4.5'
date='16Jan2025'

printf "\n\n\n%%%%%%%%%% \t LAXPCSOFT version $version, Release Date $date\t%%%%%%%%%% \n \nThis script uses the package provided by TIFR, Mumbai \nOriginal package can be downloaded from \nhttps://www.tifr.res.in/~astrosat_laxpc/LaxpcSoft.html \n \n \nThis particular BASH script is written by :: Dr. Rahul Sharma \nAffiliation :: IUCAA, Pune \ncontact :: rahul.sharma@iucaa.in\n"

printf "Date modified : 07-01-2026 \nversion - 1.5\n"


printf "\n\n Disclaimer:\n This script does not have any warranty, please use this with caution. \n We are not responsible if you get correct results.\n If you find any bug, please report to rahul.sharma@iucaa.in\n Also, contact if you need any help.\n Please acknowledge the LAXPC Payload Operation Centre (POC) at TIFR-Mumbai.\n"

printf "\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"

printf "\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"

echo "Press any key to proceed or Ctrl+C to stop :"
read proceed


cd laxpcsoft

printf "\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n"

#echo "Please give the path to the level-1 input directory :"
#echo "(give path upto level 1 data from home; e.g., /home/user/laxpcdata/)"
#read -p 'path to input directory :' indir


#read -p 'please give the path to the output directory :' outdir
[ ! -d "$outdir" ] && mkdir -p "$outdir"

#echo "please enter the obs-ID of the observation : "
#read obsid

echo "Looking for the level 1 data for obs-ID = $obsid"
echo "done"

find $indir/*000${obsid}* -name "*00000${obsid}*.*" | grep -v lxp2 | grep -v lxp3 | grep -v issdc | grep -v "gti$" | grep -v "frt$" | grep -v "xml$" | grep -v "hk$" | grep -v "orb$" | grep -v "txt$" | grep -v "bti$" | grep -v "aux1" | grep -v "aux2" | grep -v frame | grep -v ".tar" | sort > ls1

echo "Do you want to print the input data file (y/n)?"
echo "(recommended : please check if the path is correct or not)"
read check

if [[ $check = 'y' ]] 
then 
echo "yes"
cat ls1
else
echo "NO"
fi

printf "\n\n\n"

echo "Press any key to proceed (or Ctrl+C to stop) :"
read proceed

mv ls1 laxpcl1.inp

bkg=feb22
printf "backfit.lxp10${bkg}\nbacklxp10mar16ul1.pha\nbacklxp10mar16ul2.pha\nbacklxp10mar16ul3.pha\nbacklxp10mar16ul4.pha\nbacklxp10${bkg}.pha\nbackfit3.lxp10mar16\n\n\n" >back4.inp

printf "\n\n\n"

rm lxp1level2* lxp2level2*

#Generate the GTI file
echo "Generating GTI file"
echo "0" > gti.inp

printf "2 1 0\n/\n/\n/\n" > inp_laxpcl1
./laxpcl1.e < inp_laxpcl1 > laxpcl1.log

# moving the newly created GTI file to gti.inp
mv lxp2level2.gti gti.inp

#read -p 'Enter the LAXPC number (e.g., - 1) : ' inlxp


cp ../energyinput .
en=$(wc -l energyinput | awk '{print $1}')
cat energyinput
echo " "


# Extracting the product for the selected LAXPC20 detector

if [[ $inlxp == 2 ]] 
then 

lxp=$inlxp
echo "LAXPC $lxp selected"

printf "$lxp 1 0\n/\n/\n/\n" > inp_laxpcl1
./laxpcl1.e < inp_laxpcl1 > laxpcl1.log

printf "$lxp 0 0\n/\n/\n" > inp_backshift
./backshiftv3.e < inp_backshift >backshift.log

# Change the epoch of background

bkg=$(grep -aF "It may be better to use" backshift.log | awk '{print $7}')

if [ -n "$bkg" ]; then
    printf "backfit.lxp10${bkg}\nbacklxp10mar16ul1.pha\nbacklxp10mar16ul2.pha\nbacklxp10mar16ul3.pha\nbacklxp10mar16ul4.pha\nbacklxp10${bkg}.pha\nbackfit3.lxp10mar16\n\n\n" > back4.inp

    echo "The selected epoch of background is $bkg"
else
    echo "Background epoch was not updated and already mentioned used"
    cat back4.inp | head -1
fi

# Rerun pipeline with updated bkg files

printf "$lxp 1 $anode\n/\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n/\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

# Source the rmf files
rmf=$(grep -aF "use the response file" backshift.log | awk '{print $5}')

rm *rmf *.txt
cp ../rmf/$rmf .

echo "The rmf file used is $rmf"

fdump $rmf[1] $rmf.txt - -
awk '{print $1" "($2+$3)/2" "($2-$3)/2}' $rmf.txt > ${rmf}_2.txt


for ((i=1;i<=$en;i++))
do

elow=$(awk "NR==$i" energyinput | awk '{print $1}')
ehigh=$(awk "NR==$i" energyinput | awk '{print $2}')

ch1=$(awk "{print (\$2 - $elow"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')
ch2=$(awk "{print (\$2 - $ehigh"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')

ch_low_lxp2=$(echo "$ch1*4" | bc )
ch_high_lxp2=$(echo "$ch2*4" | bc )

echo "energy range: channel range"
echo "$elow-$ehigh : $ch_low_lxp2-$ch_high_lxp2"

printf "$lxp $bin $anode\n$ch_low_lxp2 $ch_high_lxp2\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n$bin $ch_low_lxp2 $ch_high_lxp2 -1\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

../as1bary/as1bary -i AstroSat.orb -f lxp${lxp}level2_corr.lcsr -o ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc -ra $ra -dec $dec -ref ICRS >as1bary.log 2>&1

echo "LC extraction done"

mv ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc $outdir
mv lxp2level2.spec lxp2level2back_shifted.spec lxp2level2back.spec $outdir 
cp $rmf $outdir

done
#rm inp_laxpcl1 inp_backshift *log
fi

# To extract event file
if [[ $event == 1 ]] 
then 

	printf "$lxp 1 $anode\n/\n/\n-1 1 -1\n">inp_laxpcl1
	./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
	
	../as1bary/as1bary -i AstroSat.orb -f lxp2level2.evn -o bary.evn -ra $ra -dec $dec -ref ICRS >as1bary_event.log 2>&1
	
	mv lxp2level2.evn bary.evn ${rmf}_2.txt $outdir 
	
fi

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



# Extracting the product for selected LAXPC10 detector

if [[ $inlxp == 1 ]] 
then 

lxp=$inlxp
echo "LAXPC $lxp selected"

printf "$lxp 1 0\n/\n/\n/\n" > inp_laxpcl1
./laxpcl1.e < inp_laxpcl1 > laxpcl1.log

printf "$lxp 0 0\n/\n/\n" > inp_backshift
./backshiftv3.e < inp_backshift >backshift.log

# Change the epoch of background

bkg=$(grep -F "It may be better to use" backshift.log | awk '{print $7}')

printf "backfit.lxp10${bkg}\nbacklxp10mar16ul1.pha\nbacklxp10mar16ul2.pha\nbacklxp10mar16ul3.pha\nbacklxp10mar16ul4.pha\nbacklxp10${bkg}.pha\nbackfit3.lxp10mar16\n\n\n" >back4.inp

echo "The selected epoch of background is $bkg"

# Rerun pipeline with updated bkg files

printf "$lxp 1 $anode\n/\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n/\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

# Source the rmf files
rmf=$(grep -F "use the response file" backshift.log | awk '{print $5}')

rm *rmf *.txt
cp ../rmf/$rmf .

echo "The rmf file used is $rmf"

fdump $rmf[1] $rmf.txt - -
awk '{print $1" "($2+$3)/2" "($2-$3)/2}' $rmf.txt > ${rmf}_2.txt


for ((i=1;i<=$en;i++))
do

elow=$(awk "NR==$i" energyinput | awk '{print $1}')
ehigh=$(awk "NR==$i" energyinput | awk '{print $2}')

ch1=$(awk "{print (\$2 - $elow"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')
ch2=$(awk "{print (\$2 - $ehigh"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')

ch_low_lxp=$(echo "$ch1*2" | bc )
ch_high_lxp=$(echo "$ch2*2" | bc )

echo "energy range: channel range"
echo "$elow-$ehigh : $ch_low_lxp-$ch_high_lxp"

printf "$lxp $bin $anode\n$ch_low_lxp $ch_high_lxp\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n$bin $ch_low_lxp $ch_high_lxp -1\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

../as1bary/as1bary -i AstroSat.orb -f lxp${lxp}level2_corr.lcsr -o ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc -ra $ra -dec $dec -ref ICRS >as1bary.log 2>&1

echo "LC extraction done"

mv ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc $outdir/

done

#rm inp_laxpcl1 inp_backshift *log
fi




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





# Extracting the product for selected detector LAXPC10 and LAXPC20

if [[ $inlxp == 12 ]] 
then 

echo "LAXPC 10 and 20 both are selected"

lxp=2

echo $lxp

printf "$lxp 1 0\n/\n/\n/\n" > inp_laxpcl1
./laxpcl1.e < inp_laxpcl1 > laxpcl1.log

printf "$lxp 0 0\n/\n/\n" > inp_backshift
./backshiftv3.e < inp_backshift >backshift.log

# Change the epoch of background

bkg=$(grep -F "It may be better to use" backshift.log | awk '{print $7}')

printf "backfit.lxp10${bkg}\nbacklxp10mar16ul1.pha\nbacklxp10mar16ul2.pha\nbacklxp10mar16ul3.pha\nbacklxp10mar16ul4.pha\nbacklxp10${bkg}.pha\nbackfit3.lxp10mar16\n\n\n" >back4.inp

echo "The selected epoch of background is $bkg"

# Rerun pipeline with updated bkg files

printf "$lxp 1 $anode\n/\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n/\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

# Source the rmf files
rmf=$(grep -F "use the response file" backshift.log | awk '{print $5}')

rm *rmf *.txt
cp ../rmf/$rmf .

echo "The rmf file used is $rmf"

fdump $rmf[1] $rmf.txt - -
awk '{print $1" "($2+$3)/2" "($2-$3)/2}' $rmf.txt > ${rmf}_2.txt

for ((i=1;i<=$en;i++))
do

elow=$(awk "NR==$i" energyinput | awk '{print $1}')
ehigh=$(awk "NR==$i" energyinput | awk '{print $2}')

ch1=$(awk "{print (\$2 - $elow"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')
ch2=$(awk "{print (\$2 - $ehigh"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')

ch_low_lxp2=$(echo "$ch1*4" | bc )
ch_high_lxp2=$(echo "$ch2*4" | bc )

echo "energy range: channel range"
echo "$elow-$ehigh : $ch_low_lxp2-$ch_high_lxp2"

printf "$lxp $bin $anode\n$ch_low_lxp2 $ch_high_lxp2\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n$bin $ch_low_lxp2 $ch_high_lxp2 -1\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

../as1bary/as1bary -i AstroSat.orb -f lxp${lxp}level2_corr.lcsr -o ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc -ra $ra -dec $dec -ref ICRS >as1bary.log  2>&1

done









lxp=1

echo $lxp

printf "$lxp 1 $anode\n/\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n/\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

# Source the rmf files
rmf=$(grep -F "use the response file" backshift.log | awk '{print $5}')

cp ../rmf/$rmf .

echo "The rmf file used is $rmf"

fdump $rmf[1] $rmf.txt - -
awk '{print $1" "($2+$3)/2" "($2-$3)/2}' $rmf.txt > ${rmf}_2.txt

for ((i=1;i<=$en;i++))
do

elow=$(awk "NR==$i" energyinput | awk '{print $1}')
ehigh=$(awk "NR==$i" energyinput | awk '{print $2}')

ch1=$(awk "{print (\$2 - $elow"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')
ch2=$(awk "{print (\$2 - $ehigh"' "\t" $0)}' ${rmf}_2.txt | sed '/^-/d' | sort | head -n 1 | awk '{print $2}')

ch_low_lxp1=$(echo "$ch1*2" | bc )
ch_high_lxp1=$(echo "$ch2*2" | bc )

echo "energy range: channel range"
echo "$elow-$ehigh : $ch_low_lxp1-$ch_high_lxp1"

printf "$lxp $bin $anode\n$ch_low_lxp1 $ch_high_lxp1\n/\n/\n">inp_laxpcl1
printf "$lxp $anode 0\n$bin $ch_low_lxp1 $ch_high_lxp1 -1\n/\n">inp_backshift

./laxpcl1.e <  inp_laxpcl1 >laxpcl1.log
./backshiftv3.e < inp_backshift >backshift.log

../as1bary/as1bary -i AstroSat.orb -f lxp${lxp}level2_corr.lcsr -o ${obsid}_${elow}-${ehigh}_lxp${lxp}.lc -ra $ra -dec $dec -ref ICRS >as1bary.log  2>&1


echo "LC extraction done"

lcmath ${obsid}_${elow}-${ehigh}_lxp1.lc ${obsid}_${elow}-${ehigh}_lxp2.lc ${obsid}_${elow}-${ehigh}.lc 1.0 1.0 yes

mv ${obsid}_${elow}-${ehigh}_lxp1.lc ${obsid}_${elow}-${ehigh}_lxp2.lc ${obsid}_${elow}-${ehigh}.lc  $outdir

done

#rm inp_* *log
fi

cd ..

