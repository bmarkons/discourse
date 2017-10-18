#!/bin/bash

echo "RAILS_MASTER: $RAILS_MASTER"
echo "RUN_LINT: $RUN_LINT"
echo "QUNIT_RUN: $QUNIT_RUN"

if [ "$RAILS_MASTER" == "1" ]; then
  bundle update --retry=3 --jobs=3 arel rails seed-fu
fi

if [ "$RAILS_MASTER" == "0" ]; then
  bundle install --without development --deployment --retry=3 --jobs=3
fi

if [ "$RUN_LINT" == "1" ]; then
  yarn global add eslint babel-eslint
fi

if [ "$RUN_LINT" == "1" ]; then
  bundle exec rubocop --parallel && \
    eslint --ext .es6 app/assets/javascripts && \
    eslint --ext .es6 test/javascripts && \
    eslint --ext .es6 plugins/**/assets/javascripts && \
    eslint --ext .es6 plugins/**/test/javascripts && \
    eslint app/assets/javascripts test/javascripts
else
  bundle exec rake db:create db:migrate

  if [ "$QUNIT_RUN" == "1" ]; then
    LOAD_PLUGINS=1 bundle exec rake qunit:test['400000']
  else
    bundle exec rspec && bundle exec rake plugin:spec
  fi
fi

