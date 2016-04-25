FROM phusion/baseimage:0.9.18

# Baseimage's init script
CMD /sbin/my_init

# Install required packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq
RUN apt-get upgrade -y -o Dpkg::Options::='--force-confold'
RUN apt-get install -y autoconf automake bison build-essential \
  curl gawk git-core libffi-dev libgdbm-dev libgmp-dev libncurses5-dev \
  libreadline6-dev libsqlite3-dev libssl-dev libtool libxslt1-dev \
  libxml2-dev libyaml-dev pkg-config sqlite3 zlib1g-dev nodejs

# Remove temp files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure app folder
ENV APP_HOME /beta.gouv.fr

RUN mkdir $APP_HOME

WORKDIR $APP_HOME

# Install RVM
COPY .ruby-* $APP_HOME/

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c 'rvm install $(cat .ruby-version)'
RUN /bin/bash -l -c 'rvm use $(cat .ruby-version)@global --default'

# Install app dependencies
COPY Gemfile $APP_HOME/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_PATH=/bundle

RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'
RUN /bin/bash -l -c 'bundle check || bundle install'

# Add local project files to app folder
COPY . $APP_HOME
