# Install Global Owner using Helm

This page describes how to install Global Owner controller using helm.

[[_TOC_]]

## Building the chart from source code

The chart can be built from repository source:

```shell
git clone https://github.com/Danil-Grigorev/global-owner.git
cd global-owner
make release-chart
```

## Installing the chart from package

```shell
helm install globalowner out/package/global-owner-v*.tgz --wait
```

## Installing chart from ghcr.io

Charts are published as [packages on ghcr.io](https://ghcr.io/danil-grigorev/global-owner)

To install it from registry:
```sh
helm install globalowner -n metacontroller --create-namespace oci://ghcr.io/danil-grigorev/global-owner --version=v0.5.1
```
