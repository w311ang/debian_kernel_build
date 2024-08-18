FROM debian:11

RUN <<'EOF'
	apt-get install build-essential -y
	apt-get build-dep linux -y
	apt-get source $KERNEL_PACKAGE_NAME

	cd $KERNEL_PACKAGE_NAME
	export MAKEFLAGS=-j$(nproc)
	export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
	cp /.config .
	dpkg-buildpackage -b -nc -uc
EOF
