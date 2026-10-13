#!/bin/bash

apt-get update
apt-get install systemctl

systemctl enable isc-dhcp-relay
systemctl restart isc-dhcp-relay
systemctl status isc-dhcp-relay