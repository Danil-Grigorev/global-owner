local rules = import 'rules.jsonnet';

// local adopter = prepare(request.controller),
// local adoptRoles = std.map(permitAdoption, globalowner),

// std.map(adopter.addAggregationLabel, adoptRoles)

function(request) {
  local child = request.object,
  local globalowner = request.parent,
  local bootstrapper = request.controller,

  // Create a clusterRole, role and roleBinding for each GlobalOwner child, to permit it's adoption
  local roles = rules.permitAdoption(globalowner, bootstrapper),
  local attachments = if std.length(child.metadata.namespace) > 0 then
    roles.roleWithBinding(child)
  else
    roles.fullClusterRole(child),

  attachments: std.trace('Data:' + std.toString(attachments), attachments),
}
