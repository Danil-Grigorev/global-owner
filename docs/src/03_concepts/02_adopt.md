# Adopt

This process involves listing and watching resource groups specified under the `ChildResources` field in the `GlobalOwner` resource, and setting ownership references on each observed resource, using metacontroller [adoption rules][].

[adoption rules]: https://metacontroller.github.io/metacontroller/api/compositecontroller.html?highlight=adopt#label-selector

## Process

Using collected objects from the `related` list collected using the [customize hook][] semantics, an adopt `CompositeController` is setting a list of `children` resources in the [sync hook response][] matching the `namespace` and `name` of each related resource. Returned list of `children` may look like:

```json
[
    {
        "kind": "Secret",
        "apiVersion": "v1",
        "name": "owned-secret",
        "namespace": "default",
    }, {
        "kind": "ConfigMap",
        "apiVersion": "v1",
        "name": "owned-config-map",
        "namespace": "default",
    },
]
```

As every object in the list is already created in the cluster, the only change the `metacontroller` replica will do, is to apply the ownership references on the object, pointing to the parent `GroupOwner` resource instance.

[customize hook]: https://metacontroller.github.io/metacontroller/api/customize.html#customize-hook-response
[sync hook response]: https://metacontroller.github.io/metacontroller/api/compositecontroller.html#sync-hook-response

## Cleanup

Upon removal of the parent `GlobalOwner` resource, each `GroupOwner` resource and subsequentially all adopted resources will be removed in the order specified by the `ChildResources` content. Resource groups will be removed from top to bottom of the list.