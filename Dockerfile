ARG build_version="rust:1.55-slim-buster"

# ******* Stage: builder ******* #
FROM ${build_version} as builder

ENV RUST_BACKTRACE 1

ARG lighthouse_version=v2.0.0

RUN apt update && apt install --yes --no-install-recommends \
  git \
  gcc \
  g++ \
  make \
  cmake \
  pkg-config

WORKDIR /tmp
RUN git clone  --depth 1 --branch ${lighthouse_version} https://github.com/sigp/lighthouse.git
RUN cd lighthouse && make

WORKDIR /tmp/lighthouse

# ******* Stage: base ******* #
FROM ubuntu:21.04 as base

RUN apt update && apt install --yes --no-install-recommends \
    ca-certificates \
    cron \
    curl \
    pip \
    tini \
  # apt cleanup
	&& apt-get autoremove -y; \
	apt-get clean; \
	update-ca-certificates; \
	rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

WORKDIR /docker-entrypoint.d
COPY entrypoints /docker-entrypoint.d
COPY scripts/entrypoint.sh /usr/local/bin/lighthouse-entrypoint

COPY scripts/lighthouse-helper.py /usr/local/bin/lighthouse-helper
RUN chmod 775 /usr/local/bin/lighthouse-helper

RUN pip install click requests

ENTRYPOINT ["lighthouse-entrypoint"]

# ******* Stage: testing ******* #
FROM base as test

ARG goss_version=v0.3.16

RUN curl -fsSL https://goss.rocks/install | GOSS_VER=${goss_version} GOSS_DST=/usr/local/bin sh

WORKDIR /test

COPY test /test
COPY --from=builder /usr/local/cargo/bin/lighthouse /usr/local/bin/

CMD ["goss", "--gossfile", "/test/goss.yaml", "validate"]

# ******* Stage: release ******* #
FROM base as release

ARG version=0.1.0

LABEL 01labs.image.authors="zer0ne.io.x@gmail.com" \
	01labs.image.vendor="O1 Labs" \
	01labs.image.title="0labs/lighthouse" \
	01labs.image.description="Ethereum 2.0 client, written in Rust and maintained by Sigma Prime" \
	01labs.image.source="https://github.com/0x0I/container-file-lighthouse/blob/${version}/Dockerfile" \
	01labs.image.documentation="https://github.com/0x0I/container-file-lighthouse/blob/${version}/README.md" \
	01labs.image.version="${version}"

COPY --from=builder /usr/local/cargo/bin/lighthouse /usr/local/bin/

# beacon-chain node default ports
#
#          discovery/p2p     http api   metrics
#               ↓     ↓        ↓         ↓
EXPOSE    9000/tcp 9000/udp   5052      5054
# validator default ports
#                              ↓         ↓
EXPOSE                        5062      5064

CMD ["lighthouse", "beacon_node"]
