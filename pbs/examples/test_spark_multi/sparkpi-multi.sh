#!/bin/bash
#
#PBS -l nodes=5:ppn=2,walltime=0:20:00
#PBS -l vmem=512mb
#PBS -N spark-pi
#PBS -q test

# -l nodes must be greater than 1. Support only 1 node spec (no + sign).
# -l vmem set the maximum memory for each spark worker process 

export SPARK_HOME=$HOME/spark-1.4.1-bin-1.2.1  
export SPARK_JOB_DIR=$PBS_O_WORKDIR

# Create/append spark configuration in SPARK_JOB_DIR from PBS environments. 
# Specific spark configuration can be put into the SPARK_JOB_DIR/conf/* a priori.
# If existing configuration is found SPARK_JOB_DIR/conf/*, spark-on-hpc.sh will
#   append its auto-generated section. 
# If rerun the job, delete the auto-generated section first
$SPARK_HOME/sbin/spark-on-hpc.sh config || { exit 1; }

# Start a spark cluster inside HPC using PBS -l nodes=xx.  
# One node will be dedicated to the master. The rest nodes are workers. 
$SPARK_HOME/sbin/spark-on-hpc.sh start

# Import several spark variables
source $SPARK_HOME/sbin/spark-on-hpc.sh vars

SPARK_URL=spark://$SPARK_MASTER_IP:$SPARK_MASTER_PORT
WEBUI_URL=http://$SPARK_MASTER_IP:$SPARK_MASTER_WEBUI_PORT

# Submit a spark job. 
# The driver and executor memory is defined from -l vmem
$SPARK_HOME/bin/spark-submit --master $SPARK_URL --class org.apache.spark.examples.JavaSparkPi $SPARK_HOME/lib/spark-examples-1.4.1-hadoop1.2.1.jar 10 > $PBS_O_WORKDIR/pi.txt

# Stop the spark cluster
$SPARK_HOME/sbin/spark-on-hpc.sh stop

