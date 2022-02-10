#!/usr/bin/env python
# -*- coding:utf-8 -*-

import time
import os
import subprocess
import threading
import inspect
import ctypes
from fun_utils import *

rq = time.strftime('%Y%m%d',time.localtime(time.time()))

class MyThread(threading.Thread):
	def __init__(self, id, cmd, path, fName,tag):
		threading.Thread.__init__(self)
		self.id = id
		self.cmd = cmd
		self.path = path
		self.fName = fName
		self.logTag = tag
		self.__running = threading.Event()
		self.__running.set()
		self.threadLock = threading.Lock()
		pass

	def run(self):
		self.threadLock.acquire();
		self.execCmdResult2File(self.id,self.cmd,self.path,self.fName)
		self.threadLock.release()
		print (self.logTag + " Thread is over!")

	def execCmdResult2File(self,id='',cmd='',path='',fileName=''):
		makeDir(path)
		feName = os.path.join(path,fileName + r'.txt')
		file = makeFile(feName)
		if(file is not None):
			file.write("\n")
			file.flush()
			os.fsync(file.fileno())
			osType = getOSType()
			if (osType == 'Windows'):
				pipe = subprocess.Popen(cmd,stdout=file, stderr=subprocess.PIPE) #subprocess.STDOUT
			elif (osType == 'Linux'):
				pipe = subprocess.Popen(cmd,stdout=file, shell=True, stderr=subprocess.PIPE)
			return_code = pipe.poll()
			while self.__running.isSet():	 #(return_code is None) and
				return_code = pipe.poll()
		else:
			print ("Logcat save fail")
			return
		time.sleep(1)
		file.close()
		try:
			pipe.terminate()
			pipe.kill()
		except Exception as err:
			print ("")

	def asyncExc(self,thrid, excCallback):
		"""raises the exception, performs cleanup if needed"""
		tid = ctypes.c_long(thrid)
		if not inspect.isclass(excCallback):
			exctype = type(exctype)
		res = ctypes.pythonapi.PyThreadState_SetAsyncExc(tid, ctypes.py_object(excCallback))
		if res == 0:
			raise ValueError("invalid thread id")
		elif (res != 1):
			ctypes.pythonapi.PyThreadState_SetAsyncExc(tid, None)
			raise SystemError("PyThreadState_SetAsyncExc failed")

	def getMyTid(self):
		"""Get thread id"""
		if not self.isAlive():
			raise threading.ThreadError("The Thread is not Active")
		if hasattr(self, "_thread_id"):
				return self._thread_id
		for tid, tobj in threading._active.items():
				if tobj is self:
					self._thread_id = tid
					#print self._thread_id
					return tid
		raise AssertionError("Unknown the thread's id")

	def stopThread(self):
		self.__running.clear()
		time.sleep(3)
		try:
			self.asyncExc(self.getMyTid(), SystemExit)
		except Exception as err:
			print ("")

if __name__ == "__main__":
	t = MyThread(1,"Thread-1",'log.txt')
	t.start()
	t.join()
