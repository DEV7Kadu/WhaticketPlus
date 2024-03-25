#!/bin/bash
#
# Variables to be used for font styling.

# color
readonly RED="\033[1;31m"
readonly GREEN="\033[1;32m"
readonly WHITE="\033[1;37m"
readonly YELLOW="\033[1;33m"
readonly GRAY_LIGHT="\033[0;37m"
readonly CYAN_LIGHT="\033[1;36m"

# thickness
readonly BOLD=$(tput bold)
readonly NORMAL=$(tput sgr0)
