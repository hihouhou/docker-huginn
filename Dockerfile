#
# huginn Dockerfile
#
# https://github.com/
#

# Pull base image.
FROM debian:latest

LABEL org.opencontainers.image.authors="hihouhou < hihouhou@hihouhou.com >"

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV NODE_MAJOR=16

# Install curl
RUN apt-get update && \
    apt-get install -y curl gnupg2 ca-certificates

# Fetch Nodejs repository
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Update & install packages for installing huginn
RUN apt-get update && \
    apt-get install -y vim nmap git build-essential libssl-dev zlib1g-dev libyaml-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev pkg-config cmake nodejs graphviz default-libmysqlclient-dev runit jq python3-requests python3-docutils bsdmainutils nodejs

#Create huginn user
RUN adduser --disabled-login --gecos 'Huginn' huginn

USER huginn
# Install Ruby 3.2.2
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc && \
    $HOME/.rbenv/bin/rbenv install 3.2.4 && \
    $HOME/.rbenv/bin/rbenv global 3.2.4

ENV PATH="/home/huginn/.rbenv/shims:${PATH}"
#Install foreman gem
RUN gem install foreman bundler:2.3.18

#Install and configure huginn
RUN cd /home/huginn && \
    git clone https://github.com/huginn/huginn.git -b master huginn && \
    cd huginn && \
    mkdir -p log tmp/pids tmp/sockets && \
    cp config/unicorn.rb.example config/unicorn.rb

WORKDIR /home/huginn/huginn

COPY .env /home/huginn/huginn/.env
COPY Procfile /home/huginn/huginn/Procfile
COPY unicorn.rb /home/huginn/huginn/config/unicorn.rb

USER huginn
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install

#Other commands
#RUN bundle exec rake db:seed RAILS_ENV=production SEED_USERNAME=admin SEED_PASSWORD=password
RUN bundle exec rake assets:precompile RAILS_ENV=production

#USER root
CMD ["bundle", "exec", "foreman", "start"]
