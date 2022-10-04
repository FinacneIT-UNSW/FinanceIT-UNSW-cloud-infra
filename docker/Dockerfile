FROM public.ecr.aws/amazonlinux/amazonlinux:2

RUN yum install wget unzip python3 --assumeyes && \
    wget -O terra.zip https://releases.hashicorp.com/terraform/1.3.1/terraform_1.3.1_linux_amd64.zip && \
    unzip terra.zip && \
    mv terraform /usr/local/bin/ && \
    rm terra.zip && \
    yum clean all && \
    python3 -m pip install ipykernel && \
    python3 -m ipykernel install && \
    yum remove wget unzip -y

USER ${NB_UID}