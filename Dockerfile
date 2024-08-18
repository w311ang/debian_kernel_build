FROM debian:11 AS download_kernel
ARG KERNEL_PACKAGE_NAME
COPY sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get build-dep linux -y
RUN apt-get source linux=${KERNEL_PACKAGE_NAME}
COPY .config /linux-*

FROM download_kernel AS build
RUN cd linux-*
RUN export MAKEFLAGS=-j$(nproc)
RUN export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
RUN dpkg-buildpackage -b -nc -uc
