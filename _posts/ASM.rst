======================================
Install and Demo of Anthos Service Mesh
======================================

.. image:: _images/istio.png
    :align: right
    :width: 400


Steps
---------

1. From a linux/mac/chromebook setup some variables and login via gcloud

.. code-block:: bash
    :linenos:

    gcloud auth login
    export PROJECT_ID=YOUR_PROJECT_ID
    gcloud config set project ${PROJECT_ID}
    export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")

2. Enable the required APIs.

.. code-block:: bash
    :linenos:

    gcloud services enable \
        container.googleapis.com \
        compute.googleapis.com \
        stackdriver.googleapis.com \
        meshca.googleapis.com \
        meshtelemetry.googleapis.com \
        meshconfig.googleapis.com \
        iamcredentials.googleapis.com \
        anthos.googleapis.com

3. Set some environment variables.

.. code-block:: bash
    :linenos:

    gcloud compute zones list | grep aus
    australia-southeast1-b
    gcloud compute machine-types list | more

    export CLUSTER_NAME=bdlab102

    export IDNS=${PROJECT_ID}.svc.id.goog

    export MESH_ID="proj-${PROJECT_NUMBER}"
    gcloud config set compute/zone ${CLUSTER_ZONE}

4. Enable the required APIs.

.. code-block:: bash
    :linenos:

curl --request POST \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --data '' \
  https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize


gcloud beta container clusters create ${CLUSTER_NAME} \
    --machine-type=n1-standard-4 \
    --num-nodes=4 \
    --identity-namespace=${IDNS} \
    --enable-stackdriver-kubernetes \
    --subnetwork=default \
    --labels mesh_id=${MESH_ID}

gcloud container clusters get-credentials ${CLUSTER_NAME}

kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole=cluster-admin \
--user="$(gcloud config get-value core/account)"

curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.6-asm.0-linux.tar.gz

curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.6-asm.0-linux.tar.gz.1.sig
openssl dgst -verify - -signature istio-1.4.6-asm.0-linux.tar.gz.1.sig istio-1.4.6-asm.0-linux.tar.gz <<'EOF'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
-----END PUBLIC KEY-----
EOF


tar xzf istio-1.4.6-asm.0-linux.tar.gz
cd istio-1.4.6-asm.0
export PATH=$PWD/bin:$PATH

istioctl manifest apply --set profile=asm \
  --set values.global.trustDomain=${IDNS} \
  --set values.global.sds.token.aud=${IDNS} \
  --set values.nodeagent.env.GKE_CLUSTER_URL=https://container.googleapis.com/v1/projects/${PROJECT_ID}/locations/${CLUSTER_ZONE}/clusters/${CLUSTER_NAME} \
  --set values.global.meshID=${MESH_ID} \
  --set values.global.proxy.env.GCP_METADATA="${PROJECT_ID}|${PROJECT_NUMBER}|${CLUSTER_NAME}|${CLUSTER_ZONE}" \
  --set values.kiali.enabled=true

kubectl create namespace demo
kubectl label namespace demo istio-injection=enabled

kubectl apply -n demo -f bookinfo/platform/kube/bookinfo.yaml
kubectl get pods -n demo

kubectl get svc

kubectl apply -n demo -f bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway -n demo

kubectl get svc istio-ingressgateway -n istio-system
we should see an external IP here.

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL

browse to IP/productpage

show 3 things.
versions of review aka round robin
show that mtls is not enabled

kubectl apply -n demo -f bookinfo/networking/destination-rule-all-mtls.yaml 

istioctl experimental describe pod productpage-v1-c7765c886-x5mr4 
-n demo

istioctl manifest apply --set values.global.mtls.auto=true

next up investigate how to enable mtls

kubectl run fortio --image=istio/fortio -- load -t 0 -qps 100 http://$GATEWAY_URL/productpage


KIALI_USERNAME=$(read -p 'Kiali Username: ' uval && echo -n $uval | base64)
KIALI_PASSPHRASE=$(read -sp 'Kiali Passphrase: ' pval && echo -n $pval | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF

istioctl manifest apply --set profile=asm \
  --set values.global.trustDomain=${IDNS} \
  --set values.global.sds.token.aud=${IDNS} \
  --set values.nodeagent.env.GKE_CLUSTER_URL=https://container.googleapis.com/v1/projects/${PROJECT_ID}/locations/${CLUSTER_ZONE}/clusters/${CLUSTER_NAME} \
  --set values.global.meshID=${MESH_ID} \
  --set values.global.proxy.env.GCP_METADATA="${PROJECT_ID}|${PROJECT_NUMBER}|${CLUSTER_NAME}|${CLUSTER_ZONE}" \
  --set values.kiali.enabled=true \
  --set values.global.mtls.auto=true


kubectl apply -f networking/destination-rule-all-mtls.yaml 



kubectl get destinationrules -o yaml
kubectl delete -f networking/virtual-service-all-v1.yaml

kubectl apply -f networking/virtual-service-all-v1.yaml

kubectl apply -f networking/virtual-service-reviews-50-v3.yaml
kubectl apply -f networking/virtual-service-reviews-v3.yaml

