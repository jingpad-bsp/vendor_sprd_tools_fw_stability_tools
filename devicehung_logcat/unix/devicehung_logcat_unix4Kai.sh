#!/bin/bash

#define folder:
folder="./iMylog"
inptFolder="./inputLog"
stackFolder="./dztProStack"
scapFolder="./scapLog"
comLogFolder="./comLog"
sfTraceFolder="./sfTrace"
hproFolder="./hprofs"
dpboxFolder="./dropbox"
dmpFolder="./dmp"
dpboxDir="/data/system/dropbox"
corefileDir="/data/corefile/"
tombsDir="/data/tombstones/"
dmpDir="/data/b2g/mozilla/Crash\ Reports/pending"
core2Folder="./core2Folder"
tombsFolder="./tombsFolder"
anrDir="/data/anr/"

#define files:
tmpLogFile="./tmpLogFile.txt"
bugReptFile="/bReport.txt"
#aLog.txt use for record cmd
aLogFile="./aLog.txt"
topFile=$comLogFolder"/top.txt"
sfTraceFile=$sfTraceFolder"/sfTrace.txt"
sflingerFile=$sfTraceFolder"/sFlinger.txt"
logcatFile=$comLogFolder"/logcat.txt"
kmsgFile=$comLogFolder"/kmsg.txt"
transLogFile=$comLogFolder"/transLog.txt"
transFile=$comLogFolder"/trans.txt"
psFile=$comLogFolder"/ps.txt"
sysrqFile="/proc/sysrq-trigger"
systemFdsFile=$comLogFolder"/sysFds.txt"
scapFile=$scapFolder"/scrcap.png"
stackFiles=$stackFolder"/dztPids.txt"
kInptFile=$inptFolder"/kInptLog.txt"
fwInptFile=$inptFolder"/fwInptLog.txt"
gEventFile=$inptFolder"/gEventLog.txt"
traceFile="/data/anr/traces.txt" 
preTraceFile="/data/anr/traces_old.txt"

#0. check device:
rm -rf $aLogFile
echo "step0 check device begin">>$aLogFile
adb shell date
adb devices
echo $? >>$aLogFile

sleep 5
adb wait-for-device
echo "- device connected!-"

adb root
sleep 3
#adb remount
echo "step0 check device end">>$aLogFile

#1.create folders:
echo -e "\nCreate local log folder:"
#create log folder:
if [ ! -d "$folder" ]; then 
  echo "mkdir MyLog Folder"
  mkdir "$folder"
