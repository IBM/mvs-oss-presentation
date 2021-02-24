# Network Policy	



## Install
Enabled by default


## Network Policy example
cloud-metadata
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-only-cloud-metadata-access
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
      cidr: 0.0.0.0/0
      except:
      - 169.254.169.254/32
```
deny-all-traffic
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```



### Run
```
kubectl run busybox1 --image busybox -- sleep 9999
kubectl run busybox2 --image busybox -- sleep 9999


kubectl get po -o wide

kubectl exec -it busybox1 -- ping -c3 busybox1
```
