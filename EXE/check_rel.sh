#!/bin/bash

# setting path
relPath=$1

# iterate over all the rel files
for relFile in $relPath/*.rel ; do 

    # debug print
    echo "Analysing file $relFile ..."

    # read the bounding box		       				      
    lonMin=$(head $relFile | grep "Geog. limits" | tr -s " " | cut -d ' ' -f 2)
    lonMax=$(head $relFile | grep "Geog. limits" | tr -s " " | cut -d ' ' -f 3)
    latMin=$(head $relFile | grep "Geog. limits" | tr -s " " | cut -d ' ' -f 4)
    latMax=$(head $relFile | grep "Geog. limits" | tr -s " " | cut -d ' ' -f 5)
    
    # extract lat and lon
    tail $relFile -n +6 | tr -s " " | cut -d " " -f 2,3 | while read -r line ; do
	stringArray=($line)
	lat=${stringArray[0]}
	lon=${stringArray[1]}
	latCheck1=$(echo $lat "<" $latMin | bc -l)
	latCheck2=$(echo $lat ">" $latMax | bc -l)
	lonCheck1=$(echo $lon "<" $lonMin | bc -l)
	lonCheck2=$(echo $lon ">" $lonMax | bc -l)

	if [[ $lonCheck1 -eq 1 || $lonCheck2 -eq 1 || $latCheck1 -eq 1 || $latCheck2 -eq 1 ]] ; then
	    echo "ERROR! Coordinates $lat $lon out of the bounding box"
	    echo "       Bounding box: lat in [$latMin,$latMax] -- lon in [$lonMin,$lonMax]"
	fi
    done
done
