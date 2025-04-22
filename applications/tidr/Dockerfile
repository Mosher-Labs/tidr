# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /tidr

# Install base packages including libpq
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq5 git && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="vendor/bundle" \
  BUNDLE_WITHOUT="development" \
  RAILS_LOG_TO_STDOUT=true \
  STDOUT_SYNC=true

# ----- Build stage -----
FROM base AS build

# Install packages needed to build gems and use PostgreSQL
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential git pkg-config libpq-dev jq && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN addgroup --system rails && adduser --system --ingroup rails rails
RUN mkdir -p /tidr/vendor/bundle && chown -R rails:rails /tidr/vendor

# Set bundler config and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set path /tidr/vendor/bundle
RUN bundle config set frozen false
RUN bundle update --bundler && \
  bundle install && \
  rm -rf ~/.bundle/ vendor/bundle/ruby/*/cache vendor/bundle/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copy the rest of the application code
COPY . .

# Precompile bootsnap and assets
RUN bundle exec bootsnap precompile app/ lib/
RUN ./bin/rails assets:precompile
RUN ./bin/rails tailwindcss:build

# ----- Final stage -----
FROM base

# Copy gems and app code
COPY --from=build /tidr/vendor/bundle /tidr/vendor/bundle
COPY --from=build /tidr /tidr

# Create non-root user and take ownership
RUN groupadd --system --gid 1000 rails && \
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
  chown -R rails:rails /tidr
USER 1000:1000

RUN echo "alias be='bundle exec'" >> ~/.profile
RUN echo "alias ll='ls -lah'" >> ~/.profile

ENTRYPOINT ["/tidr/bin/docker-entrypoint"]

EXPOSE ${PORT:-3000}
CMD ["./bin/thrust", "./bin/rails", "server"]
