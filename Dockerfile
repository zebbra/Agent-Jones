# FROM python:3.7.7
FROM centos/python-36-centos7
WORKDIR /usr/src/app
USER root
RUN yum install gcc openssl-devel bzip2-devel libffi-devel -y
RUN wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tgz && tar xzf Python-3.7.7.tgz && cd Python-3.7.7 && ./configure --enable-optimizations && make altinstall
RUN yum install libsmi libsmi-devel net-snmp-devel net-snmp-libs -y

COPY deployment/requirements.txt .
RUN mkdir /var/log/aj
RUN pip3.7 install --no-cache-dir -r requirements.txt

COPY aj aj
COPY util util

RUN cd util && python3.7 iana_enterprise_numbers_convert.py -i http://www.iana.org/assignments/enterprise-numbers -o ./../aj/etc/enterprise-numbers.json

CMD [ "python3.7", "./aj/aj.py" ]