#!/bin/bash

#XTRACE=$(set +o | grep xtrace)
#set -o xtrace

#ERREXIT=$(set +o | grep errexit)
#set -o errexit

function change_hostname  {
	OLD_HOST=hostname
	read -p "Enter a New Host Name........" HOST_NAME
	hostnamectl set-hostname $HOST_NAME
	sudo sed -i "s/${OLD_HOST}/${HOST_NAME}/g" /etc/hosts

	#Starting Telegraf After Changing Host Name
	sudo sed -i.bak '/telegraf/d' /etc/rc.local
	sudo usermod -aG docker telegraf
	serivce telegraf start
	tar -xvf /usr/share/naanal_pkgs/monitor_pkgs/briangann-gauge-panel.tar -C /var/lib/grafana/plugins/
	service grafana-server restart
}

function change_kolla {
	
	figlet -f digital 'Applying Network Changes on Kolla'	

	sudo sed -i \
		"s/kolla_internal_vip_address: \"127\.0\.0\.1/kolla_internal_vip_address: \"${IP_ADDR}/g" \
		/etc/kolla/globals.yml
	
	echo "IP Address Updated...."
	
	sudo sed -i \
                "s/network_interface: \"eth0/network_interface: \"${PRI_INTERFACE}/g" \
                /etc/kolla/globals.yml

	echo "Primary Interface Changed..."
	
	sudo sed -i \
                "s/neutron_external_interface: \"eth1/neutron_external_interface: \"${SEC_INTERFACE}/g" \
                /etc/kolla/globals.yml

	echo "Secondary Interface Changed..."
}

function gather_networks  {
	ifconfig -a
        read -p "Enter the primary interface...." PRI_INTERFACE
      	read -p "Enter the secondary interface...." SEC_INTERFACE
	GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
	echo "Your GATEWAY Address is....... $GATEWAY"
	if ping -c 1 $GATEWAY &> /dev/null
	then
  		echo "Network Successfully pinged..."
		IP_ADDR=$(ip addr | grep inet | grep $PRI_INTERFACE | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
		echo "Your IP Address is....... $IP_ADDR"
		echo "Do you want to continue? Press 1 for Yes, 2 for No"
		select yn in "Yes" "No"; do
    			case $yn in
        			Yes ) change_kolla; break;;
        			No ) exit;;
			esac
		done
	else
		echo "NETWORK NOT PROPERLY CONFIGURE... Make Sure Host ping to Gateway and Try Again"
		exit
	fi
}

function install_dashboard {
	
	echo "Creating Dashboard User"
	
	/usr/sbin/useradd -m dashboard
	adduser dashboard sudo
	echo dashboard:naanal | chpasswd
	
	echo "Extracting Dashboard"
	cp /usr/share/naanal_pkgs/dashboard/naanalstack_dashboard.tar /home/dashboard/naanalstack_dashboard.tar
	sudo -H -u dashboard bash -c 'tar -xvf /home/dashboard/naanalstack_dashboard.tar -C /home/dashboard'
	rm /home/dashboard/naanalstack_dashboard.tar
	
	figlet -f digital 'Applying Changes in Dashboard'


	sudo sed -i \
                "s/OPENSTACK_HOST = \"127\.0\.0\.1/OPENSTACK_HOST = \"${IP_ADDR}/g" \
                /home/dashboard/product/admin/dashboard/openstack_dashboard/local/local_settings.py

        echo "Keystone Endpoint Changed..."

	sudo sed -i \
                "s/MONITORING_HOST = \"http:\/\/127\.0\.0\.1:3000/MONITORING_HOST = \"http:\/\/${IP_ADDR}:3000/g" \
                /home/dashboard/product/admin/dashboard/openstack_dashboard/settings.py

        echo "Monitoring Endpoint Added..."

	sudo sed -i \
                "s/NETWORK_HOST = \"http:\/\/127\.0\.0\.1/NETWORK_HOST = \"http:\/\/${GATEWAY}/g" \
                /home/dashboard/product/admin/dashboard/openstack_dashboard/settings.py

        echo "Network Endpoint Added..."

}

function configuring_apache {

	sudo sed -i \
                "s/80/8002/g" \
                /etc/apache2/sites-available/000-default.conf

        echo "Default apache modified to 8002..."

	cp /home/dashboard/product/admin/config/admin_dashboard.conf /etc/apache2/sites-available/admin_dashboard.conf

	a2ensite admin_dashboard

	service apache2 restart
}

function uninstall {
	serivce apache2 stop
	rm -r /home/dashboard
	rm /etc/apache2/sites-enabled/admin_dashboard.conf
	rm /etc/apache2/sites-available/admin_dashboard.conf
	deluser dashboard
	
	sudo sed -i \
                "s/8002/80/g" \
                /etc/apache2/sites-available/000-default.conf

	service apache2 start
	
}

# Check If User run as root

if (( "$EUID" != 0 )); then 
	echo "Please run as root"
	exit
else
	if [[ "$1" == "uninstall" ]]; then
		figlet -f digital 'Reverting Changes..'
		uninstall
	else

		figlet -f small 'NaanalStack  Pre Configurations'
		

		figlet -f digital 'Changing Host Name'
			change_hostname

		figlet -f digital 'Gathering Network Informations'
			gather_networks

		figlet -f digital 'Installing NaanalStack Dashboard'
			install_dashboard

		figlet -f digital 'Removing Default Apache and Enable NaanalStack'
			configuring_apache
	
		figlet -f digital 'Pre Configuration Completed'

#			kolla-ansible prechecks

#		figlet -f digital 'Prechecks get Successful. Now You can start your deployment'
	fi
fi
#Restore errexit
#$ERREXIT

# Restore xtrace
#$XTRACE
