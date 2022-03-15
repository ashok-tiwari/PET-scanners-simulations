#!/bin/sh
# This is a simple example of a SGE batch script

#$ -N necr-int-act

#
# print date and time
date

# This is a sample bash script file for running a GATE simulation
# program under Sun Grid Engine, I want Grid Engine to send mail
# when the job begins and when it ends
#

#$ -M ashok-tiwari@uiowa.edu
#$ -m be

#$ -l h_vmem=4G
# -l h_rt=20:00:00

#$ -cwd

# -q CCOM-GPU

#$ -q UI,CCOM

# -q UI-HM
#$ -pe smp 2

Gate -a [activity,60] main.mac
