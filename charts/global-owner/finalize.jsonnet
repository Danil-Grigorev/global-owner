local sortByWeight(globalowner) = {
  // Collect a list of resources from childResources
  resource(child): child.resource,
  resources: std.map($.resource, globalowner.spec.childResources),
  // Convert resource kind to plural - ConfigMap -> configmaps
  toResource(obj): std.asciiLower(obj.kind) + 's',
  // Get first (and only) occurence of resource in the childResources
  index(obj): std.find($.toResource(obj), $.resources)[0],
  // Collect the assigned weight of the resource
  item(obj): globalowner.spec.childResources[$.index(obj)],
  key(obj): std.get($.item(obj), 'weight', 0),
  hasWeight(obj): std.objectHas(obj, 'weight'),
};

local resources(related) = [
  related[group][obj]
  for group in std.objectFields(related)
  for obj in std.objectFields(related[group])
];

function(request) {
  local sort = sortByWeight(request.parent),
  local allRelated = resources(request.related),

  // The moment the global owner resource is getting deleted, this will ensure an ordered deletion
  // of the decendants based on specified resource weight in ascending order
  local toRemoveSorted = std.sort(allRelated, sort.key),
  local toRemove = std.slice(toRemoveSorted, std.min(std.length(allRelated), 1), std.length(allRelated), 1),
  local finalized = std.length(std.filter(sort.hasWeight, toRemove)) == 0,

  children: if finalized then allRelated else toRemove,
  // Mark as finalized once all weighted resources are gone.
  finalized: finalized,
}
