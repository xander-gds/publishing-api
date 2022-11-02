ARG base_image=ghcr.io/alphagov/govuk-ruby-base:3.1.2
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:3.1.2

FROM $builder_image AS builder

ENV GOVUK_APP_NAME=publishing-api
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle install
COPY . /app


FROM $base_image

ENV GOVUK_CONTENT_SCHEMAS_PATH=/govuk-content-schemas
ENV GOVUK_APP_NAME=publishing-api

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
WORKDIR /app
CMD bundle exec puma
