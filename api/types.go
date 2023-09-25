/*
 *
 * Copyright 2023.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * /
 */

// +groupName=globalowner.metacontroller.io
package v1alpha1

import (
	metacontrollerv1alpha1 "metacontroller/pkg/apis/metacontroller/v1alpha1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// GlobalOwner
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=globalowners,scope=Cluster
type GlobalOwner struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`

	Spec   GlobalOwnerSpec   `json:"spec"`
	Status GlobalOwnerStatus `json:"status,omitempty"`
}

type GlobalOwnerSpec struct {
	Selector       *metav1.LabelSelector `json:"selector,omitempty"`
	ChildResources []ChildResource       `json:"childResources"`
}

type ChildResource struct {
	metacontrollerv1alpha1.ResourceRule `json:",inline"`

	UpdateStrategy *metacontrollerv1alpha1.CompositeControllerChildUpdateStrategy `json:"updateStrategy,omitempty"`

	Names     []string              `json:"names,omitempty"`
	Namespace string                `json:"namespace,omitempty"`
	Selector  *metav1.LabelSelector `json:"selector,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
type OwnedResource struct {
	metav1.TypeMeta `json:",inline"`

	Name      string `json:"name,omitempty"`
	Namespace string `json:"namespace,omitempty"`
}

type GlobalOwnerStatus struct {
	ObservedGeneration int `json:"observedGeneration,omitempty"`
}

// GroupOwner
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=groupowners,scope=Cluster
type GroupOwner struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`

	Spec   GroupOwnerSpec   `json:"spec"`
	Status GroupOwnerStatus `json:"status,omitempty"`
}

type GroupOwnerSpec struct {
	Selector      *metav1.LabelSelector `json:"selector,omitempty"`
	ChildResource ChildResource         `json:"childResource"`
}

type GroupOwnerStatus struct {
	OwnedResources     []OwnedResource `json:"ownedResources,omitempty"`
	ObservedGeneration int             `json:"observedGeneration,omitempty"`
}
