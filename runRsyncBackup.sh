#!/bin/sh

###################################
# rsync_script
# author : xblood
###################################

#create file name
fileName=backup_log_`date +%Y%m%d%H%M%S`.log
echo fileName = ${fileName}

#check success file
successFileName=success_`date +%Y%m%d`.txt
SFCount=`ls -l  ./logs/success/${successFileName} | wc -l`
echo ${SFCount}

# if exist success file, finish shell script
if [ ${SFCount} -ge 1 ]; then
#finish today's running
  exit 0
fi

#H drive mount flg
h="0" 
#Z drive mount flg
z="0" 

#get mount information and set flg
for textfile in $( ls /mnt/ ); do
  if [ "h" = ${textfile} ]; then
    h=1 
  elif [ "z" = ${textfile} ]; then
    z=1
  fi
done

# H -> Z
if [ ${h} = 1 -a ${z} = 1 ]; then
  echo run backup from H drive to Z drive
  bash rsync_from_H_to_Z.sh >> ./logs/${fileName}
else
  echo H drive or Z drive unmount
fi

# create success file
touch ./logs/success/${successFileName}

# send to slack channel
echo "Successful backup process with rsync script.
Log File Name : ${fileName}
Success File Name(=Date) : ${successFileName}
Mount Status : h=${h}, z=${z}" | bash sendResultToSlack.sh

exit 0