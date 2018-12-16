#!/bin/bash
# A dirty script to check istio status or check connectivity between containers
# Scribbled 15.11.2018 P.Caron
# pcaron.de@protonmail.com
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
NORMAL='\033[0m'

kcmd=kubectl
icmd=istioctl
# MAKE CHANGES HERE
# Set source and target container apps (e.g. sleepi and httpbin)
source_container="sleep"
target_container="codescene"
target_port="3003"
target_ns="codescene"
target_pod=`kubectl get pod -l app=$target_container -n $target_ns -o jsonpath={.items..metadata.name}`

if [ "$1" == "check" ]; then
echo $target_pod
echo $icmd proxy-config clusters $target_pod -n $target_ns --fqdn $target_container.$target_ns.svc.cluster.local -o json
exit 0

# Just run a basic curl test
elif [ "$1" == "test" ] ; then
echo "Single curl test:"
echo "kubectl exec $(kubectl get pod -l app=$source_container -n $target_ns -o jsonpath={.items..metadata.name}) -c $source_container -n $target_ns -- curl http://$target_container.$target_ns:$target_port/ip -s -o /dev/null -w '%{http_code}'"
echo -e "\nNext: we'll makes sure that there is noe mesh policy or default destination rule"
    echo "Authentication policies"
    $kcmd get policies.authentication.istio.io --all-namespaces
    echo "Default mesh policy"
    $kcmd get meshpolicies.authentication.istio.io
    exit 0

# Information about current policy and destination rules
elif [ "$1" == "info" ]; then
    echo -e "\n\033[1mAuthentication policies\033[0m"
    $kcmd get policies.authentication.istio.io --all-namespaces
    echo -e "\033[1mDefault mesh policy\033[0m"
    $kcmd get meshpolicies.authentication.istio.io
    echo -e "\033[1mIngress Services\033[0m"
    $kcmd get services istio-ingressgateway -n istio-system
    echo -e "\n\033[1mCurrent Ingress\033[0m"
    $kcmd get svc istio-ingressgateway -n istio-system
    echo -e "\n\033[1mCurrent destination rules\033[0m"
    # Verify that there are no destination rules that apply on the example services. 
    $kcmd get destinationrules.networking.istio.io --all-namespaces -o yaml | grep "host:"
    echo -e "\n\033[1mCurrent TLS Conflicts\033[0m"
    $icmd authn tls-check | grep CONFLICT
    exit 0
elif [ "$1" == "proxy" ]; then
    echo -e "\033[1mCurrent proxy status\033[0m"
    $icmd proxy-status
echo -e $BLUE
read -p "Press [Enter] key to continue ..."
echo -e $NORMAL
    echo -e "\033[1mCurrent proxy status for $target_pod\033[0m"
    $icmd proxy-config clusters $target_pod -n $target_ns --fqdn $target_container.$target_ns.svc.cluster.local -o json
    
#    POD=$(kubectl get pod -l app=$target_container -n bar -o jsonpath={.items..metadata.name})
    echo $POD

# Usage
else
    echo -e "\n\033[1mUsage:\n\033[0m$0 [arguments]" 
    echo -e "\033[1m ex:\033[0m $0 [test | info | proxy]"
fi

