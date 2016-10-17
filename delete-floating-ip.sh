#!/bin/bash

read ip <<<$(nova floating-ip-list | grep 192.168 | awk '{print $4}')
#echo $ip

for a in $ip
do
#echo $a
nova floating-ip-delete $a
done

nova floating-ip-list
