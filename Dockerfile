# Definir las versiones de Erlang, Elixir y Debian
ARG OTP_VERSION=25.0.4
ARG OTP_VERSION=25.0.4
ARG ELIXIR_VERSION=1.15.8
ARG DEBIAN_VERSION=bullseye-20250224-slim

# Configuración de las imágenes base para el builder y el runner
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# Usar la imagen base de Elixir como builder
FROM ${BUILDER_IMAGE} AS builder

# Agregar repositorios deb-src y backports correctamente a la lista de fuentes de APT
RUN echo "deb http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list \
    && apt-get update

# Instalar las dependencias necesarias para construir y manejar GNOME XML
RUN apt-get install -y build-essential git curl wget autoconf m4 libncurses5-dev libssh-dev unixodbc-dev \
    xsltproc fop libxml2-utils libsctp-dev lksctp-tools locales sed

# Limpiar la caché de APT para reducir el tamaño de la imagen final
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar WKHTMLTOPDF desde la fuente
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin/
RUN rm -rf wkhtmltox

# Generar las configuraciones locales necesarias
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Instalar Hex y Rebar
RUN mix local.hex --force && mix local.rebar --force

# Establecer las variables de entorno para el idioma y la localización
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Limpiar los residuos de APT y otras dependencias no necesarias
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove