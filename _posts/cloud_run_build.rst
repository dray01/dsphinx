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

01. A Dockerfile

We need a docker file for our base image. There are a few lines of note.
Personally, I like to use Alpine as it's light weight and has a wide variety of packages available.
We then need to install some packages for sphinx and nginx.
Following on from this the other line of note is ``sphink-build`` as this is the process that builds out out .html pages based on the .rst pages we contribute.
Finally we copy our base configuration file for nginx then kickoff our web server instance of nginx to load the _html directory of sphinx.

.. literalinclude:: ../Dockerfile
   :language: yaml
    :linenos:
    :emphasize-lines: 1,9,26-27

02. Build a Container image

Next up, we need to take the above Dockerfile and build a Container image from it.
Now the GCP SDK called "gcloud" gives us some cli options such as ``gcloud build --tag gcr.io/[PROJECT_ID]/[IMAGE_NAME] .`` 
Note the ``.`` is the current working directory that will include the ``Dockerfile``

Now looking at this from an end to end process I would prefer to automate as much as possible. This brings us to *Cloud Build*.
Let's call *Cloud Build* to build our Container image.

Expanding on this, will look to utilise *Cloud Build* to not only build the Container image but take that image and upload it to *Cloud Registry* 
and finally deploy the image to *Cloud Run*.

.. literalinclude:: ../cloudbuild.yaml
   :language: yaml

