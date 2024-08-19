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
RUN apt-get install pip -y
RUN apt-get remove python3-sphinx -y
RUN apt-get autoremove -y

ENV PACKAGE_NAME=python3-sphinx
COPY <<EOF ${PACKAGE_NAME}/DEBIAN/control
Package: ${PACKAGE_NAME}
Version: 1.0
Architecture: all
Description: A dummy package
 This is a dummy package that does nothing.
EOF
RUN dpkg-deb --build $PACKAGE_NAME
RUN dpkg -i $PACKAGE_NAME.deb

ENV PACKAGE_NAME=python3-sphinx-rtd-theme
COPY <<EOF ${PACKAGE_NAME}/DEBIAN/control
Package: ${PACKAGE_NAME}
Version: 1.0
Architecture: all
Description: A dummy package
 This is a dummy package that does nothing.
EOF
RUN dpkg-deb --build $PACKAGE_NAME
RUN dpkg -i $PACKAGE_NAME.deb

RUN pip install sphinx sphinx-rtd-theme six
# post_download #

FROM download_kernel AS build
ENV DEB_BUILD_PROFILES=nodoc
RUN <<EOF
    cd linux-*
    make oldconfig
    export MAKEFLAGS="-j$(nproc) $MAKEFLAGS"
    dpkg-buildpackage -b -nc -uc
EOF
