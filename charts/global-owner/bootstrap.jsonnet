local rules = import 'rules.jsonnet';

local roles() = [{
  resource: 'clusterroles',
  apiVersion: 'rbac.authorization.k8s.io/v1',
}, {
  resource: 'roles',
  apiVersion: 'rbac.authorization.k8s.io/v1',
}, {
  resource: 'rolebindings',
  apiVersion: 'rbac.authorization.k8s.io/v1',
}];

local globalownerResource() = {
  apiVersion: 'globalowner.metacontroller.io/v1alpha1',
  resource: 'globalowners',
};

local prepareRuleSelector(globalowner) = {
  apply(obj): obj {
    labelSelector: globalowner.spec.selector,
  },
};

function(request) {
  local globalowner = request.object,
  local bootstrapper = request.controller,
  local selector = prepareRuleSelector(globalowner),
  local adopter = rules.permitAdoption(globalowner, bootstrapper),

  // Create a composite controller for each GlobalOwner, with a list of api types to adopt
  attachments: [
    {
      apiVersion: 'metacontroller.k8s.io/v1alpha1',
      kind: 'CompositeController',
      metadata: {
        name: globalowner.metadata.name + '-adopt',
      },
      spec: {
        parentResource: globalownerResource(),
        childResources: globalowner.spec.childResources,
        hooks: {
          sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/adopt' } },
          customize: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.adopter + '/customize' } },
        },
      },
    },
    {
      apiVersion: 'metacontroller.k8s.io/v1alpha1',
      kind: 'DecoratorController',
      metadata: {
        name: globalowner.metadata.name + '-bind',
        annotations: bootstrapper.metadata.annotations,
      },
      spec: {
        resources: std.map(selector.apply, globalowner.spec.childResources),
        attachments: roles(),
        hooks: {
          sync: { webhook: { url: 'http://' + bootstrapper.metadata.annotations.binder + '/bind' } },
        },
      },
    },
    adopter.clusterRole(globalowner) {
      rules: [
        adopter.apiGroups(child) + adopter.adoptVerbs() { resources: [child.resource] },
        for child in globalowner.spec.childResources
      ],
    },
  ],
}
