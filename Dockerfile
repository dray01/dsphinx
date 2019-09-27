FROM alpine:3.7
LABEL description "Sphinx documentation tool"

ENV SPHINX_DEFAULT_THEME sphinx_rtd_theme

# Sphinx-quickstart default value
ENV _SPHINX_DEFAULT_THEME sphinx_rtd_theme
ENV PORT=8080
RUN apk add --update --no-cache \
        python3 \
        py3-pip \
        nginx \
        make && \
        pip3 install --upgrade pip && \
        pip3 install sphinx sphinx_rtd_theme recommonmark && \
        mkdir -p /usr/src/dcloud/_html && \
        mkdir -p /run/nginx && \
        touch /run/nginx/nginx.pid

#RUN mkdir -p /run/nginx
COPY . /usr/src/dcloud
WORKDIR /usr/src/dcloud

#CMD sphinx-quickstart .
RUN sphinx-build -b html /usr/src/dcloud /usr/src/dcloud/_html
EXPOSE 8080

## Copy a new configuration file setting listen port to 8080
COPY ./default.conf /etc/nginx/conf.d/
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
