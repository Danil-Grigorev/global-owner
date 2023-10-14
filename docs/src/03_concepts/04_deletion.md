# Deletion

This process specifies how the ordered deletion is handled, when the `GlobalOwner` resource is removed.

## Deletion

*TODO*

## Opt-out
As the resource is adopted using owner reference to the parent object, when the parent object is removed using foreground or background policy, the adopted resource will be removed as well. To opt out of this behavior, the metacontroller instance should be scaled down, the finalizer `metacontroller.io/compositecontroller-<global-owner-name>` should be removed from the resource, and then the `GlobalOwner` resource can be deleted with the `orphan` deletion policy. Adopted resources will stay untouched, however, the `CompositeController` and the `ClusterRole` created by the `GlobalOwner` resource will stay in the cluster, so the permission scope will not be reduced. Those will have to be cleaned up manually.