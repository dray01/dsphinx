======================================
Geting Started with Cloud Run
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
I'll assume that you've signed up for your GCP account and are somewhat familiar with the UI. We'll also assume you're familiar with git and the cli in general.

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

02. Build the Container image using gcloud SDK.

Next up, we need to take the above Dockerfile and build a Container image from it.
Now the GCP SDK called "gcloud" gives us some cli options such as ``gcloud build --tag gcr.io/[PROJECT_ID]/[IMAGE_NAME] .`` 
Note the ``.`` is the current working directory that will include the ``Dockerfile``

03. Push the image to the Container Registry in GCP

Now that we've built the image, we need to upload/push it to GCP so we can deploy it in some way shape or form...
To push an image via the cli DK we can use the following command ``gcloud docker -- push gcr.io/[PROJECT_ID]/[IMAGE_NAME]``.
Note the project ID and image name variables.

04. The fun bit... Deploying the image withs Cloud Run.

Now looking at this from an end to end process I would prefer to automate the process. This brings us to Cloud Build.
Cloud Build let's us build and deploy our software in minutes. As a first timer to CLoud Build, I was surprised just how easy it was to consume!

We need Cloud Build to do 3 things for us when code is checked into git.

-  Building the image
-  Pushing the image to the Cloud Registry
-  Deploying the image to Cloud Run

Below is a ``.yaml`` file that delares this process. 

.. literalinclude:: ../cloudbuild.yaml
   :language: yaml
   :linenos:

The last thing we need to do is link Cloud Build to your GitHub repo to trigger a new build when a new commit is pushed.

Follow the guide on connecting Cloud Build to Git with triggers_.

.. _triggers: https://cloud.google.com/cloud-build/docs/create-github-app-triggers

05. Putting it all together

Now let's put it all together. We need to complete a couple of things here. First we need to clone a base repo that 
includes all the needed files.

The following instructions will differ depending on your own personal workflow/OS/machine etc.
From a terminal in your new working dir run ``git clone git@github.com:dray01/public-sphinx.git``

Create a new repo at Github_.

.. _GitHub: https://github.com 

Take a look with your favourite editor in the _posts directory and edit the .rst files as desired.

You will need to make some edits to the ``cloudbuild.yaml`` file. Edit and update your image name and service name in the file. 
Note the ``$PROJECT ID`` variable. 
This assumes that you have set the default project with the GCP SDK. You can set this with the following command: ``gcloud config set project my-project``

Push the content you just cloned/editid up to the new repo on GitHub. 
From within the working directory that includes the Dockerfile etc ``git add . && git commit -m "First Push" && git push origin master``
(Atlassian has some great command references to help those not too familiar with git available at Atlassian_.

.. _Atlassian: https://confluence.atlassian.com/bitbucketserver/basic-git-commands-776639767.html

Note: if you do create new files then you will need to add them to the ``index.rst`` file to ensure they appear 
in the left hand pane on the page.

Now if all things are working as expected, the first build should of triggered on your first commit to GitHub.
Therefore we should see 2 new artifacts in GCP.

-  A new image in Container Registry
-  The above image running in Cloud Run

Navigate to https://console.cloud.google.com -> Cloud Run | You should see a service with the defined service name.
Click the hyperlink on the service name and the following page will provide a public URL to access the site.

That just about does it.

Quick Win 
---------------

Quick note, check out the ``README.md`` as part of the https://github.com/dray01/public-sphinx repo. There is a button to simply deploy the image to 
Cloud Run! Kinda cool if you just want to click the button, log into GCP console and it will do the rest!

More on the Cloud Run Button_.

.. _Button: https://cloud.google.com/blog/products/serverless/introducing-cloud-run-button-click-to-deploy-your-git-repos-to-google-cloud

Till next time!

BD

