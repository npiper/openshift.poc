# New Project 'logging'
oc adm new-project logging --node-selector=""
oc project logging

oc secrets new logging-deployer nothing=/dev/null

oc create -f - <<API
apiVersion: "v1"
kind: "PersistentVolumeClaim"
metadata:
  name: "storage-claim-log"
spec:
  accessModes:
    - "ReadWriteMany"
  resources:
    requests:
      storage: "100Mi"
  volumeName: "pv0001"
API

oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: logging-deployer
secrets:
- name: logging-deployer
API

oc secrets new logging-deployer nothing=/dev/null

oc create sa aggregated-logging-kibana
oc create sa aggregated-logging-elasticsearch
oc create sa aggregated-logging-fluentd
oc create sa aggregated-logging-curator
oc create sa aggregated-logging-deployer


oc policy add-role-to-user edit --serviceaccount logging-deployer

oc adm policy add-scc-to-user privileged system:serviceaccount:logging:aggregated-logging-fluentd
oc adm policy add-scc-to-user privileged system:serviceaccount:logging:aggregated-logging-kibana
oc adm policy add-scc-to-user privileged system:serviceaccount:logging:aggregated-logging-elasticsearch

oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-fluentd
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-kibana
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-elasticsearch
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:logging:logging-deployer

oc adm policy add-role-to-user admin developer -n logging



# Should have template 'logging-deployer-template'
oc new-app logging-deployer-template --param KIBANA_HOSTNAME=kibana.example.com --param ES_CLUSTER_SIZE=1 --param PUBLIC_MASTER_URL=https://localhost:8443
