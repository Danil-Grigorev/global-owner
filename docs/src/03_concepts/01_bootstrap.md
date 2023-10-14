# Bootstrap

This process involves creating infrastructure resources, bound to the parent `GlobalOwner` object by ownership references, and allowing the child objects to be adopted by the `GlobalOwner` resource later.

## Steps

Bootstrap process is carried by a single `DecoratorController` replica created during installation phase.

The process consists of 2 parts:
1. For each child group in the `GlobalOwner` resource, create a `CompositeController` replica.
2. Create an aggregated `ClusterRole` with permissions required to access every resource from child groups. The rules in this role will aggregate to the `metacontroller` replica installed with the controller.

A `ClusterRole` per each group has only these permissions:
- `get`
- `list`
- `watch`
- `update` - required for the created `CompositeController` to apply ownership reference on the resource.

## Cleanup

Upon removal of the parent `GlobalOwner` resource, every bootstrapped component will be deleted using kubernetes garbage collection. This allows for the aggregated permissions to be scaled down upon removal, as the `ClusterRole` is getting removed.