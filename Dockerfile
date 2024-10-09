# FROM python:3.11.10
FROM rockylinux:9.3
WORKDIR /usr/src/app
USER root
RUN dnf install -y wget
RUN dnf install gcc openssl-devel bzip2-devel libffi-devel -y
RUN dnf install libsmi -y
RUN dnf install zlib-devel -y
RUN wget https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz && tar xzf Python-3.11.10.tgz && cd Python-3.11.10 && ./configure --enable-optimizations && make altinstall

COPY deployment/requirements.txt .
RUN mkdir /var/log/aj
RUN dnf install python-devel -y
RUN pip3.11 install --no-cache-dir -r requirements.txt
RUN pip3.11 install --upgrade pip

COPY aj aj
COPY util util


RUN cd util && python3.11 iana_enterprise_numbers_convert.py -i https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers -o ./../aj/etc/enterprise-numbers.json

EXPOSE 80


CMD [ "python3.11", "./aj/aj.py" ]
