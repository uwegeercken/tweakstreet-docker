FROM debian:buster-slim

LABEL maintainer="Tweakstreet Docker Maintainers <hi@tweakstreet.io>"

ENV TS_GID        101
ENV TS_UID        101
ENV TS_VERSION    1.7.0
ENV TS_HOME       /home/tweakstreet
ENV TS_LOCATION   /opt/tweakstreet
ENV TS_SHA256     e9e4a83e558df4cf8c043cd418fb7f5a6a1a736ca5947a61275fc93e70a33852

ENV TERM          xterm-256color

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y bash ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup --gid "${TS_GID}" tweakstreet \
    && adduser --system --home /home/tweakstreet --ingroup tweakstreet --gecos "tweakstreet user" --shell /bin/bash --uid "${TS_UID}" tweakstreet \
    && mkdir -p "${TS_HOME}/.tweakstreet/drivers" \
    && mkdir -p "${TS_LOCATION}" \
    && chown -R tweakstreet:tweakstreet "${TS_LOCATION}" \
    && mkdir -p "/app" \
    && chown tweakstreet:tweakstreet /app

USER tweakstreet

SHELL ["/bin/bash", "-c"]

RUN curl "https://tweakstreet.io/updates/Tweakstreet-${TS_VERSION}-portable.tar.gz" --output "${TS_LOCATION}/portable.tar.gz" \
    && echo "${TS_SHA256} *portable.tar.gz" > "${TS_LOCATION}/SHA256SUMS" \
    && cd "${TS_LOCATION}" && sha256sum -c SHA256SUMS 2>&1 | grep OK \
    && tar --strip-components=1 -xzf portable.tar.gz Tweakstreet-${TS_VERSION}-portable/bin \
    && rm portable.tar.gz

ENV PATH "${TS_LOCATION}/bin:$PATH"

COPY docker-entrypoint.sh "${TS_LOCATION}/"
ENTRYPOINT ["/opt/tweakstreet/docker-entrypoint.sh"]

CMD ["engine.sh", "--help"]
