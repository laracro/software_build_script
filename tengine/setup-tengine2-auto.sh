#!/bin/bash
src_path=$(pwd)
cd $src_path
groupadd apache
useradd -g apache -m apache

# install system modules
yum -y install gd-devel openssl-devel readline-deve lncurses-devel readline readline-devel libxml2 libxml2-devel libxslt libxslt-devel

# download software package
wget http://tengine.taobao.org/download/tengine-2.2.2.tar.gz
wget https://openssl.org/source/openssl-1.0.2.tar.gz

t_ver="tengine-2.2.2"
o_ver="openssl-1.0.2"
tar zxvf ${t_ver}.tar.gz
tar zxvf ${o_ver}.tar.gz

# install tengine 2.2.x
cd $t_ver
./configure --prefix=/usr/local/$t_ver \
    --user=apache --group=apache \
    --with-pcre-jit \
    --with-mail \
    --with-openssl=../openssl-1.0.2 \
    --with-mail_ssl_module \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-openssl-opt="enable-tlsext" \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_image_filter_module \
    --with-http_sub_module \
    --with-http_flv_module \
    --with-http_slice_module \
    --with-http_mp4_module \
    --with-http_concat_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_sysguard_module
make && make install

ln -s /usr/local/$t_ver/ /usr/local/tengine

# make dir
cd $src_path
mkdir -p /data/logs/tengine
mkdir -p /data/www/localhost
mkdir -p /usr/local/$t_ver/conf/sites-enable
rm -f /usr/local/$t_ver/conf/nginx.conf
cp -a config/nginx.conf /usr/local/$t_ver/conf/nginx.conf
cp -a config/proxy/* /usr/local/$t_ver/conf/sites-enable/
chown -R apache.apache /data/www/localhost

# copy startup script
cd $src_path
cp config/tengine2 /etc/init.d/
chmod +x /etc/init.d/tengine2
chkconfig --add tengine2
chkconfig tengine2 on

# for systemctl (centos 7)

## cp config/tengine2.service /etc/systemd/system/multi-user.target.wants/

# start and test

/etc/init.d/tengine2 start
/usr/local/$t_ver/sbin/nginx -V

# for systemctl (centos 7)

## systemctl status tengine2

# del

rm -rf tengine-2.2.2 openssl-1.0.2