#!/bin/bash

#列出工程的所有scheme
if [ $2 == true ]; then
    echo `xcodebuild -workspace ./$1  -list` > ./listSchemes.temp
else
    echo `xcodebuild -project ./$1  -list` > ./listSchemes.temp
fi

#截取字符串
scheme=`expr $1 | cut -d'.' -f 1`
all_schemes=($scheme)

#读取文件
value=`cat ./listSchemes.temp`

#将文件内容存入数组
IFS=', ' read -r -a array <<< $value
#while (( ${#array[@]} > i )); do
#    printf "${array[i++]}\n"
#done

#删除临时文件
rm ./listSchemes.temp
#针对workspace跟project工程做处理
if [ $2 == true ]; then #workspace
    #文件读取出来的，前面5个元素是没意义的
    #截取有用的schemes
    sclice_schemes=("${array[@]:5}")


    #因为读取出来的schemes并没有包含工程的主scheme（很奇怪 - -）
    #所以拼接数组
    let i=0
    while (( ${#sclice_schemes[@]} > i )); do
        all_schemes+=(${sclice_schemes[i]})
        i=`expr $i + 1`
    done
else
    value='Schemes:'
    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" = "${value}" ]]; then
            index=`expr $i + 1`
            break
        fi
    done
    #截取有用的schemes
    sclice_schemes=("${array[@]:${index}}")
fi
