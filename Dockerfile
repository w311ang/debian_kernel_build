FROM debian:11 AS download_kernel
ARG KERNEL_PACKAGE_NAME
COPY sources.list /etc/apt/sources.list
RUN <<"EOF"
	apt-get install build-essential -y
	apt-get build-dep linux -y
	apt-get source linux=${KERNEL_PACKAGE_NAME}
EOF
COPY .config /linux-*

FROM download_kernel AS build
RUN <<"EOF"
	cd linux-*
	export MAKEFLAGS=-j$(nproc)
	export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
	dpkg-buildpackage -b -nc -uc
EOF
