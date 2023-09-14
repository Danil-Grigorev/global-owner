local owned(children) = [
  {
    kind: child.kind,
    apiVersion: child.apiVersion,
    name: child.metadata.name,
    namespace: child.metadata.namespace,
  }
  for child in children
];

local adopt(obj) = {
  apiVersion: obj.apiVersion,
  kind: obj.kind,
  metadata: obj.metadata,
};

local sync(related) = [
  adopt(related[group][obj])
  for group in std.objectFields(related)
  for obj in std.objectFields(related[group])
];

function(request) {
  local children = sync(request.related),

  children: children,
  status: { ownedResources: owned(children) },
}
