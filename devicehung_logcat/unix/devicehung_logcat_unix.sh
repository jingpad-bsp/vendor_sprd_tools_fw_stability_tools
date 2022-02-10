#!/bin/bash

#define folder:
folder="./scene_log_01"
inptFolder="./inputLog"
stackFolder="./dzt_stack"
scapFolder="./screenshot"
sfTraceFolder="./surfaceflinger"
hproFolder="./hprofs"
dpboxFolder="./dropbox"
dpboxDir="/data/system/dropbox"
corefileDir="/data/corefile/"
tombsDir="/data/tombstones/"
propDir="/data/property/"
core2Folder="./core2Folder"
tombsFolder="./tombstone"
binderFolder="./binder"
systemserverFolder="./systemserver"
tracesFolder="./traces"
bootanimFolder="./bootanim"

#define files:
topFile="top.txt"
bootanimFile=$bootanimFolder"/bootanim.txt"
sfTraceFile=$sfTraceFolder"/stacktrace.txt"
sFlingerFile=$sfTraceFolder"/dumpsys.txt"
surflgerFdsFile=$sfTraceFolder"/fd.txt"
transLogFile=$binderFolder"/transactions_log.txt"
transFile=$binderFolder"/transactions.txt"
transFailFile=$binderFolder"/transactions.txt"
psFile="ps.txt"
sysrqFile="/proc/sysrq-trigger"
systemFdsFile=$systemserverFolder"/fd.txt"
systemMapsFile=$systemserverFolder"/maps.txt"
scapBeforeFile=$scapFolder"/scrcap_before.png"
scapAfterFile=$scapFolder"/scrcap_after.png"
stackFiles=$stackFolder"/dzt_pids.txt"
traceFile="/data/anr/traces.txt"
preTraceFile="/data/anr/traces_old.txt"
bugReportFile="bugreport.txt"
devInfoFile="deviceinfo.txt"
dfFile="df.txt"
dumpWindFile="dumpsys_window.txt"
dumpActivitysFile="dumpsys_activitys.txt"
memFile="meminfo.txt"
othersFile="others.txt"
toolFile="toollog.txt"
logcatFile="logcat.txt"
kmsgFile="kmsg.txt"
kInptFile=$inptFolder"/kInptLog.txt"
fwInptFile=$inptFolder"/fwInptLog.txt"
gEventFile=$inptFolder"/gEventLog.txt"

#var define:
ver456="4 5 6"
ver7="7"
ver8="8"
ver9="9"
ver10="10"

#0. check device:
cmd=''
devno=''
if [ "$1" ]; then
  devno=$1
  adb -s $devno root
  cmd=' -s '$devno' '
