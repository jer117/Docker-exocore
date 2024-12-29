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

ARG VERSION=v1.0.9

RUN git clone https://github.com/ExocoreNetwork/exocore.git \
    && cd exocore \
    && git checkout tags/$VERSION \
    && make install \
    && make build

RUN mkdir -p /root/.exocored/bin
RUN mkdir /root/.exocored/config

WORKDIR /root/.exocored/bin

# Final image
FROM ubuntu:jammy

# Install ca-certificates
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y ca-certificates curl wget jq git \
    && apt-get -y purge && apt-get -y clean

COPY --from=go-builder /go/bin/exocored /usr/bin/exocored

# Run the binary.
CMD ["/bin/sh"]

COPY . .

ENV SHELL /bin/bash