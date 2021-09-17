ARG UBUNTU_VER="focal"
FROM ubuntu:${UBUNTU_VER} as packages

# build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE

# environment variables
ENV \
	keys="generate" \
	harvester="false" \
	farmer="false" \
	plots_dir="/plots" \
	farmer_address="null" \
	farmer_port="null" \
	testnet="false" \
	full_node_port="null" \
	TZ="UTC"

# set workdir 
WORKDIR /mint-blockchain

# install dependencies
RUN \
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		bc \
		ca-certificates \
		curl \
		git \
		jq \
		lsb-release \
		sudo \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# build package
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/MintNetwork/mint-blockchain/tags" \
	| jq -r ".[0].name") ; \
	fi \
	&& git clone -b "${RELEASE}" --recurse-submodules https://github.com/MintNetwork/mint-blockchain.git \
		/mint-blockchain \		
	&& sh install.sh \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# add local files
COPY ./entrypoint.sh entrypoint.sh
ENTRYPOINT ["bash", "./entrypoint.sh"]
