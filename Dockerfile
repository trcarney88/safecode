FROM debian:bookworm-slim

ARG CONTEXT7_API_KEY
ARG LINEAR_API_KEY

ENV SHELL=/bin/bash

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
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash clanker-1

RUN mkdir -p \
    /home/clanker-1/.config/opencode \
    /home/clanker-1/.local/share/opencode \
    /home/clanker-1/.local/state \
    /home/clanker-1/work \
    /home/clanker-1/Documents \
  && chown -R clanker-1:clanker-1 /home/clanker-1

USER clanker-1

ENV HOME=/home/clanker-1
ENV PATH=/home/clanker-1/.opencode/bin:$PATH

ENV CONTEXT7_API_KEY=$CONTEXT7_API_KEY
ENV LINEAR_API_KEY=$LINEAR_API_KEY

# Install opencode
RUN curl -fsSL https://opencode.ai/install | bash

# Pull in agents and skills
COPY ./agents /home/clanker-1/.config/opencode/agents
COPY ./skills /home/clanker-1/.config/opencode/skills
COPY ./opencode.json /home/clanker-1/.config/opencode/
COPY ./tui.json /home/clanker-1/.config/opencode/


WORKDIR /home/clanker-1/work

CMD ["opencode", "."]
