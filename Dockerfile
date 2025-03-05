FROM ubuntu:25.04

ENV ERLANG_VERSION=25.3.2
ENV ELIXIR_VERSION=1.15.5-otp-25
ENV PHOENIX_VERSION=1.7.20
ENV NODE_VERSION=18.16.0

## Instalar dependencias necesarias
RUN apt-get update
RUN apt-get install -y curl git
RUN apt-get install -y wget build-essential autoconf m4 libncurses5-dev libssh-dev unixodbc-dev

## Instalar herramientas relacionadas con GNOME XML
RUN apt-get install -y xsltproc fop libxml2-utils libsctp-dev lksctp-tools

# Descargar e instalar WKHTMLTOPDF
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin/
RUN rm -rf wkhtmltox

# Clonar y configurar asdf (gestor de versiones)
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1 && \
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

# Configurar PATH para asdf
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:${PATH}"

# Verificar la instalación de asdf
RUN /bin/bash -c "source ~/.bashrc && asdf version"

# Instalar Erlang usando asdf
RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
ENV KERL_CONFIGURE_OPTIONS --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --without-javac --enable-darwin-64bit
RUN /bin/bash -c "asdf install erlang $ERLANG_VERSION"
RUN apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN /bin/bash -c "asdf global erlang $ERLANG_VERSION"

# Instalar Elixir usando asdf
RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"
RUN /bin/bash -c "asdf install elixir $ELIXIR_VERSION"
RUN /bin/bash -c "asdf global elixir $ELIXIR_VERSION"

# Instalar Node.js usando asdf
RUN /bin/bash -c "source ~/.bashrc && \
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
    asdf install nodejs $NODE_VERSION && \
    asdf global nodejs $NODE_VERSION"

# Configuraciones finales
RUN apt-get install -y inotify-tools
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"

# Limpiar caché de apt para reducir el tamaño de la imagen
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove

