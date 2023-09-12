function(request) {
  local globalowner = request.object,
  local bootstrapper = request.controller,

  // Create a composite controller for each GlobalOwner, with a list of api types to adopt
  attachments: [
    {
      apiVersion: 'metacontroller.k8s.io/v1alpha1',
      kind: 'CompositeController',
      metadata: {
        name: globalowner.metadata.name,
      },
      spec: {
        parentResource: {
          apiVersion: 'globalowner.metacontroller.io/v1alpha1',
          resource: 'globalowners',
        },
        childResources: globalowner.spec.childResources,
        hooks: {
          sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations['adopter'] + '.metacontroller/sync' } },
          customize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations['adopter'] + '.metacontroller/customize' } },
        },
      },
    },
  ],
}
