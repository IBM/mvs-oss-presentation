# Falco	



## Install
[Detailed Guide](https://falco.org/docs/getting-started/installation/)


## Pod

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ubuntu
  name: ubuntu
spec:
  hostNetwork: true
  containers:
  - command:
    - sleep
    - "9999"
    image: ubuntu
    name: badboy
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```



### Run
```
systemctl start falco

cat /var/log/syslog | grep falco
kubectl exec -it ubuntu -- apt update
```
