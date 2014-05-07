#!/bin/bash

# 07/10/13
#
# CREATES SGE (SUN GRID ENGINE) CLUSTER SCRIPT ($FNAME.sh) TO RUN ON [-s] NODES (SLOTS)
# NODES ARE REQUESTED VIA OpenMPI (orte)
# THE RESULTING SCRIPT IS THEN SUBMITTED TO CLUSTER via "qsub ./$FNAME.sh"
# TO ACCESS NODES ACROSS WORKSTATIONS R PROGRAM NEEDS TO USE MPI PROTOCOL (s.a Rmpi package)
#
# NOTE: can add min memory requirement with "-l mem_free=2G,h_vmem=4G"
#

# USAGE:
# -s [number]: number of slots, when omitted defaults to SLOTS=1
# -f [name]: the file name of the R script
#

# get arguments as options:
SLOTS=1
while getopts es:f:a: option
do
        case "${option}"
        in
                s) SLOTS=${OPTARG};;
                f) FILE=${OPTARG};;
        esac
done

export CURR_DIR=`pwd`
export MPI_DIR=/opt/openmpi/bin
export PATH=$MPI_DIR:$PATH
export PATH=$PATH:`pwd`
export MPILIB_DIR=/opt/openmpi/lib
export LD_LIBRARY_PATH=$MPILIB_DIR:$LD_LIBRARY_PATH

echo ""
echo "****Running with params:"
echo "EXECUTE=$EXECUTE"
echo "SLOTS=$SLOTS"
echo "FILENAME=$FILE"
echo "SIM_NUM=$SIM_NUM"

# create temp subdir
if [ ! -d tmp ]; then
	mkdir tmp
fi

# write the SGE script file:
echo "#!/bin/bash" > ./$FILE$SIM_NUM.sh
echo "#$ -cwd" >> ./$FILE$SIM_NUM.sh
echo "#$ -V" >> ./$FILE$SIM_NUM.sh
echo "#$ -o ./tmp/job_out$SIM_NUM.log" >> ./$FILE$SIM_NUM.sh
echo "#$ -j y" >> ./$FILE$SIM_NUM.sh
echo "#$ -S /bin/bash" >> ./$FILE$SIM_NUM.sh
echo "#$ -m beas" >> ./$FILE$SIM_NUM.sh
# ENTER YOUR EMAIL ADDRESS IF WANT TO RECEIVE UPDATES ABOUT THE JOB
echo "#$ -M youremail@berkeley.edu" >> ./$FILE$SIM_NUM.sh
# if [[ "$SLOTS" -gt "1" ]]
# then 
echo "#$ -pe orte $SLOTS -R y" >> ./$FILE$SIM_NUM.sh
# fi
echo "mpirun -v -np 1 R --vanilla < $FILE > ./tmp/Rout_$SIM_NUM$FILE" >> ./$FILE$SIM_NUM.sh
#alternative:
#echo "R CMD BATCH -args -type=MPI -cpus=8 $FILE sim_out" >> ./$FILE$SIM_NUM.sh

echo "" >> ./$FILE$SIM_NUM.sh
chmod u+x ./$FILE$SIM_NUM.sh

# Submit SGE cluster job via qsub:
  echo ""
  echo "****Run cluster with $SLOTS slot(s)"
  echo "qsub ./$FILE$SIM_NUM.sh"
  echo ""
  cd $CURR_DIR
  qsub ./$FILE$SIM_NUM.sh

# TESTS FILENAME EXISTS:
#if [ -f $FILENAME ]; then
#  echo "Size is $(ls -lh $FILENAME | awk '{ print $5 }')"
#  echo "Type is $(file $FILENAME | cut -d":" -f2 -)"
#  echo "Inode number is $(ls -i $FILENAME | cut -d" " -f1 -)"
#  echo "$(df -h $FILENAME | grep -v Mounted | awk '{ print "On",$1", \
#which is mounted as the",$6,"partition."}')"
#else
#  echo "File does not exist."
#fi