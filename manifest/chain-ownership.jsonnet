local originalChild(child) = {
  apiVersion: child.apiVersion,
  resource: child.resource,
};

local defaultSelector = {
  matchExpressions: [
    { key: 'skipAdoption', operator: 'DoesNotExist' },
  ],
};

local groupOwner(globalowner, child, n) = {
  local name = globalowner.metadata.name + '-' + std.split(child.apiVersion, '/')[0] + '-' + child.resource + '-' + n,

  apiVersion: 'globalowner.metacontroller.io/v1alpha1',
  kind: 'GroupOwner',
  metadata: {
    name: name,
  },
  spec: {
    selector: std.get(child, 'selector', std.get(globalowner.spec, 'selector', defaultSelector)),
    childResource: child,
  },
};

local groupOwners(globalowner) = [
  groupOwner(globalowner, globalowner.spec.childResources[index], index + 1)
  for index in std.range(0, std.length(globalowner.spec.childResources) - 1)
];

local ownerReference(child, uid) = {
  apiVersion: child.apiVersion,
  kind: child.kind,
  name: child.metadata.name,
  uid: uid,
  blockOwnerDeletion: true,
};

local withOwnershipChain(children, childrenUIDs) = [
  children[index] {
    local child = children[index],
    local previousChild = children[index - 1],
    local previousChildUid = childrenUIDs[previousChild.metadata.name],
    metadata+: {
      ownerReferences+: [
        ownerReference(previousChild, previousChildUid),
      ],
    },
  }
  for index in std.range(1, std.length(children) - 1)
];

local deduplicate(child) = child.metadata.name;

local childGroups(children) = [
  child
  for group in std.objectValues(children)
  for child in std.objectValues(group)
];

function(request) {
  local groups = groupOwners(request.parent),
  local children = childGroups(request.children),
  local ownersWithUIDs = {
    [group.metadata.name]: group.metadata.uid
    for group in children
  },

  children: if std.length(children) <= 1 || std.length(children) != std.length(groups) then
    // Create a list of GroupOwners to adopt specific types
    groups
  else
    // Apply ownership refrenfce chain on consequent groupOwners
    withOwnershipChain(groups, ownersWithUIDs),
}
