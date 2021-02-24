# K8S audit logs	



## Install
[Detailed Guide](https://falco.org/docs/getting-started/installation/)


## API server conf

```
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 192.168.100.21:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
    - --audit-log-path=/etc/kubernetes/audit/logs/audit.log
    - --audit-log-maxsize=5
    - --audit-log-maxbackup=1                                    
    - --advertise-address=192.168.100.21
    - --allow-privileged=true
...
volumeMounts:
  - mountPath: /etc/kubernetes/audit/policy.yaml
    name: audit
    readOnly: true
  - mountPath: /etc/kubernetes/audit/logs/audit.log
    name: audit-log
    readOnly: false
...
- name: audit
  hostPath:
    path: /etc/kubernetes/audit/policy.yaml
    type: File

- name: audit-log
  hostPath:
    path: /etc/kubernetes/audit/logs/audit.log
    type: FileOrCreate

```
Audit Policy:
```
# /etc/kubernetes/audit/policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
​
# log Secret resources audits, level Metadata
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
​
# log node related audits, level RequestResponse
- level: RequestResponse
  userGroups: ["system:nodes"]
​
# for everything else don't log anything
- level: None
```


### Run
```
systemctl start falco

cat /var/log/syslog | grep falco
kubectl exec -it ubuntu -- apt update
```
