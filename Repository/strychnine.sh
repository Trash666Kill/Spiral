#!/bin/bash
#
autossh -M 0 -N -R 2222:localhost:22 -p 4634 emperor@strychnine.duckdns.org -o StrictHostKeyChecking=false
#
