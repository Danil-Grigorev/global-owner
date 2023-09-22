local hasWeight(child) = std.objectHas(child, 'weight');

local addAdoptRule(child) = {
  local apiGroup = std.split(child.apiVersion, '/')[0],
  local containsSeparator = std.length(apiGroup) == 1,

  local verbs = [
    'get',
    'list',
    'watch',
    'update',
  ],

  apiGroups: [if containsSeparator then apiGroup else ''],
  resources: [child.resource],
  verbs: if hasWeight(child) then verbs + ['delete'] else verbs,
};

local originalChild(child) = {
  apiVersion: child.apiVersion,
  resource: child.resource,
};

local hooks(bootstrapper) = {
  sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/adopt' } },
  customize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/customize' } },
  finalize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/finalize' } },
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
        childResources: std.map(originalChild, globalowner.spec.childResources),
        hooks: hooks(bootstrapper),
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
