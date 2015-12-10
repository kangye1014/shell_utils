#!/bin/bash
################################################
#set env
#export PATH=$PATH:/bin:/sbin:/usr/sbin
#export PATH="zh_CN.GB18030"
#Require root to run this script.
#if [[ "$(/usr/bin/whoami)" != "root"  ]];then
#        echo "Please run this script as root "
#	    exit
#fi
#Source function library
. /etc/init.d/functions
# Config Yum CentOS-Base.repo
Configyum(){
     echo "Config Yum CentOS-Base.repo."   	
     cd /etc/yum.repos.d/
     /bin/mv CentOS-Base.repo CentOS-Base.repo.ori.$(date +%F)
     #ping -c 1 www.baidu.com
     #[ $? -ne 0 ] && echo "Networking  can't found " && exit 2
     wget http://mirrors.sohu.com/help/CentOS-Base-sohu.repo
     /bin/mv /root/python/CentOS-Base-sohu.repo CentOS-Base.repo
}
#Install Init Package
installTool(){
    echo "lrzsz"
    yum -y install lrzsz >/dev/null 2>&1
}
##Charset GB18030
initI180n(){
    echo "#set LANG="zh_cn.gb18030""
    cp /etc/sysconfig/i18n /etc/sysconfig/i18n_$(date +%F)
    sed -i 's#LANG="en_US.UTF-8"#LANG="zh_CN.GB18030"#g' /etc/sysconfig/i18n
    source  /etc/sysconfig/i18n 
    sleep 2
}
initFirewall(){
 #disable iptables
/etc/init.d/iptables stop
chkconfig iptables off
 #disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled,you must reboot!"
    setenforce 0 
}
#Init Auto Startup Service
initService(){
    echo "Init Auto Startup Service"
    export LANG="en_US.UTF8"
    for i in `chkconfig --list| grep 3:on|awk '{print$1}'`;do chkconfig --level 3 $i off;done
    for i in crond nfs portmap syslog network sshd ;do chkconfig --level 3 $i on;done 
    export LANG="zh_CN.GB18030"
    sleep 1
}
#initTime
initTime(){
    echo "time configure"
    /usr/sbin/ntpdate time.nist.gov
	#ntpdate ntp.sjtu.edu.cn
    echo '#time sync by oldboy at 2015-05-07' >>/var/spool/cron/root
    echo '*/5 * * * * /usr/sbin/ntpdate 172.16.1.17 >/dev/null 2>&1' >>/var/spool/cron/root
}
#openFiles
openFiles(){
    echo "change openfile "
    cp /etc/security/limits.conf   /etc/security/limits.conf.$(date +%F)
    echo '*  -  nofile  65535 ' >>/etc/security/limits.conf
    ulimit -HSn 65535
    ulimit -s 65535 
   echo " ulimit -HSn 65535
    #stack size 
    ulimit -s 65535" >>/etc/rc.local
    sleep 1
}
###optimizationKernel
optimizationKernel(){
    cp /etc/sysctl.conf  /etc/sysctl.conf.$(date +%F)
cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
EOF
  /sbin/sysctl -p && action optimizationKernel /bin/true || action optimizationKernel /bin/false
}
#set
filesafe(){
   chmod 644 /etc/passwd
   chmod 644 /etc/shadow
   chmod 644 /etc/group
   chmod 644 /etc/gshadow
   action filesafed /bin/true
}
#Configyum  
#installTool  
#initI180n  
#initFirewall 
initService 
initTime 
openFiles 
optimizationKernel
filesafe