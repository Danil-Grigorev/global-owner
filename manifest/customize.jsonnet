local customize(controller, selector) = [
  std.prune(controller {
    labelSelector: if std.objectHas(controller, 'names') || std.objectHas(controller, 'namespace') then
      {}
    else
      std.get(controller, 'selector', selector),
  } + { selector: null }),
];

function(request) {
  local parent = request.parent,
  local relatedResources = customize(parent.spec.childResource, std.get(parent.spec, 'selector', {})),

  relatedResources: relatedResources,
}
