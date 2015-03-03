#!/bin/bash
apt-key adv --keyserver keyserver.ubuntu.com --recv E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y supervisor logrotate locales \
      nginx openssh-server mysql-client postgresql-client redis-tools \
      git-core ruby2.1 python2.7 python-docutils \
      libmysqlclient18 libpq5 zlib1g libyaml-0-2 libssl1.0.0 \
      libgdbm3 libreadline6 libncurses5 libffi6 \
      libxml2 libxslt1.1 libcurl3 libicu52 \
      mysql-server redis-server \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure locales \
 && gem install --no-document bundler \
 && rm -rf /var/lib/apt/lists/* # 20150220

mkdir -p /app
cp -r assets/setup/ /app/setup/
chmod 755 /app/setup/install
/app/setup/install

cp -r assets/config/ /app/setup/config/
cp -r assets/init /app/init
chmod 755 /app/init

# Initialize database
mysql < gitlabhq.sql

mkdir -p /var/log/gitlab
mkdir -p /var/log/gitlab/gitlab
chown -R git:git /var/log/gitlab

mkdir -p /home/git/data/tmp/cache
chown -R git:git /home/git/data/tmp/cache

# use default sshd, don't use sshd which started by supervisord
rm -f /etc/supervisor/conf.d/sshd.conf
rm -f /etc/supervisor/conf.d/cron.conf

cat > /app/env << END
DB_USER=gitlab
DB_PASS=gitlab
DB_NAME=gitlabhq_production
DB_HOST=localhost
DB_PORT=3306
DB_TYPE=mysql
REDIS_HOST=localhost
REDIS_PORT=6379
GITLAB_RELATIVE_URL_ROOT=/git
GITLAB_HOST=192.168.33.11
GITLAB_SSH_PORT=22
GITLAB_BACKUPS=daily
SMTP_USER=
SMTP_PASS=
#REDMINE_URL=http://10.1.28.99/redmine
END
