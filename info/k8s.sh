#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "容器运行时"
echo "https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/"
echo
echo "kubeadm 概述"
echo "https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm/"
echo
echo "安装 kubeadm"
echo "https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/"
echo
echo "使用 kubeadm 创建一个单主集群"
echo "https://kubernetes.io/zh/docs/setup/independent/create-cluster-kubeadm/"
echo
echo "使用 kubeadm 引导集群"
echo "https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/"
echo
echo "安装并配置 kubectl"
echo "https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/"
echo
echo "使用 Kops 安装 Kubernetes"
echo "https://kubernetes.io/zh/docs/setup/production-environment/tools/kops/"
