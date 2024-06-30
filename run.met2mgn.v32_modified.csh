#! /bin/csh -f
#
# MET2MGN v3
# --
#
#
# TPAR2IOAPI v2.03a 
# --added 26-category landuse capability for mm5camx (number of landuse categories defined by NLU) 
# --added capability for LATLON and UTM projections
# --added capability for MCIP v3.3 input (2m temperatures)
# --bug in PAR processing subroutine fixed where first few hours in GMT produced zero PAR
# --added code to fill missing par data (if valid data exists for the hours surrounding it)
#
# TPAR2IOAPI v2.0
# --added capability for MM5 or MCIP input
# 
#
#        RGRND/PAR options:
#           setenv MM5RAD  Y   Solar radiation obtained from MM5
#           OR 
#           setenv MCIPRAD Y   Solar radiation obtained from MCIP
#                  --MEGAN will internally calculate PAR for each of these options and user needs to  
#                    specify `setenv PAR_INPUT N' in the MEGAN runfile
#           OR
#           setenv SATPAR Y (satellite-derived PAR from UMD GCIP/SRB files)
#                  --user needs to specify `setenv PAR_INPUT Y' in the MEGAN runfile
#
#        TEMP options:
#           setenv CAMXTEMP Y         2m temperature, calculated from mm5camx output files
#           OR
#           setenv MM5MET  Y         2m temperature, calculated from MM5 output files
#                                     Note: 2m temperature is calculated since the P-X/ACM PBL
#                                     MM5 configuration (most commonly used LSM/PBL scheme for AQ 
#                                     modeling purposes) does not produce 2m temperatures.
#           OR
#           setenv MCIPMET Y         temperature obtained from MCIP
#              -setenv TMCIP  TEMP2   2m temperature, use for MCIP v3.3 or newer
#              -setenv TMCIP  TEMP1P5 1.5m temperature, use for MCIP v3.2 or older
#
#        TZONE   time zone for input mm5CAMx files 
#        NLAY    number of layers contained in input mm5CAMx files 
#        NLU     number of landuse categories contained in CAMx landuse file 
#

############################################################

# Setting up episode   IMPORTANT: you cannot run a period a few days at a time.  You must run the entire period at once.  If additional days are required, extend the period and run the entire thing again (this is due to the PFILE issue, see: ../Input/MGNMET/QA_steps/README.txt)
############################################################
source ../setcase.csh
foreach dom ( $dom )
#foreach dom ( 4km )                      # <<< Orijinal skriptte açık
#setenv sJDATE 2012153    #2018122        # <<< Orijinal skriptte açık
#setenv eJDATE 2012243    #2018122        # <<< Orijinal skriptte açık
#setenv STJD $sJDATE[$ii]             
#setenv EDJD $eJDATE[$ii]            
#setenv STJD $sJDATE                      # <<< Orijinal skriptte açık
#setenv EDJD $eJDATE                      # <<< Orijinal skriptte açık

#set INPPATH     = $MGNINP/MCIP/${dom}    # <<< Orijinal skriptte açık
#set OUTPATH     = $MGNINP/MGNMET         # <<< Orijinal skriptte açık

#set for grid
#setenv GRIDDESC ${INPPATH}/GRIDDESC      # <<< Orijinal skriptte açık
setenv GDNAM3D ${dom}
setenv MET_FILE_END ${dom}.nc 

# Output directory
setenv OUTDIR  # ***************************************************



# Setting up directories and common environment variable
############################################################

setenv PROG met2mgn
setenv EXE $MGNEXE/$PROG
#setenv EXE /disk8/MEGAN3_1/source_code/MEGAN3_1/src/MET2MGN/$PROG


set logdir = logdir/$PROG
if ( ! -e $logdir) mkdir -p $logdir

if (! -e $OUTPATH) mkdir $OUTPATH

setenv PFILE $OUTPATH/PFILE

# Looping
############################################################
set JDATE = $STJD
while ($JDATE <= $EDJD)
setenv EPISODE_SDATE $JDATE
setenv EPISODE_STIME 000000   
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" 
echo $JDATE is processing
rm -fv $PFILE
echo $PFILE
if ($JDATE == 2007366) setenv JDATE 2008001
if ($JDATE == 2008367) setenv JDATE 2009001
if ($JDATE == 2011366) setenv JDATE 2012001
if ($JDATE == 2012367) setenv JDATE 2013001
if ($JDATE == 2013366) setenv JDATE 2014001

@ jdy  = $JDATE - 2000000
setenv Y4  `echo $JDATE | cut -c 1-4`
setenv nday `echo $JDATE | cut -c 5-7`
@ nday = $nday - 1                    
setenv Y2  `echo $JDATE | cut -c 3-4`
setenv CAL_DATE `date -d "${Y4}0101 +${nday} day" +%Y%m%d`
setenv MM `echo $CAL_DATE | cut -c 5-6`
setenv DD `echo $CAL_DATE | cut -c 7-8`
@ JDATEm1 = $JDATE - 1

if ($JDATEm1 == 2007000) setenv JDATEm1 2006365
if ($JDATEm1 == 2008000) setenv JDATEm1 2007365
if ($JDATEm1 == 2009000) setenv JDATEm1 2008366
if ($JDATEm1 == 2012000) setenv JDATEm1 2011365
if ($JDATEm1 == 2013000) setenv JDATEm1 2012366
@ jdym1  = $JDATEm1 - 2000000
#set Y4m1 = `yj2ymd $JDATEm1 | awk '{print $1}'`  
#set Y2m1 = `echo $Y4m1 | cut -c 3-4`             
#set MMm1 = `yj2ymd $JDATEm1 | awk '{print $2}'`  
#set DDm1 = `yj2ymd $JDATEm1 | awk '{print $3}'` 

setenv Y4m1  `echo $JDATEm1 | cut -c 1-4`       
setenv daym1 `echo $JDATEm1 | cut -c 5-7`       
@ daym1 = $daym1 - 1                          
setenv Y2m1  `echo $JDATEm1 | cut -c 3-4`       
setenv CLDATEm1 `date -d "${Y4}0101 +${daym1} days" +%Y%m%d`  
setenv MMm1 `echo $CLDATEm1 | cut -c 5-6`       
setenv DDm1 `echo $CLDATEm1 | cut -c 7-8`

echo $Y4m1$MMm1$DDm1



#set start/end dates
setenv STDATE ${jdy}00
setenv ENDATE ${jdy}23

#TEMP/PAR input choices
#
#set if using MM5 output files
setenv MM5MET N
setenv MM5RAD N
#setenv numMM5 2
#setenv MM5file1 /pete/pete5/fcorner/met/links/MMOUT_DOMAIN1_G$Y4$MM$DD
#setenv MM5file2 /pete/pete5/fcorner/met/links/MMOUT_DOMAIN1_G$Y4$MM$DD

#set if using UMD satellite PAR data
set PARDIR = $MGNINP/PAR
setenv SATPAR N
set satpar1 = "$PARDIR/$Y2m1${MMm1}par.h"
set satpar2 = "$PARDIR/$Y2${MM}par.h"

if ($satpar1 == $satpar2) then
  setenv numSATPAR 1
  setenv SATPARFILE1 $satpar2
else
  setenv numSATPAR 2
  setenv SATPARFILE1 $satpar1
  setenv SATPARFILE2 $satpar2
endif

#set if using MCIP output files
setenv MCIPMET Y
setenv TMCIP  TEMP2          #MCIP v3.3 or newer
#setenv TMCIP  TEMP1P5       #MCIP v3.2 or older
setenv SOICRO_YN  Y      # [Y/N] set Y for MCIP4.5+ to read soil moisture/soil
                         # temperature from SOI_CRO file


#set PROJNAME = "thesis"   # <<< ben ekledim
#set DOMNAME = "marmara"   # <<< ben ekledim

setenv MCIPRAD Y
if ($JDATE == $EPISODE_SDATE) then
  setenv METCRO2Dfile1 ${INPPATH}/METCRO2D_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
  #setenv METCRO2Dfile1 $INPPATH/METCRO2D_$MET_FILE_END    # <<< Orig
  if ( $SOICRO_YN == Y ) then
   setenv SOICROfile1   ${INPPATH}/SOI_CRO_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
   #setenv SOICROfile1   $INPPATH/SOI_CRO_$MET_FILE_END    # <<< Orig
  endif
else
  setenv METCRO2Dfile1 ${INPPATH}/METCRO2D_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
  #setenv METCRO2Dfile1 $INPPATH/METCRO2D_$MET_FILE_END    # <<< Orig
  setenv METCRO2Dfile2 ${INPPATH}/METCRO2D_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
  #setenv METCRO2Dfile2 $INPPATH/METCRO2D_$MET_FILE_END    # <<< Orig
  if ( $SOICRO_YN == Y ) then
   setenv SOICROfile1   ${INPPATH}/SOI_CRO_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
   #setenv SOICROfile1   $INPPATH/SOI_CRO_$MET_FILE_END    # <<< Orig
   setenv SOICROfile2   ${INPPATH}/SOI_CRO_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc   # <<< ben ekledim
   #setenv SOICROfile2   $INPPATH/SOI_CRO_$MET_FILE_END    # <<< Orig
  endif

endif
setenv METCRO3Dfile  ${INPPATH}/METCRO3D_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc    # <<< ben ekledim
#setenv METCRO3Dfile  $INPPATH/METCRO3D_$MET_FILE_END      # <<< Orig
setenv METDOT3Dfile  ${INPPATH}/METDOT3D_${PROJNAME}_${dom}_${DOMNAME}_$Y4$MM$DD.nc    # <<< ben ekledim
#setenv METDOT3Dfile  $INPPATH/METDOT3D_$MET_FILE_END      # <<< Orig 

setenv OUTFILE $OUTPATH/MET.MEGAN.$GDNAM3D.rad45.$JDATE.ncf
rm -rf $OUTFILE

$EXE |tee $logdir/log.$PROG.$GDNAM3D.rad45.$JDATE.txt 

@ JDATE++
end  # End while JDATE
end  # End foreach dom

echo ""
echo "======================================================================"
echo "Output Dir. ==> $OUTPATH"                                                        # <<< ben ekledim
echo "Log Dir.    ==> $MGNLOG/$PROG"                                                   # <<< ben ekledim
echo "======================================================================"
echo ""
