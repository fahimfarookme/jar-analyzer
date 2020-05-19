#!/bin/bash

# Copyright (c) 2020 Fahim Farook
# Released under the terms of the MIT License 

file="jar-analyzer.properties"

function property {
   key=$1
   cat $file | grep "$key" | cut -d "=" -f2
}

temp_dir=$(property temp.dir)
if [ -d "$temp_dir" ]
then
   rm -rf $temp_dir
fi

mkdir $temp_dir

jar_dir=$(property jar.dir)
if [ ! -z $jar_dir ]
then
   printf "Copying jars from $jar_dir.\n"
   find $jar_dir -type f -name '*.jar' -exec cp {} $temp_dir/  \;
fi

project_dir=$(property project.dir)
if [ ! -z $project_dir ]
then
  $project_dir/mvnw dependency:copy-dependencies -Dmdep.prependGroupId=true -DoutputDirectory=$temp_dir
fi

class_names=$(property class.names) 
cd $temp_dir
printf "Finding $class_names in $temp_dir.\n\n"
for j in ./*.jar ; do
  jar tf $j | grep -e .class$ | nl -s "$j -> " | cut -c 7- | grep -E "/($class_names)"
done
