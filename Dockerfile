FROM ubuntu:22.04 AS builder_base
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake
WORKDIR /app

FROM builder_base AS builder_mcmap2
RUN apt-get install -y libpng-dev zlib1g-dev
RUN git clone https://github.com/WRIM/mcmap.git .
RUN sed -i 's/-msse//g' Makefile
RUN make

FROM builder_base AS builder_mcmap3
RUN apt-get install -y libpng-dev cmake libspdlog-dev
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install -y libfmt-dev libfmt8
WORKDIR /app
RUN git clone https://github.com/spoutn1k/mcmap.git
WORKDIR /app/mcmap
RUN mkdir -p build
WORKDIR /app/mcmap/build
RUN cmake ..
RUN make -j

FROM builder_base
COPY --from=builder_mcmap2 /app/mcmap /app/mcmap2
COPY --from=builder_mcmap3 /app/mcmap/build/bin/mcmap /app/mcmap3
COPY --from=builder_mcmap3 /app/mcmap/build/bin/ /app/mcmap3-utils/

ENV PATH="/app:/app/mcmap3-utils/:${PATH}"
CMD ["mcmap3"]
