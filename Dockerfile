FROM alpine:3.17.2 AS builder_base
RUN apk add --update --no-cache \
    build-base \
    git \
    openssl-dev \
    libffi-dev \
    zlib-dev \
    cmake \
    fmt-dev \
    spdlog-dev \
    libpng-dev
WORKDIR /app

FROM builder_base AS builder_mcmap2
RUN git clone https://github.com/WRIM/mcmap.git .
RUN sed -i 's/-msse//g' Makefile
RUN make

FROM builder_base AS builder_mcmap3
RUN git clone -b mineflayer https://github.com/spoutn1k/mcmap.git .
RUN mkdir -p build
WORKDIR /app/build
RUN cmake .. -DMINEFLAYER=1
RUN make -j

FROM builder_base
RUN apk add --update --no-cache \
    libstdc++ \
    libpng \
    zlib \
    fmt \
    spdlog \
    libgomp \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder_mcmap2 /app/mcmap /app/mcmap2
COPY --from=builder_mcmap3 /app/build/bin/mcmap /app/mcmap3
COPY --from=builder_mcmap3 /app/build/bin/ /app/mcmap3-utils/

ENV PATH="/app:/app/mcmap3-utils/:${PATH}"
CMD ["mcmap3"]
