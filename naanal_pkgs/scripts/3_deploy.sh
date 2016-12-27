figlet -f digital 'Deployement started'

if (( "$EUID" != 0 )); then
        echo "Please run as root"
        exit
else

        kolla-ansible deploy
        kolla-ansible post-deploy
        cp /etc/kolla/admin-openrc.sh /home/admin-openrc.sh

        figlet -f digital 'Deployment Completed'
fi

