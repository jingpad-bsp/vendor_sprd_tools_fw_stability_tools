#!/usr/bin/env python
# -*- coding:utf-8 -*-

import time
import os,shutil
import subprocess
import threading
import inspect
import ctypes
import platform
import sys,string
rq = time.strftime('%Y%m%d',time.localtime(time.time()))
majorVerNum = 0
minorVerNum = 0

def makeDir(path):
	#print "makeDir, path = " + path
	if not os.path.exists(path):
		try:
			os.makedirs(path)
			return True
		except:
			print ("Create Dir Fail!")
			return False
	return True

def removeFile(fName):
	if os.path.exists(fName):
		try:
			os.remove(fName)
			#os.unlink(fName)
			return True
		except:
			print ("Remove File Fail!")
			return False
	return False

def makeFile(fName):
	#print "makeFile, fName = " + fName
	try:
		file = open(fName,'a+')
		#print "\n",file
		return file
	except IOError:
		print ("Open File Fail!")
		return None

def moveFile(srcFile,dstDir):
	if not os.path.isfile(srcFile):
		print ("%s not exist!"%srcFile)
	else:
		if os.path.exists(dstDir):
			shutil.move(srcFile,dstDir)
			#print "move %s -> %s"%( srcFile,dstDir)

def getOSType():
	osType = platform.system();
	return osType

def checkOSMatch(osTypeSelted=''):
	osType = getOSType()
	if (osTypeSelted != osType):
		return False

def checkPythonVersion():
	#print("The current python version is " + sys.version[0:1])
	if int(sys.version[0:1]) >= 3 :
		global majorVerNum,minorVerNum
		majorVerNum = int(sys.version[0:1])
		minorVerNum = int(sys.version[2:3])
	return int(sys.version[0:1])

if __name__ == "__main__":
	print ("Util Module")