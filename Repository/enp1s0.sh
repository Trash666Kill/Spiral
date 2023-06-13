#!/bin/bash
route del default enp7s0
ip route add default via 10.0.1.1 dev enp1s0
