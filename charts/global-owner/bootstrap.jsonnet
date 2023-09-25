local addAdoptRule(child) = {
  local group = std.split(child.apiVersion, '/'),
  local apiGroup = group[0],
  local containsSeparator = std.length(group) > 1,

  local verbs = [
    'get',
    'list',
    'watch',
    'update',
  ],

  apiGroups: [if containsSeparator then apiGroup else ''],
  resources: [child.resource],
  verbs: verbs,
};

local originalChild(child) = {
  apiVersion: child.apiVersion,
  resource: child.resource,
};

local hooks(bootstrapper) = {
  sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/adopt' } },
  customize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/customize' } },
};

local compositeController(child, index, globalowner, bootstrapper) = {
  apiVersion: bootstrapper.apiVersion,
  kind: 'CompositeController',
  metadata: {
    name: 'group-owner' + '-' + child.resource + '-' + index,
  },
  spec: {
    parentResource: {
      apiVersion: globalowner.apiVersion,
      resource: 'groupowners',
    },
    childResources: [originalChild(child)],
    hooks: hooks(bootstrapper),
  },
};

local infrastructure(globalowner, bootstrapper) = [
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
] + [
  compositeController(globalowner.spec.childResources[n], n, globalowner, bootstrapper)
  for n in std.range(0, std.length(globalowner.spec.childResources) - 1)
];

function(request) {
  local globalowner = request.object,
  local bootstrapper = request.controller,

  // Create a composite controller for every GroupOwner, and a list of GroupOwners to adopt
  // specific type
  attachments: infrastructure(globalowner, bootstrapper),
}
