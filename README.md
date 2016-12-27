Step 1: Mount And Copy ISO

Step 2: Change the Menu

Step 3: Prepare Seed File

	To Install apt-package:

		Install required packages in fresh system: Copy /var/cache/apt/archives/*.deb  to pool/extras
		
	To Download pip package required for kolla:

		Save: pip install --download=/path/to/packages/downloaded -r requirements.txt

		Install: pip install --no-index --find-links="/path/to/downloaded/packages" -r requirements.txt

	To Save and load Docker Images:

		tar -cvf docker_images.tar /var/lib/docker/aufs /var/lib/docker/image
		tar -xvf docker_images.tar -C /var/lib/docker/
