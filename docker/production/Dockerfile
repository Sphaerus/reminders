FROM quay.io/netguru/ng-ruby:2.2.3-rails-onbuild

ENV RAILS_ENV production
ENV RAILS_MAX_THREADS 3

ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

## Set timezone
RUN echo 'Europe/Warsaw' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
