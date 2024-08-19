ARG BUILD_DEBIAN_VERSION

FROM debian:${BUILD_DEBIAN_VERSION} AS download_kernel
ARG KERNEL_VERSION
WORKDIR /root
COPY sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get install libncurses-dev imagemagick -y
RUN apt-get build-dep linux -y
RUN apt-get source linux=${KERNEL_VERSION}
COPY .config /tmp/.config
RUN mv /tmp/.config linux-*/

FROM download_kernel AS build
WORKDIR /root
RUN <<EOF
    cd linux-*
    export MAKEFLAGS=-j$(nproc)
    export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
    dpkg-buildpackage -b -nc -uc
EOF
