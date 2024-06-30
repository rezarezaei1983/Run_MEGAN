#! /bin/csh -f
########################################################################
source ../setcase.csh
## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv PROG   megvea
setenv EXEDIR $MGNEXE 
setenv EXE    $EXEDIR/$PROG

# Input map data directory
setenv INPDIR $INPPATH

# Output directory
setenv OUTDIR $OUTPATH

# Log directory
setenv LOGDIR $MGNLOG/megvea
mkdir -p $LOGDIR

########################################################################

setenv Layers 5	         # canopy vertical layers, default is 5
setenv NLAI $NLAI

# User's options to select specific emission activity factors to be applied
setenv GAMAQ_YN   N      # [Y/N]: Y applies air quality stress; default is N
		         #        if set to Y, user needs to set AQFILE below
setenv GAMCO2_YN  N      # [Y/N]: Y applies emission response to CO2; default is N
setenv GAMHW_YN   N      # [Y/N]: Y applies emission response to high wind storm; default is N
setenv GAMHT_YN   N      # [Y/N]: Y applies emission response to high temperature; default is N
setenv GAMLT_YN   N      # [Y/N]: Y applies emission response to low temperature; default is N
setenv GAMSM_YN   N      # [Y/N]: Y applies emission response to soil moisture; default is N
setenv GAMBD_YN   N      # [Y/N]: Y applies bidirectional exchange LAI response; default is N

########################################################################

foreach dom ( $dom )
set JD = $STJD
while ($JD <= $EDJD )
########################################################################
# Set up time and date to process
setenv SDATE $JD        #start date
setenv STIME 0
setenv RLENG 240000

########################################################################

########################################################################
# Set up for MEGAN
setenv RUN_MEGAN   Y       # Run megan?

# Grid definition
setenv GRIDDESC $GRIDDESC
setenv GDNAM3D ${dom}

# number of previous days used for Max/Min temeprature/wind speed
if ( $JD == 2018122 ) then
setenv N_MaxT 1		# Number of past days for maximum temperature to be used
                        # [neglected if GAMHT_YN is set to N]
setenv N_MinT 1		# Number of past days for minimum temeprature to be used
                        # [neglected if GAMLT_YN is set to N]
setenv N_MaxWS 1        # number of past days for maximum wind speed to be used
                        # [neglected if GAMHW_YN is set to N]
else
setenv N_MaxT 2         # Number of past days for maximum temperature to be used
                        # [neglected if GAMHT_YN is set to N]
setenv N_MinT 2         # Number of past days for minimum temeprature to be used
                        # [neglected if GAMLT_YN is set to N]
setenv N_MaxWS 2        # Number of past days for maximum wind speed to be used
                        # [neglected if GAMHW_YN is set to N]
endif

# LAIS46
setenv LAIFILE $INPDIR/LAI3_$GDNAM3D.ncf

# CANMET
setenv CANMET $MGNINT/CANMET.$GDNAM3D.${SDATE}.ncf

# DailyMET
setenv DailyMET $MGNINT/DAYMET.$GDNAM3D.${SDATE}.ncf

# MEGSEA output
setenv SMFILE $MGNINT/MGNSEA.$GDNAM3D.${SDATE}.ncf

# AQFILE (required if GAMAQ_YN is set to Y)
setenv AQFILE $INPDIR/W126_$GDNAM3D.ncf

# LDFILE
setenv LDFILE $INPDIR/LDF_$GDNAM3D.2019b.ncf

# Output
setenv MGNERS $MGNINT/MGNERS.$GDNAM3D.${SDATE}.ncf

########################################################################
## Run MEGAN
if ( $RUN_MEGAN == 'Y' ) then
   rm -f $MGNERS
   $EXE | tee $LOGDIR/log.run.$PROG.$GDNAM3D.$SDATE.txt
endif

@ JD++
end  # End while JD

end # dom


echo ""
echo "================================================================="
echo "Output Dir. ==> $MGNINT"
echo "Log Dir.    ==> $LOGDIR"
echo "================================================================="
echo ""
