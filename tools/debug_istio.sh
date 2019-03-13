#!/bin/bash
# A dirty script to check istio status or check connectivity between containers
# Scribbled 15.11.2018 P.Caron
# pcaron.de@protonmail.com
INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
INGRESS_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
kcmd=kubectl
icmd=istioctl

# Set source and target container apps (e.g. sleep and httpbin)
#source_container="sleep"
#target_container="httpbin"
#target_port="8000"

# Collect CLI params
# Assume default namespace is default unless defined
if [ -z "$5" ];then
    target_ns="default"
else
    target_ns="$5"
fi
source_container="$2"
target_container="$3"
target_port="$4"

# Just run a basic curl test
if [ "$1" == "test" ] ; then
echo "Single curl test:"

echo "kubectl exec $(kubectl get pod -l app=$source_container -n $target_ns -o jsonpath={.items..metadata.name}) -c $source_container -n $target_ns -- curl http://$target_container:$target_port/ -s -o /dev/null -w '%{http_code}'"
kubectl exec $(kubectl get pod -l app=$source_container -n $target_ns -o jsonpath={.items..metadata.name}) -c $source_container -n $target_ns -- curl http://$target_container:$target_port/ -s -o /dev/null -w '%{http_code}'
echo ""
exit 0

# Check default mesh and authentication policies
elif [ "$1" == "check" ]; then
echo -e "\nMake sure that there is no mesh policy or default destination rule"
    echo "Authentication policies"
    $kcmd get policies.authentication.istio.io --all-namespaces
    echo "Default mesh policy"
    $kcmd get meshpolicies.authentication.istio.io
    echo "If these exist delete them before running '$0 test'"
    echo "Next: run $0 test"
    echo "... then $0 mesh and $0 test again"
    exit 0

# Display information about current policy and destination rules
elif [ "$1" == "info" ]; then
    echo -e "\033[1mCurrent proxy status\033[0m"
    $icmd proxy-status
    echo -e "\n\033[1mAuthentication policies\033[0m"
    $kcmd get policies.authentication.istio.io --all-namespaces
    echo -e "\033[1mDefault mesh policy\033[0m"
    $kcmd get meshpolicies.authentication.istio.io
    echo -e "\033[1mIngress Services\033[0m"
    $kcmd get services istio-ingressgateway -n istio-system
    echo -e "\n\033[1mCurrent destination rules\033[0m"
    # Verify that there are no destination rules that apply on the example services.
    $kcmd get destinationrules.networking.istio.io --all-namespaces -o yaml | grep "host:"
    echo -e "\n\033[1mCurrent Ingress\033[0m"
        $kcmd get svc istio-ingressgateway -n istio-system
        echo "INGRESS_HOST: "$INGRESS_HOST
        echo "INGRESS_IP: "$INGRESS_IP
        echo "INGRESS_PORT: "$INGRESS_PORT
        echo "GATEWAY_URL: "$GATEWAY_URL
echo -e "\033[34m"
read -p "Press [Enter] key to display istio TLS conflicts "
echo -e "\033[0m"
    echo -e "\n\033[1mCurrent TLS Conflicts\033[0m"
    $icmd authn tls-check | grep CONFLICT

# Display Usage
else
    echo -e "\n\033[1mUsage:\n\033[0m$0 [arguments]"
    echo -e "\033[1m ex:\033[0m $0 [test | check | info] <source> <target> <port>"
    echo -e "\ntest runs a curl check between source and target (default)"
    echo -e "\ncheck authentication and mesh policies"
    echo -e "\ninfo gives proxy, policies. mesh, ingress and det rules for target ns"

fi

