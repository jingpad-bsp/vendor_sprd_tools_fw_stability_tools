devicehung_logcat脚本的作用：
该脚本主要针对处于ADB可连状态的定屏问题，抓取定屏现场的log信息。

准备工作：
1. 首先确认PC是否安装Python 环境：
	1). 如已安装,继续执行 2 ;
	2). 如无Python环境可根据当前PC环境单独运行如下脚本:
	 (1).ubuntu系统 : unix/devicehung_logcat_unix.sh
	     拷贝此脚本并修改权限 chmod 777 devicehung_logcat_unix.sh, 直接运行 ./devicehung_logcat_unix.sh 即可;
	 (2).windows系统: windows/devicehung_logcat
	     将此脚本 push 到手机 /data 目录下,并修改权限 chmod 777 devicehung_logcat, 而后直接运行 ./devicehung_logcat 即可；
2. 确认设备定屏时adb是否可连状态;
3. 将1台(或多台)定屏手机连接到电脑,脚本一次会抓取所有定屏设备的现场信息,请确保在抓取过程中不要断开手机,避免log的缺失.
4. 该脚本支持unix和windows系统，但尽可能使用unix系统，在unix系统下运行更加稳定，获取的信息更多。
5. 确认机器是user还是userdebug版本，如果是user版本则需要打开usb调试模式并授权。

操作步骤：
1. 进入脚本所在的目录, 执行以下命令：
python ./mian_devicehung_logcat.py

2. 按提示信息执行操作:
   1) 选择 log 抓取模式：
      (0)普通模式(包含bugreport的抓取)
      (1)快速模式(不包含bugreport的抓取)
      默认"回车" 将采用 "普通模式".

   2) 选择需要抓log的设备序列号, 默认"回车" 将抓取所有连接的设备.

   3) 待出现如下提示信息时,请依次此点击手机物理按键(备注: 这一步很重要):
      Please In Order to Press Power key、Volume key and Touch, Waitting....

   4).等待直到出现下述执行完成的提示信息，表示此台定屏抓取完毕:
      Log Fetch Finish! The current PCTime is xxx, The Total Time Spent xxxs!
      每完成1台设备提示1次，直到所连接的设备全部执行完.

3. 抓取的log会保存在脚本所在目录的scene_log目录下，每台设备对应一个LOG文件夹, 可将scene_log目录下的所有内容打包和ylog一起上传给研发分析。

4. 保持设备充电状态，并保留现场以便后续进行一步check;

备注：
tools目录下为adb工具,如果PC使用的adb版本较低,存在脚本中adb命令可能无法正常运行的情况,进而导致log无法正常抓取,因此可用tools下的adb工具替换本地PC上的,或者升级本地PC adb工具.

