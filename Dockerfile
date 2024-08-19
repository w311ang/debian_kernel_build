ARG BUILD_DEBIAN_VERSION

FROM debian:${BUILD_DEBIAN_VERSION} AS download_kernel
ARG KERNEL_VERSION
WORKDIR /root
COPY sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get install libncurses-dev imagemagick -y
RUN apt-get build-dep linux=${KERNEL_VERSION} -y
RUN apt-get source linux=${KERNEL_VERSION}
COPY .config /tmp/.config
RUN mv /tmp/.config linux-*/
ENV MAKEFLAGS="${MAKEFLAGS_ADD}"

FROM download_kernel AS build
ARG MAKEFLAGS_ADD
RUN <<EOF
    cd linux-*
    export MAKEFLAGS="-j$(nproc) ${MAKEFLAGS_ADD}"
    dpkg-buildpackage -b -nc -uc
EOF
