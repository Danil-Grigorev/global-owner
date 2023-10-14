# Global Owner resource

This is an API specification for the `GlobalOwner` resource.

## Resources

This is a list of structures representing the `GlobalOwner` resource API.

### `GlobalOwner`
```go
type GlobalOwner struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`

	Spec   GlobalOwnerSpec   `json:"spec"`
	Status GlobalOwnerStatus `json:"status,omitempty"`
}
```

### `GlobalOwner` spec

```go
type GlobalOwnerSpec struct {

	// Global label selector value. Will be applied to all child resources
	// if resource does not have its own.
	Selector       *metav1.LabelSelector `json:"selector,omitempty"`

	// A list of child resources which global owner should adopt.
	// Each child resource is passed to generated Group Owner object spec.
	//
	// The order of the resources in the list specifies removal ordering,
	// top to bottom.
	ChildResources []ChildResource       `json:"childResources"`
}
```

### `GlobalOwner` resource rule

```go
type ResourceRule struct {

	// Resource api version, for example: v1
	APIVersion string `json:"apiVersion"`

	// Resource plural name, for example: secrets
	Resource   string `json:"resource"`
}
```

### `GlobalOwner` child resource

```go
type ChildResource struct {
	ResourceRule `json:",inline"`

	// A list of unique names for the resources to adopt
	// Mutually exclusive with the selector value.
	Names     []string              `json:"names,omitempty"`

	// A namespace, where the resources should be looked up.
	Namespace string                `json:"namespace,omitempty"`

	// Label selector value for resource group.
	// Mutually exclusive with the names and namespace values.
	// Has precedence on Names/Namespaces if specified.
	Selector  *metav1.LabelSelector `json:"selector,omitempty"`
}
```

### `GlobalOwner` status

```go
type GlobalOwnerStatus struct {
	ObservedGeneration int `json:"observedGeneration,omitempty"`
}
```