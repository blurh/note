#!/bin/bash

: << EOF
    背景: 
    有 27G 的 dfs 索引文件
    要求根据 file_id 头两位, cretae_time, flags, favorite flags 按天聚合分析数量, 大小: 

    createtime  fileType  flag  favoriteFlag  count  size(bytes)
    2020-05-11  WI        0     0             1      27634
    ...
EOF

# one of index file block: 
cat > allfileinfo.txt <<EOF
    {
        file_id: WI5811-Hj_H12oejasSa24wpaJgCa5,
        file_size: 27634,
        file_md5: ,
        file_sha: ,
        create_time: 1589212408,
        flags: 0,
        idc: 1,
        ip1: 192.168.0.1,
        ip2: 192.168.0.2,
        ip3: 192.168.0.3,
        cache_ip_list1: ,
        cache_ip_list2: ,
        cache_ip_list3: ,
        version: 12
        favorite flags: 0
    }
EOF

# 由 grep 去掉不需要字段, 再交由 awk 去掉多余字符, 再进行聚合统计
# 这样分开进行可以适当避免单核性能问题, 加快处理速度
# 实测 27G 索引文件需要处理 36min
grep -E 'create_time|file_id|file_size|flags' allfileinfo.txt \
  | awk -F: '{
      if(/file_id:/){
        printf substr($2, 2, 2)
      }else if(/file_size:/){
        sub(/,/, " ", $2);
        printf $2
      }else if(/create_time/){
        sub(/,/, "", $2);
        printf strftime("%F", $2)
      }else if(/flags/ && $1 !~ /favorite flags/){
        sub(/,/, "", $2);
        printf $2;
      }else if(/favorite flags/){
        print $2
      }
    }' \
  | awk '{
      if($1 !~ /WI|WB|WN|WD/){
        $1="OTHER"
      };
      fileSizeOfTypeAndDay[$3" "$1" "$4" "$5]+=$2;
      fileCountOfTypeAndDay[$3" "$1" "$4" "$5]+=1
    }END{
      print "createtime fileType flag favoriteFlag count size(bytes)";
      for(type in fileSizeOfTypeAndDay){
        print type, fileCountOfTypeAndDay[type],fileSizeOfTypeAndDay[type]
      }
    }' \
  | column -t 

