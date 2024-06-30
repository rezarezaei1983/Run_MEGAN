#! /bin/csh -f
########################################################################
source ../setcase.csh
## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv PROG   megsea
setenv EXEDIR $MGNEXE 
setenv EXE    $EXEDIR/$PROG
# Input map data directory
setenv INPDIR $MGNINP/MAP

# Number of LAI records
setenv NLAI $NLAI

# Met data directory
setenv METDIR $INPPATH

# Output directory
setenv OUTDIR $OUTPATH

# Log directory
setenv LOGDIR $MGNLOG/megsea
mkdir -p $LOGDIR

setenv GAMSM_MODEL F #T:G2006 model F:Jiang et al. 2018 
########################################################################


foreach dom ( $dom )# TEX_09 CAL_09 )

setenv DOMAIN `echo $dom | cut -d '_' -f1`
setenv GRIDDESC $GRIDDESC
setenv SDATE $STJD
setenv EDATE $EDJD  


set JD = $SDATE
while ($JD <= $EDATE )
setenv EPISDATE $JD # Episode start date
setenv EPIEDATE $JD # Episode start date


setenv Y4  `echo $JD | cut -c 1-4`
setenv nday `echo $JD | cut -c 5-7`
@ nday = $nday - 1
setenv Y2  `echo $JD | cut -c 3-4`
setenv CAL_DATE `date -d "${Y4}0101 +${nday} day" +%Y%m%d`
setenv MM `echo $CAL_DATE | cut -c 5-6`
setenv DD `echo $CAL_DATE | cut -c 7-8`

set GD = $CAL_DATE
set m = `echo $GD | cut -c 5-6 | sed 's/^0//g'`
########################################################################
# Set up time and date to process
setenv SDATE $JD        #start date
setenv STIME 0
setenv RLENG 240000
setenv MONTH $m

@ JDnext = $JD + 1

########################################################################

########################################################################
# Set up for MEGAN
setenv RUN_MEGAN   Y       # Run megan?

# Grid definition
setenv GDNAM3D ${dom}

########### START OF SETTING BDSNP SOIL NO ###############
# New in MEGAN3.1
# YL (BDSNP=N) or Berekely Dalhousie (BDSNP=Y) for soil NO estimation?
setenv BDSNP_YN        N      # [Y/N]: Y uses Berekely Dalhousie for soil NO calculation;
                              # N uses YL95 (same as older MEGAN versions);
                              # if Y is chosen, user needs to provide additional input data
setenv EPIC            N      # [Y/N]: Y uses EPIC model output for fertilizer;
                              # N uses default MEGAN provided fertilizer input
if ( $BDSNP_YN == Y ) then
setenv PX_VERSION      N      # MCIP must be PX version when using BDSNP option

if ( $JD == $EPISDATE ) then
setenv INITIAL_RUN     $INITRUN   # Initial run if the model hasn't been run before;
                                  # otherwise set to false and a restart file is needed
else
setenv INITIAL_RUN     $INITRUN   # Initial run if the model hasn't been run before;
                                  # otherwise set to false and a restart file is needed

# Restart file from running previous day
setenv SOILINSTATE $MGNINT/SOILINSTATE.$GDNAM3D.$JD.ncf
endif # INITIAL_RUN
# Additional input files for BDSNP algorithm
# canopy climate conditions
setenv CANMET $OUTDIR/CANMET.$GDNAM3D.${SDATE}.ncf
# climate file, nonarid
setenv CLIMAFILE $INPDIR/ARID_${GDNAM3D}.ncf
# climate file, arid
setenv CLIMNAFILE $INPDIR/NONARID_${GDNAM3D}.ncf
# biome type file
setenv LANDTYPEFILE $INPDIR/LANDTYPE_${GDNAM3D}.ncf
# Nitrogen deposition file
setenv NDEPFILE $INPDIR/NDEP_${GDNAM3D}.ncf
# fertilizer reservoir file
if ( $EPIC == N ) then
setenv FERTRESFILE $INPDIR/FERT_${GDNAM3D}.ncf
else
# if using EPIC model for fertilizer input
setenv EPICRESFILE $INPDIR/EPIC_$GDNAM3D.ncf
endif

# Restart file for next day
setenv SOILOUT $MGNINT/SOILINSTATE.$GDNAM3D.$JDnext.ncf
rm -f $SOILOUT

endif
######## END OF SETTINGS FOR BDSNP NO ##############

# CANTYP
setenv CANTYP $INPDIR/CT3_$GDNAM3D.ncf

# LAIS46
setenv LAIFILE $INPDIR/LAI3_$GDNAM3D.ncf

# MGNMET
setenv MGNMET $METDIR/MET.MEGAN.$GDNAM3D.rad45.${JD}.ncf

# Output
setenv MGNSEA $MGNINT/MGNSEA.$GDNAM3D.${SDATE}.ncf

########################################################################
## Run MEGAN
if ( $RUN_MEGAN == 'Y' ) then
   rm -f $MGNSEA
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

