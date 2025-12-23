.PHONY: genconfig apply all replace-ipv4

all: genconfig apply replace-ipv4 kubeconfig

genconfig:
	talhelper genconfig

replace-ipv4:
	sed -i '' 's/192\.168\.1\.138/2a01:e0a:5b7:4a40::11/g' ./clusterconfig/talosconfig
	sed -i '' 's/192\.168\.1\.64/2a01:e0a:5b7:4a40::12/g' ./clusterconfig/talosconfig
	sed -i '' 's/192\.168\.1\.18/2a01:e0a:5b7:4a40::13/g' ./clusterconfig/talosconfig
apply:
	talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=192.168.1.138 --file=./clusterconfig/ipv6-only-talos-cluster-talos-ipv6-only-01.yaml --insecure;
	talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=192.168.1.64 --file=./clusterconfig/ipv6-only-talos-cluster-talos-ipv6-only-02.yaml --insecure;
	talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=192.168.1.18 --file=./clusterconfig/ipv6-only-talos-cluster-talos-ipv6-only-03.yaml --insecure;
bootstrap:
	talosctl bootstrap --talosconfig=./clusterconfig/talosconfig -n 2a01:e0a:5b7:4a40::11
install-cilium:
	KUBECONFIG=kubeconfig cilium install \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=2a01:e0a:5b7:4a40::11 \
    --set k8sServicePort=6443 \
	--set cgroup.hostRoot=/sys/fs/cgroup \
	--helm-set ipv6.enabled=true \
	--helm-set ipv4.enabled=false \
	--helm-set ipv6NativeRoutingCIDR=2a01:e0a::/32 \
	--helm-set ipam.operator.clusterPoolIPv6PodCIDRList="{2a01:e0a:5b7:4a41::/64}" \
	--helm-set enableIPv6Masquerade=false \
	--helm-set routingMode=native

kubeconfig:
	talosctl --talosconfig=./clusterconfig/talosconfig kubeconfig --nodes=192.168.1.138 --merge=false 
debug-pod:
	KUBECONFIG=kubeconfig kubectl run -i --tty debug -n kube-system --image=ubuntu --restart=Never -- sh
reset:
	talosctl reset --talosconfig=./clusterconfig/talosconfig --nodes=2a01:e0a:5b7:4a40::11,2a01:e0a:5b7:4a40::12,2a01:e0a:5b7:4a40::13 --graceful=false --reboot;