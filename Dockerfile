FROM nginx:alpine

LABEL maintainer="Lukas Wolfsteiner <lukas@wolfsteiner.media>"
LABEL org.opencontainers.image.source="https://github.com/dotWee/docker-element-web"

ARG version
RUN [ -z "$version" ] && echo "Version build argument is required and missing. Aborting..." && exit 1 || true

ARG GPG_KEY=2BAA9B8552BD9047
RUN apk add --no-cache --virtual .build-deps curl gnupg \
  && curl -sSL https://github.com/vector-im/element-web/releases/download/${version}/element-${version}.tar.gz -o element-web.tar.gz \
  && curl -sSL https://github.com/vector-im/element-web/releases/download/${version}/element-${version}.tar.gz.asc -o element-web.tar.gz.asc \
  && for server in \
			hkp://keyserver.ubuntu.com:80 \
			hkp://p80.pool.sks-keyservers.net:80 \
			ha.pool.sks-keyservers.net \
		; do \
			echo "Fetching GPG key $GPG_KEY from $server"; \
			gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEY" && break; \
		done \
  && gpg --batch --verify element-web.tar.gz.asc element-web.tar.gz \
  && tar -xzf element-web.tar.gz \
  && mv element-${version} /etc/element-web \
  && cp /etc/element-web/config.sample.json /etc/element-web/config.json \
  && rm -rf /usr/share/nginx/html && ln -s /etc/element-web /usr/share/nginx/html \
  && rm element-web.tar.gz* \
  && apk del .build-deps
