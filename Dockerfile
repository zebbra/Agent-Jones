# FROM python:3.11.10
FROM rockylinux:9.3
WORKDIR /usr/src/app
USER root

RUN dnf install -y \
      bzip2-devel \
      dnf-plugins-core \
      gcc \
      libffi-devel \
      openssl-devel \
      wget \
      zlib-devel \ 
      net-snmp-devel \ 
      net-snmp-libs

RUN wget https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz \
    && tar xzf Python-3.11.10.tgz \
    && cd Python-3.11.10 \
    && ./configure --enable-optimizations --disable-test-modules \
    && make -j$(nproc) build_all \
    && make altinstall

RUN dnf config-manager --set-enabled devel \
    && dnf install -y libsmi-devel python-devel \
    && dnf config-manager --set-disabled devel

COPY deployment/requirements.txt .
RUN mkdir /var/log/aj
RUN pip3.11 install --no-cache-dir -r requirements.txt
RUN pip3.11 install --upgrade pip

COPY aj aj
COPY util util

RUN cd util && \
    python3.11 iana_enterprise_numbers_convert.py \
      -i https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers \
      -o ./../aj/etc/enterprise-numbers.json

EXPOSE 80


CMD [ "python3.11", "./aj/aj.py" ]
