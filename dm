#!/bin/bash
# Usage: dm <device>
# Mount a given device asif it were used via Gnome
# e.g. dm sda6

sudo devkit-disks --mount "/dev/$1"
