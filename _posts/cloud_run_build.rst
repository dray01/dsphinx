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
update content when it is committed to Git. There are a couple of links below to help you get started with Sphinx and reStructuredText

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

01. The Dockerfile for Sphinx and NGINX

We need a Dockerfile for our base image. There are a few lines of note.
Personally, I like to use Alpine as it's light weight and has a wide variety of packages available.
We then need to install some packages for sphinx and nginx.
Following on from this the other line of note is ``sphink-build`` as this is the process that builds out out .html pages based on the .rst pages that contain the content we want to share.
Finally we copy our base configuration file for nginx then kickoff our web server instance of nginx to load the _html directory of sphinx.

.. literalinclude:: ../Dockerfile
   :language: dockerfile
   :emphasize-lines: 1,9,24-25
   :linenos:

02. Build, Upload and Deploy the Container image to Cloud Run

Next up, we need to take the above Dockerfile and build a Container image from it.
Now the GCP SDK called "gcloud" gives us some cli options such as ``gcloud build --tag gcr.io/[PROJECT_ID]/[IMAGE_NAME] .`` 
Note the ``.`` is the current working directory that will include the ``Dockerfile``

Now looking at this from an end to end process I would prefer to automate the process. This brings us to Cloud Build.
ClLet's call Cloud Build to build our Container image.

Expanding on this, will look to utilise Cloud Build to not only build the Container image but take that image and upload it to Cloud Registry 
and finally deploy the image to Cloud Run.

Below is a ``.yaml`` file that delares this process. 

-  Building the image
-  Pushing the image to the Cloud Registry
-  Deploying the image to Cloud Run

.. literalinclude:: ../cloudbuild.yaml
   :language: yaml

 03. Putting it all together

Now let's put it all together. We need to complete a couple of things here. First we need to clone a base repo that 
includes all mainly the ``Dockerfile`` and the ``cloudbuild.yaml`` file.

From a terminal in your new working dir run ``git clone git@github.com:dray01/public-sphinx.git``

Create a new repo at Github_.

.. _GitHub: https://github.com 

Push the content you just cloned/editid up to the new repo on GitHub. (Atlassian has some great command references to help those not too familiar with git available _here.

.. _here: https://confluence.atlassian.com/bitbucketserver/basic-git-commands-776639767.html

From there, you can make some edits or write new files inside the _posts/ directory.
Also, if you do create new files then you will need to add them to the ``index.rst`` file to ensure they appear 
in the left hand pane on the page.

Next up we need to connect your new Git repo to Cloud Build so that when you push any changes to the repo they are reflected in your new documentation page.


