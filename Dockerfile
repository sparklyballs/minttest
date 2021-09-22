ARG UBUNTU_VER="focal"
FROM ubuntu:${UBUNTU_VER}

# build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE

# environment variables
ENV \
	APP_ROOT=/root/.mint/mainnet \
	farmer_address="null" \
	farmer="false" \
	farmer_port="null" \
	full_node_port="null" \
	harvester="false" \
	keys="generate" \
	plots_dir="/plots" \
	testnet="false" \
	TZ="UTC"

# set workdir for build stage
WORKDIR /mint-blockchain

# install dependencies
RUN \
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		acl \
		bc \
		ca-certificates \
		curl \
		git \
		jq \
		lsb-release \
		openssl \
		python3 \
		sudo \
		tar \
		tzdata \
		unzip \
	\
# set timezone
	\
	&& ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
	&& echo "$TZ" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata \
	\
# cleanup
	\
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# build package
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/MintNetwork/mint-blockchain/releases/latest" \
	| jq -r ".tag_name"); \
	fi \
	&& git clone -b "${RELEASE}" https://github.com/MintNetwork/mint-blockchain.git \
		/mint-blockchain \		
	&& git submodule update --init mozilla-ca \
	&& sh install.sh

# set path
ENV PATH=/mint-blockchain/venv/bin:$PATH

# copy local files
COPY docker-start.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/

# entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-start.sh"]
