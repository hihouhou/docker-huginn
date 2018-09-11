#
# huginn Dockerfile
#
# https://github.com/
#

# Pull base image.
FROM debian:latest

MAINTAINER hihouhou < hihouhou@hihouhou.com >

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

# Install curl
RUN apt-get update && \
    apt-get install -y curl gnupg2

# Fetch repository
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# Update & install packages for installing huginn
RUN apt-get install -y vim build-essential git zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python-docutils pkg-config cmake nodejs graphviz ruby2.3 bundler default-libmysqlclient-dev runit jq 

#Create huginn user
RUN adduser --disabled-login --gecos 'Huginn' huginn

#Install foreman gem
RUN gem install foreman

USER huginn
#Install and configure hashcat
RUN cd /home/huginn && \
    git clone https://github.com/huginn/huginn.git -b master huginn && \
    cd huginn && \
    mkdir -p log tmp/pids tmp/sockets && \
    cp config/unicorn.rb.example config/unicorn.rb

WORKDIR /home/huginn/huginn

COPY .env /home/huginn/huginn/.env
COPY Procfile /home/huginn/huginn/Procfile
COPY unicorn.rb /home/huginn/huginn/config/unicorn.rb

# Install gems
RUN bundle install --path vendor/bundle --deployment --without development test

#Other commands
#RUN bundle exec rake db:seed RAILS_ENV=production SEED_USERNAME=admin SEED_PASSWORD=password
RUN bundle exec rake assets:precompile RAILS_ENV=production

#USER root
CMD ["bundle", "exec", "foreman", "start"]
