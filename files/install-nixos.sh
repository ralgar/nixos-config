#!/usr/bin/env bash

########################################
###	  TEXT MANIPULATION HELPERS
########################################
off='\e[0m'		# Reset all attributes
bld='\e[1m'		# Bold/bright text
dim='\e[2m'		# Dim text
und='\e[4m'		# Underlined text
bln='\e[5m'		# Blinking text
inv='\e[7m'		# Inverted text (FG/BG)
hid='\e[8m'		# Hidden text
red='\e[31m'	# Red text
grn='\e[32m'	# Green text
yel='\e[33m'	# Yellow text
blu='\e[34m'	# Blue text
pur='\e[35m'	# Purple text
cyn='\e[36m'	# Cyan text

########################################
###	  TRAP / CLEANUP
########################################
function cleanup
{
    setterm -cursor on	# Show the terminal cursor
}
trap cleanup EXIT 1 2 3 SIGTRAP 6 14 15

########################################
###	  CHECK PRIVILEGES
########################################
if [[ $EUID != 0 ]] ; then
    echo -e "\n${bld}${red}ERROR: This script must be run as root.${off}"
    exit 2
fi

#############################################
###	YES OR NO FUNCTION
#############################################
function yes_or_no
{
    local question="${1:?}"
    local answer
    local yes_cmd="${2:?}"
    local no_cmd="$3"

    setterm -cursor on
    read -rp "${question} [y/N]: " answer
    setterm -cursor off
    echo
    case $answer in
        [Yy])
            ${yes_cmd:?}
            ;;
        [Nn]|*)
            # If a no command has been passed, execute it.
            if [[ -n "$no_cmd" ]] ; then
                ${no_cmd:?}
            fi
            ;;
    esac
}

########################################
###	  RUN FUNCTION
########################################
# Used to make commands look nice while saving their output to a log file.
log_file="/tmp/$(basename -s .sh "$0")-$(date +'%Y-%m-%d_%H-%M-%S_%Z').log"
function run
{
	"$@" &> "$log_file" &
	run_pid=$!
	while [[ -d /proc/"$run_pid" ]] ; do
		echo -en "[      ]  $desc\r" ; sleep .75
		[[ -d /proc/"$run_pid" ]] || break
		echo -en "[ .    ]  $desc\r" ; sleep .75
		[[ -d /proc/"$run_pid" ]] || break
		echo -en "[ ..   ]  $desc\r" ; sleep .75
		[[ -d /proc/"$run_pid" ]] || break
		echo -en "[ ...  ]  $desc\r" ; sleep .75
		[[ -d /proc/"$run_pid" ]] || break
		echo -en "[ .... ]  $desc\r" ; sleep .75
	done
	wait $run_pid ; code=$?
	if [[ $code = 0 ]] ; then
		echo -e "[  ${bld}${grn}OK${off}  ]  $desc"
	else
		echo -e "[ ${bld}${red}FAIL${off} ]  $desc\n"
		sleep 3
		echo -e "\n${bld}${red}Something went wrong! See the log file '${log_file}' for more detail.${off}"
        exit 2
	fi
}

# Disable the terminal cursor
setterm -cursor off

########################################
###	  INSTALL NIXOS
########################################

function reset_screen
{
    clear
    echo -e "\n${bld}${blu}##########################"
    echo -e "###   ${cyn}Install NixOS!   ${blu}###"
    echo -e "##########################${off}\n"
    sleep 1
}

function partition_disks
{
    nix run github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        --flake "/etc/nixos#${REF}" \
        --yes-wipe-all-disks || return 1
}

function install_nixos
{
    mkdir -p /mnt/etc
    rsync -a "$(realpath /etc/nixos)/" /mnt/etc/nixos/ || return 1
    nixos-generate-config --no-filesystems --root /mnt || return 1
    nixos-install --no-root-passwd --root /mnt --flake "/mnt/etc/nixos#${REF}" || return 1
}

function reboot_system
{
    unmount_filesystems || return 1
    reboot || return 1
}

function unmount_filesystems
{
    # Sync and unmount all filesystems to complete installation
    sync || return 1
    nix run github:nix-community/disko/latest -- \
        --mode unmount \
        --flake "/etc/nixos#${REF}" || return 1
}

# Get list of configurations
mapfile -t configs < <(sudo nix flake show --json /etc/nixos | jq -r '.nixosConfigurations | keys[]')

# Display menu
reset_screen
echo -e "Available Configurations:\n"
for i in "${!configs[@]}"; do
    echo "  $i) ${configs[$i]}"
done
echo

# Get user choice
read -rp "Select configuration (0-$((${#configs[@]} - 1))): " choice

# Validate and use selection
if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt "${#configs[@]}" ]; then
    REF="${configs[$choice]}"
    echo "Selected: $selected"
else
    echo -e "\nInvalid selection"
    exit 1
fi

# Confirm selection and disk erasure. If confirmed, continue with installation.
reset_screen
echo -e "${bld}${yel}WARNING: This will ERASE the disk targeted by this configuration${off}\n"
read -rp "Are you sure? (y/N): " confirm
case "$confirm" in
    [Yy])
        ;;
    *)
        echo -e "\n${bld}${red}Installation cancelled!${off}"
        exit 1
        ;;
esac

# Begin installation
reset_screen
echo -e "${bld}${cyn}Installing${off}\n"

# Partition the target disk
desc="Partitioning disk"
partition_disks

desc="Installing NixOS"
install_nixos

echo -e "\n${bld}${grn}Installation complete! Remove the USB and reboot.${off}\n"
yes_or_no "Unmount and reboot now?" reboot_system
