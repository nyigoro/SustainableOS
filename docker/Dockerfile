FROM ubuntu:22.04

# Install required packages for AOSP build
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk git-core repo curl python3 unzip wget ccache \
    bc build-essential zip

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Create working directory
WORKDIR /workspace

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
