#!/bin/bash

source /home/ubuntu/devstack/openrc admin

read key <<<$(nova keypair-list | grep mykey | awk '{print $2}')

read img_id <<<$(glance image-list | grep Ubuntu | awk '{print $2}')

read nw_id <<<$(nova network-list | grep private | awk '{print $2}')

nova boot --user-data install_hadoop.sh --flavor d2 --image $img_id --nic net-id=$nw_id --key-name $key $1

read ip <<<$(nova floating-ip-create | grep 192.168 | awk '{print $4}')

#echo $ip
nova floating-ip-associate $1 $ip

