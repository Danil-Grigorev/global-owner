# Configuration

This page describes how to configure the Global Owner resource.

## Helm values

| Parameter | Description | Default |
|-|-|-|
`namespaceOverride` | Namespace override value for installed global owner controller instance | `""` |
`nameOverride` | Name override value for installed global owner controller instance | `""` |
`image` | Jsonnet image to use for controller functionality | `ghcr.io/danil-grigorev/jsonnetd:v0.3.1` |
`aggregationLabel` | ClusterRole aggregation label to provide granular permission scaling to the owned set of resources. Matches the metacontroller `ClusterRole` aggregation label value. | `rbac.metacontroller.k8s.io/aggregate-to-metacontroller` |
