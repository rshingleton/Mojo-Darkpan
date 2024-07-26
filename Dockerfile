FROM perl:5.41.2-slim-threaded AS compile-image

RUN apt-get update
RUN apt-get update && apt-get install -y \
    curl tar build-essential \
    wget gnupg ca-certificates \
    libssl-dev \
    g++ git zlib1g zlib1g-dev
    
RUN curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
    && curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm \
    | perl - install -g App::cpm

COPY cpanfile ./

RUN cpm install --global --show-build-log-on-failure

FROM perl:5.41.2-slim-threaded AS build-image

RUN apt-get update && apt-get install  --no-install-recommends --no-install-suggests  -y \
    curl tar wget ca-certificates \
    git openssh-client

COPY --from=compile-image /usr/local /usr/local
WORKDIR /opt

ARG VER=1.0

COPY ./lib /opt/lib
COPY ./script /opt/script

EXPOSE 3000

# docker build --progress plain --tag mojo-darkpan:latest .
# docker run -init mojo-darkpan:latest script/darkpan