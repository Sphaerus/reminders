#!/bin/bash
set -e

cd /var/www/app
# run startup script, like migrations
bundle exec rake db:migrate

# run the CMD
exec "$@"