else
  echo "rm Mylog Folder"
  rm -rf $folder/* 
fi
mv $aLogFile $folder
cd "$folder"

echo -e "\nstep1 create folders begin">>$aLogFile
#create input folder:
echo "step1 InputLog folder begin">>$aLogFile
if [ ! -d "$inptFolder" ]; then 
  echo "mkdir InputLog Folder"
  mkdir -p "$inptFolder"
fi
echo "step1 InputLog folder end">>$aLogFile

#create scrcap folder:
echo "step1 Screencap folder begin">>$aLogFile
if [ ! -d "$scapFolder" ]; then 
  echo "mkdir Screencap Folder"
  mkdir -p "$scapFolder"
fi
echo "step1 Screencap folder end">>$aLogFile

#create scrcap folder:
echo "step1 dmp folder begin">>$aLogFile
if [ ! -d "$dmpFolder" ]; then 
  echo "mkdir dmp Folder"
  mkdir -p "$dmpFolder"
fi
echo "step1 Screencap folder end">>$aLogFile

#create common folder:
echo "step1 CommonLog folder begin">>$aLogFile
if [ ! -d "$comLogFolder" ]; then 
  echo "mkdir CommonLog Folder"
  mkdir -p "$comLogFolder"
fi
echo "step1 CommonLog folder end">>$aLogFile

#create tombsFolder folder:
echo "step1 Tombstones folder begin">>$aLogFile
if [ ! -d "$tombsFolder" ]; then  
  echo "mkdir Tombstones Folder"
  mkdir -p "$tombsFolder"
fi
echo "step1 Tombstones folder end">>$aLogFile
echo "step1 create folders end">>$aLogFile

#2.device info:
echo -e "\nstep2 get device info begin">>$aLogFile
echo -e "\nDeviceinfo:">>$tmpLogFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [serialno]=`adb shell getprop ro.serialno`" >>$tmpLogFile 
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [build.description]=`adb shell getprop ro.build.description`" >>$tmpLogFile
#adb -s devices1 shell | adb -s devices1 cmd
echo "step2 get device info end">>$aLogFile

#3.get common log:
echo -e "\nstep3 get common info begin">>$aLogFile
echo "step3 exec ps cmd">>$aLogFile
adb shell ps > $psFile &
echo "step3 logcat cmd">>$aLogFile
adb shell logcat -v threadtime >$logcatFile &
echo "step3 kmsg cmd">>$aLogFile
adb shell cat /proc/kmsg >$kmsgFile &

tsCnt=`adb shell ls $tombsDir |wc -l`
echo -e "\nTombstones Cnt is = $tsCnt"
echo "step3 pull tombstones begin">>$aLogFile
if [ "$tsCnt" -ne 0 ]; then
  echo "Pulling Tombstones"
  adb shell chmod 777 $tombsDir/tomb* 2>&1|tee -a $tmpLogFile &
  adb pull $tombsDir $tombsFolder 2>&1|tee -a $tmpLogFile &
fi
echo "step3 pull tombstones end">>$aLogFile
echo "step3 get common info end">>$aLogFile

#get dmp file: /data/b2g/mozilla/Crash\ Reports/pending
dmpCnt=`adb shell ls $dmpDir |wc -l`
echo -e "\nb2g dmpCnt is = $dmpCnt"
echo "step3 pull dmpFile begin">>$aLogFile
if [ "$dmpCnt" -ne 0 ]; then
  echo "Chmod dmpFiles"
  adb shell chmod 777 $dmpDir/* 2>&1|tee -a $tmpLogFile &
  echo "Pulling dmpFiles"
  adb shell cp $dmpDir/* $anrDir 2>&1|tee -a $tmpLogFile &
  adb pull $anrDir $dmpFolder 2>&1|tee -a $tmpLogFile &
fi
echo "step3 pull dmpFile end">>$aLogFile
sleep 3

#4.check key/touch driver ok?
echo -e "\nstep4 check key/touch driver is ok begin">>$aLogFile
echo -e "\nPlease In Order to Press Power key,Volume and Other Key:" 2>&1|tee -a $tmpLogFile
adb shell date >>$aLogFile

sleep 5
adb shell getevent > $gEventFile &
sleep 1
adb shell cat /proc/kmsg > $kInptFile &

sleep 2

#kill proc:getevent :
echo "step4 getEvent pid begin">>$aLogFile
getEventPid=`adb shell ps -t|grep getevent | awk '{print $2}'`
echo "getEventPid is $getEventPid"
for pid in $getEventPid
do
    echo "Kill Process getevent Pid = $pid"
    adb shell kill -9 $pid &
    sleep 1
done
echo "step4 getEvent pid end">>$aLogFile
echo "step4 check key/touch driver is ok end">>$aLogFile

#5.check b2g state:
echo -e "\nGet b2g-ps begin:">>$tmpLogFile
adb shell b2g-ps --oom >> $tmpLogFile &
echo "\nstep5 b2g-ps end">>$aLogFile

b2gPid=`adb shell ps |grep b2g | awk '{print $2}'`
echo "b2gPid is $b2gPid"
for pid in $b2gPid
do
    echo "B2g Process Pid = $pid"
    echo -e "\nDump $pid trace:">>$tmpLogFile
    adb shell debuggerd -b $pid >>$tmpLogFile
    sleep 1
    break
done

#6.start brightness:
echo -e "\nstep6 brightness begin">>$aLogFile
backLightVal=`adb shell cat /sys/class/backlight/sprd_backlight/brightness`
echo -e "\nThe BackLightVal is = $backLightVal"

sleep 2

echo "step6 start screencap begin">>$aLogFile
adb shell /system/bin/screencap -p > $scapFile &
echo "step6 start screencap end">>$aLogFile
echo "step6 screencap end">>$aLogFile

#7.get memoryinfo:
echo "\nstep7 get b2g meminfo end">>$aLogFile
echo -e "\nGet b2g-info:">>$tmpLogFile
adb shell b2g-info >>$tmpLogFile
echo "\nstep7 get b2g meminfo end">>$aLogFile

#8.get each partition size:
echo -e "\nstep8 get each partition size begin">>$aLogFile
echo -e "\nEach Partition Size info :">>$tmpLogFile
adb shell df >>$tmpLogFile &
echo "step8 get each partition size end">>$aLogFile

sleep 1

adb shell date
sleep 10

exit 1
