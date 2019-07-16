# reference: https://hub.docker.com/r/nvidia/cuda/
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

# Adds metadata to the image as a key value pair example LABEL version="1.0"
LABEL maintainer="Siddharth Vashishtha <svashishtha.iitkgp@gmail.com>"


#################### Install Anaconda
# Why Anaconda?  Its recommended Package Manager For PyTorch
# The following section is from https://hub.docker.com/r/continuumio/anaconda3/~/dockerfile/
# You may have to check this periodically and update

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git-core git mercurial subversion \
    build-essential \
    byobu \
    curl \
    htop \
    libcupti-dev \
    libfreetype6-dev \
    libpng12-dev \
    libzmq3-dev \
    pkg-config \
    python3-pip \
    python3-dev \
    python-virtualenv \
    rsync \
    software-properties-common \
    unzip \
    cuda-samples-$CUDA_PKG_VERSION\
    && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# Install Java
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# Install Pytorch Instructions at http://pytorch.org/
RUN conda install -y pytorch torchvision cuda80 -c soumith
RUN conda install -y opencv

# Install app dependencies
# RUN pip install --upgrade pip
RUN pip install git+https://github.com/hltcoe/PredPatt.git
RUN pip install git+git://github.com/factslab/factslab-python.git 
RUN pip install cloudpickle==0.5.6
RUN pip install allennlp


# Open Ports for Jupyter, and SSH
EXPOSE 7745
EXPOSE 22

#Setup File System
RUN mkdir ds
ENV HOME=/ds
ENV SHELL=/bin/bash
VOLUME /ds
WORKDIR /ds

## Add directories from host to the container
ADD run_jupyter.sh /ds/run_jupyter.sh
ADD model_package /ds/


RUN ["chmod", "+x", "/ds/run_jupyter.sh"]

#RUN chmod +x /ds/run_jupyter.sh

# Run the shell
# CMD  ["./run_jupyter.sh"]
CMD ["/bin/bash"]