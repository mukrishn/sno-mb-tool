# sno-mb-tool

## Prerequisites 
* Install [Kubeburner](https://github.com/cloud-bulldozer/kube-burner)
* Install [Dittybopper](https://github.com/cloud-bulldozer/performance-dashboards)
* Install OC clients and set `KUBECONFIG` environment variable 
* Install podman
* pip3 install numpy

## Run scripts

* Clone repository to `/root` 
* Set environment variables in `env.sh` file
    * kube-burner inputs
    * MB inputs
    * scale inputs - namespace and pod count
* `podman-route-script-mb.sh` - Traffic via ingress route between podman container(on prov) and pods inside cluster
* `podman-svc-script-mb.sh` - Traffic via service between podman container(on prov) and pods inside cluster
* `route-script-mb.sh` - pod to pod traffic via ingress route
* `svc-script-mb.sh` - pod to pod traffic via service network
* `pod-script-mb.sh` - pod to pod direct traffic
