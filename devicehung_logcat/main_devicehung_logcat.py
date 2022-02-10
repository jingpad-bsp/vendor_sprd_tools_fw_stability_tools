#!/usr/bin/env python
# -*- coding:utf-8 -*-

import time
import os
import sys
import re
import copy
import datetime
import subprocess
#import numpy as np
from os import path
from threading import Timer
mRootpath = os.path.dirname(path.abspath(__file__))
windPath = os.path.join(mRootpath,'windows')
sys.path.append(windPath)
from fun_mythread import MyThread
import fun_utils as utils

curTime = time.time()
print ('The current PCTime is ' + time.strftime('%Y%m%d %H:%M:%S',time.localtime(curTime)))

#define constant:
mRtLogPath=''
mAndrVer = ''
mVerStr7='7'
mVerStr8='8'
mVerStr9='9'
mLgcatFlag = '1'
mKmsgFlag = '2'
mGeteventFlag = '3'
mBugreptFlag = '4'
mPsFlag = '5'
mDfFlag = '6'
mMountFlag = '7'
mDmesgFlag = '8'
mCmdCd = 'cd '
mCmdCpy = 'cp '
mCmdRemove = 'rm -rf '
mScenePathName = 'scene_log'
cfgstr = "config.xml"
mCmdHeader = 'adb '
mCmdHeaderSh = 'adb shell '
mCmdHeaderDS = 'adb -s '
mCmdRoot = ' root'
mCmdShell = ' shell '
mCmdKillSvr = ' kill-server '
mCmdlogcat = ' logcat -v threadtime -b all'
mCmdkmsg = ' cat /proc/kmsg'
mGetevent = ' getevent'
mCmdBugrept = ' bugreport'
mCmdPs = ' ps -AT'
mCmdDf = ' df'
mCmdMount = ' mount'
mCmdDmesg = ' dmesg -w'
mKmsgFile = 'kmsg'
mDmesgFile = 'dmesg'
mGetEventFile = 'getevent'
mLogcatFile = 'logcat'
mCmdAdbDevs = 'adb devices'
mUserStr = 'user'
mUserdebugStr = 'userdebug'
mBugreptFile = 'bugreport'
mPsFile = 'ps'
mDfFile = 'df'
mMountFile = 'mount'
mTempFile = 'temp'
mShellStr = 'devicehung_logcat_unix.sh '
#mModeArray = np.array(["Normal mode","Quick mode"])
mModeArray = ["Normal mode","Quick mode"]
mBugrptFlag = "setprop persist.sys.bugrpt.flag "
mSegLine = os.path.sep
mLogPath = os.path.join(mRootpath,mScenePathName + mSegLine)
mScriptpath = os.path.join(mRootpath,'unix' + mSegLine)
mScriptpath4Wind = os.path.join(mRootpath,'windows' + mSegLine)
mShlScrpt = mScriptpath + mShellStr
mCmdPush = " push " + mScriptpath4Wind + "devicehung_logcat /data"
mCmdPull = " pull /data/scene_log_01/. "
mShlCmd4Lnx = '&&chmod 777 ./devicehung_logcat_unix.sh&&./devicehung_logcat_unix.sh '
mShlCmd4Wind = 'cd data/&&chmod 777 /data/devicehung_logcat&&./devicehung_logcat&&cd ../&&exit'

mTimeout = 240
mIsTimeout = False

#Get Device list
#Parameters : none
#Returns the connected device list.
def getDeviceList():
	deviceIDs = []
	devsList = os.popen(mCmdAdbDevs)
	devsList = devsList.read()
	deviceIDs = re.findall(r'(.*?)\tdevice\b', devsList)
	#check devices: retLine.partition('\n')[2].replace('\n', '').split('\tdevice')
	#retLine = subprocess.Popen(mCmdAdbDevs, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]
	#deviceIDs = re.findall(r'(\w+)\s+device\s', retLine)
	#print(deviceIDs)
	if (len(deviceIDs) <= 0):
		print ("No Devices found, Please Connect Devices.")
		return None
	print ("The Connected Device List, deviceIDs = %s" %deviceIDs)
	return deviceIDs

