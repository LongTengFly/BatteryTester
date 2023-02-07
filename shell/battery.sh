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

echo "**********************************************************"
echo "Welcome to the battery life test tool"
echo "Version: $Version"
echo "Developed by Alice."
echo "**********************************************************"

writeLog()
{
    # echo `date +"%Y-%m-%d %H:%M:%S"` begin >> ./a.log
    # echo `date +"%Y-%m-%d %H:%M:%S"` end >> ./a.log
    echo -e `date +"%Y-%m-%d %H:%M:%S "` $1 >> $testLogFile
}

# Standard endurance test.
# 标准测试
standardTest() {
    echo "Start Standard endurance test."
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

# Main function
# 测试的主函数
mainLoop() {
    checkBatteryPercent
    

    standardTest
}
#######################################################
# 最开始的地方
######################################################
if [ $# -eq 0 ]
then
# Handling cases without command line arguments
# 处理没有命令行参数的情况
    echo "Without command line arguments."
    while true
    do
        echo "Please select the test mode (enter a number, enter 'q' to exit):"
        echo -e "\t1) Standard endurance test."
        echo -e "\t2) User Scenario Endurance Test."
        echo -e "\t3) Video playback endurance test."
        echo -e "\tq) quit."

        # Read user input
        # 读取用户输入
        read num

        # Judge whether the input parameters are correct.
        # 检查输入的参数是否正确
        case $num in
        "q")
            echo "Byte!"
            exit 1;;
        1 | 2 | 3)
            echo "choose $num"
            mainLoop
            exit 0;;
        esac

        echo -e "warning: Please enter the correct number!\n"

    done
else
# Handles the case of passing parameters through the command line.
# 处理通过命令行传递参数的情。
    echo "Parse parameters"
fi

#echo $1