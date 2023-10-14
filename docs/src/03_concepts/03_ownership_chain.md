# Ownership chain

This process creates a `GroupOwner` resource per each resource group specified in the parent `GlobalOwner` resource spec.

## Process

The process of setting up ownership chain consists of 2 parts.

When the [bootstrap][] process finishes, each created `CompositeController` is creating a `GroupOwner` resource replica from the parents `GlobalOwner` children resource group.

Each of the created `GroupOwner` resources have a label matching the `CompositeController` [label selector][], for narrowing down the adopted resources to the target `GroupOwner` object. `Secrets` owned by the `Secret` group owner.

Once all of the `GroupOwner` resources are created, the controller is setting ownership references between the `GroupOwner` resources. This (in the best case scenario - see the [issue][]) allows the removal process to fully rely on the kubernetes [garbage collection][] by using foreground cascading deletion finalizer on the `GroupOwner` resource. More in the [design] document.

[bootstrap]: ./02_bootstrap.md
[label selector]: https://metacontroller.github.io/metacontroller/api/compositecontroller.html#parent-resource
[issue]: ../05_design/02_ordered_deletion.md#blockers
[garbage collection]: https://kubernetes.io/docs/concepts/architecture/garbage-collection/#cascading-deletion
[design]: ../05_design/02_ordered_deletion.md#ordered-deletion