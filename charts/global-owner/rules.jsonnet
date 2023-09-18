{
  permitAdoption(globalowner, bootstrapper): {
    local this = self,
    serviceAccount: {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: bootstrapper.metadata.annotations.serviceAccount,
        namespace: bootstrapper.metadata.annotations.serviceAccountNamespace,
      },
    },
    apiGroup(obj): {
      local apiGroup = std.split(obj.apiVersion, '/')[0],
      local containsSeparator = std.length(apiGroup) == 1,

      apiGroup: if containsSeparator then apiGroup else '',
    },
    apiGroups(obj): { apiGroups: [this.apiGroup(obj).apiGroup] },
    resources(obj): { resources: [std.asciiLower(obj.kind) + 's'] },
    adoptVerbs(): { verbs+: ['get', 'list', 'watch'] },
    updateVerbs(): { verbs+: ['update'] },
    adoptRule(obj): this.apiGroups(obj) + this.resources(obj) + this.adoptVerbs(),
    updateRule(obj): this.apiGroups(obj) + this.resources(obj) + this.updateVerbs(),
    adoptRuleOwner(child): this.apiGroups(child) + this.adoptVerbs() { resources: [child.resource] },
    adoptRules(obj): { rules+: [this.adoptRule(obj)] },
    updateRules(obj): { rules+: [this.updateRule(obj)] },
    namespace(obj): if std.length(obj.metadata.namespace) > 0 then {
      namespace: obj.metadata.namespace,
    } else {},
    subject(obj): this.apiGroup(obj) {
      kind: obj.kind,
      name: obj.metadata.name,
    },
    role(child): this.updateRules(child) {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'Role',
      metadata: {
        name: child.metadata.name + '-owner',
        namespace: child.metadata.namespace,
      },
    },
    roleBinding(child): {
      local clusterRole = this.clusterRole(child),
      local role = this.role(child),

      kind: 'RoleBinding',
      apiVersion: 'rbac.authorization.k8s.io/v1',
      metadata: {
        name: child.metadata.name + '-owner-binding',
        namespace: child.metadata.namespace,
        labels: std.get(child, 'labels', {}),
      },
      roleRef: this.subject(role),
      subjects: [this.subject(this.serviceAccount) + this.namespace(this.serviceAccount)],
    },
    clusterRole(obj): {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRole',
      metadata: {
        name: obj.metadata.name + '-owner',
        labels: std.get(obj, 'labels', {}) { [bootstrapper.metadata.annotations.aggregationLabel]: 'true' },
      },
    },
    roleWithBinding(child): [this.role(child), this.roleBinding(child)],
    fullClusterRole(child): [this.clusterRole(child) + this.updateRules(child)],
  },
}
