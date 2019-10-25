ARG debian_version
ARG golang_version

FROM golang:${golang_version:-1.13}-${debian_version:-buster}

ARG ansible_version
ARG awscli_version
ARG terraform_version

ENV TERRAFORM_VERSION=${terraform_version:-0.12.12}
ENV ANSIBLE_VERSION=${ansible_version:-2.8.6}
ENV AWSCLI_VERSION=${awscli_version:-1.16.266}

ENV SCRIPT_MAIN='/tmp/main_script.sh'
ENV SCRIPT_LOCATION='/tmp/script/script.sh'
ENV EC2_INI_PATH "/etc/ansible/ec2.ini"

#locale
ENV LC_ALL="en_US.UTF-8"
ENV LC_CTYPE="en_US.UTF-8"

LABEL maintainer="salvatore181@gmail.com"

COPY script/ /tmp
COPY ec2/ /etc/ansible/ec2


RUN set -xe && \
    apt-get update && \
    apt-get install -y locales && \
    dpkg-reconfigure locales && \
    apt-get install -y sudo curl ca-certificates openssh-client unzip\
            python3-dev python3 libffi-dev openssl git vim build-essential\
            python3-pip python3-setuptools python3.7-venv openjdk-8-jdk && \
    pip3 install --upgrade boto3 pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    pip install --no-cache --upgrade ansible==${ANSIBLE_VERSION} awscli==${AWSCLI_VERSION} && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -r /root/.cache && \
    chmod +x ${SCRIPT_MAIN}

CMD sh +x ${SCRIPT_MAIN}; /bin/sh
