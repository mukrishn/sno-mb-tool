# KB inputs
export KUBE_BURNER_RELEASE_URL=${KUBE_BURNER_RELEASE_URL:-https://github.com/cloud-bulldozer/kube-burner/releases/download/v0.9.1/kube-burner-0.9.1-Linux-x86_64.tar.gz} 
export QPS=${QPS:-40} 
export BURST=${BURSTS:-40}
export CLEANUP_WHEN_FINISH=${CLEANUP_WHEN_FINISH:-true}
export ENABLE_INDEXING=${ENABLE_INDEXING:-true}
export ES_SERVER=${ES_SERVER:-https://search-perfscale-dev-chmf5l4sh66lvxbnadi4bznl3a.us-west-2.es.amazonaws.com:443}
export ES_INDEX=${ES_INDEX:-ripsaw-kube-burner}
export ES_ENABLE=false
export LOG_LEVEL="info"


# number of namespaces
export NUMBER_OF_NS_LIST=(1)
# Number of pods
export PODS_PER_NS_LIST=(1 10 100)
# container image
export CONTAINER_IMAGE="quay.io/openshift-scale/nginx"
export MB_CONTAINER_IMAGE="quay.io/mukrishn/snomb:2"

# MB inputs
# duration of mb script execution
export MB_DURATION="300"
# mb client counts
export KEEPALIVE_COUNT=(1 10 100)
export NUMBER_OF_MB_CLIENT=(1 10 100 1000)
export HTTP_RESPONSE_SIZE_LIST=(128 1024 8192 16384)

