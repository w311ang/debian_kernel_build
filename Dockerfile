ARG BUILD_DEBIAN_VERSION

FROM debian:${BUILD_DEBIAN_VERSION} AS download_kernel
WORKDIR /root
COPY sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get install libncurses-dev imagemagick -y
ARG KERNEL_VERSION
RUN apt-get build-dep linux=${KERNEL_VERSION} -y
RUN apt-get source linux=${KERNEL_VERSION}
COPY .config /tmp/.config
RUN mv /tmp/.config linux-*/
ARG MAKEFLAGS_ADD
ENV MAKEFLAGS="${MAKEFLAGS_ADD}"

FROM download_kernel AS build
RUN <<EOF
    cd linux-*
    export MAKEFLAGS="-j$(nproc) ${MAKEFLAGS_ADD}"
    dpkg-buildpackage -b -nc -uc
EOF
