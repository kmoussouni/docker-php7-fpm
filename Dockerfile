FROM php:7.4-fpm

RUN pecl install apcu

RUN apt-get update -y
RUN apt-get install -y git-core \
	curl \
	build-essential \
	openssl \
	libssl-dev \
	xz-utils \
	gnupg \
	wget

#############################################
## node
#############################################
RUN cd /opt \
	&& VERSION=12.18.2 \
	&& DISTRO=linux-x64 \
	&& wget https://nodejs.org/dist/v$VERSION/node-v$VERSION-$DISTRO.tar.xz \
	&& tar -xf node-v$VERSION-$DISTRO.tar.xz 

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

RUN adduser --home /home/dev dev
RUN usermod -aG www-data dev

#############################################
## yarn
#############################################
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN apt -y update && apt -y install yarn

#############################################
## wkhtmltopdf
#############################################
RUN wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    tar vxf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    cp wkhtmltox/bin/wk* /usr/local/bin/ && \
    rm -rf wkhtmltox


#WORKDIR /usr/src/app

#RUN PATH=$PATH:/usr/src/apps/vendor/bin:bin