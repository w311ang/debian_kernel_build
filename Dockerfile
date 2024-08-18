FROM debian:11 AS download_kernel

ARG KERNEL_PACKAGE_NAME

RUN <<"EOF"
	apt-get install build-essential -y
	apt-get build-dep linux -y
	apt-get source ${KERNEL_PACKAGE_NAME}

	cd ${KERNEL_PACKAGE_NAME}
	export MAKEFLAGS=-j$(nproc)
	export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
EOF

COPY .config /${KERNEL_PACKAGE_NAME}

FROM download_kernel AS build
RUN <<"EOF"
	dpkg-buildpackage -b -nc -uc
EOF
