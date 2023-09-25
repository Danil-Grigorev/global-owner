local own(child) = {
  kind: child.kind,
  apiVersion: child.apiVersion,
  name: child.metadata.name,
  namespace: child.metadata.namespace,
};

local adopt(obj) = {
  apiVersion: obj.apiVersion,
  kind: obj.kind,
  metadata: obj.metadata,
};

local sync(related) = [
  adopt(obj)
  for group in std.objectValues(related)
  for obj in std.objectValues(group)
];

function(request) {
  local parent = request.parent,
  local children = std.trace(std.toString([r.kind for r in sync(request.related)] + [parent.spec]), sync(request.related)),

  children: children,
  status: { ownedResources: std.map(own, children) },
}
