======================================
Installing Istio Service Mesh on GKE.
======================================

.. image:: _images/istio.png
    :align: left
    :width: 400

Over the past few years we've been hearing and talking about a Service Mesh. To me this technology 
certainly can solve many problems in both digitel natives and traditional enterprise alike. I'm very much
enjoying watching the SM space mature and really form a value statement that many architects I speak to are
looking for. If we say that kubernetes has won. Then we will continue to see larger/more complex kubernetes 
deployments which will further drive the need for a Service Mesh.
At a high level there are a few capabilities a Service Mesh will provide. 
Offload certificate mangement (mTLS) from the developers.
Provide the SRE/Ops teams with insight into service performance/latency and to further abstract services from the network.


Objective
---------
The intent of this post is to share the installation process to get the OSS version of Istio Service Mesh 
on our GKE cluster. This is more of an enablement and prep before I go ahead and test out Anthos SM or ASM which it will be known as. 
ASM will provide the capability to build your mesh across many clusters and clouds.

Here is a guide to getting your first GKE_ cluster up and running.

.. _GKE: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster

Steps
---------

01. Activate the Cloud Shell

From the GCP console ensure that you have your project selected. Then you can select the below icon to 
activate Cloud Shell

.. image:: _images/cloud-shell.png
    :align: left

Then you will see a terminal window open up at the bottom of your console tab.

02. Here is a guide to getting your first GKE_ cluster up and running.

.. _GKE: https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster
or, you can enter the below into your cloud-shell session.

.. code-block:: bash

    GCP_PROJECT=$(gcloud config list --format "value(core.project)")
    export IDNS=${GCP_PROJECT}.svc.id.goog

    gcloud compute networks subnets update default \
        --region australia-southeast1 \
        --add-secondary-ranges pods=10.60.0.0/14 

    gcloud beta container clusters create istio-cluster --zone \
        australia-southeast1 \
        --enable-ip-alias \
        --machine-type n1-standard-4 \
        --identity-namespace=${IDNS} \
        --enable-stackdriver-kubernetes \
        --subnetwork=default \
        --cluster-secondary-range-name=pods \
        --services-ipv4-cidr=10.120.0.0/20 \
        --labels csm=


03. Once you have this up and running we need to enable access to a few API's in GCP.

.. code-block:: bash

    gcloud services enable \
        cloudresourcemanager.googleapis.com \
        container.googleapis.com \
        containeranalysis.googleapis.com \
        binaryauthorization.googleapis.com \
        gkeconnect.googleapis.com \
        gkehub.googleapis.com \
        serviceusage.googleapis.com \
        sourcerepo.googleapis.com \
        iamcredentials.googleapis.com \
        contextgraph.googleapis.com \
        stackdriver.googleapis.com

04. Download and prepare to deploy Istio to the new cluster.

.. code-block:: bash

    curl -L https://istio.io/downloadIstio | sh -

.. code-block:: bash

    cd istio-1.4.3

.. code-block:: bash

    export PATH=$PWD/bin:$PATH

These instructions are taken from Istio's site_

.. _site: https://istio.io/docs/setup/getting-started/

Note: ``Current latest version is 1.4.3.`` 

05. Create an alias using kubectx to make it easier to refer to the istio cluster

.. code-block:: bash
    GCP_PROJECT=$(gcloud config list --format "value(core.project)")
    kubectx istio-cluster=gke_${GCP_PROJECT}_australia-southeast1_istio-cluster

06. The cluster we just provisioned uses Workload Identity for authenticating with GCP Services. 
This provides an improved security posture for when applications running into GKE need to connect to GCP Services. 
The application we will be deploying later will be shipping traces to Stackdriver. 
Run the following commands to configure Workload Identity for the default namespace that we’ll be 
running our application in.  

.. code-block:: bash

    gcloud iam service-accounts create microservices-demo
    gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
    --member=serviceAccount:microservices-demo@${GCP_PROJECT}.iam.gserviceaccount.com \
    --role=roles/cloudtrace.agent

    gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
    --member=serviceAccount:microservices-demo@${GCP_PROJECT}.iam.gserviceaccount.com \
    --role=roles/cloudprofiler.agent

    gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${GCP_PROJECT}.svc.id.goog[default/default]" \
    microservices-demo@${GCP_PROJECT}.iam.gserviceaccount.com

    kubectl annotate serviceaccount \
    --namespace default \
    default \
    iam.gke.io/gcp-service-account=microservices-demo@${GCP_PROJECT}.iam.gserviceaccount.com

07. Deploy Istio to the new cluster and define your profile.

Firstly, we'll be deploying the ``Demo`` profile as it meets my needs. At a high level a pofile 
is a pre-built definition of what features get enabled.
More information on Istio profiles is available here_.

.. _here: https://istio.io/docs/setup/additional-setup/config-profiles/

.. code-block:: bash

    istioctl manifest apply --set profile=demo \
    --set values.global.mtls.auto=true  \
    --set values.global.mtls.enabled=false

This tasks shows a simplified workflow for mutual TLS adoption as per Istio documentation_

.. _documentation: https://istio.io/docs/tasks/security/authentication/auto-mtls/

With Istio auto mutual TLS feature, you can adopt mutual TLS by only configuring authentication policy 
without worrying about destination rule.

08. Enable Istio injection to your namespace.

I'll create a demo namespace for the purposes of this post.

.. code-block:: bash
    kubectl create namespace demo
    kubectl label namespace demo istio-injection=enabled


