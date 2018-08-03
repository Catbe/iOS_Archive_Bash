#!/bin/bash

# 换行符
__LINE_BREAK_LEFT="\n\033[32;1m"
__LINE_BREAK_RIGHT="\033[0m\n"

#更新timeout
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=120

#计时
SECONDS=0

echo "============================================================================"
echo "                              😁 温馨提示  😆"
echo " 运行此脚本前，请您正确填写脚本同路径下的ExportOptions.plist所需相关信息"
echo "                         否则会导致打包失败 ☹️  ☹️  ☹️"
echo -e "============================================================================\n "

printf "\n\033[32;1m是否已经填写ExportOptions.plist (y/n)?\033[0m   "
while :
do
    read already
    if [ $already = "y" ] || [ $already = "yes" ]; then
        break
    elif [ $already = "n" ] || [ $already = "no" ]; then
        exit
    else
        echo "输入有误，请重新输入"
    fi
done

# 判断脚本所在目录是否存在工程文件
hasWorkspace=false
hasProject=false

if [ -e ./*.xcworkspace ]; then
    hasWorkspace=true
fi

if [ -e ./*.xcodeproj ]; then
    hasProject=true
fi

if [ $hasWorkspace == false ] && [ $hasProject == false ]; then
    echo "未找到工程文件 ☹️"
    echo "请将脚本放在工程目录下 😁  😁  😆"
    exit
fi

for file in `ls`
do
    if [[ $file = *".xcworkspace" ]]; then
        workspaceName=$file
    fi
    if [[ $file = *".xcodeproj" ]]; then
        projectName=$file
    fi
done

#取当前时间字符串添加到文件结尾
now=$(date +"%Y-%m-%d-%H-%M-%S")

#列取出该工程的所有scheme
if [ $hasWorkspace == true ]; then
    source ./list_schemes.sh $workspaceName $hasWorkspace
else
    source ./list_schemes.sh $projectName $hasWorkspace
fi

printf "\n\033[32;1m请选择想要打包的scheme(输入对应数字，回车即可) \033[0m\n"
let i=0
while (( ${#all_schemes[@]} > i )); do
    index=`expr $i + 1`
    printf "\033[34;1m${index}. ${all_schemes[i++]}\033[0m\n"
done

while :
do
    read scheme_index
    if [ $scheme_index -le ${#all_schemes[@]} ] && [ $scheme_index -ge 1 ]; then
        index=`expr $scheme_index - 1`
        scheme=${all_schemes[${index}]}
        break
    else
        printf "\033[28;1;5m请选择正确的scheme\033[0m\n"
    fi
done

printf "${__LINE_BREAK_LEFT}请选择打包的模式(输入对应数字，回车即可)${__LINE_BREAK_RIGHT}"
printf "\033[34;1m1. app-store模式\033[0m"
printf "\n\033[34;1m2. ad-hoc模式\033[0m\n"
read mode

#上述scheme/target/configuration若不清楚值可以用`xcodebuild -list`查看
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
case $mode in
    1)
        export_method="app-store"
        ;;
    2)
        export_method="ad-hoc"
        ;;
esac

while :
do
    printf "${__LINE_BREAK_LEFT}请输入ipa导出路径${__LINE_BREAK_RIGHT}"
    read path
    if [ ! -d $path ]; then
        printf "\033[28;1;5m输入的路径不是目录！请重新输入\033[0m\n"
    elif [ ! -e $path ]; then
        mkdir $path
        break
    else
        break
    fi
done

#配置默认导出路径
#path="把上面的while循环代码注释掉，然后在这里填写你的ipa导出路径, 注意需要是个目录"

#指定打包的配置名
configuration="Release"

#指定项目地址
workspace_path="./${workspaceName}"
project_path="./${projectName}"
output_path="${path}/${scheme}_${now}"
#指定输出归档文件地址
archive_path="$output_path/${scheme}.xcarchive"
#指定输出ipa名称
ipa_name="${scheme}.ipa"
#指定输出ipa地址
ipa_path="$output_path/${scheme}"

#build之前先clean
#echo "fastlane gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --include_bitcode false --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}"
#fastlane gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --include_bitcode false --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}

mkdir $output_path

if [ $hasWorkspace == true ]; then
    xcodebuild archive  -workspace ${workspace_path} -scheme ${scheme} -configuration ${configuration} -archivePath ${archive_path}
else
    xcodebuild archive  -project ${project_path} -scheme ${scheme} -configuration ${configuration} -archivePath ${archive_path}
fi

xcodebuild -exportArchive -archivePath ${archive_path} -exportPath ${ipa_path} -exportOptionsPlist ./ExportOptions.plist

#输出总用时
echo "🎉  🎉  🎉  打包成功  🎉  🎉  🎉"
echo "-----本次用时: ${SECONDS}s -----"


