FROM amazonlinux:2 AS builder

RUN yum update -y

# 1st line: What this Dockerfile needs
# 2nd line: What pyenv needs to install a new Python version
# 3rd line: selinux README requirements
# 4th line: selinux other requirements needed due to encountering errors during build
RUN yum install -y git \
    openssl-devel ncurses-devel libffi-devel readline-devel xz-devel \
    audit-libs-devel bison bzip2-devel dbus-devel dbus-glib-devel flex flex-devel flex-static glib2-devel libcap-devel libcap-ng-devel pam-devel pcre-devel python-devel setools-devel swig ustr-devel \
    xmlto
RUN yum group install -y "Development Tools"

RUN curl https://pyenv.run | bash

WORKDIR /src

ARG PYTHON3_VERSION=3.8.14
ARG LIBSELINUX_VERSION=2.5
ARG BUILD_DIR=/build

ENV PYTHON3_VERSION="${PYTHON3_VERSION}" \
    LIBSELINUX_VERSION="${LIBSELINUX_VERSION}" \
    BUILD_DIR="${BUILD_DIR}"

RUN ~/.pyenv/bin/pyenv install "${PYTHON3_VERSION}"
RUN git clone --depth 1 https://github.com/SELinuxProject/selinux.git -b "libselinux-${LIBSELINUX_VERSION}"

COPY ./build.sh /src/
CMD ["./build.sh"]

FROM builder AS built
RUN ./build.sh

CMD ["/bin/bash"]