#execute pull log files cmd
#Parameters : 1. device : the current dev; 2. targetDir : The log saved path
#Returns the result: 1.fail :False ; 2. success : True
def execPullLogFiles(device, targetDir):
	""" Pull files from device """
	print ("\n")
	print (datetime.datetime.now())
	print ("Pull Files To the Path: " + targetDir)
	utils.makeDir(targetDir)
	print ("Pulling Files, It Will Take a few minutes, Please Wait...")
	result = subprocess.Popen(mCmdHeaderDS + device + mCmdPull + targetDir, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
	#print ('result : ',result)	#('', 'error: device not found\r\n')
	if(('error:' in str(result[1])) or ('does not exist') in str(result[1])):
		print ("Pulling LogFile Fail")
		return False
	print ("Pull LogFiles Finished, 3KS!")
	return True

#execute a set of cmds and set timeout: 1. push the log script into dev; 2.Setup script execute permissions; 3. Run the script ; 4. exit
#Parameters : 1. serNo : the current dev serial number
#Result: Whether successful or not, need to  close Popen and cancle timeout.
def execPushAndRunScriptCmds(serNo):
	""" execPushAndRunScriptCmds """
	global mIsTimeout
	#print 'execPushAndRunScriptCmds, serNo = ', serNo
	if (os.system(mCmdHeaderDS + serNo + mCmdPush) < 0):
		print ("Push Script File Fail, The File System May Appear abnormal!!")
		return None
	pipe = subprocess.Popen(mCmdHeaderDS + serNo + mCmdShell + mShlCmd4Wind,stdout=subprocess.PIPE, stderr=subprocess.PIPE)	 
	timer = Timer(mTimeout, execCallback, [pipe])
	timer.start()
	try:
		print ("\n")
		print ("Now Running the Script to Catch log,It Will Take A Few Minutes,Please Wait...")
		pipe.communicate()
	finally:
		pipe.stdout.close()
		pipe.stderr.close()
		pipe.terminate()
		timer.cancel()
	if mIsTimeout:
		print ("Execing the Script Error!")
		mIsTimeout = False
		return None
	print ("Exec the Script End, Thank You For Your Waiting!")
	pipe.kill()
	return True

#check version [ro.build.description]:
#Parameters : Normal mode & Quick mode
#Returns the result:  1.user : Flase; 2. userdebug : True
def checkDevVersionType(devID):
	result = execCmd(mCmdHeaderDS + devID + mCmdShell + 'getprop ro.build.description')
	relt = result.readline()
	if( relt.find(mUserdebugStr) >=0 ):
		return True
	elif( relt.find(mUserStr) >= 0 ):
		return False

#execute A command
def execCmd(cmd=''):
	result = os.popen(cmd) #file read mode
	return result

#execute logcat mode select
#Parameters: 1. mdtypes includ two modes : Normal mode & Quick mode
#Returns the selected logcat mode.
def execLogModeSelected(mdtypes):
	print ('\nIncluding three modes:')
	for index,type in enumerate(mdtypes):
		print (str(index) + '. ' + type)
	print (str(index + 1) + '. Enter key for default Normal mode type')
	try:
		pyVerNum = utils.checkPythonVersion()
		if pyVerNum >= 3:
			selectno = int(input('Please Select the Log Catch Mode:'))
		elif pyVerNum <= 2:
			selectno = int(raw_input('Please Select the Log Catch Mode:'))
		while	((selectno > (index + 1))):
			if pyVerNum >= 3:
				selectno = int(input('U Choose wrong, please choose again:'))
			elif pyVerNum <= 2:
				selectno = int(raw_input('U Choose wrong, please choose again:'))
		#print 'U Select ModeType is ' + str(selectno)
		return selectno
	except:
		print ('Default Normal mode')
		return 0

#execute devices select
#Parameters : 1. devs : the conneced dev list
#Returns the selected devices.
def execDevSelectded(devs):
	cpDevArray = []
	for index,dev in enumerate(devs):
		print (str(index) + '.' + dev)
	print (str(index + 1) + '.Push Enter key for choose all devs')
	try:
		pyVerNum = utils.checkPythonVersion()
		if pyVerNum >= 3:
			devID = int(input('Please Choose U Need Device Number:'))
		elif pyVerNum <= 2:
			devID = int(raw_input('Please Choose U Need Device Number:'))
		while	((devID > (index + 1))):
			if pyVerNum >= 3:
				devID = int(input('U select wrong, please choose again:'))
			elif pyVerNum <= 2:
				devID = int(raw_input('U select wrong, please choose again:'))
		print ('U You choose the deviceId is ', str(devID) + ", Device Serial Number is " + devs[devID])
		cpDevArray.append(devs[devID])
	except:
		print ("All the Devices")
		cpDevArray = copy.deepcopy(devs)
	return cpDevArray

#execute bugreport property set
#Parameters : 1. serNo : the current dev serNo; 2.selectedId : the value of bugreport mode
def execSetBugreprtMode(serNo,selectedId):
	execCmd(mCmdHeaderDS + serNo + mCmdShell + mBugrptFlag + str(selectedId))
	time.sleep(4)

#execute start asyn thread
#Parameters : 1. seriNum : the current dev seriNum; 2.path : The log saved path; 3.flag : Used to distinguish the log type
def execAsynThread(seriNum='',path='',flag=''):
	if (flag == '1'):
		tag = 'Logcat'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdlogcat
		logFile = mLogcatFile
	elif (flag == '2'):
		tag = 'Kmsg'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdkmsg
		logFile = mKmsgFile
	elif (flag == '3'):
		tag = 'Getevent'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mGetevent
		logFile = mGetEventFile
	elif (flag == '4'):
		tag = 'Bugrept'
		cmd = mCmdHeaderDS + seriNum + mCmdBugrept
		logFile = mBugreptFile
	elif (flag == '5'):
		tag = 'Ps'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdPs
		logFile = mPsFile
	elif (flag == '6'):
		tag = 'Df'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdDf
		logFile = mDfFile
	elif (flag == '7'):
		tag = 'Mount'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdMount
		logFile = mMountFile
	elif (flag == '8'):
		tag = 'Dmesg'
		cmd = mCmdHeaderDS + seriNum + mCmdShell + mCmdDmesg
		logFile = mKmsgFile #mDmesgFile
	thread = MyThread(seriNum,cmd, path, logFile,tag)
	thread.setDaemon(True)
	thread.start()
	time.sleep(1)
	return thread

#user logcatch:
#Parameters : 1. dev : the current dev ; 2.logpath : The log saved path
#used to catch 1.logcat; 2.bugreport; 3.ps; 4.df; 5.mount
def execLogcat4User(dev,logpath):
	if utils.makeDir(logpath) :
		thrLogcat = execAsynThread(dev,logpath,mLgcatFlag)
		thrPs = execAsynThread(dev,logpath,mPsFlag)
		thrDf = execAsynThread(dev,logpath,mDfFlag)
		time.sleep(1)
		thrMount = execAsynThread(dev,logpath,mMountFlag)
		thrBugrept = execAsynThread(dev,logpath,mBugreptFlag)
		print ("All logs are fetching,Please Wait...")
		time.sleep(150)   #Block and Wait
		stopThreads(thrLogcat,thrBugrept,thrPs,thrDf,thrMount)
		return True
	return False

#execute disconnect cmd
#Parameters :  1.serNo : the current connected dev; 2. disconnect cmd
def execDisconnect(serNo,cmd=''):
	print ("Disconnecting")
	execCmd(mCmdHeaderDS + serNo + cmd)
	time.sleep(2)

#execute callback cmd if timeout
#Parameters :  1.p : the created Popen
def execCallback(p):
	global mIsTimeout
	try:
		print ("Execute Cmd Timeout!")
		mIsTimeout = True
		p.kill()
		#os.kill(p.pid, signal.SIGKILL)
	except Exception as error:
		print ("error")

#stop threads:
#Parameters :  1.thrds : the async threads
def stopThreads(*thrds):
	time.sleep(4)
	for thr in thrds:
		if thr:
			thr.stopThread()
		time.sleep(1)

#write finish flag to temp.txt file.
#temp.txt used to notify the log parse
#Parameters :  1.logpath : The log saved path
def execWriteFinsh2TmpFile(logpath):
	if utils.makeDir(logpath) :
		fName = os.path.join(logpath, mTempFile + r'.txt')
		utils.removeFile(fName)
		file = utils.makeFile(fName)
		if(file is not None):
			file.write("Finished\n")
			file.flush()
			os.fsync(file.fileno())
			file.close()

#delete the temp.txt file:
def execDeleteTmpFile(logpath):
	if os.path.exists(logpath):
		utils.removeFile(os.path.join(logpath, mTempFile + r'.txt'))
		return True
	return False

#move bugreport file to the dev/log dir
#Parameters : 1. rootpath : The script dir; 2. logpath : The log saved path
def execMvFile2SpecifiedDir(rootpath,logpath):
	if os.path.exists(rootpath):
		files = os.listdir(rootpath)
		for file in files:
			if os.path.isfile(file) :
				fileName = os.path.basename(file) #os.path.splitext(file)[0]
				if ((fileName.find("bugreport-") != -1) or (fileName.find("bugreport") != -1)):
					utils.moveFile(file,logpath)
					break

#execute root cmd	and Start the timeout
#Parameters : 1. retryCnt : Try several times; 2. dev : the current dev
#Returns the result: if root fail, then return "" and close Popen; if root sucess, return the current dev and close Popen & cancle timeout
def execRoot(retryCnt=0,dev=''):
	global mIsTimeout
	p = subprocess.Popen(mCmdHeaderDS + dev + mCmdRoot, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE) #preexec_fn=os.setsid
	myTimer = Timer(mTimeout, execCallback, [p])
	myTimer.start()
	try:
		p.communicate()
	finally:
		p.stdout.close()
		p.stderr.close()
		myTimer.cancel()
	if mIsTimeout:
		print ("Device not found, Please Check Whether the device is already connected!")
		mIsTimeout = False
		return ""
	print ("Adb rootting Success.")
	time.sleep(2)
	return dev

if __name__ == "__main__":
	devices = getDeviceList()
	if devices is not None:
		selectedId = execLogModeSelected(mModeArray)
		print ("\n")
		dSltArray = execDevSelectded(devices)
		devCnt = len(dSltArray)
		if devCnt > 0:
			execDeleteTmpFile(mLogPath)
		for dev in dSltArray:
			print ("\n")
			print ("The Current Device is " + dev)
			targetPath = os.path.join(mLogPath, dev + "_" + time.strftime('%Y%m%d_%H%M%S',time.localtime(time.time())))  #create log path:
			bRet = checkDevVersionType(dev)
			if (bRet == False):
				print ('User Version')
				if execLogcat4User(dev,targetPath) :
					execFinished = True
				time.sleep(2)
				execMvFile2SpecifiedDir(mRootpath,targetPath)
			elif ( bRet == True):
				seriNo = execRoot(5,dev)
				if seriNo.strip() != '':
					execSetBugreprtMode(seriNo,selectedId)
					osType = utils.getOSType()
					if (osType == 'Windows'):
						print ("Windows ENV")
						if utils.makeDir(targetPath) :
							#thrKmsg = execAsynThread(seriNo,targetPath,mKmsgFlag)        #kmsg thread
							thrDmesg = execAsynThread(seriNo,targetPath,mDmesgFlag)       #Dmesg thread
							time.sleep(2)
							thrLogcat = execAsynThread(seriNo,targetPath,mLgcatFlag)      #logcat thread
							time.sleep(2)
							execPushAndRunScriptCmds(seriNo)                              #push and run the script
							time.sleep(1)
							if execPullLogFiles(seriNo,targetPath) :                      #pull the logs
								execFinished = True
							time.sleep(2)
							thrGetevnt = execAsynThread(seriNo,targetPath,mGeteventFlag)  #getevent thread
							time.sleep(2)
							print ("\n")
							print ("Please In Order to Press Power key, Volume key and Touch, Collectting and Waitting....")
							time.sleep(80)
							stopThreads(thrLogcat,thrGetevnt,thrDmesg)            #stop threads
					elif (osType == 'Linux'):
						print ("\nLinux ENV")
						print ("Now Execing The Script to Catch log, Please Wait...")
						utils.makeDir(targetPath)
						execCmd(mCmdCpy + mShlScrpt + targetPath)                       #copy the script to the target path
						execCmd(mCmdCd + targetPath + mShlCmd4Lnx + seriNo)             #switch to the target path
						time.sleep(4)
						thrdGetevnt = execAsynThread(seriNo,targetPath,mGeteventFlag)   #getevent thread
						time.sleep(1)
						thrDmesg = execAsynThread(seriNo,targetPath,mDmesgFlag)         #kmsg thread
						time.sleep(2)
						print ("\nPlease In Order to Press Power key, Volume key and Touch, Collectting and Waitting....")
						time.sleep(80)
						execCmd(mCmdRemove + os.path.join(targetPath,mShellStr))        #remove logcat script
						stopThreads(thrDmesg,thrdGetevnt)
						execFinished = True
			time.sleep(2)
			execDisconnect(dev,mCmdKillSvr)
			time.sleep(2)
			pass
		nowTime = time.time()
		print ('\nLog Fetch Finish! The current PCTime is ' + time.strftime('%Y%m%d %H:%M:%S',time.localtime(nowTime)) + ", The Total Time Spent " + str(int(nowTime - curTime)) + "s!")
		#write finish to file:
		if execFinished :
			execWriteFinsh2TmpFile(mLogPath)
else:
	print ("Other module")
