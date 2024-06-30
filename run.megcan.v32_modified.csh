#! /bin/csh -f
########################################################################
source ../setcase.csh
## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv PROG   MEGCAN
setenv EXEDIR $MGNEXE  
setenv EXE    $EXEDIR/megcan

# Input map data directory
setenv INPDIR $INPPATH

# Number of LAI records
setenv NLAI $NLAI

# MCIP input directory
setenv METDIR $MGNINP/MGNMET

# Output directory
setenv OUTDIR $OUTPATH

# Log directory
setenv LOGDIR $MGNLOG/megcan
mkdir -p $LOGDIR
########################################################################

foreach dom ( $dom  )

set JD = $STJD
set ED = $EDJD
while ($JD <= $ED)
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
setenv GDNAM3D ${dom} 
setenv GRIDDESC $GRIDDESC

# CANTYP
setenv CANTYP $INPPATH/CT3_$dom.ncf

# LAIS46
setenv LAIFILE $INPPATH/LAI3_$dom.ncf

# MGNMET
setenv MGNMET $METDIR/MET.MEGAN.${dom}.rad45.${SDATE}.ncf

# Output
setenv CANMET $OUTDIR/CANMET.$dom.${SDATE}.ncf    

########################################################################
## Run MEGAN
if ( $RUN_MEGAN == 'Y' ) then
   rm -f $CANMET
   $EXE | tee $LOGDIR/log.run.$PROG.$GDNAM3D.$SDATE.txt
endif

@ JD++
end  # End while JD

end  # dom


echo ""
echo "================================================================="
echo "Output Dir. ==> $OUTDIR"
echo "Log Dir.    ==> $LOGDIR"
echo "================================================================="
echo ""
