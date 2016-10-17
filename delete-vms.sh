#!/bin/bash

source /home/ubuntu/devstack/openrc admin

read vms <<<$(nova list | grep $1 | awk '{print $4}')
#echo $vms

for vm in $vms
do
#echo $vm
nova delete $vm
done

#/bin/bash ./delete-floating-ip.sh

sleep 3
nova list
