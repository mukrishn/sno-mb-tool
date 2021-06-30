#!/usr/bin/env bash 
set -e

source env.sh

for fs in ${HTTP_RESPONSE_SIZE_LIST[@]}
do
for ns in ${NUMBER_OF_NS_LIST[@]}
do
for pods in ${PODS_PER_NS_LIST[@]}
do

target=""
while [ "$target" == "" ]
do
target=$(oc get --no-headers route -n dittybopper | awk {'print $2'})
done

uuid=$(uuidgen)

export NUMBER_OF_NS=$ns
export PODS_PER_NS=$pods

echo "---------------------STARTING KB-------------------------"
kube-burner init -c mb_test.yml --uuid $uuid 

for kp in ${KEEPALIVE_COUNT[@]}
do
for mb in ${NUMBER_OF_MB_CLIENT[@]}
do

podips=""
while [ "$podips" == "" ]
do
podips=$(oc get pods --no-headers -n web-server-mb-1 -o wide | awk '{print $6}')
done

echo "---------------------Creating request.json---------------"

cat <<EOT >> configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: request-json
  namespace: web-server-mb-1
  labels:
    group: kb-mb-wl
    app: mb-pod
data:
  request.json: |
     [
EOT

for ip  in $podips
do
cat <<EOT >> configmap.yml
        {
          "scheme": "http",
          "host": "$ip",
          "port": 8080,
          "method": "GET",
          "path": "/$fs.html",
          "keep-alive-requests": $kp,
          "clients": $mb
        },
EOT
done
echo '     ]' >> configmap.yml

oc apply -f configmap.yml

starttime=$(date +%s%N | cut -b1-13)
echo "Run $fs file $kp keepalive $mb mb clients for $MB_DURATION seconds per port"
echo "---------------------STARTING MB-------------------------"
kube-burner init -c mb_pod.yml --uuid $uuid 
sleep $MB_DURATION 
sleep 20
endtime=$(date +%s%N | cut -b1-13)
echo "---------------------Summary-----------------------------"
oc logs -n web-server-mb-1 mb-pod-1 | grep "Time: "
oc logs -n web-server-mb-1 mb-pod-1 | grep "Sent: "
oc logs -n web-server-mb-1 mb-pod-1 | grep "Recv: "
oc logs -n web-server-mb-1 mb-pod-1 | grep "Hits: "
oc cp -n web-server-mb-1 mb-pod-1:/tmp/response.csv response.csv
python3 parser.py --output response.csv --runtime $MB_DURATION
echo "---------------------FINISHED MB-------------------------"


for i in {1..5}
do
curl -H "Content-Type: application/json" -X POST -d "{\"dashboardId\":$i,\"time\":$starttime,\"isRegion\":\"true\",\"timeEnd\":$endtime,\"tags\":[\"mb-test\"],\"text\":\"data plane test running HTTP GETs on $((pods*ns)) OCP routes, $kp keepalive connection & $mb mb client per route for $MB_DURATION seconds and downloading $fs Bytes file\"}" http://admin:admin@$target/api/annotations
done

echo "--"
echo "---------------------FINISHED KB-------------------------"
sleep 60
done
sleep 60
done
sleep 60
done
done
sleep 60
done
