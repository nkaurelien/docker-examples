# OpenResty + bouncer Lua CrowdSec (lua-cs-bouncer) + lua-resty-http
FROM openresty/openresty:1.31.1.1-4-bookworm

ARG LUA_CS_BOUNCER_VERSION=1.0.19
ARG LUA_CS_BOUNCER_SHA256=8d15e80886f08624d8435f82ffe7dca1309eb6104d146ae947619dc8c320d11d
ARG LUA_RESTY_HTTP_VERSION=0.17.2
ARG LUA_RESTY_HTTP_SHA256=3da18ca8582243eff28302591e36651dc7fab046e77336aa4a6fa718bccce4a2

ADD https://github.com/crowdsecurity/lua-cs-bouncer/archive/refs/tags/v${LUA_CS_BOUNCER_VERSION}.tar.gz /tmp/lua-cs-bouncer.tar.gz
ADD https://github.com/ledgetech/lua-resty-http/archive/refs/tags/v${LUA_RESTY_HTTP_VERSION}.tar.gz /tmp/lua-resty-http.tar.gz

RUN set -eux; \
    cd /tmp; \
    echo "${LUA_CS_BOUNCER_SHA256}  lua-cs-bouncer.tar.gz" | sha256sum -c -; \
    echo "${LUA_RESTY_HTTP_SHA256}  lua-resty-http.tar.gz" | sha256sum -c -; \
    tar -xzf lua-cs-bouncer.tar.gz; \
    tar -xzf lua-resty-http.tar.gz; \
    mkdir -p /usr/local/openresty/site/lualib/resty /var/lib/crowdsec/lua/templates \
             /etc/crowdsec/bouncers /var/log/openresty; \
    cp -r lua-cs-bouncer-${LUA_CS_BOUNCER_VERSION}/lib/. /usr/local/openresty/site/lualib/; \
    cp lua-cs-bouncer-${LUA_CS_BOUNCER_VERSION}/templates/*.html /var/lib/crowdsec/lua/templates/; \
    cp lua-resty-http-${LUA_RESTY_HTTP_VERSION}/lib/resty/*.lua /usr/local/openresty/site/lualib/resty/; \
    rm -rf /tmp/lua-cs-bouncer* /tmp/lua-resty-http*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 0755 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
