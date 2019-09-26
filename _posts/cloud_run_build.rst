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

.. image:: _images/cloud-run.png
    :align: right

Objective
---------
Build a documentation/blog site based on the Sphinx documentation generator. The site will automatically
update content when it is committed to Git. 

Software/Tools Used:

-  *Cloud Run GCP Service*
-  *Cloud Build GCP Service*
-  *Github*
-  *Sphinx*
-  *Nginx*

Sphinx Documentation_.

.. _Documentation: http://www.sphinx-doc.org/en/master/

ReStructured Text DocumCheatsheet_

.. _Cheatsheet: https://github.com/ralsina/rst-cheatsheet/blob/master/rst-cheatsheet.rst

.. code-block:: yaml
   :linenos: