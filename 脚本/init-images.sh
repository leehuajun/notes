#!/bin/sh
#批量删除所有镜像
echo -e "\033[32m 1. 删除当前所有镜像 \033[0m"
docker rmi -f $(docker images -q)
#定义要pull的镜像:repository:tag
echo -e "\033[32m --------------------------------------------------------------------------- \033[0m"
echo -e "\033[32m 2. 拉取需要的镜像 \033[0m"
arr1=(
   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver-amd64:v1.9.2
   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.9.2
)
echo -e "  \033[36m 需要拉取镜像列表 \033[0m"
for each in ${arr1[*]};do
  echo -e "      \033[36m $each \033[0m"
done
echo -e "\033[32m --------------------------------------------------------------------------- \033[0m"
num=1
repo=k8s.gcr.io
for each in ${arr1[*]};
do
  echo -e "\033[32m 2.$num.1 拉取镜像: $each \033[0m"
  docker pull $each
  str1=${each##*/}
# 得到 k8s-dns-kube-dns-amd64:1.14.7 之类
  name=${str1%%:*}
  version=${str1##*:}
#  docker images -q $each
  arr2=$(docker images -q $each)
  imageid=${arr2[*]}
  echo -e "\033[32m 2.$num.2 重新定义标签为: $repo/$name:$version \033[0m"
  docker tag $imageid $repo/$name:$version
  echo -e "\033[32m 2.$num.3 导出新标签镜像: $repo/$name:$version \033[0m"
  docker save -o $name-$version.tar $repo/$name:$version
  echo -e "\033[32m 2.$num.4 删除镜像IMPAGE_ID: $imageid \033[0m"
  docker rmi -f $imageid
  echo -e "\033[32m 2.$num.5 导入2.$num.2步骤中导出的新镜像文件:$name-$version.tar \033[0m"
  docker load -i $name-$version.tar
  echo -e "\033[32m 2.$num.6 删除2.$num.2步骤中导出的新镜像文件:$name-$version.tar \033[0m"
  rm -rf $name-$version.tar
  echo -e "\033[32m --------------------------------------------------------------------------- \033[0m"
  let num++
done
echo -e "\033[32m 镜像处理完成,祝你玩得happy~~~~\033[0m"