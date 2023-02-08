#!/bin/bash

#######################################
# Developed by Alice (maoyamin)
#######################################

# 工具当前的版本号
Version="1.0.0"

# 设置允许测试的电量阈值
testPercent="98"

# 保存log的路径
testLogFile="batterytest.log"

# PPT的路径
path_PPT="hello.pptx"

# 默认的测试模式
testMode=1

starLine="**********************************************************"
welcomeStr="Welcome to the battery life test tool"
versionStr="Version: $Version"
authorsStr="Developed by Alice."

writeLog(){
    echo -e `date +"%Y-%m-%d %H:%M:%S "` $1 >> $testLogFile
}

# 检查电池电量百分比
checkBatteryPercent(){
    echo "Check the battery percent......"
    # type指令判断upower是否存在,并获取返回值
    
    checkUpower=`type upower`
    echo $checkUpower
    if [ $? -eq 0 ]
    then
        # 检查电脑是否有电池
        cmdRet=`upower -e | grep battery`

        if [ ${#cmdRet} -eq 0 ];then
            echo "warning: The device has no battery"
            exit 1
        fi
        echo -e "$cmdRet"
        array=(${cmdRet//'\n'/ })
        # 提取battery信息的文件位置
        batteryPath=${array[0]}
        

        # 获取电池的电量（百分比）
        cmdRet=`upower -i $batteryPath | grep "percentage"`
        echo -e "$cmdRet"
        #writeLog "$cmdRet"
        array=(${cmdRet// /})
        for var in "${array[@]}"
        do
            # 对结果进行解析
            array2=(${var//:/ })
            array2=(${array2[1]//%/})
            echo ${array2[0]}
            
        done
        if [[ "${array2[0]}" -lt "$testPercent" ]];then
		    echo "warning: The battery is too low to perform the test."
            echo "${array2[0]} % < $testPercent %"
            exit 1
        fi
        
    else
        echo "no shell suport"
        exit 1
    fi
}

# 关闭网卡
closeNetwork(){
    echo "Disable the network NIC......"
    # 获取网卡信息，筛选出网卡名称
    a=(`ifconfig | grep ^[a-z] | awk '{print $1}' | sed 's/://'| sed 's/lo//'`)
    for var in "${a[@]}"
    do
        echo "ifconfig $var down"
        #ifconfig $var down
    done
}

test01(){
    
}

#
# 主循环函数
#
mainLoop(){
    echo "environmental checking......"
    checkBatteryPercent
    closeNetwork
    echo"start test......"
    startTime=`date +%Y%m%d-%H:%M:%S`
    startTime_s=`date +%s`

    writeLog "$starLine"
    writeLog "$welcomeStr"
    writeLog "$versionStr"
    writeLog "$authorsStr"
    writeLog "$starLine"

    while true
    do
        case $testMode in
        1)
            ;;
        2)
            ;;
        3)
            ;;
        *)
            echo "Warning: Parameter $testMode is incorrect"
            ;;
        esac

        endTime=`date +%Y%m%d-%H:%M:%S`
        endTime_s=`date +%s`
        sumTime=$[ $endTime_s - $startTime_s ]
        writeLog "passed $sumTime seconds"
        echo "passed $sumTime seconds"
    done
}


##############################################
# 最开始执行的地方
###############################################

echo "$starLine"
echo "$welcomeStr"
echo "$versionStr"
echo "$authorsStr"
echo "$starLine"

if [ $# -ne 0 ]
then
    testMode=$1
fi
# Judge whether the input parameters are correct.
# 检查输入的参数是否正确
case $testMode in
1)
    echo -e "(1) Standard endurance test."
    mainLoop
    exit 0;;
2)
    echo -e "(2) User Scenario Endurance Test."
    mainLoop
    exit 0;;
3)
    echo -e "(3) Video playback endurance test."
    mainLoop
    exit 0;;

esac

echo -e "warning: Please enter the correct number!\n"


