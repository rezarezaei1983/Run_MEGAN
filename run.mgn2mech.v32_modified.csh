#! /bin/csh -f
########################################################################
source ../setcase.csh
## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv PROG   mgn2mech
setenv EXEDIR $MGNEXE 
setenv EXE    $EXEDIR/$PROG

# Input map data directory
setenv INPDIR $INPPATH

setenv GRIDDESC $GRIDDESC

# Intermediate file directory
setenv INTDIR $MGNINT

# Output directory
setenv OUTDIR $OUTPATH

# MCIP input directory
setenv METDIR $MGNINP/MGNMET

# Log directory
setenv LOGDIR $MGNLOG/$PROG
if ( ! -e $LOGDIR ) mkdir -p $LOGDIR
########################################################################

foreach mech ( $MECH )
foreach dom ( $dom )
set JD = $STJD
while ($JD <= $EDJD)
########################################################################
# Set up time and date to process
setenv SDATE $JD        #start date
setenv STIME 0
setenv RLENG 240000
setenv TSTEP 10000
########################################################################

########################################################################
# Set up for MECHCONV
setenv RUN_SPECIATE   Y    # run MG2MECH

setenv RUN_CONVERSION Y    # run conversions?
                           # run conversions MEGAN to model mechanism
                           # units are mole/s

setenv SPCTONHR       N    # speciation output unit in tonnes per hour
                           # This will convert 138 species to tonne per
                           # hour or mechasnim species to tonne per hour.
setenv BDSNP_YN       N    # Using BDSNP estimated soil NO? This flag needs
	                   # to be consistent with that in MEGSEA step
                           
# If RUN_CONVERSION is set to "Y", one of mechanisms has to be selected.
#setenv MECHANISM    RADM2
#setenv MECHANISM    RACM
#setenv MECHANISM    CBMZ
#setenv MECHANISM    CB05
setenv MECHANISM    $mech
#setenv MECHANISM    SOAX
#setenv MECHANISM    SAPRC99
#setenv MECHANISM    SAPRC99Q
#setenv MECHANISM    SAPRC99X

# Grid name
setenv GDNAM3D ${dom} 

# EFMAPS NetCDF input file
setenv EFMAPS  $INPDIR/EFMAP.2019b.$GDNAM3D.ncf

# MEGAN ER filename
setenv MGNERS $INTDIR/MGNERS.$GDNAM3D.${SDATE}.ncf

# MEGSEA filename
setenv MGNSEA $INTDIR/MGNSEA.$GDNAM3D.${SDATE}.ncf

# Output filename
if ( $BDSNP_YN == Y ) then
setenv MGNOUT $OUTDIR/MEGANv32.$GDNAM3D.$MECHANISM.$SDATE.BDSNP.ncf
else
setenv MGNOUT $OUTDIR/MEGANv32.$GDNAM3D.$MECHANISM.$SDATE.ncf
endif

########################################################################
## Run speciation and mechanism conversion
if ( $RUN_SPECIATE == 'Y' ) then
   rm -f $MGNOUT
   $EXE | tee $LOGDIR/log.run.$PROG.$GDNAM3D.$MECHANISM.$SDATE.txt
endif

@ JD++
end  # End while JD

end # dom
end # mech


echo ""
echo "================================================================="
echo "Output Dir. ==> $OUTDIR"
echo "Log Dir.    ==> $LOGDIR"
echo "================================================================="
echo ""
