local addAdoptRule(child) = {
  local apiGroup = std.split(child.apiVersion, '/')[0],
  local containsSeparator = std.length(apiGroup) == 1,

  apiGroups: [if containsSeparator then apiGroup else ''],
  resources: [child.resource],
  verbs: [
    'get',
    'list',
    'watch',
    'update',
  ],
};

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
          sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/adopt' } },
          customize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/customize' } },
        },
      },
    },
    {
      kind: 'ClusterRole',
      apiVersion: 'rbac.authorization.k8s.io/v1',
      metadata: {
        name: globalowner.metadata.name,
        labels: {
          [bootstrapper.metadata.annotations.aggregationLabel]: 'true',
        },
      },
      rules: std.map(addAdoptRule, globalowner.spec.childResources),
    },
  ],
}
