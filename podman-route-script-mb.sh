#!/usr/bin/env bash 
set -e

source env.sh

old_pods=$(podman ps -a | grep snomb | awk '{print $1}' | xargs)

if [ "$old_pods" != "" ]; then
echo "--------------Deleting old podman pods------------------"
podman rm $old_pods
fi

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

echo "---------------------Creating request.json---------------"
echo '[' > request.json

routes=""
while [ "$routes" == "" ]
do
routes=$(oc get routes -A -l group=kb-mb-wl --no-headers | awk '{print $3}')
done


for route in $routes
do
cat <<EOT >> request.json       
  {
    "scheme": "http",
    "host": "$route",
    "port": 80,
    "method": "GET",
    "path": "/$fs.html",
    "keep-alive-requests": $kp,
    "clients": $mb
  },
EOT
done
echo ']' >> request.json

starttime=$(date +%s%N | cut -b1-13)
echo "Run $fs file $kp keepalive $mb mb clients for $MB_DURATION seconds per port"
echo "---------------------STARTING MB-------------------------"
podman run -v /root/sno-mb-tool:/data -it snomb:1 -i request.json -d$MB_DURATION -o response.csv
endtime=$(date +%s%N | cut -b1-13)
echo "---------------------Summary-----------------------------"
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
