FROM ruby:mysql

RUN apk add build-base

WORKDIR app

ADD . .

RUN gem install bundler && \
  bundle install

CMD ["ruby", "-v"]
