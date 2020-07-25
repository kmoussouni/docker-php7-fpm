FROM php:7.4-fpm

RUN pecl install apcu

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y \
	apt-transport-https \
	curl \
	build-essential \
	ca-certificates \ 
	git-core \
	gnupg \
	libicu-dev \
	libzip-dev \
	libssl-dev \
	zlib1g-dev \
	libpng-dev \
	libjpeg-dev \
	libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libwebp-dev \
	lsb-release \
	openssl \
	wget \
	xz-utils \
	nano \
	unzip 

RUN apt search php7

#Now install the php7 package:

#sudo apt install php7.0-mysql

#############################################
## php extensions
#############################################
COPY docker-php-ext-* docker-php-entrypoint /usr/bin/
ENTRYPOINT ["docker-php-entrypoint"]
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure zip
RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd exif intl

#############################################
## composer
#############################################
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

#############################################
## node
#############################################
RUN cd /opt \
	&& VERSION=12.18.2 \
	&& DISTRO=linux-x64 \
	&& wget https://nodejs.org/dist/v$VERSION/node-v$VERSION-$DISTRO.tar.xz \
	&& tar -xf node-v$VERSION-$DISTRO.tar.xz 

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

RUN adduser --home /home/dev dev
RUN usermod -aG www-data dev

RUN echo 'alias ll="ls -la"' >> /home/dev/.profile

CMD ["php-fpm"]
