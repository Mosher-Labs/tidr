# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.1

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development" \
  RAILS_LOG_TO_STDOUT=true \
  STDOUT_SYNC=true \
  APP_NAME=tidr

WORKDIR "/${APP_NAME}"

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq5 git netcat-openbsd && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM base AS build

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential pkg-config libpq-dev jq watchman && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle config set frozen false
RUN bundle update --bundler && \
  bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN ./bin/rails assets:precompile && \
    ./bin/rails tailwindcss:build

COPY ./cert.pem .
COPY ./privkey.pem .

FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build "/${APP_NAME}" "/${APP_NAME}"

RUN groupadd --system --gid 1000 rails && \
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
  chown -R rails:rails ./
USER 1000:1000

RUN echo "alias be='bundle exec'; alias ll='ls -lah';" > ~/.profile

ENTRYPOINT ["/tidr/bin/docker-entrypoint"]

EXPOSE ${PORT:-3000}
CMD ["./bin/thrust", "./bin/rails", "server"]
