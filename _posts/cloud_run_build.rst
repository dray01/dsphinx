======================================
Post 01. Geting Started with Cloud Run
======================================

What is Cloud Run I hear you ask? Cloud Run is obviously part of GCP. I like to think of it
as a kind of new look at both serverless functions and kubernetes. Basically it combines some
of the princples of both into one service. 
For this purposes of this post I thought it would be kind of neat to build this very site in Cloud Run.
The obvious and easier alternative would be to utilise Google Cloud Storage with static HTML hosting with a Cloud Build hook into Git. 
Serverless with Kubernetes is just a little more interesting to me...

More on Cloud Run here_.

.. _here: https://cloud.google.com/run/

Now let's get started.
I'll assume that you've signed up for your GCP account and are somewhat familiar with the UI.

Objective
---------
Build a documentation/blog site based on the Sphinx documentation generator. The site will automatically
update content when it is committed to Git. 

Software/Tools Used:

.. image:: _images/cloud-run.png
    :align: right

-  *Cloud Run GCP Service*
-  *Cloud Build GCP Service*
-  *Container Registry GCP Service*
-  *Github*
-  *Sphinx*
-  *Nginx*

Sphinx Documentation_.

.. _Documentation: http://www.sphinx-doc.org/en/master/

ReStructured Text Cheatsheet_.

.. _Cheatsheet: https://github.com/ralsina/rst-cheatsheet/blob/master/rst-cheatsheet.rst

Steps
---------

01. We need a docker file for our base image. There are a few lines of note.
Personally, I like to use Alpine as it's light weight and has a wide variety of packages available.
We then need to install some packages for sphinx and nginx.
Following on from this the other line of note is `sphink-build` as this is the process that builds out out .html pages based on the .rst pages we contribute.
Finally we copy our base configuration file for nginx then kickoff our web server instance of nginx to load the _html directory of sphinx.

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 1,9,26-27

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

    # RUN sed -i "s/${_SPHINX_DEFAULT_THEME}/${SPHINX_DEFAULT_THEME}/g" `find / -name conf.py_t`

    #CMD sphinx-quickstart .
    RUN sphinx-build -b html /usr/src/dcloud /usr/src/dcloud/_html
    EXPOSE 8080
    #CMD gunicorn -w 1 'sphinxserver:app(home="/usr/src/dcloud/_html")' -b 0.0.0.0:8080

    ## Copy a new configuration file setting listen port to 8080
    COPY ./default.conf /etc/nginx/conf.d/
    EXPOSE 8080
    CMD ["nginx", "-g", "daemon off;"]

