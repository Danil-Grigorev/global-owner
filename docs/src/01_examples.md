# Examples

This example presents the functionality by adopting `ConfigMaps` matching label selector expression and setting ownership on those resources across the cluster, but the same process could be applied to any resource kind existing in the cluster. For each resource type the permissions to own the object will be granularly adjusted.

[[_TOC_]]

## Steps

To create an example `GlobalOwner` and a `ConfigMap`:

```sh
kubectl apply -f example
```

A `GlobalOwner` resource will be created and will adopt all resources matching the given `GVK`s provided in the `spec.childResources` field assuming they match the label selector `spec.selector` value.

This example shows how a `GlobalOwner` resource could be used to adopt all `ConfigMaps` that have an `adopt` label specified.

Example `ConfigMap` and a `Secret` resource located in [example/example-resource-set.yaml](./example/example-resource-set.yaml):
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
---
apiVersion: v1
kind: Secret
metadata:
  name: test
  namespace: default
  labels:
    adopt: "true"
data: {}
```

After these resources are applied in the cluster, the ownership reference should be set on the resource.

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
  childResources:
  - apiVersion: v1
    resource: secrets
    namespace: default
    names:
    - test
  - apiVersion: v1
    resource: configmaps
status:
  observedGeneration: 1
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
