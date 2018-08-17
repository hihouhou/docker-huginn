#
# Huginn Dockerfile
#
# https://github.com/
#

# Pull base image.
FROM debian:latest

MAINTAINER hihouhou < hihouhou@hihouhou.com >

# Update & install packages for installing hashcat
RUN apt-get update && \
    apt-get install -y git ruby runit-systemd libssl1.0-dev

RUN gem install bundler

RUN git clone https://github.com/huginn/huginn.git

COPY .env /huginn/.env

#to create a development database with some example Agents.
RUN cd huginn && \
    bundle install && \
    bundle exec rake db:create && \
    bundle exec rake db:migrate && \
    bundle exec rake db:seed


CMD ["bundle", "exec", "foreman", "start"]
