#!/bin/bash -x
#
# Documentation on RFS and aRFS
# ==============================
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/network-rfs
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/network-acc-rfs
#

iface=${1-ens2f0np0}

service irqbalance stop

#ethtool -L $iface combined $rx_queues
#ethtool -l $iface 

# Number of rx queues
rx_queues=$(ethtool -l $iface | grep "Combined:" | tail -1 | awk '{print $2}')

# Set the value of this file to the maximum expected number of
# concurrently active connections. We recommend a value of 32768 for
# moderate server loads. All values entered are rounded up to the
# nearest power of 2 in practice.
flow_entries=32768

echo $flow_entries > /proc/sys/net/core/rps_sock_flow_entries

# Set the value of this file to the value of rps_sock_flow_entries
# divided by N, where N is the number of receive queues on a
# device. For example, if rps_flow_entries is set to 32768 and there
# are 16 configured receive queues, rps_flow_cnt should be set to
# 2048. For single-queue devices, the value of rps_flow_cnt is the
# same as the value of rps_sock_flow_entries.

#flow_count=$(( $flow_entries / $rx_queues ))
flow_count=$flow_entries

for f in $(seq 0 $(($rx_queues-1))); do
    echo $flow_count > /sys/class/net/$iface/queues/rx-$f/rps_flow_cnt;
done

# Accelerated RFS must be supported by the network interface
# card. Accelerated RFS is supported by cards that export the
# ndo_rx_flow_steer() netdevice function.
# ntuple filtering must be enabled.
ethtool -K $iface ntuple on
