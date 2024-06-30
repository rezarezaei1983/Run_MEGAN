#! /bin/csh -f
########################################################################
## Common setups
source ../setcase.csh

## Directory setups
#setenv PRJ "4km" 
setenv PROMPTFLAG N

# Program directory
setenv PROG daymet
setenv EXEDIR $MGNEXE 
setenv EXE    $EXEDIR/$PROG

# Input MCIP met directory
setenv METDIR $INPPATH               # ben değiştirdim


# Output directory
setenv OUTDIR $OUTPATH               # ben değiştirdim

# Log directory
setenv LOGDIR $MGNLOG/daymet
########################################################################

# Grid definition
#foreach dom ( 36 12 )
foreach dom ( $dom )

setenv GRIDDESC $GRIDDESC
setenv GDNAM3D ${dom}                

#setenv STARTDATE 2012153            # Orijinal skriptte açık
#setenv ENDDATE 2012243              # Orijinal skriptte açık
setenv RUNDAY 1
setenv STIME 00		             # start time
setenv RLENG 230000	             # time step of meteorology files
setenv NDAYS 1                       # number of meteorology files

# loop over episode
set i = 1
while ( $i <= $RUNDAY )         
set j = `printf "%03i" $i`

#@ JDATE =  $STARTDATE + $i - 1      # <<< Orijinal hali
@ JDATE =  $STJD + $i - 1
setenv EPISDATE  $JDATE              # Episode start date

echo "EPISDATE: --> $EPISDATE"
echo "JDATE   : --> $JDATE"

# MGNMET
#setenv MGNMET$j $METDIR/MET.MEGAN.${GDNAM3D}.rad45.${JDATE}.ncf
setenv MGNMET001 $METDIR/MET.MEGAN.${GDNAM3D}.rad45.${JDATE}.ncf
# Output
setenv DailyMET $OUTDIR/DAYMET.$GDNAM3D.$JDATE.ncf

########################################################################
## Run MEGAN
rm -f $DailyMET
if ( ! -e $LOGDIR ) mkdir -p $LOGDIR
$EXE | tee $LOGDIR/log.run.$PROG.$GDNAM3D.$EPISDATE.txt
#$EXE | tee $LOGDIR/log.run.$PROG.$GDNAM3D.txt                # Orijinal hali
@ i++
end 
end # dom

echo ""
echo "================================================================="
echo "Output Dir. ==> $OUTPATH"
echo "Log Dir.    ==> $LOGDIR"
echo "================================================================="
echo ""

