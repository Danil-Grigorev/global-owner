# Installation

This page describes how to install Global Owner resource controller using kustomize.

### Prerequisites

* Install [Metacontroller](https://github.com/metacontroller/metacontroller)

### Deploy the controller

```sh
kubectl apply -k https://github.com/danil-grigorev/global-owner/v1
```

or locally from the cloned repo:
```sh
kubectl apply -k v1
```