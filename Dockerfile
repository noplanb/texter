FROM zazo/rails

ENV APP_HOME /usr/src/app

COPY Gemfile $APP_HOME/
COPY Gemfile.lock $APP_HOME/
RUN bundle install --jobs 8 --retry 3

COPY . $APP_HOME
RUN rake assets:precompile RAILS_ENV=production
RUN chown www-data:www-data -R $APP_HOME

EXPOSE 80
CMD bin/start.sh
