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
RUN export

FROM download_kernel AS build
ARG MAKEFLAGS_ADD
ENV DEB_BUILD_PROFILES='nodoc pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
RUN <<EOF
    cd linux-*
    export MAKEFLAGS="-j$(nproc) ${MAKEFLAGS_ADD}"
    export
    make oldconfig
    nice make $MAKEFLAGS bindeb-pkg
EOF

FROM build AS extract_artifact
RUN mkdir artifact/
RUN for i in *; do ln -s "$i" artifact/; done
RUN rm artifact/linux-*/ artifact/artifact .*
