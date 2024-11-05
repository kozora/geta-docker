FROM continuumio/miniconda3:latest

# Set non-interactive mode for APT
ENV DEBIAN_FRONTEND=noninteractive

#RUN apt-get install libgomp1
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --add channels r

# Install basic dependencies
RUN apt-get update && apt-get install -yqq \
    build-essential \
    curl \
    unzip \
    tar \
    git \
    perl \
    libpng-dev \
    libncurses5-dev \
    zlib1g-dev \
    pkg-config \
    lzma \
    bioperl \
    wget \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Create environment.yml for dependencies installation
COPY <<EOF /tmp/environment.yml
name: geta
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.9
  - openjdk=11  # Replaced with version 11 since 20.0.1 is not available
  - parallel
  - hmmer=3.3.2
  - hisat2=2.2.1  # Updated version to ensure compatibility with Python 3.9
  - samtools=1.17
  - mmseqs2
  - busco=5.4.7
  - augustus=3.5.0
  - diamond=2.1.8
  - blast=2.14.1
  - wget
  - bzip2
  - tar
  - curl
  - biopython
  - perl
EOF

# Install dependencies via conda
RUN echo "y"|conda env create -f /tmp/environment.yml && conda clean --all -y
RUN echo "source activate geta" > ~/.bashrc

# Set PATH for custom installations
ENV PATH="/opt/bin:/opt/sysoft/parafly-r2013-01-21/bin:/opt/conda/envs/geta_env/bin:${PATH}"

WORKDIR /tmp

# Install ParaFly
RUN wget https://sourceforge.net/projects/parafly/files/parafly-r2013-01-21.tgz -P /tmp \
    && tar zxf /tmp/parafly-r2013-01-21.tgz \
    && cd parafly-r2013-01-21 \
    && ./configure --prefix=/opt/sysoft/parafly-r2013-01-21 \
    && make -j 8 \
    && make install \
    && cd .. && rm -rf parafly-r2013-01-21 /tmp/parafly-r2013-01-21.tgz

# Default command
CMD ["/bin/bash"]
