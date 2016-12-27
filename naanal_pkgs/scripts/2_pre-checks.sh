tal 'Prechecks started'

if (( "$EUID" != 0 )); then
        echo "Please run as root"
        exit
else

        kolla-ansible prechecks

        figlet -f digital 'Prechecks Completed'
fi

