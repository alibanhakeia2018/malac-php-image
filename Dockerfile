# Image PHP pour malac.shop (PrestaShop 9.0.3)
#
# Raison d'etre : les images officielles prestashop/prestashop embarquent
# encore PHP 8.3.35 / 8.4.26, vulnerables a CVE-2026-109618 et CVE-2026-109619
# (RCE, CVSS 9.2). Cette image part de php:8.3.36-apache, qui contient le
# correctif, et reproduit a l'identique l'environnement de l'image PrestaShop.
#
# L'application PrestaShop n'est PAS dans l'image : elle vit sur le PVC ps-data.
# Cette image ne fournit que PHP + Apache + les extensions.
FROM php:8.3.36-apache

# Dependances systeme necessaires a gd, intl, zip et soap
RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libicu-dev \
        libzip-dev \
        libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Les 6 extensions que l'image PrestaShop ajoute par-dessus php:apache
# (sodium est deja presente dans l'image de base ; opcache est explicite)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        pdo_mysql \
        soap \
        zip \
        opcache

# PrestaShop a besoin de la reecriture d'URL (URL simplifiees)
RUN a2enmod rewrite

COPY php-prestashop.ini /usr/local/etc/php/conf.d/zz-prestashop.ini

WORKDIR /var/www/html
