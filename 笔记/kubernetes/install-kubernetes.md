# 安装kubernetes集群步骤：

> 注：所有节点：包括 master 和 node 节点

## 所有节点操作：

#### 1、安装 Docker 参照下面命令，也可以使用 yum install -y docker 安装（所有节点安装）
```shell
rpm -ihv docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
rpm -ivh docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm
```

#### 2、配置 docker 的 DaoCloud 镜像加速（所有节点执行）
```shell
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://28e14c14.m.daocloud.io
```
#### 3、设置 docker 随机启动，并启动 docker（所有节点执行）
```shell
systemctl daemon-reload
systemctl start docker && systemctl enable docker
```
#### 4、在 /etc/hosts 文件中绑定 master和node01....  如：
```shell
192.168.56.200  master
192.168.56.201  node01
192.168.56.202  node02
```
#### 5、生成密钥对，建立 master 和 node 之间互信 （在 master 执行）
> master节点使用ssh-keygen生成公钥和私钥对

> master节点使用 ssh-copy-id -i 私钥文件 root@node01 ,把私钥分发到node节点，需要node节点root密码
    如下：
```shell
[root@kube-master ~]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): kube
Enter passphrase (empty for no passphrase): 123456
Enter same passphrase again: 123456
Your identification has been saved in kube.
Your public key has been saved in kube.pub.
The key fingerprint is:
SHA256:UqsHLtz5HA3blxDYwNjhZKNPDmY9/59eOtFGkoIgNsE root@kube-master
```


#### 6、关闭防火墙和 selinux （所有节点执行）
> 关闭防火墙
```shell
systemctl stop firewalld && systemctl disable firewalld
```
> 关闭 selinux
```shell
vim /etc/sysconfig/selinux  
vim /etc/selinux/config  
```
>> 两种命令都可以用久关闭 selinux， 设置如下： 
```shell
SELINUX=disabled
```
>> 使用指令临时关闭 selinux ，系统重启后， selinux 又恢复启动状态： 
```shell
setenforce 0
```

#### 7、配置系统路由参数，防止 kubeadm 包路由警告/错误 (所有节点执行)
```shell
echo "
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" >> /etc/sysctl.conf
sysctl -p
```
> 注：相当于在 /etc/sysctl.conf 文件末尾，增加下面两行信息：
```shell
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1 
```
> 所以，也可以直接编辑 /etc/sysctl.conf 文件。

#### 8、导入离线的 kubernetes 相关 image 到 docker （所有节点执行, node可以少导入一些，没做更深研究），如下：
```shell
docker load -i /root/k8s_images/docker_images/etcd-amd64_v3.1.10.tar
docker load -i /root/k8s_images/docker_images/flannel:v0.9.1-amd64.tar
docker load -i /root/k8s_images/docker_images/k8s-dns-dnsmasq-nanny-amd64_v1.14.7.tar
docker load -i /root/k8s_images/docker_images/k8s-dns-kube-dns-amd64_1.14.7.tar
docker load -i /root/k8s_images/docker_images/k8s-dns-sidecar-amd64_1.14.7.tar
docker load -i /root/k8s_images/docker_images/kube-apiserver-amd64_v1.9.0.tar
docker load -i /root/k8s_images/docker_images/kube-controller-manager-amd64_v1.9.0.tar
docker load -i /root/k8s_images/docker_images/kube-scheduler-amd64_v1.9.0.tar
docker load -i /root/k8s_images/docker_images/kube-proxy-amd64_v1.9.0.tar
docker load -i /root/k8s_images/docker_images/pause-amd64_3.0.tar
docker load -i /root/k8s_images/kubernetes-dashboard_v1.8.1.tar
```
#### 9、安装 kubelet、kubeadm、kubectl 包 (所有节点安装，严格按照下面顺序执行,注意文件路径)
```shell
yum install -y socat-1.7.3.2-2.el7.x86_64.rpm
yum install -y kubernetes-cni-0.6.0-0.x86_64.rpm  kubelet-1.9.0-0.x86_64.rpm  kubectl-1.9.0-0.x86_64.rpm kubeadm-1.9.0-0.x86_64.rpm
```


***
## master节点操作：

