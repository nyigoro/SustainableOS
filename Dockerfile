# Base image
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages for building Android 9–11
RUN apt-get update && apt-get install -y \
    git-core gnupg flex bison build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
    xsltproc unzip fontconfig python3 python-is-python3 openjdk-11-jdk \
    rsync bc libssl-dev sudo wget ccache && \
    apt-get clean

# Set JAVA_HOME for Android build
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

# Create working directory
RUN useradd -m builder && mkdir -p /home/builder/sustainable_os && \
    chown -R builder:builder /home/builder
WORKDIR /home/builder/sustainable_os
USER builder

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
