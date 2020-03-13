FROM ubuntu:16.04
MAINTAINER zying <my527596@gmail.com>
LABEL Description="Based on Ubuntu 16.04 LTS. Includes .htaccess support and popular PHP7 features." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html zvuldrill" \
	Version="1.0"
RUN mv /etc/apt/sources.list /opt/
COPY sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y zip unzip
RUN apt-get install -y \
	php7.0 \
	php7.0-bz2 \
	php7.0-common \
	php7.0-curl \
	php7.0-dev \
	php7.0-fpm \
	php7.0-gd \
	php7.0-json \
	php7.0-mbstring \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-zip
RUN apt-get install apache2 libapache2-mod-php7.0 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get autoclean && apt-get clean && apt-get autoremove

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

COPY src/ /var/www/html/
COPY run.sh /usr/sbin/

RUN a2enmod rewrite

RUN chmod +x /usr/sbin/run.sh
RUN chown -R www-data:www-data /var/www/html
RUN rm -rf /var/www/html/index.html
RUN /etc/init.d/mysql start && \
	mysql -e "grant all privileges on *.* to 'root'@'%' identified by 'zvuldrill';" && \
	mysql -e "grant all privileges on *.* to 'root'@'localhost' identified by 'zvuldrill';"
RUN /etc/init.d/mysql start && \ 
	mysql -uroot -pzvuldrill -e "CREATE DATABASE IF NOT EXISTS zvuldrill DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;use zvuldrill;source /var/www/html/sys/zvuldrill.sql;"

VOLUME /var/www/html
VOLUME /var/log/apache2
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

EXPOSE 80

CMD ["/usr/sbin/run.sh"]
