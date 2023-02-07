# -*-coding:UTF-8 -*-
import os
import time
def useUpower():
    print("Check the power supply with upower")
    cmd=os.popen("upower -e");
    strUpowerE=cmd.read();
    cmd.close();
    print(strUpowerE);
    listUpowerE=strUpowerE.split("\n");
    batteryPath='';
    for line in listUpowerE:
        if "battery" in line:
            batteryPath=line;
            break;
    #print(batteryPath);
    if len(batteryPath)==0:
        print("The device has no battery.");
        return;
    itimeCount=0;
    while True:
        cmd=os.popen("upower -i "+batteryPath);
        strUpowerInfo=cmd.read();
        cmd.close();
        
        batteryDitail = dict();
        batteryDitail["time to empty"]='N/A';
        for eachline in strUpowerInfo.split("\n"):
            count = eachline.count(":");
            if count == 1:
                batteryDitail[eachline.split(':')[0].strip()] = eachline.split(':')[1];
            else:
                pass
        times=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        print(times)
        print("剩余电量：%s"%batteryDitail["percentage"]);
        #print("电量还可用：%s"%batteryDitail["time to empty"])
        #print("状态: %s"%batteryDitail['state'])
        #print("电压：%s"%batteryDitail["voltage"]);
        #print("温度：%s"%batteryDitail["temperature"]);
        print("用时：\t\t"+str(itimeCount)+" sec");
        with open('battery.txt', 'a+') as f:
            f.write(times+'\n');
            f.write("剩余电量："+batteryDitail["percentage"]+'\n');
            f.write("计时器: "+str(itimeCount)+" sec\n")
        time.sleep(10);
        itimeCount=itimeCount+10;

def useSysfs(path):
    print("Check the power supply with sysfs");
    
    itimeCount=0;
    while True:
        cmd=os.popen("cat "+path+"/uevent");
        strBatUevent=cmd.read();
        cmd.close();
        
        batteryDitail = dict();
        batteryDitail["POWER_SUPPLY_TIME_TO_EMPTY_AVG"]='N/A';
        for eachline in strBatUevent.split("\n"):
            count = eachline.count("=");
            if count == 1:
                try:
                    batteryDitail[eachline.split('=')[0].strip()] = eachline.split('=')[1];
                except Exception as e:
                    pass
            else:
                pass
        times=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        print(times)
        print("剩余电量：\t%s%%"%batteryDitail["POWER_SUPPLY_CAPACITY"]);
        #print("电量还可用：\t%s sec"%batteryDitail["POWER_SUPPLY_TIME_TO_EMPTY_AVG"])
        #print("状态: \t\t%s"%batteryDitail['POWER_SUPPLY_STATUS'])
        #print("电压：\t\t%s"%batteryDitail["POWER_SUPPLY_VOLTAGE_NOW"]);
        #print("温度：\t\t%s C"%batteryDitail["POWER_SUPPLY_TEMP"]);
        print("用时：\t\t"+str(itimeCount)+" sec");
        with open('battery.txt', 'a+') as f:
            f.write(times+'\n');
            f.write("剩余电量："+batteryDitail["POWER_SUPPLY_CAPACITY"]+'%\n');
            f.write("计时器: "+str(itimeCount)+" sec\n")
        time.sleep(10);
        itimeCount=itimeCount+10;
def main():
    cmd=os.popen("ls /sys/class/power_supply/");
    strSysfs=cmd.read();
    cmd.close();
    listSysfs=strSysfs.split("\n");
    strPowerSupply='';
    for line in listSysfs:
        if os.system('cat /sys/class/power_supply/'+line+"/capacity")==0:
             strPowerSupply='/sys/class/power_supply/'+line;
             break;

    if len(strPowerSupply)!=0:
        useSysfs(strPowerSupply);
    elif os.system('tlp-stat -v')==0:
        print("tlp-stat部分待开发")
    elif os.system('acpi -v')==0:
        print("acpi部分待开发")
    elif os.system('upower -v')==0:
        useUpower();
    elif os.system('batstat -v')==0:
        print("batstat部分待开发")
    else:
        print("No commands available")
if __name__=='__main__':
    main()
