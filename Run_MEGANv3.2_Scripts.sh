#! /bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#                                <<< NOTE >>>                                   #
#                                                                               #
#   This script executes the run scripts in the "/work" directory, except the   #
#   "run.txt2ioapi.v32.csh" script. Make sure that the "setcase.csh" script is  #
#   under "/MEGAN/MEGANv3.2/" directory. This script reads paths from the       #
#   "setcase.csh" script.                                                       #
#   Edit the parameters in 'USER INPUTS' and execute the script for each run    #
#   script (under 'Modified Scripts') separately.                               #
#                                                                               #
# author: Reza Rezaei                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# Modified Scripts
modified_met2mgn="run.met2mgn.v32_modified.csh"
modified_daymet="run.daymet.v32_modified.csh"
modified_megsea="run.megsea.v32_modified.csh"
modified_megcan="run.megcan.v32_modified.csh"
modified_megvea="run.megvea.v32_modified.csh"
modified_mgn2mech="run.mgn2mech.v32_modified.csh"

#================================== USER INPUTS ==================================
SCRIPT_NAME=$modified_mgn2mech              # Select one of the "Modified Scripts" 
                                            # files (in lines above)

INITIAL_RUN="Y"                             # Initial run if the model hasn't been
                                            # run before; otherwise set to false
					    # and a restart file is needed (megsea)

CMAQ_WORKFLOW_PROJECT_NAME="thesis"         # From cmaq_wf (or MCIP outputs name)
CMAQ_WORKFLOW_DOMAIN_NAME_STRING="marmara"  # From cmaq_wf (or MCIP outputs name)
DOMAIN_SIZE="4km"                           # From GRIDDESC
START_DATE=2012153                          # Julian Date
END_DATE=2012244                            # Julian Date
NLAI=46                                     # Number of LAI files

MECH=CB6X                                   # Use one of these mechanisms:
                                            # (CB6X, RADM2, RACM, CBMZ, CB05, SOAX, 
					    #  SAPRC99, SAPRC99Q, SAPRC99X)
#=================================================================================


##################################################################################
########               Read paths from 'setcase.csh' script               ########  

var1=MGNHOME
var2=MGNINP
var3=MGNINT
var4=MGNOUT

while read cmd var1 val1 var2 val2 var3 val3 var4 val4
do
  if [[ $cmd == "setenv" ]]
  then
    declare -x "$var1=$val1"
    declare -x "$var2=$val2"
    declare -x "$var3=$val3"
    declare -x "$var4=$val4"
  fi
done < ../setcase.csh  > /dev/null 2>&1

# Remove quotation marks
MGNHOME="${MGNHOME%\"}"
MGNHOME="${MGNHOME#\"}"

eval MGNINP=("$MGNINP")
eval MGNINT=("$MGNINT")
eval MGNOUT=("$MGNOUT")

##################################################################################
########                          Set directories                         ########

if [ $SCRIPT_NAME == $modified_met2mgn ]
then 
   INPUT_PATH=$MGNINP/MCIP/${DOMAIN_SIZE}
   OUTPUT_PATH=$MGNINP/MGNMET
   GRIDDESC_PATH=${INPUT_PATH}/GRIDDESC
elif [ $SCRIPT_NAME == $modified_daymet ] || [ $SCRIPT_NAME == $modified_megsea ]
then 
   INPUT_PATH=$MGNINP/MGNMET
   OUTPUT_PATH=$MGNINT
   GRIDDESC_PATH=$MGNINP/MCIP/${DOMAIN_SIZE}/GRIDDESC
elif [ $SCRIPT_NAME == $modified_megcan ] || [ $SCRIPT_NAME == $modified_megvea ]
then 
   INPUT_PATH=$MGNINP/MAP
   OUTPUT_PATH=$MGNINT
   GRIDDESC_PATH=$MGNINP/MCIP/${DOMAIN_SIZE}/GRIDDESC 
elif [ $SCRIPT_NAME == $modified_mgn2mech ]
then
   INPUT_PATH=$MGNINP/MAP
   OUTPUT_PATH=$MGNOUT
   GRIDDESC_PATH=$MGNINP/MCIP/${DOMAIN_SIZE}/GRIDDESC
fi


INITRUN=$INITIAL_RUN
PROJNAME=$CMAQ_WORKFLOW_PROJECT_NAME
DOMNAME=$CMAQ_WORKFLOW_DOMAIN_NAME_STRING
dom=$DOMAIN_SIZE
INPPATH=$INPUT_PATH
OUTPATH=$OUTPUT_PATH
GRIDDESC=$GRIDDESC_PATH


##################################################################################
########                   Loop over the simulation days                  ########

for ((i=START_DATE;i<=END_DATE;i++));
do
  STJD=$i
  EDJD=$i
  export STJD
  export EDJD
  export INITRUN
  export PROJNAME
  export DOMNAME 
  export NLAI
  export MECH
  export INPPATH
  export OUTPATH
  export dom
  export GRIDDESC
  ./$SCRIPT_NAME
done
