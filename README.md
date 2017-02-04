Tutorial: http://askubuntu.com/questions/409607/how-to-create-a-customized-ubuntu-server-iso

	To Install apt-package:

		Install required packages in fresh system: Copy /var/cache/apt/archives/*.deb  to pool/extras
		
	To Download pip package required for kolla:

		Save: pip install --download=/path/to/packages/downloaded -r requirements.txt

		Install: pip install --no-index --find-links="/path/to/downloaded/packages" -r requirements.txt

	To Save and load Docker Images:

		tar -cvf docker_images.tar /var/lib/docker/aufs /var/lib/docker/image
		tar -xvf docker_images.tar -C /var/lib/docker/


Manual Configuration:

Network Configuration
hostname
Disk Partition
