FROM debian:bookworm-slim

ARG CONTEXT7_API_KEY
ARG LINEAR_API_KEY
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL

ENV SHELL=/bin/bash
ENV PNPM_VERSION=10.28.1

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    git \
    vim \
    less \
    procps \
    iputils-ping \
    net-tools \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash clanker-1

RUN mkdir -p \
    /home/clanker-1/.config/opencode \
    /home/clanker-1/.local/share/opencode \
    /home/clanker-1/.local/state \
    /home/clanker-1/work \
    /home/clanker-1/Documents \
    /home/clanker-1/nvm \
  && chown -R clanker-1:clanker-1 /home/clanker-1

USER clanker-1

ENV HOME=/home/clanker-1
ENV PNPM_HOME="/home/clanker-1/.local/share/pnpm"
ENV PATH=/home/clanker-1/.local/share/pnpm:/home/clanker-1/.opencode/bin:/home/clanker-1/.local/bin:$PATH
ENV NVM_DIR="/home/clanker-1/nvm"
ENV NODE_VERSION="22"

ENV CONTEXT7_API_KEY=$CONTEXT7_API_KEY
ENV LINEAR_API_KEY=$LINEAR_API_KEY

# Install opencode
RUN curl -fsSL https://opencode.ai/install | bash

# Pull in agents and skills
COPY ./agents /home/clanker-1/.config/opencode/agents
COPY ./skills /home/clanker-1/.config/opencode/skills
COPY ./opencode.json /home/clanker-1/.config/opencode/
COPY ./tui.json /home/clanker-1/.config/opencode/

# Install PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    # Source NVM and install Node.js within the same shell
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    mkdir -p /home/clanker-1/.local/bin && \
    ln -sf "$(nvm which default)" /home/clanker-1/.local/bin/node && \
    ln -sf "$(dirname "$(nvm which default)")/npm" /home/clanker-1/.local/bin/npm && \
    ln -sf "$(dirname "$(nvm which default)")/npx" /home/clanker-1/.local/bin/npx

WORKDIR /home/clanker-1/work

CMD ["opencode", "."]