else
  adb root
  if [ ! -d "$folder" ]; then
      echo "mkdir SceneLog Folder" >>$toolFile
      mkdir "$folder"
  else
      echo "rm SceneLog Folder" >>$toolFile
      rm -rf $folder/*
  fi
  mv $toolFile $folder
  cd "$folder"
fi

#create toolFile:
if [ ! -f "$othersFile" ]; then
	touch $othersFile
else
	adb $cmd shell cat dev/null > $othersFile
fi
sleep 2

echo "step0 The Current Device $1" >>$toolFile
echo "Log Catch Script Start Time - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
echo "Log Catch Script : devicehung_logcat_unix.sh" >>$toolFile

echo "step0 check device begin">>$toolFile
#adb devices

sleep 2
#adb remount
echo "step0 check device end">>$toolFile

#1.create folders:
echo -e "\nstep1 create folders begin" >>$toolFile
#create bootanim folder:
echo "step1 Bootanim folder begin" >>$toolFile
if [ ! -d "$bootanimFolder" ]; then
  echo "mkdir Bootanim Folder" >>$toolFile
  mkdir -p "$bootanimFolder"
fi
echo "step1 Bootanim folder end" >>$toolFile

#create input folder:
echo "step1 InputLog folder begin" >>$toolFile
if [ ! -d "$inptFolder" ]; then
  echo "mkdir InputLog Folder" >>$toolFile
  mkdir -p "$inptFolder"
fi
echo "step1 InputLog folder end" >>$toolFile

#create stack floder"
echo "step1 ProStack folder begin" >>$toolFile
if [ ! -d "$stackFolder" ]; then
  echo "mkdir ProStack Folder" >>$toolFile
  mkdir -p "$stackFolder"
fi
echo "step1 ProStack folder end" >>$toolFile

#create scrcap folder:
echo "step1 Screencap folder begin" >>$toolFile
if [ ! -d "$scapFolder" ]; then
  echo "mkdir Screencap Folder" >>$toolFile
  mkdir -p "$scapFolder"
fi
echo "step1 Screencap folder end" >>$toolFile


#create sf trace:
echo "step1 Sftrace folder begin" >>$toolFile
if [ ! -d "$sfTraceFolder" ]; then
  echo "mkdir Sftrace Folder" >>$toolFile
  mkdir -p "$sfTraceFolder"
fi
echo "step1 Sftrace folder end" >>$toolFile

#create dropbox folder:
echo "step1 Dropbox folder begin" >>$toolFile
if [ ! -d "$dpboxFolder" ]; then
  echo "mkdir Dropbox Folder" >>$toolFile
  mkdir -p "$dpboxFolder"
fi
echo "step1 Dropbox folder end" >>$toolFile

#create hprofs folder:
echo "step1 Hprofs folder begin" >>$toolFile
if [ ! -d "$hproFolder" ]; then
  echo "mkdir Hprofs Folder" >>$toolFile
  mkdir -p "$hproFolder"
fi
echo "step1 Hprofs folder end" >>$toolFile

#create tombsFolder folder:
echo "step1 Tombstones folder begin" >>$toolFile
if [ ! -d "$tombsFolder" ]; then
  echo "mkdir Tombstones Folder" >>$toolFile
  mkdir -p "$tombsFolder"
fi
echo "step1 Tombstones folder end" >>$toolFile
#creat binder folder:
echo "step1 Binder folder begin" >>$toolFile
if [ ! -d "$binderFolder" ]; then
  echo "mkdir binder Folder" >>$toolFile
  mkdir -p "$binderFolder"
fi
echo "step1 Binder folder end" >>$toolFile

#creat Systemserver folder:
echo "step1 Systemserver folder begin" >>$toolFile
if [ ! -d "$systemserverFolder" ]; then
  echo "mkdir Systemserver Folder" >>$toolFile
  mkdir -p "$systemserverFolder"
fi
echo "step1 Systemserver folder end" >>$toolFile

#creat traces folder:
echo "step1 Traces folder begin" >>$toolFile
if [ ! -d "$tracesFolder" ]; then  
  echo "mkdir Traces Folder" >>$toolFile
  mkdir -p "$tracesFolder"
fi
echo "step1 Traces folder end" >>$toolFile
echo "step1 create folders end" >>$toolFile

#define funcs:
function getDropboxFiles()
{
  #for file in `adb shell ls $dpboxDir |egrep "watchdog|crash"`
  echo "getDropboxFiles" >>$toolFile
  
  adb $cmd shell chmod 777 $dpboxDir/*
  for file in `adb $cmd shell ls $dpboxDir `
  do
    #if [ -f "$file" ]; then 1>/dev/null &
      adb $cmd pull $dpboxDir"/"$file $dpboxFolder 1>/dev/null &
    #fi
  done
}

function Assert()
{
   #getSystemServerInfo
   adb $cmd shell cat /data/sprdinfo/apr.xml | grep "assert" -i
}

function killMonkey()
{
	echo " - Obtain monkey pid..." >>$toolFile
	monkeyPid=` adb $cmd shell ps | grep 'monkey' | busybox awk '{print $2}'`
	if [ "$monkeyPid" ]; then
		echo " - ps monkeyPid: "$monkeyPid >>$toolFile
		adb $cmd shell kill -3 $monkeyPid
		echo " - ps killMonkey Success!" >>$toolFile
		#exit 1
	else
		monkeyPid=` adb $cmd shell ps -A | grep 'monkey' | busybox awk '{print $2}'`
		if [ "$monkeyPid" ]; then
			echo " - ps -A monkeyPid: "$monkeyPid >>$toolFile
			adb $cmd shell kill -3 $monkeyPid
			echo " - ps -A killMonkey Success!" >>$toolFile
			#exit 1
		else
			echo " - Monkey pid is not exist!" >>$toolFile
		fi
	fi
}

function execCmdTimeout()
{
        echo "execCmdTimeout" >>$toolFile
        waitfor=4
        cmdPid=$!
        echo "execCmdTimeout,cmdPid : $cmdPid" >>$toolFile
        ( sleep $waitfor ; adb $cmd shell kill -9 $cmdPid  > /dev/null 2>&1) &
        bgSlKilPid=$!
        echo "execCmdTimeout,bgSlKilPid : $bgSlKilPid" >>$toolFile
        wait $cmdPid > /dev/null 2>&1
        #(pPid=$PPID; echo "\n pPid : $pPid"; kill -9 $pPid > /dev/null 2>&1) #the devicehung_logcat script PID.
}

#2.device info: ro.bootimage.build.fingerprint | ro.build.version.release :
echo -e "\nstep2 get device info begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
echo -e "\nDeviceinfo:" >>$devInfoFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [serialno]=`adb $cmd shell getprop ro.serialno`" >>$devInfoFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [build.description]=`adb $cmd shell getprop ro.build.description`" >>$devInfoFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [build.version.release]=`adb $cmd shell getprop ro.build.version.release`" >>$devInfoFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [init.svc.bootanim]=`adb $cmd shell getprop init.svc.bootanim`" >>$devInfoFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` [service.bootanim.exit]=`adb $cmd shell getprop service.bootanim.exit`" >>$devInfoFile

#verFlag=`adb $cmd shell getprop ro.build.description`
verFlag=`adb $cmd shell getprop ro.build.version.release`
substr=${verFlag:0:1}
echo -e "\nverFlag is = $verFlag" >>$toolFile
echo -e "step2 The Substr of Version is $substr" >>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]]; then
   echo -e "Version is <=7" >>$toolFile
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version is $verFlag" >>$toolFile
else
  echo -e "Unknown Version" >>$toolFile
fi

#adb -s devices1 shell | adb -s devices1 cmd
echo "step2 get device info end - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile

#2.1get bootanim PID:
echo -e "\nstep2.1 Bootanim info begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
banmRFlag=`adb $cmd shell getprop init.svc.bootanim`

echo -e "step2.1 The Substr of Version is $substr" >>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 PS |grep bootanim" >>$toolFile
   bootanimPid=` adb $cmd shell ps |grep bootanim | busybox awk '{print $2}'`
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version $verFlag PS -A |grep bootanim" >>$toolFile
   bootanimPid=` adb $cmd shell ps -A|grep bootanim | busybox awk '{print $2}'`
else
  echo -e "\nUnknown PS |grep bootanim"
fi

echo -e "Bootanim Pid is $bootanimPid" >>$toolFile
#if [[ -z "$bootanimPid" ]]; then
if [ "$bootanimPid" ]; then
  if [[ "$banmRFlag"x != "stopped"x ]]; then
   	echo -e "\nBootanim is Not Stopped" >>$toolFile
   	adb $cmd shell debuggerd -b $bootanimPid > $bootanimFile &
	fi
fi
echo -e "step2.1 Bootanim info end - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile

#3.get common log:
echo -e "\nstep3 get common info begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

echo "step3 exec ps cmd">>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 PS Cmd">>$toolFile
   adb $cmd shell ps -t> $psFile &
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version $verFlag PS -A Cmd">>$toolFile
   adb $cmd shell ps -A -T > $psFile &
else
  echo -e "Unknown PS"
fi

# logcat:
echo "step3 logcat cmd" >>$toolFile
adb $cmd shell logcat -v threadtime >$logcatFile &
#adb $cmd shell cat /proc/kmsg > $kmsgFile &
adb $cmd shell dmesg -w > $kmsgFile &
sleep 1
adb $cmd shell "echo w > /proc/sysrq-trigger" &
execCmdTimeout
echo "step3 kmsg cmd" >>$toolFile
sleep 2

#binder trans log:
echo "step3 transaction_log cmd" >>$toolFile
adb $cmd shell cat /sys/kernel/debug/binder/transaction_log > $transLogFile &
echo "step3 transaction cmd" >>$toolFile
adb $cmd shell cat /sys/kernel/debug/binder/transactions > $transFile &
echo "step3 failed_transaction_log cmd" >>$toolFile
adb $cmd shell cat /sys/kernel/debug/binder/failed_transaction_log > $transFailFile &

#top:
echo "step3 top cmd" >>$toolFile
adb $cmd shell top -n 5 > $topFile &

# reboot check:
bootFlag=`adb $cmd shell getprop sys.debug.fwc`
echo "step3 getprop sys.debug.fwc begin">>$toolFile
#if [ "$bootFlag" == "1" ]; then
  echo -e "\n======android reboot check======" >>$othersFile
  echo -e "\nandroid reboot:$bootFlag" >>$othersFile
  echo "Pulling Dropbox Files" >>$toolFile
  getDropboxFiles
#else
  #echo -e "\nbootFlag is Null" 2>&1|tee -a $othersFile &
#fi
echo "step3 getprop sys.debug.fwc end" >>$toolFile

#adb pull /data/misc/hprofs $hproFolder 1>/dev/null &
sleep 2

#tombstones check:
tsCnt=`adb $cmd shell ls $tombsDir |wc -l`
echo -e "\nTombstones Cnt is = $tsCnt">>$toolFile
echo "step3 pull tombstones begin">>$toolFile
if [ "$tsCnt" -ne 0 ]; then
  echo "Pulling Tombstones" >>$toolFile
  adb $cmd shell chmod 777 $tombsDir/tomb* &
  adb $cmd pull $tombsDir $tombsFolder &
fi
echo "step3 pull tombstones end" >>$toolFile
echo "step3 get common info end - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile

sleep 3

#4.check key/touch driver ok?
echo -e "\nstep4 check key/touch driver is ok begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
if [ "$devno" ]; then
  echo -e "\nPlease In Order to Press Power key,Volume and Touch, Waitting...." >>$toolFile
  #adb $cmd shell cat /proc/kmsg >> $kInptFile &
  adb $cmd shell dmesg -w >> $kInptFile &
  sleep 6
else
  echo -e "\nPlease In Order to Press Power key,Volume and Touch, Waitting...."
  adb shell getevent > $gEventFile &
  adb $cmd shell dmesg -w >> $kInptFile &
  sleep 10
fi
#adb shell getevent > $gEventFile  2>&1|tee -a $othersFile &
adb $cmd shell date >>$toolFile
adb $cmd logcat -v threadtime -s "InputReader" "InputDispatcher" "WindowManager"  > $fwInptFile &

sleep 4
echo -e "\nstep4 check key/touch driver is ok end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#5.check system_server state:
echo -e "\nstep5 check system_server state begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
if [ -f "$traceFile" ]; then
	adb $cmd shell mv $traceFile $preTraceFile
	echo "step5 touch&chmod tracefile begin">>$toolFile
	adb $cmd shell touch $traceFile
	adb $cmd shell chmod 777 $traceFile &
	echo "step5 touch&chmod tracefile end">>$toolFile
fi
sleep 1

if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 PS |grep system_server">>$toolFile
   systemSerPid=`adb $cmd shell ps |grep system_server | awk '{print $2}'`
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version $verFlag PS -A |grep system_server">>$toolFile
   systemSerPid=`adb $cmd shell ps -A|grep system_server | awk '{print $2}'`
else
  echo -e "Unknown PS |grep system_server"
fi
echo -e "Systemserver Pid is $systemSerPid">>$toolFile
if [ "$systemSerPid" ]; then
  #get fd
  echo "step5 pull system_server fds begin">>$toolFile
  adb $cmd shell ls -l /proc/$systemSerPid/fd > $systemFdsFile
  adb $cmd shell cat /proc/$systemSerPid/maps > $systemMapsFile
  echo "Killing Systemserver, Waitting...">>$toolFile
  adb $cmd shell kill -3 $systemSerPid
  echo "step5 pull system_server fds end" >>$toolFile
  sleep 3
fi
echo "step5 check system_server state end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#5.1 check systemui state:
echo -e "\nstep5.1 check systemui state begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
if [[ $verFlag == *$ver7* ]] || [[ $ver456 == *$substr* ]]; then
   echo -e "Version <=7 PS |grep systemui">>$toolFile
   systemuiPid=`adb $cmd shell ps |grep systemui | busybox awk '{print $2}'`
elif [[ $verFlag == *$ver8* ]] || [[ $verFlag == *$ver9* ]] || [[ $verFlag == *$ver10* ]]; then
   echo -e "Version $verFlag PS -A |grep systemui">>$toolFile
   systemuiPid=`adb $cmd shell ps -A|grep systemui | busybox awk '{print $2}'`
else
   echo -e "Unknown PS |grep systemui"
fi
echo -e "Systemui Pid is $systemuiPid">>$toolFile
if [ "$systemuiPid" ]; then
  echo "Killing -3 Systemui, Waitting...">>$toolFile
  adb $cmd shell kill -3 $systemuiPid
  sleep 2
fi
echo "step5.1 check systemui state end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#5.2 check launcher state:
echo -e "\nstep5.2 check launcher state begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
if [[ $verFlag == *$ver7* ]] || [[ $ver456 == *$substr* ]]; then
   echo -e "Version <=7 PS |grep launcher">>$toolFile
   launcherPid=`adb $cmd shell ps |grep launcher | busybox awk '{print $2}'`
elif [[ $verFlag == *$ver8* ]] || [[ $verFlag == *$ver9* ]] || [[ $verFlag == *$ver10* ]]; then
   echo -e "Version $verFlag PS -A |grep launcher">>$toolFile
   launcherPid=`adb $cmd shell ps -A|grep launcher | busybox awk '{print $2}'`
else
   echo -e "Unknown PS |grep launcher"
fi
echo -e "Launcher Pid is $launcherPid">>$toolFile
if [ "$launcherPid" ]; then
  echo "Killing -3 Launcher, Waitting...">>$toolFile
  adb $cmd shell kill -3 $launcherPid
  sleep 2
fi
echo "step5.2 check launcher state end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#5.3 catch monkey trace:
echo -e "\nstep5.3 check monkey state begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
killMonkey
echo "step5.3 check monkey state end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
sleep 2

adb $cmd pull /data/anr/. $tracesFolder &
sleep 2

#6.check surfaceflinger state:
echo -e "\nstep6 check surfaceflinger state begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 PS |grep surfaceflinger">>$toolFile
   sfPid=`adb $cmd shell ps |grep surfaceflinger | awk '{print $2}'`
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version $verFlag PS -A |grep surfaceflinger">>$toolFile
   sfPid=`adb $cmd shell ps -A|grep surfaceflinger | awk '{print $2}'`
else
  echo -e "Unknown PS |grep surfaceflinger">>$toolFile
fi
echo -e "SurfaceFlinger Pid is $sfPid, Catching The Trace Info, Waitting..." >>$toolFile
adb $cmd shell debuggerd -b $sfPid > $sfTraceFile &
echo "step6 dumpsys SurfaceFlinger cmd" >>$toolFile
adb $cmd shell ls -l /proc/$sfPid/fd > $surflgerFdsFile
adb $cmd shell dumpsys SurfaceFlinger > $sFlingerFile &
echo "step6 check surfaceflinger state end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#7.get "D/Z/T" process & trace:
echo -e "\nstep7 get D/Z/T process & trace begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "7 Pro and trace begin">>$toolFile
   adb $cmd shell ps -t|awk '{if($8 == "D" || $8 == "Z" || $8 == "T" || $8 == "t") print $1,$2,$3,$8,$9}' > $stackFiles
   dztProPids=`adb $cmd shell ps -t| awk '{if($8 == "D" || $8 == "Z" || $8 == "T" || $8 == "t") print $2}'`
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "8 Pro and trace begin">>$toolFile
   adb $cmd shell ps -A |awk '{if($8 == "D" || $8 == "Z" || $8 == "T" || $8 == "t") print $1,$2,$3,$8,$9}' > $stackFiles
   dztProPids=`adb $cmd shell ps -A | awk '{if($8 == "D" || $8 == "Z" || $8 == "T" || $8 == "t") print $2}'`
else
  echo -e "Unknown Pro and trace"
fi
for dztPid in $dztProPids
do
    echo "Catch Stack dztPid = $dztPid" >>$toolFile
    adb $cmd shell cat /proc/$dztPid/stack > $stackFolder/kernelstack$dztPid.txt &
    adb $cmd shell debuggerd -b $dztPid > $stackFolder/nativestack_$dztPid.txt 2>&1|tee -a $toolFile &
done
echo "step7 get D/Z/T process & trace end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
sleep 2

#8.start activity & screencap:
echo -e "\nstep8 start activity & screencap begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
backLightVal=`adb $cmd shell cat /sys/class/backlight/sprd_backlight/brightness`
echo -e "\n======backlight check======" >>$othersFile
echo -e "backlight level:$backLightVal">>$othersFile
if [ $backLightVal -eq 0 ];then
 echo -e "\n======inject keyevent check======" >>$othersFile
 echo "Sending keyevent 26" >>$othersFile
 adb $cmd shell input keyevent 26 >>$othersFile &
 #echo $? >>$tmpLogFile
 echo "Sending keyevent 26 end" >>$toolFile
 sleep 1
fi

echo "step8 input swipe begin">>$toolFile
adb $cmd shell input swipe 380 1100 380 290 >>$toolFile &
echo "step8 input swipe end">>$toolFile

sleep 2

echo "step8 start screencap begin">>$toolFile
adb $cmd shell /system/bin/screencap -p > $scapBeforeFile &
sleep 1
echo -e "\n======activity switch check======" >>$othersFile
echo "step8 start deskclock activity begin">>$toolFile
adb $cmd shell am start -n com.android.deskclock/.DeskClock >>$othersFile &
echo "step8 start deskclock activity end">>$toolFile

sleep 2

echo "step8 start screencap begin">>$toolFile
adb $cmd shell /system/bin/screencap -p > $scapAfterFile &
echo "step8 start screencap end" >>$toolFile
echo "step8 start activity & screencap end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#9. check assert:
echo -e "\nstep9 check assert info begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
echo -e "\n=====modem assert check======" >>$othersFile
echo -e "Assertinfo:">>$othersFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` - Assert = `Assert` " >>$othersFile
echo "step9 check assert info end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#10.get memoryinfo:
echo -e "\nstep10 get memoryinfo begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
memFree=`adb $cmd shell cat /proc/meminfo | grep MemFree | busybox awk '{print $2}'`
cached=`adb $cmd shell cat /proc/meminfo | grep Cached | busybox awk 'NR==1{print $2}'`
value=`echo $memFree $cached | busybox awk '{print $1+$2}'`

let freeM=$value/1024
echo -e "\nMemoryinfo :">>$memFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` - MemFree = ${value}KB = ${freeM}MB" >>$memFile
echo " - `date '+%Y-%m-%d %H:%M:%S - '` - Free = $memFree+$cached KB" >>$memFile
adb $cmd shell cat /proc/meminfo >>$memFile
echo "step10 get memoryinfo end - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile

echo -e "\nstep10.1 emem_trigger begin - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
adb $cmd shell echo 0 > /proc/sys/vm/emem_trigger 1>>$toolFile 2>>$toolFile
echo "step10.1 emem_trigger end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

#11.get each partition size:
echo -e "\nstep11 get each partition size begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
echo -e "\nEach Partition Size info :" >>$dfFile
adb $cmd shell df -h >>$dfFile &
echo "step11 get each partition size end - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile

sleep 1

#12.dump window :
echo -e "\nstep12 dump window&activitys info begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
adb $cmd shell dumpsys window >>$dumpWindFile &
echo $? >>$dumpWindFile
adb $cmd shell dumpsys activity activities >>$dumpActivitysFile &
echo "step12 dump window&activitys info end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile
sleep 5

#13.bugreport:
#Exec bugreport cmd, Waitting...
#=============================================================================
#WARNING: flat bugreports are deprecated, use bugreport <zip_file> instead [[ -n "$bugrpt" ]] && || echo $?(cmd return value)
#=============================================================================
#adb shell bugreport >$bugReptFile
echo -e "\nstep13 exec bugreport begin - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
echo -e "Exec bugreport cmd, Waitting...">>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 bugreport">>$toolFile
   adb $cmd bugreport $bugReportFile
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]] ; then
   echo -e "Version $verFlag bugreport">>$toolFile
   adb $cmd shell bugreport >>$bugReportFile
else
  echo -e "Unknown bugreport"
fi
echo "step13 exec bugreport end  - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
sleep 1

#kill proc:getevent :
echo -e "\nstep4 getEvent pid begin- `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
if [[ $verFlag =~ $ver7 ]] || [[ $ver456 =~ $substr ]] ; then
   echo -e "Version <=7 PS |grep getevent">>$toolFile
   getEventPid=`adb $cmd shell ps |grep getevent | awk '{print $2}'`
elif [[ $verFlag =~ $ver8 ]] || [[ $verFlag =~ $ver9 ]] || [[ $verFlag =~ $ver10 ]]; then
   echo -e "Version $verFlag PS -A |grep getevent">>$toolFile
   getEventPid=`adb $cmd shell ps -A|grep getevent | awk '{print $2}'`
else
  echo -e "Unknown PSCmd"
fi
echo "getEventPid is $getEventPid">>$toolFile
for pid in $getEventPid
do
    echo "Kill Process getevent Pid = $pid">>$toolFile
    adb $cmd shell kill -9 $pid &
    sleep 1
done
echo "step4 getEvent pid end - `date '+%Y-%m-%d %H:%M:%S - '` ">>$toolFile

adb $cmd shell "echo w > /proc/sysrq-trigger" &
execCmdTimeout

sleep 15
echo -e "\nLog Catch Script End Time - `date '+%Y-%m-%d %H:%M:%S - '` " >>$toolFile
exit 0
