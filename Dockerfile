FROM golang:1.21-bullseye AS go-builder

# Set Golang environment variables.
ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

# Install dependencies
ENV PACKAGES git make gcc musl-dev wget ca-certificates
RUN apt-get update
RUN apt-get install -y $PACKAGES

# Update ca certs
RUN update-ca-certificates

ARG VERSION=v1.1.0

RUN git clone https://github.com/imua-xyz/imuachain.git \
    && cd imuachain \
    && git checkout tags/$VERSION \
    && make install \
    && make build

RUN mkdir -p /root/.imuad/bin
RUN mkdir /root/.imuad/config

WORKDIR /root/.imuad/bin

# Final image
FROM ubuntu:jammy

# Install ca-certificates
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y ca-certificates curl wget jq git \
    && apt-get -y purge && apt-get -y clean

COPY --from=go-builder /go/bin/imuad /usr/bin/imuad

# Run the binary.
CMD ["/bin/sh"]

COPY . .

ENV SHELL /bin/bash