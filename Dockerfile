# Start with an Ubuntu 18.04 image
FROM ubuntu:18.04

# Set the working directory for the container build
WORKDIR /sequence

# Install system level packages
ARG DEBIAN_FRONTEND=noninteractive
# ensure R 3.6.3
RUN apt-get update --yes
RUN apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

RUN apt-get update --yes \
  && apt-get install --yes \
      software-properties-common \
      fastqc         \
      python         \
      python3        \
      python3-pip    \
      r-base         \
      samtools       \
      subread        \
      wget	     \
      libxml2-dev    \
      libcurl4-openssl-dev \
      libssl-dev \ 
      libfuse-dev \
      curl \
      unzip \
      rsem \
  && rm -rf /var/lib/apt/lists/*

# Install the required R packages
RUN R -e 'install.packages("BiocManager")'
RUN R -e 'install.packages("XML")'
RUN R -e 'install.packages("RCurl")'
RUN R -e 'install.packages("httr")'
RUN R -e 'BiocManager::install()'
RUN R -e 'BiocManager::install("GenomicFeatures")'
RUN R -e 'BiocManager::install("DESeq2")'
RUN R -e 'BiocManager::install("biomaRt")'
RUN R -e 'BiocManager::install("SummarizedExperiment")'
RUN R -e 'BiocManager::install("rsem")'

# Install python/pip packages
RUN pip3 install Cython
RUN pip3 install multiqc rseqc
RUN wget https://github.com/alexdobin/STAR/archive/2.7.3a.tar.gz
RUN tar -xzf 2.7.3a.tar.gz
# Fuse requirements
#RUN pip3 install fuse-python
#RUN curl 'https://codeload.github.com/Gene-Home/GHFS/zip/1.0?token=AAMR32E7QMVYNUHVFBWZBWK6GSO7Y' > ghfs.zip
# will unzip in to a directory GHFS-1.0
#RUN unzip ghfs.zip
 
# Container processes should (almost) never run as root

# Create non-privileged user and group sequencer
RUN /usr/sbin/groupadd --gid 2020 sequencer \
  && /usr/sbin/useradd --comment "Sequencing user " --home-dir /sequencer --uid 2020 --gid 2020 --shell /bin/bash sequencer

# process runs as sequencer
#USER sequencer:sequencer
ENV PATH=$PATH:/sequence/STAR-2.7.3a/bin/Linux_x86_64/
# If not specified, run a bash shell for debugging purposes
CMD /bin/bash
# Expecting to find /ghfsconfig/config.ghfs
#CMD GHFS_CONFIG=/ghfsconfig/config.ghfs
#CMD [ ! -d mountpoint ] && mkdir mountpoint
#CMD python3 /GHFS-1.0/ghfs.py mountpoint
