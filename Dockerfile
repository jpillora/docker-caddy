FROM alpine:latest
LABEL maintainer="dev@jpillora.com"
# webproc release settings
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
ENV CADDY_VERSION 0.11.1
ENV CADDY_URL https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_amd64.tar.gz
# fetch caddy and webproc binary (rely on ca root certs signing github.com for security)
RUN set -e && set -x
RUN apk update \
	&& apk add ca-certificates \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& curl -sL $CADDY_URL | gzip -d - | tar -xv -C /tmp -f - \
	&& mv /tmp/caddy /usr/local/bin/caddy \
	&& apk del .build-deps \
	&& rm -rf /tmp/* /var/cache/apk/*
#configure caddy
COPY Caddyfile /etc/Caddyfile
#run!
ENTRYPOINT ["webproc","--config","/etc/Caddyfile","--","caddy"]
CMD ["-agree", "-conf", "/etc/Caddyfile"]
