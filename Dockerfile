#
# Dockerfile for liquid-feedback
#

FROM debian:bullseye-slim AS builder

#MAINTAINER Pascal Schneider <https://github.com/DarkGigaByte>

ENV LF_CORE_VERSION v4.2.2
ENV LF_FEND_VERSION v4.0.0
ENV LF_WMCP_VERSION v2.2.1
ENV LF_MOONBRIDGE_VERSION v1.1.3
ENV LF_LATLON_VERSION v0.14

#
# install dependencies
#

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get install -yqq --no-install-recommends \
        build-essential \
        lsb-release\
        postgresql-server-dev-all\
        postgresql\
        nullmailer \
        libbsd-dev\
        imagemagick \
        libpq-dev \
        lua5.3 \
        liblua5.3-0 \
        liblua5.3-0-dbg \
        liblua5.3-dev \
        mercurial \
        python3-markdown2 \
        pmake \
        ca-certificates \
        curl && rm -rf /var/lib/apt/lists/*

#
# prepare file tree
#
RUN mkdir -p /opt/lf/sources/patches \
             /opt/lf/sources/scripts \
             /opt/lf/bin

WORKDIR /opt/lf/sources


#
# Download sources
# 
RUN curl https://www.public-software-group.org/pub/projects/liquid_feedback/backend/${LF_CORE_VERSION}/liquid_feedback_core-${LF_CORE_VERSION}.tar.gz -o core.tar.gz \
 && curl https://www.public-software-group.org/pub/projects/liquid_feedback/frontend/${LF_FEND_VERSION}/liquid_feedback_frontend-${LF_FEND_VERSION}.tar.gz -o frontend.tar.gz \
 && curl https://www.public-software-group.org/pub/projects/webmcp/${LF_WMCP_VERSION}/webmcp-${LF_WMCP_VERSION}.tar.gz -o webmcp.tar.gz \
 && curl https://www.public-software-group.org/pub/projects/moonbridge/${LF_MOONBRIDGE_VERSION}/moonbridge-${LF_MOONBRIDGE_VERSION}.tar.gz -o moonbridge.tar.gz
 
#
# Extract sources
# 
RUN mkdir ./core \ 
 && mkdir ./frontend \ 
 && mkdir ./webmcp \ 
 && mkdir ./moonbridge
 
RUN tar -zxf core.tar.gz -C ./core --strip 1 \ 
 && tar -zxf frontend.tar.gz -C ./frontend --strip 1 \ 
 && tar -zxf webmcp.tar.gz -C ./webmcp --strip 1 \ 
 && tar -zxf moonbridge.tar.gz -C ./moonbridge --strip 1

#
# Build moonbridge
#
RUN cd /opt/lf/sources/moonbridge\
    && pmake MOONBR_LUA_PATH=/opt/lf/moonbridge/?.lua \
    && mkdir /opt/lf/moonbridge \
    && cp moonbridge /opt/lf/moonbridge/ \
    && cp moonbridge_http.lua /opt/lf/moonbridge/

#
# build core
#
WORKDIR /opt/lf/sources/core

RUN make \
    && cp lf_update lf_update_issue_order lf_update_suggestion_order /opt/lf/bin

#
# build WebMCP
#
WORKDIR /opt/lf/sources/webmcp

RUN make \
    && mkdir /opt/lf/webmcp \
    && cp -RL framework/* /opt/lf/webmcp

WORKDIR /opt/lf/

RUN cd /opt/lf/sources/frontend \
    && mkdir /opt/lf/frontend \
    && cp -ar /opt/lf/sources/frontend/ /opt/lf/ \
    && cd /opt/lf/frontend/fastpath/ \
    && make \
    && chown www-data /opt/lf/frontend/tmp


FROM debian:bullseye-slim

RUN apt-get update && apt-get install --no-install-recommends -y\
                                      nullmailer imagemagick python3-markdown2 sassc\
                                      liblua5.3-0 postgresql-client

COPY --from=builder /opt/lf /opt/lf

#
# setup db
#
RUN cp /opt/lf/sources/core/core.sql /opt/lf/
COPY ./scripts/config_db.sql /opt/lf/

RUN addgroup --system lf \
    && adduser --system --ingroup lf --no-create-home --disabled-password lf


#
# cleanup
#


#
# configure everything
#

# app config (for running container without -v)
COPY ./scripts/lfconfig.lua /opt/lf/frontend/config/
# app config (for copy-if-not-exists when running container with -v)
COPY ./scripts/lfconfig.lua /tmp/

# update script
COPY ./scripts/lf_updated /opt/lf/bin/

# startup script
COPY ./scripts/start.sh /opt/lf/bin/

#
# ready to go
#

EXPOSE 8080

VOLUME /opt/lf/frontend/config/

WORKDIR /opt/lf/frontend

ENTRYPOINT ["/opt/lf/bin/start.sh"]
