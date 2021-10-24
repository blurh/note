#!/bin/bash

# 需求: 
# 从工具拉取出 idx 分配器使用情况, 根据 localglobal.conf 配置使用的 idx 序号
# 输出分配器: 总数, 已使用数, 已使用百分比

# idx 使用情况例: 
# 第二列表示 idx 序号, 第四列表示 idx 已使用量(1000000 表示已使用满)
cat > idx.txt <<EOF
idx 0 sect 4000
idx 1 sect 1000000
idx 2 sect 1000000
idx 3 sect 1000000
idx 4 sect 1000000
idx 5 sect 1000000
idx 6 sect 1000000
idx 7 sect 1000000
idx 8 sect 1000000
idx 9 sect 1000000
idx 10 sect 1000000
idx 11 sect 1000000
idx 12 sect 1000000
idx 13 sect 1000000
idx 14 sect 1000000
idx 15 sect 184304
idx 16 sect 184584
idx 17 sect 184628
idx 18 sect 184623
idx 19 sect 184479
idx 20 sect 184606
idx 21 sect 184675
idx 22 sect 184582
idx 23 sect 184742
idx 24 sect 184259
idx 25 sect 185542
idx 26 sect 184408
idx 27 sect 184716
idx 28 sect 185582
idx 29 sect 185303
idx 30 sect 184817
EOF

# localgloal.conf 配置文件
cat > localglobal.conf <<EOF
[UinType3]
UinSect=1-11,21-30
[UinType6]
UinSect=12-20
EOF

# idx 已使用情况, 测试情况直接读取 idx 文件
# IdAllocData=$(qso && tools/wwlocal_tools GetIdAllocData 3)
IdAllocData=$(cat ./idx.txt)

function GetCount(){
    UinTypeMax=$1
    UinTypeMin=$2
    echo "${IdAllocData}" \
      | awk -v UinTypeMax=${UinTypeMax} -v UinTypeMin=${UinTypeMin} -v UsageCount=0 \
         '{ 
           if($2 <= UinTypeMax && $2 >= UinTypeMin){UsageCount+=$4} 
           if($2 <= UinTypeMax && $2 >= UinTypeMin){TotalCount+=1000000} 
         }
         END{
           print UsageCount, TotalCount
         }' 
}

function MonUinTypeUsage() {
    UinType="$1"

    UinTypeList=$(sed -n 's/,/ /g;/^\['$UinType'\]$/,/^\[.*\]$/ p' ./localglobal.conf | awk -F'=' '/UinSect=/ {print $2}')

    let AllUsageCount=0
    let AllTotalCount=0
    for scope in $(echo ${UinTypeList}); do 
        eval $(echo ${scope} | awk '{match($0, /([0-9]+)\-([0-9]+)/, list);printf "UinTypeMin=%d;UinTypeMax=%d", list[1], list[2]}' )
        UsageCount=$(GetCount ${UinTypeMax} ${UinTypeMin} | awk '{print $1}')
        TotalCount=$(GetCount ${UinTypeMax} ${UinTypeMin} | awk '{print $2}')
        AllUsageCount=$(expr ${AllUsageCount:-0} + ${UsageCount})
        AllTotalCount=$(expr ${AllTotalCount:-0} + ${TotalCount})
    done
    
    UsagePer="$(expr ${AllUsageCount} \* 100 / ${AllTotalCount})%"
    echo \"type\": \"${UinType}\", \"usage\": ${AllUsageCount},  \"total\": ${AllTotalCount}, \"usagePercent\": \"${UsagePer}\"
}

MonUinTypeUsage UinType3
MonUinTypeUsage UinType6

