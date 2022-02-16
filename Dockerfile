FROM ruby:mysql

RUN apk add build-base

WORKDIR app

ADD Gemfile .

RUN gem install bundler && \
  bundle install

ADD . .

CMD ["/bin/sh"]
