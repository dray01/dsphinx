======================================
Installing Istio Service Mesh on GKE.
======================================

Over the past few years we've been hearing and talking about a Service Mesh. To me this technology 
certainly can solve many problems in both digitel natives and traditional enterprise shops. I'm very much
enjoying watch the SM space mature and really form a value statement that many architects I speak to are looking for.

Objective
---------
The intent of this post is to share the installation process to get the OSS version of Istio Service Mesh 
configured on our GKE cluster. The follow up to this is it's a bit of a prep for the upcomign GA release of Anthos 
SM which will bring a managed SM offering to Google's Hybrid/multi cloud solutions.

Here is a guide to getting your first GKE_ cluster up and running.

.. _GKE: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster

Steps
---------

01. Here is a guide to getting your first GKE_ cluster up and running.

.. _GKE: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster

02. Enable the Cloud Shell

03. Once you have this up and running we need to enable access to a few API's in GCP.

.. literalinclude:: ../cloudbuild.yaml
   :language: yaml
   :linenos: