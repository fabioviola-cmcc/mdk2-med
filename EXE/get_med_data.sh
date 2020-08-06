#!/bin/bash

#####################################################
#
# Base configuration
#
#####################################################

# APPNAME: a variable used to print the program name in debug messages
APPNAME=$(basename $0)

# SRC_BASE_PATH: the location of original MED files
SRC_BASE_PATH=/data/inputs/metocean/rolling/ocean/CMCC/CMEMS/1.0forecast/1h/

# WORK_PATH: the work and output directory
WORK_PATH="./"

# PROD_DATE: the production date
PROD_DATE=20200729


#####################################################
#
# Process files for U and V
#
#####################################################

# debug print
echo "[$APPNAME] -- Start processing U and V files..."

# loop over input files
for ORIG_INPUT_FILE in $SRC_BASE_PATH/$PROD_DATE/*--RFVL-MFSeas5*; do

    # debug print
    echo "[$APPNAME] -- Reading file $ORIG_INPUT_FILE"

    # save the basename of the input file
    INPUT_FILE=$(basename $ORIG_INPUT_FILE)
    
    # remove useless depth levels TODO
    ncks -H -d depth,1.018237 -d depth,10.53660 -d depth,29.88564 -d depth,119.8554 ${ORIG_INPUT_FILE} -o ${WORK_PATH}/${INPUT_FILE}_step0 

    
    #####################################################
    #
    # U file
    #
    #####################################################

    # debug print
    echo "[$APPNAME] -- Started working on U file..."

    # convert files to netcdf3 in order to rename variables
    ncks -3 ./${INPUT_FILE}_step0 ./${INPUT_FILE}_step1

    # rename dimensions and variables
    ncrename -O -d lat,y -d lon,x -d depth,depthu -v lon,nav_lon -v lat,nav_lat -v time,time_counter -v uo,vozocrtx ${WORK_PATH}/${INPUT_FILE}_step1    
    
    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step1
    
    # back to netcdf 4
    ncks -4 ${WORK_PATH}/${INPUT_FILE}_step1 ${WORK_PATH}/${INPUT_FILE}_step2
    
    # remove variables
    ncks -x -v vo ${WORK_PATH}/${INPUT_FILE}_step2 MDK_ocean_${INPUT_FILE:2:6}_U.nc

    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step2

    # debug print
    echo "[$APPNAME] -- Generated file MDK_ocean_${INPUT_FILE:2:6}_U.nc"

    
    #####################################################
    #
    # V file
    #
    #####################################################
    
    # debug print
    echo "[$APPNAME] -- Started working on V file..."

    # convert files to netcdf3 in order to rename variables
    ncks -3 ${WORK_PATH}/${INPUT_FILE}_step0 ${WORK_PATH}/${INPUT_FILE}_step1       
    
    # rename dimensions and variables
    ncrename -O -d lat,y -d lon,x -d depth,depthv -v lon,nav_lon -v lat,nav_lat -v time,time_counter -v uo,vomecrty ${WORK_PATH}/${INPUT_FILE}_step1

    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step1
    
    # back to netcdf 4
    ncks -4 ${WORK_PATH}/${INPUT_FILE}_step1 ${WORK_PATH}/${INPUT_FILE}_step2
	
    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step1

    # remove useless variables
    ncks -x -v uo ${WORK_PATH}/${INPUT_FILE}_step2 MDK_ocean_${INPUT_FILE:2:6}_V.nc

    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step2

    # debug print
    echo "[$APPNAME] -- Generated file MDK_ocean_${INPUT_FILE:2:6}_V.nc"

    # final clean
    rm ${WORK_PATH}/${INPUT_FILE}_step0 
    
done

#####################################################
#
# Process files for T
#
#####################################################

# debug print
echo "[$APPNAME] -- Start processing T files..."

# loop over input files
for ORIG_INPUT_FILE in $SRC_BASE_PATH/$PROD_DATE/*--TEMP-MFSeas5*; do

    # debug print
    echo "[$APPNAME] -- Reading file $INPUT_FILE"

    # save the basename of the input file
    INPUT_FILE=$(basename $ORIG_INPUT_FILE)   
    
    # remove useless depth levels
    ncks -H -d depth,1.018237 -d depth,10.53660 -d depth,29.88564 -d depth,119.8554 ${ORIG_INPUT_FILE} -o ${WORK_PATH}/${INPUT_FILE}_step0
    
    # convert files to netcdf3 in order to rename dimensions and variables
    ncks -3 ${WORK_PATH}/${INPUT_FILE}_step0 ${WORK_PATH}/${INPUT_FILE}_step1

    # rename dimensions and variables
    ncrename -O -d lat,y -d lon,x -d depth,deptht -v lon,nav_lon -v lat,nav_lat -v time,time_counter -v thetao,votemper ${WORK_PATH}/${INPUT_FILE}_step1
    
    # back to netcdf 4
    ncks -4 ${WORK_PATH}/${INPUT_FILE}_step1 ${WORK_PATH}/${INPUT_FILE}_step2
	
    # clean
    rm ${WORK_PATH}/${INPUT_FILE}_step1
 
    # remove useless variables
    ncks -x -v bottomT ${WORK_PATH}/${INPUT_FILE}_step2 MDK_ocean_${INPUT_FILE:2:6}_T.nc

    # final clean
    rm ${WORK_PATH}/${INPUT_FILE}_step2

    # debug print
    echo "[$APPNAME] -- Generated file MDK_ocean_${INPUT_FILE:2:6}_T.nc"

    # final clean
    rm ${WORK_PATH}/${INPUT_FILE}_step0 

done
