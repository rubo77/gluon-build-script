build-all-targets.sh
====================

builds all 7 targets for gluon

# Install:

	sudo apt-get install git make gcc g++ unzip libncurses5-dev zlib1g-dev subversion gawk bzip2 libssl-dev
	git clone https://github.com/freifunk-gluon/gluon.git
	cd gluon
	# adapt your site/
	make update
	./build-all-targets.sh

# Tip: call the script through `ccze`

    ./build-all-targets.sh | ccze -A

