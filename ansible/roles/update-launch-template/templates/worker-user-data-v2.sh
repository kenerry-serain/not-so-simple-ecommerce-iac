#!/bin/bash

function updateHostname(){
    hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/hostname)
}

function installSystemsManagerAgentOnEc2(){

    if [ ! -d "/tmp/ssm" ]; then
        mkdir -p /tmp/ssm
    fi

    cd /tmp/ssm

    if [ ! -f "amazon-ssm-agent.deb" ]; then
        wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
    fi

    dpkg -i amazon-ssm-agent.deb
}

function installKubernetesDependencyPackages(){
    sleep 30
    apt-get update -o DPkg::Lock::Timeout=5 -y
    apt-get install -o DPkg::Lock::Timeout=5 -y apt-transport-https\
        ca-certificates \
        curl \
        gpg\
        software-properties-common
}

function installKubernetesPackages(){
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
        gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
        tee /etc/apt/sources.list.d/kubernetes.list

    apt-get update -o DPkg::Lock::Timeout=5 -y
    apt-get install -o DPkg::Lock::Timeout=5 -y kubelet \
        kubeadm \
        kubectl
    apt-mark hold kubelet \
        kubeadm \
        kubectl
}

function installContainerRuntime(){
    curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/deb/Release.key |\
        gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

    echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/deb/ /" |\
        tee /etc/apt/sources.list.d/cri-o.list

    apt-get update -o DPkg::Lock::Timeout=5 -y
    apt-get install -o DPkg::Lock::Timeout=5 -y cri-o
    sysctl -w net.ipv4.ip_forward=1
    systemctl start crio.service
}

function joinWorkerNode(){
    # {{joinWorkerCommand}}
    kubeadm join nsse-production-cp-nlb-86c722d3a946bf3e.elb.us-east-1.amazonaws.com:6443 --token cwii33.sije55nxciq3oci1 --discovery-token-ca-cert-hash sha256:99bd836762b8652e823d96015ecd6aa68580bf174d9aa035ca33f70c5901aa4c
}

updateHostname
installSystemsManagerAgentOnEc2
installKubernetesDependencyPackages
installKubernetesPackages
installContainerRuntime
joinWorkerNode