devicehung_logcat�ű������ã�
�ýű���Ҫ��Դ���ADB����״̬�Ķ������⣬ץȡ�����ֳ���log��Ϣ��

׼��������
1. ����ȷ��PC�Ƿ�װPython ������
	1). ���Ѱ�װ,����ִ�� 2 ;
	2). ����Python�����ɸ��ݵ�ǰPC���������������½ű�:
	 (1).ubuntuϵͳ : unix/devicehung_logcat_unix.sh
	     �����˽ű����޸�Ȩ�� chmod 777 devicehung_logcat_unix.sh, ֱ������ ./devicehung_logcat_unix.sh ����;
	 (2).windowsϵͳ: windows/devicehung_logcat
	     ���˽ű� push ���ֻ� /data Ŀ¼��,���޸�Ȩ�� chmod 777 devicehung_logcat, ����ֱ������ ./devicehung_logcat ���ɣ�
2. ȷ���豸����ʱadb�Ƿ����״̬;
3. ��1̨(���̨)�����ֻ����ӵ�����,�ű�һ�λ�ץȡ���ж����豸���ֳ���Ϣ,��ȷ����ץȡ�����в�Ҫ�Ͽ��ֻ�,����log��ȱʧ.
4. �ýű�֧��unix��windowsϵͳ����������ʹ��unixϵͳ����unixϵͳ�����и����ȶ�����ȡ����Ϣ���ࡣ
5. ȷ�ϻ�����user����userdebug�汾�������user�汾����Ҫ��usb����ģʽ����Ȩ��

�������裺
1. ����ű����ڵ�Ŀ¼, ִ���������
python ./mian_devicehung_logcat.py

2. ����ʾ��Ϣִ�в���:
   1) ѡ�� log ץȡģʽ��
      (0)��ͨģʽ(����bugreport��ץȡ)
      (1)����ģʽ(������bugreport��ץȡ)
      Ĭ��"�س�" ������ "��ͨģʽ".

   2) ѡ����Ҫץlog���豸���к�, Ĭ��"�س�" ��ץȡ�������ӵ��豸.

   3) ������������ʾ��Ϣʱ,�����δ˵���ֻ�������(��ע: ��һ������Ҫ):
      Please In Order to Press Power key��Volume key and Touch, Waitting....

   4).�ȴ�ֱ����������ִ����ɵ���ʾ��Ϣ����ʾ��̨����ץȡ���:
      Log Fetch Finish! The current PCTime is xxx, The Total Time Spent xxxs!
      ÿ���1̨�豸��ʾ1�Σ�ֱ�������ӵ��豸ȫ��ִ����.

3. ץȡ��log�ᱣ���ڽű�����Ŀ¼��scene_logĿ¼�£�ÿ̨�豸��Ӧһ��LOG�ļ���, �ɽ�scene_logĿ¼�µ��������ݴ����ylogһ���ϴ����з�������

4. �����豸���״̬���������ֳ��Ա��������һ��check;

��ע��
toolsĿ¼��Ϊadb����,���PCʹ�õ�adb�汾�ϵ�,���ڽű���adb��������޷��������е����,��������log�޷�����ץȡ,��˿���tools�µ�adb�����滻����PC�ϵ�,������������PC adb����.

