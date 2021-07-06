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
* Run Script `script-mb.sh` to run HTTP traffic between localhost(mb client runs inside podman containers) and webserver pod via ingress routes
* Run Script `pod-script-mb.sh` to run HTTP traffic between webserver pod and mb pod within OCP cluster. 