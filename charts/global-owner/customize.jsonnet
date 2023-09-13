local customize(controller, selector) = [
  c { labelSelector: selector }
  for c in controller
];

function(request) {
  local parent = request.parent,
  local controller = request.controller,
  local relatedResources = customize(controller.spec.childResources, parent.spec.selector),

  relatedResources: relatedResources,
}
