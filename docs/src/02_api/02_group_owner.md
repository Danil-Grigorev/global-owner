# Group Owner resource

This is an API specification for the `GroupOwner` resource.

## Resources

This is a list of structures representing the `GroupOwner` resource API.

### `GroupOwner` resource

```go
type GroupOwner struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`

	Spec   GroupOwnerSpec   `json:"spec"`
	Status GroupOwnerStatus `json:"status,omitempty"`
}
```

### `GroupOwner` spec

- [ChildResource](./02_global_owner.md#globalowner-child-resource)

```go
type GroupOwnerSpec struct {
	Selector      *metav1.LabelSelector `json:"selector,omitempty"`
	ChildResource ChildResource         `json:"childResource"`
}
```

### `GroupOwner` status

```go
type GroupOwnerStatus struct {
	OwnedResources     []OwnedResource `json:"ownedResources,omitempty"`
	ObservedGeneration int             `json:"observedGeneration,omitempty"`
}
```

### `OwnedResource`

```go
type OwnedResource struct {
	metav1.TypeMeta `json:",inline"`

	Name      string `json:"name,omitempty"`
	Namespace string `json:"namespace,omitempty"`
}
```