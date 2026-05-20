#!/bin/bash
set -e
efibootmgr --bootnext 0000
reboot
