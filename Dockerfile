FROM openaustralia/buildstep:early_release as base

COPY Gemfile.lock Gemfile Procfile /app/

ENV NPM_CONFIG_CAFILE /etc/ssl/certs/ca-certificates.crt
ENV NODE_TLS_REJECT_UNAUTHORIZED 0

RUN /bin/herokuish buildpack build

FROM base as scraper

COPY . /app
