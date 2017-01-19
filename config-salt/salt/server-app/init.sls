dotdeb-repo:
  pkgrepo.managed:
    - humanname: Dotdeb
    - name: deb http://packages.dotdeb.org jessie all
    - file: /etc/apt/sources.list.d/dotdeb.list
    - key_url: http://www.dotdeb.org/dotdeb.gpg

apt_update: 
  cmd.run: 
    - name: apt-get update

nginx:
  pkg:
    - installed
  service:
    - running
    - enable: True

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://server-app/config/nginx/default
    - mode: 755

/var/www/html:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

install_php7:
  pkg.installed:
    - pkgs:
      - php7.0-cli
      - php7.0-fpm
      - php7.0-mysql

/var/www/html/index.php:
  file.managed:
    - source: salt://server-app/app/index.php
    - user: www-data
    - group: www-data
    - mode: 755

delete_example_nginx_file:
  file.absent:
    - name: /var/www/html/index.nginx-debian.html

restart_nginx:
  cmd.run:
    - name: /etc/init.d/nginx restart 
    - require :
      - pkg: nginx
