FROM debian:jessie-slim

# We need apt-show-versions to do a downgrade of currently installed packages.
# https://askubuntu.com/questions/138284/how-to-downgrade-a-package-via-apt-get
# apt-show-versions require uncompressed package index files!!!
# https://groups.google.com/forum/#!topic/beagleboard/jXb9KhoMOsk
RUN	rm /etc/apt/apt.conf.d/docker-gzip-indexes && \
	apt-get update && \
	apt-get -y install apt-show-versions

# Add snapshot package mirror to get only packages until a specific snapshot date
# https://snapshot.debian.org/
# Note: Don´t use security updates as this break everything!!!
ENV SNAPSHOTTAG 20180601T043106Z
RUN	echo "deb http://snapshot.debian.org/archive/debian/${SNAPSHOTTAG}/ jessie main" > /etc/apt/sources.list && \
	#echo "deb http://snapshot.debian.org/archive/debian-security/${SNAPSHOTTAG}/ jessie/updates main" >> /etc/apt/sources.list && \
	echo "Acquire::Check-Valid-Until no;" > /etc/apt/apt.conf.d/99no-check-valid-until

# Add the emdebian package repo for cross toolchanis
ADD	http://emdebian.org/tools/debian/emdebian-toolchain-archive.key /tmp
RUN	dpkg --add-architecture armhf && \
	dpkg --add-architecture armel && \
	echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/crosstools.list && \
	apt-key add /tmp/emdebian-toolchain-archive.key

# refresh package indexes
RUN	apt-get clean && \
	apt-get autoclean && \
	apt-get update

# downgrade packages to versions from snapshot repo
# Note: "--force-yes" is needed to downgrade packages without user input
RUN	apt-get -y --force-yes install $(apt-show-versions | grep -P 'newer than version in archive' | awk -F: '{print $1"/jessie"}')

CMD [ "/bin/bash" ]