#### 1、启动 kubelet 
```shell
systemctl enable kubelet && sudo systemctl start kubelet
```
#### 2、初始化 master 节点
```shell
kubeadm init --kubernetes-version=v1.9.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.200 --apiserver-cert-extra-sans=10.2.0.35,127.0.0.1,master
```
> 注:apiserver-advertise-address 为 apiserver 访问的 ip 地址，如果有多个 ip/网卡, 务必指定具体的那个ip,  apiserver-cert-extra-sans  #该参数指定自己内网地址和映射
#### 3、运行上面指令后，会生成一些列 kubernetes 的配置文件，具体在 /etc/kubernetes/ 目录下面，但可能会发生异常：
> 查看 /var/log/messages 日志，会有一行错误提示：kubelet 默认的 cgroup 的 driver 和 docker 的不一样，docker默认的 cgroupfs ，kubelet默认为 systemd，修改如下：
```shell
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
> 把参数:
```shell
KUBELET_CGROUP_ARGS=--cgroup-driver=systemd
```
> 调整为：
```shell
KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs
```

#### 4、重启 kubelet
```shell
systemctl daemon-reload && systemctl restart kubelet
```

#### 5、 使用 kubeadm 重置一下：
```shell
kubeadm reset
```

#### 6、继续执行 第2点 的指令
```shell
kubeadm init --kubernetes-version=v1.9.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.200 --apiserver-cert-extra-sans=10.2.0.35,127.0.0.1,master
```
> 注： 将kubeadm join xxx保存下来，等下node节点需要使用，如果忘记了，可以在master上通过kubeadmin token list得到，另外，在node节点执行该条命令，--token是有有效期的，默认是24小时
#### 7、执行完上面步骤后，但 root 用户还需要做下面执行 ：
> 按照上面提示，此时root用户还不能使用kubelet控制集群需要，配置下环境变量
>> 对于非root用户：
```shell
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```
>> 对于root用户
```shell
export KUBECONFIG=/etc/kubernetes/admin.conf
```
>> 也可以直接放到~/.bash_profile
```shell
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
```
>> source一下环境变量
```shell
source ~/.bash_profile
```

#### 8、安装网络，安装网络，可以使用flannel、calico、weave、macvlan这里我们用flannel
> 下载此文件
```shell
wget https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```
> 若要修改网段，需要kubeadm --pod-network-cidr=和这里同步
```shell
vim kube-flannel.yml
```
> 修改network项
```shell
"Network": "10.244.0.0/16",
```
> 执行
```shell
kubectl create -f kube-flannel.yml
```
#### 9、检查 master 节点的 pod 部署情况
```shell
kubectl get pod -n kube-system    #查找 kube-system 命名空间的 pod
```

***
## node 节点安装 

#### 1、启动 kubelet
```shell
systemctl daemon-reload && systemctl enable kubelet && sudo systemctl start kubelet
```

#### 2、加入 master 集群
> 使用刚刚在 master 上执行 kubeadm init 后得到 kubeadm join xxx 字符串，直接执行，比如：
```shell
kubeadm join --token 361c68.fbafaa96a5381651 192.168.56.200:6443 
--discovery-token-ca-cert-hash sha256:e5e392f4ce66117635431f76512d96824b88816dfdf0178dc497972cf8631a98
```
    
>> 注：没有执行 kubeadm 之前，kubelet 服务是无法启动的，加入成功后，kubelet 服务就会自动运行来了

***
# 测试集群：
## 在 master 节点上发起个创建应用请求
> 这里我们创建个名为 httpd-app 的应用，镜像为 httpd ，有两个副本 pod
```shell
kubectl run httpd-app --image=httpd --replicas=2
```
> 使用命令查看部署情况,会看见有个 name为 httpd-app 的部署情况
```shell
kubectl get deployment
```
> 使用命令查看 pod 情况
```shell
kubectl get cs
kubectl get nodes                           #查看所有节点
kubectl get deployment

kubectl get pods                            #查看默认命名空间default的节点
kubectl get pods -o wide                    #查看默认命名空间default的节点，包括部署节点及pod所分配的ip
kubectl get pods --all-namespaces           #查看所有命名空间的节点
kubectl get pods --all-namespaces -o wide   #查看所有命名空间的节点，包括部署节点及pod所分配的ip
```


***

