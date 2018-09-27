# Introduction 
Deploy SonarQube with postress to Google Cloud Console
Some customization has to be done on the SonarQube base image.
[Final image](https://hub.docker.com/r/vstashchenko/sonar/)

# Getting Started
##### 1. Make sure your kubernetes cluster is up and running
    
```
kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
gke-my-testnode-default-pool-4321s   Ready     <none>    20d       v1.9.7-gke.5
```
##### 2. Create secret for postgres database

`kubectl create secret generic postgres-pwd --from-literal=password=YourSecretPass`

##### 3. Run manifests

```
kubectl apply -f k8s/sonar-pv-postgres.yaml
kubectl apply -f k8s/sonar-pvc-postgres.yaml
kubectl apply -f k8s/sonar-postgres-deployment.yaml
kubectl apply -f k8s/sonar-postgres-service.yaml
kubectl apply -f k8s/sonarqube-deployment.yaml
kubectl apply -f k8s/sonarqube-service.yaml
```
This will create pods in the cluster.

##### 4. Connect to SonarQube
You can check the pods with:

```
kubectl get po -o wide
NAME                             READY     STATUS    RESTARTS   AGE       IP            NODE
sonar-postgres-bbc4bbf66-fm87z   1/1       Running   0          22h       10.31.6.12   gke-my-testnode-default-pool-4321s
sonarqube-5dcbcdbf7d-zvgc7       1/1       Running   0          51m       10.31.7.13    gke-my-testnode-default-pool-4321s

```

You sonar app will be available through ingress. You can check the ingress with:
```
kubectl get ingress
NAME                HOSTS     ADDRESS         PORTS     AGE
sonarqube-ingress   *         35.232.31.158   80        22h
```

The default username and password for the SonarQube is admin. After login to the sonarqube follow the steps by choosing the language of the project like Java or other. Create the project specific key and hash of the project.
