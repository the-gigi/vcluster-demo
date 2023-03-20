# vcluster-demo

Short demo of the awesome [vcluster](https://github.com/loft-sh/vcluster) project.

# Pre-requisties 

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [kind](https://kubernetes.io/docs/tasks/tools/#kind)
- [vcluster](https://github.com/loft-sh/vcluster)

# Running the demo

The Makefile makes it really easy.


## Simple demo

```
$ k version --short --context kind-kind 2> /dev/null
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.25.2
Kustomize Version: v4.5.7
Server Version: v1.25.3
```

Create a virtual cluster with version 1.26

```
$ vcluster create demo --kubernetes-version 1.26 -n demo --context kind-kind
```

Check the context of the new cluster
```
$ k config current-context
vcluster_demo_demo_kind-kind
```

Now, let's look at the version of the vcluster. It is 1.26 indeed.
```
$ k version --short --context vcluster_demo_demo_kind-kind 2> /dev/null

Client Version: v1.25.2
Kustomize Version: v4.5.7
Server Version: v1.26.0+k3s1
```


Here is what the virtual cluster looks like from the "inside":

```
$ k get po -A --context vcluster_demo_demo_kind-kind
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   coredns-56bfc489cf-vtdgl   1/1     Running   0          95m
```

Here is what the virtual cluster looks like from the host cluster point of view:

```
$ k get po -n demo --context kind-kind
NAME                                            READY   STATUS    RESTARTS   AGE
coredns-56bfc489cf-vtdgl-x-kube-system-x-demo   1/1     Running   0          15m
demo-0                                          2/2     Running   0          16m
```

let's deploy nginx to the vcluster:

```
$ k create deploy nginx --image nginx --context vcluster_demo_demo_kind-kind
deployment.apps/nginx created
```

Let's check out the pods at the host and vcluster level:

```
$ k get po -n demo --context kind-kind
NAME                                            READY   STATUS    RESTARTS   AGE
coredns-56bfc489cf-vtdgl-x-kube-system-x-demo   1/1     Running   0          100m
demo-0                                          2/2     Running   0          100m
nginx-748c667d99-rt2f6-x-default-x-demo         1/1     Running   0          70s

$ k get po -A --context vcluster_demo_demo_kind-kind
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   coredns-56bfc489cf-vtdgl   1/1     Running   0          100m
default       nginx-748c667d99-rt2f6     1/1     Running   0          58s
```

Let's look at the deployment at the host and vcluster level:

```
$ k get deploy -n demo --context kind-kind
No resources found in demo namespace.

$ k get deploy -n default --context vcluster_demo_demo_kind-kind
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           68m
```

Listing all virtual clusters

```
$ vcluster list

 NAME        NAMESPACE   STATUS    CONNECTED   CREATED                         AGE           CONTEXT
 cleopatra   cleopatra   Running               2023-01-10 20:40:10 -0800 PST   1581h24m0s    kind-kind
 demo        demo        Running   True        2023-03-17 16:43:58 -0700 PDT   2h20m12s      kind-kind
 napoleon    napoleon    Running               2023-01-10 20:37:15 -0800 PST   1581h26m55s   kind-kind
 stalin      stalin      Running               2023-01-10 20:39:01 -0800 PST   1581h25m9s    kind-kind
 ```
