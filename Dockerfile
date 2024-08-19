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
# post_download #
RUN sed -i 's/debug-info: true/debug-info: false/' linux-*/debian/config/defines
# post_download #

FROM download_kernel AS build
ARG MAKEFLAGS_ADD
ENV DEB_BUILD_PROFILES=nodoc
RUN <<EOF
    cd linux-*
    export MAKEFLAGS="-j$(nproc) ${MAKEFLAGS_ADD}"
    make oldconfig
    nice make $MAKEFLAGS bindeb-pkg
EOF
