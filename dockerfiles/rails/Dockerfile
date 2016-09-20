FROM ruby:2.3.1-slim

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      locales task-japanese \
      git \
      mysql-client \
      libmysqlclient-dev && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash rails && \
    mkdir -p /usr/src/app && \
    chown rails:rails /usr/src/app

RUN echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ja_JP.UTF-8

USER rails

# localeの設定
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP.UTF-8
ENV BUNDLE_APP_CONFIG /usr/src/app/.bundle

WORKDIR /usr/src/app

CMD ["/bin/bash"]