FROM phusion/baseimage:noble-1.0.0 AS base

LABEL Description="Container to run m4b-tool as a deamon."

# Base container with tools needed for runtime and/or builds
RUN apt-get update && apt-get install -y --no-install-recommends \
        fdkaac \
        ffmpeg \
        php-cli \
        php-curl \
        php-intl \
        php-json \
        php-mbstring \
        php-xml \
        php-zip

# Build container with tools needed to build runtime apps from source
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git

# mp4v2 provides utilities to read, create, and modify mp4 files
RUN git clone https://github.com/sandreas/mp4v2 \
        && cd mp4v2 \
        && ./configure \
        && make \
        && make install

# m4b-tool is a php-based tool to work with m4b audio books
RUN curl -o /usr/local/bin/m4b-tool -L \
        https://github.com/sandreas/m4b-tool/releases/latest/download/m4b-tool.phar \
        && chmod +x /usr/local/bin/m4b-tool

ADD m4bber /usr/local/bin

# The final image copies the build artifacts from the builder image. This
# multistage approach allows for the shipped image to be as small as
# possible.
FROM base AS final

# Mount volumes
VOLUME /audiobooks

# Copy over the build artifacts from the builder image
COPY --from=builder /usr/local /usr/local

# Install the mp4v2 library
RUN ldconfig

ENTRYPOINT ["m4bber"]
