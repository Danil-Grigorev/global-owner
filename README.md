## GlobalOwner resource

This is an example of a Custom Resource called `GlobalOwner`, which is responsible for setting ownership on any kubernetes native or custom resources across the cluster.

It uses `customize` hook to select a list of resources to adopt based on provider `spec.selector` value in the resource and `childResources` definition inside the `CompositeController` definition.

### Prerequisites

* Install [Metacontroller](https://github.com/metacontroller/metacontroller)

### Deploy the controller

```sh
kubectl apply -k v1
```

### Create an example GlobalOwner, adopting deployments matching label selector expression

```sh
kubectl apply -f example-globalowner.yaml
```

A `GlobalOwner` resource will be created and will adopt all resources matching the given `GVK`s provided in the `childResources` field under the `CompositeController` definition, assuming they match the `selector` value.

## Example

This example shows how a `GlobalOwner` resource could be used to adopt all `ConfigMaps` that don't have a `skip` annotation specified.

Example `ConfigMap` resource located in [example-configmap.yaml](./example-configmap.yaml):
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test
  namespace: default
  labels:
    adopt: "true"
data:
  some: "value"
  other: "value"
```

```sh
kubectl apply -f example-configmap.yaml
```

After applying this resource in the cluster, the ownership reference should be set on the resource.

```bash
$ kubectl get globalowner -o yaml
```
returns

```yaml
apiVersion: globalowner.metacontroller.io/v1alpha1
kind: GlobalOwner
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"globalowner.metacontroller.io/v1alpha1","kind":"GlobalOwner","metadata":{"annotations":{},"name":"global-owner"},"spec":{"selector":{"matchExpressions":[{"key":"skip","operator":"DoesNotExist"}]}}}
  creationTimestamp: "2023-09-11T11:18:25Z"
  generation: 1
  name: global-owner
  resourceVersion: "3436"
  uid: 53f365d2-4c8e-469b-b09a-62994a968f8f
spec:
  selector:
    matchExpressions:
    - key: adopt
      operator: Exists
status:
  observedGeneration: 1
  ownedResources:
  - apiVersion: v1
    kind: ConfigMap
    name: test
    namespace: default
```

```bash
$ kubectl get cm test -n default -o yaml
```
will show that a `ConfigMap` has an `OwnershipReference` pointing to the `GlobalOwner` resource.

```yaml
apiVersion: v1
data:
  other: value
  some: value
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"other":"value","some":"value"},"kind":"ConfigMap","metadata":{"annotations":{},"labels":{"adopt":"true"},"name":"test","namespace":"default"}}
  creationTimestamp: "2023-09-11T12:23:41Z"
  labels:
    adopt: "true"
  name: test
  namespace: default
  ownerReferences:
  - apiVersion: globalowner.metacontroller.io/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: GlobalOwner
    name: global-owner
    uid: 6a3269db-f713-41cb-8111-6155f2c2b4b7
  resourceVersion: "1602"
  uid: e3aa2bc8-7615-44de-a788-e6a5296b47bb
```