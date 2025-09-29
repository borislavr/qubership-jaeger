{{/* vim: set filetype=mustache: */}}

{{/******************************************************************************************************************/}}
{{/*
Set default value for hotrod ingress host if not specify in Values.
*/}}
{{- define "hotrod.ingress" -}}
  {{- if not .Values.hotrod.ingress.host -}}
      hotrod-{{ .Values.NAMESPACE | default .Release.Namespace }}.{{ .Values.CLOUD_PUBLIC_HOST }}
  {{- else -}}
      {{ .Values.hotrod.ingress.host | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Set default value for query ingress host if not specify in Values.
*/}}
{{- define "query.ingress" -}}
  {{- if not .Values.query.ingress.host -}}
      query-{{ .Values.NAMESPACE | default .Release.Namespace }}.{{ .Values.CLOUD_PUBLIC_HOST }}
  {{- else -}}
      {{ .Values.query.ingress.host | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Set default value for hotrod route host if not specify in Values.
*/}}
{{- define "hotrod.route" -}}
  {{- if not .Values.hotrod.route.host -}}
      hotrod-{{ .Values.NAMESPACE | default .Release.Namespace }}.{{ .Values.CLOUD_PUBLIC_HOST }}
  {{- else -}}
      {{ .Values.hotrod.route.host | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Set default value for query route host if not specify in Values.
*/}}
{{- define "query.route" -}}
  {{- if not .Values.query.route.host -}}
      query-{{ .Values.NAMESPACE | default .Release.Namespace }}.{{ .Values.CLOUD_PUBLIC_HOST }}
  {{- else -}}
      {{ .Values.query.route.host | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Create common labels for each resource which is creating by this chart.
*/}}
{{- define "jaeger.commonLabels" -}}
app: jaeger
app.kubernetes.io/part-of: jaeger
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}

{{/*
Return list of hosts for Ingress.
Support as already existing syntax with only one .host and syntax to specify list of hosts inside one Ingress
*/}}
{{- define "collector.ingress.grpc.rules" -}}
{{- if .Values.collector.ingress.grpc.host -}}
- host: {{ .Values.collector.ingress.grpc.host | quote }}
  http:
    paths: {{ include "collector.ingress.grpc.hostPaths" (list $ .) | nindent 6 }}
{{- end -}}
{{- if .Values.collector.ingress.grpc.hosts -}}
{{- range .Values.collector.ingress.grpc.hosts }}
- host: {{ tpl .host $ | quote }}
  http:
    paths: {{ include "collector.ingress.grpc.hostPaths" (list $ .) | nindent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "collector.ingress.http.rules" -}}
{{- if .Values.collector.ingress.http.host -}}
- host: {{ .Values.collector.ingress.http.host | quote }}
  http:
    paths: {{ include "collector.ingress.http.hostPaths" (list $ .) | nindent 6 }}
{{- end -}}
{{- if .Values.collector.ingress.http.hosts -}}
{{- range .Values.collector.ingress.http.hosts }}
- host: {{ tpl .host $ | quote }}
  http:
    paths: {{ include "collector.ingress.http.hostPaths" (list $ .) | nindent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return list of paths and endpoints for one host
*/}}
{{- define "collector.ingress.grpc.hostPaths" -}}
{{/* Restore the global context in the "$" */}}
{{/* Start render template in the relative content, here .Values.jaeger.collector.ingress.grpc.hosts */}}
{{- $ := index . 0 }}
{{- $defaultServiceName := printf "%s-collector" $.Values.jaeger.serviceName -}}
{{- with index . 0 }}
{{- $pathsToApply := coalesce .paths $.Values.collector.ingress.grpc.defaultPaths -}}
{{- range $pathsToApply }}
- path: {{ .prefix }}
  pathType: Prefix
  backend:
    service:
      name: {{ coalesce .service.name $defaultServiceName }}
      port:
        number: {{ .service.port }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return list of paths and endpoints for one host
*/}}
{{- define "collector.ingress.http.hostPaths" -}}
{{/* Restore the global context in the "$" */}}
{{- $ := index . 0 }}
{{- $defaultServiceName := printf "%s-collector" $.Values.jaeger.serviceName -}}
{{/* Start render template in the relative content, here .Values.jaeger.collector.ingress.http.hosts */}}
{{- with index . 1 }}
{{- $pathsToApply := coalesce .paths $.Values.collector.ingress.http.defaultPaths -}}
{{- range $pathsToApply }}
- path: {{ .prefix }}
  pathType: Prefix
  backend:
    service:
      name: {{ coalesce .service.name $defaultServiceName }}
      port:
        number: {{ .service.port }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Find a collector image in various places.
Image can be found from:
* from default values .Values.collector.image
*/}}
{{- define "collector.image" -}}
  {{- if .Values.collector.image -}}
    {{- printf "%s" .Values.collector.image -}}
  {{- else -}}
    {{- print "jaegertracing/jaeger:2.10.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a jaeger-query image in various places.
Image can be found from:
* from default values .Values.query.image
*/}}
{{- define "query.image" -}}
  {{- if .Values.query.image -}}
    {{- printf "%s" .Values.query.image -}}
  {{- else -}}
    {{- print "jaegertracing/jaeger:2.10.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a envoy image in various places.
Image can be found from:
* from default values .Values.proxy.image
*/}}
{{- define "proxy.image" -}}
  {{- if .Values.proxy.image -}}
    {{- printf "%s" .Values.proxy.image -}}
  {{- else -}}
    {{- print "envoyproxy/envoy:v1.35.2" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a jaeger-cassandra-schema-job image in various places.
Image can be found from:
* from default values .Values.cassandraSchemaJob.image
*/}}
{{- define "cassandra-schema-job.image" -}}
  {{- if .Values.cassandraSchemaJob.image -}}
    {{- printf "%s" .Values.cassandraSchemaJob.image -}}
  {{- else -}}
    {{- print "jaegertracing/jaeger-cassandra-schema:1.73.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a hotrod example image in various places.
Image can be found from:
* from default values .Values.hotrod.image
*/}}
{{- define "hotrod.image" -}}
  {{- if .Values.hotrod.image -}}
    {{- printf "%s" .Values.hotrod.image -}}
  {{- else -}}
    {{- print "jaegertracing/example-hotrod:1.73.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a indexCleaner image in various places.
Image can be found from:
* from default values .Values.elasticsearch.indexCleaner.image
*/}}
{{- define "indexCleaner.image" -}}
  {{- if .Values.elasticsearch.indexCleaner.image -}}
    {{- printf "%s" .Values.elasticsearch.indexCleaner.image -}}
  {{- else -}}
    {{- print "jaegertracing/jaeger-es-index-cleaner:1.73.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a rollover image in various places.
Image can be found from:
* from default values .Values.elasticsearch.rollover.image
*/}}
{{- define "rollover.image" -}}
  {{- if .Values.elasticsearch.rollover.image -}}
    {{- printf "%s" .Values.elasticsearch.rollover.image -}}
  {{- else -}}
    {{- print "jaegertracing/jaeger-es-rollover:1.73.0" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a jaeger-integration-tests image in various places.
Image can be found from:
* from default values .Values.collector.image
*/}}
{{- define "jaeger-integration-tests.image" -}}
  {{- if .Values.integrationTests.image -}}
    {{- printf "%s" .Values.integrationTests.image -}}
  {{- else -}}
    {{- print "ghcr.io/netcracker/jaeger-integration-tests:0.0.8" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a Deployment Status Provisioner image in various places.
*/}}
{{- define "deployment-status-provisioner.image" -}}
  {{- if .Values.statusProvisioner.image -}}
    {{- printf "%s" .Values.statusProvisioner.image -}}
  {{- else -}}
    {{- print "ghcr.io/netcracker/qubership-deployment-status-provisioner:0.2.2" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a readiness-probe image in various places.
*/}}
{{- define "readiness-probe.image" -}}
  {{- if .Values.readinessProbe.image -}}
    {{- printf "%s" .Values.readinessProbe.image -}}
  {{- else -}}
    {{- print "ghcr.io/netcracker/jaeger-readiness-probe:0.0.8" -}}
  {{- end -}}
{{- end -}}

{{/*
Find a Spark Dependencies image in various places.
*/}}
{{- define "spark-dependencies.image" -}}
  {{- if .Values.spark.image -}}
    {{- printf "%s" .Values.spark.image -}}
  {{- else -}}
    {{- print "ghcr.io/jaegertracing/spark-dependencies/spark-dependencies:v0.5.1" -}}
  {{- end -}}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Return name of secret for cassandraSchemaJob.
*/}}
{{- define "cassandraSchemaJob.secretName" -}}
  {{- if .Values.cassandraSchemaJob.existingSecret -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.existingSecret)  -}}
  {{- else -}}
    {{- if .prehook -}}
      {{- print "jaeger-cassandra-pre-hook" -}}
    {{- else -}}
      {{- print "jaeger-cassandra" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return name of secret for cassandraSchemaJob TLS.
*/}}
{{- define "cassandraSchemaJob.tls.secretName" -}}
  {{- if .Values.cassandraSchemaJob.tls.existingSecret -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.tls.existingSecret)  -}}
  {{- else -}}
    {{- if .prehook -}}
      {{- print "jaeger-cassandra-tls-pre-hook" -}}
    {{- else -}}
      {{- print "jaeger-cassandra-tls" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return host for cassandra database.
*/}}
{{- define "cassandraSchemaJob.host" -}}
  {{- if .Values.cassandraSchemaJob.host -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.host) -}}
  {{- else -}}
    {{- if .Values.INFRA_CASSANDRA_HOST -}}
      {{- printf "%s" (.Values.INFRA_CASSANDRA_HOST) -}}
    {{- else -}}
      {{- print "cassandra.cassandra.svc" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return port for cassandra database.
*/}}
{{- define "cassandraSchemaJob.port" -}}
  {{- if .Values.cassandraSchemaJob.port -}}
    {{- printf "%v" (.Values.cassandraSchemaJob.port) -}}
  {{- else -}}
    {{- if .Values.INFRA_CASSANDRA_PORT -}}
      {{- printf "%v" (.Values.INFRA_CASSANDRA_PORT) -}}
    {{- else -}}
      {{- print "9042" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return datacenter for cassandra database.
*/}}
{{- define "cassandraSchemaJob.datacenter" -}}
  {{- if .Values.cassandraSchemaJob.datacenter -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.datacenter) -}}
  {{- else -}}
    {{- if .Values.INFRA_CASSANDRA_DC -}}
      {{- printf "%s" (.Values.INFRA_CASSANDRA_DC) -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return username for cassandra database.
*/}}
{{- define "cassandraSchemaJob.userName" -}}
  {{- if .Values.cassandraSchemaJob.username -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.username) -}}
  {{- else -}}
    {{- if .Values.INFRA_CASSANDRA_USERNAME -}}
      {{- printf "%s" (.Values.INFRA_CASSANDRA_USERNAME) -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return list of allowed authenticators for Cassandra as string joined using comma (,).
Will use the default list of values if user don't specify custom values.
For example: org.apache.cassandra.auth.PasswordAuthenticator,com.instaclustr.cassandra.auth.SharedSecretAuthenticator,...
*/}}
{{- define "cassandraSchemaJob.allowedAuthenticators" -}}
  {{- if .Values.cassandraSchemaJob.allowedAuthenticators -}}
    {{- join "," .Values.cassandraSchemaJob.allowedAuthenticators -}}
  {{- else -}}
    {{- join "," .Values.cassandraSchemaJob.defaultAllowedAuthenticators -}}
  {{- end -}}
{{- end -}}

{{/*
Return password for cassandra database.
*/}}
{{- define "cassandraSchemaJob.password" -}}
  {{- if .Values.cassandraSchemaJob.password -}}
    {{- printf "%s" (.Values.cassandraSchemaJob.password) -}}
  {{- else -}}
    {{- if .Values.INFRA_CASSANDRA_PASSWORD -}}
      {{- printf "%s" (.Values.INFRA_CASSANDRA_PASSWORD) -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return name of secret for OpenSearch/Elasticsearch TLS.
*/}}
{{- define "elasticsearch.tls.secretName" -}}
  {{- if .Values.elasticsearch.client.tls.existingSecret -}}
    {{- printf "%s" (.Values.elasticsearch.client.tls.existingSecret)  -}}
  {{- else -}}
    {{- if .prehook -}}
      {{- printf "%s-es-pre-hook-tls-assets" (.Values.jaeger.serviceName) -}}
    {{- else -}}
      {{- printf "%s-elasticsearch-tls-assets" (.Values.jaeger.serviceName) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return URL for OpenSearch/Elasticsearch.
*/}}
{{- define "elasticsearch.url" -}}
  {{- if .Values.elasticsearch.client.url -}}
    {{- printf "%s://%s" (.Values.elasticsearch.client.scheme) (.Values.elasticsearch.client.url) -}}
  {{- else -}}
    {{- if .Values.INFRA_OPENSEARCH_URL -}}
      {{- printf "%s" .Values.INFRA_OPENSEARCH_URL -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return username for OpenSearch/Elasticsearch.
*/}}
{{- define "elasticsearch.userName" -}}
  {{- if .Values.elasticsearch.client.username -}}
    {{- printf "%s" (.Values.elasticsearch.client.username) -}}
  {{- else -}}
    {{- if .Values.INFRA_OPENSEARCH_USERNAME -}}
      {{- printf "%s" .Values.INFRA_OPENSEARCH_USERNAME -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return password for OpenSearch/Elasticsearch.
*/}}
{{- define "elasticsearch.password" -}}
  {{- if .Values.elasticsearch.client.password -}}
    {{- printf "%s" (.Values.elasticsearch.client.password) -}}
  {{- else -}}
    {{- if .Values.INFRA_OPENSEARCH_PASSWORD -}}
      {{- printf "%s" .Values.INFRA_OPENSEARCH_PASSWORD -}}
    {{- else -}}
      {{- print "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for Cassandra Schema Job Container
*/}}
{{- define "cassandraSchemaJob.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.cassandraSchemaJob.containerSecurityContext -}}
      {{- toYaml .Values.cassandraSchemaJob.containerSecurityContext | nindent 10 }}
    {{- else }}
          allowPrivilegeEscalation: false
          capabilities:
            drop:
              - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.cassandraSchemaJob.containerSecurityContext -}}
      {{- toYaml .Values.cassandraSchemaJob.containerSecurityContext | nindent 10 }}
    {{- else }}
          {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for Collector Container
*/}}
{{- define "collector.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.collector.containerSecurityContext -}}
      {{- toYaml .Values.collector.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.collector.containerSecurityContext -}}
      {{- toYaml .Values.collector.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for integration tests Container
*/}}
{{- define "integrationTests.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.integrationTests.containerSecurityContext -}}
      {{- toYaml .Values.integrationTests.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.integrationTests.containerSecurityContext -}}
      {{- toYaml .Values.integrationTests.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for status provisioner Container
*/}}
{{- define "statusProvisioner.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.statusProvisioner.containerSecurityContext -}}
      {{- toYaml .Values.statusProvisioner.containerSecurityContext | nindent 10 }}
    {{- else }}
          allowPrivilegeEscalation: false
          capabilities:
            drop:
              - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.statusProvisioner.containerSecurityContext -}}
      {{- toYaml .Values.statusProvisioner.containerSecurityContext | nindent 10 }}
    {{- else }}
          {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for Hotrod Container
*/}}
{{- define "hotrod.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.hotrod.containerSecurityContext -}}
      {{- toYaml .Values.hotrod.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.hotrod.containerSecurityContext -}}
      {{- toYaml .Values.hotrod.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for elasticsearch rollover Container
*/}}
{{- define "elasticsearch.rolloverjob.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.elasticsearch.rollover.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.rollover.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end }}
  {{- else -}}
    {{- if .Values.elasticsearch.rollover.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.rollover.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for elasticsearch index cleaner Container
*/}}
{{- define "elasticsearch.indexCleaner.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.elasticsearch.indexCleaner.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.indexCleaner.containerSecurityContext | nindent 14 }}
    {{- else }}
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.elasticsearch.indexCleaner.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.indexCleaner.containerSecurityContext | nindent 14 }}
    {{- else }}
              {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for elasticsearch lookback Container
*/}}
{{- define "elasticsearch.lookback.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.elasticsearch.lookback.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.lookback.containerSecurityContext | nindent 14 }}
    {{- else }}
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.elasticsearch.lookback.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.lookback.containerSecurityContext | nindent 14 }}
    {{- else }}
              {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for elasticsearch rollover Container
*/}}
{{- define "elasticsearch.rollovercronjob.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.elasticsearch.rollover.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.rollover.containerSecurityContext | nindent 14 }}
    {{- else }}
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.elasticsearch.rollover.containerSecurityContext -}}
      {{- toYaml .Values.elasticsearch.rollover.containerSecurityContext | nindent 14 }}
    {{- else }}
              {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for query Container
*/}}
{{- define "query.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.query.containerSecurityContext -}}
      {{- toYaml .Values.query.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.query.containerSecurityContext -}}
      {{- toYaml .Values.query.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for proxy Container
*/}}
{{- define "proxy.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.proxy.containerSecurityContext -}}
      {{- toYaml .Values.proxy.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.proxy.securityContext -}}
            runAsUser: {{ default 2000 .Values.proxy.securityContext.runAsUser }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return securityContext section for ReadinessProbe Container
*/}}
{{- define "readinessProbe.containerSecurityContext" -}}
  {{- if ge .Capabilities.KubeVersion.Minor "25" -}}
    {{- if .Values.readinessProbe.containerSecurityContext -}}
      {{- toYaml .Values.readinessProbe.containerSecurityContext | nindent 12 }}
    {{- else }}
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
    {{- end -}}
  {{- else }}
    {{- if .Values.readinessProbe.containerSecurityContext -}}
      {{- toYaml .Values.readinessProbe.containerSecurityContext | nindent 12 }}
    {{- else }}
            {}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Return securityContext section for cassandraSchemaJob pod
*/}}
{{- define "cassandraSchemaJob.securityContext" -}}
  {{- if .Values.cassandraSchemaJob.securityContext }}
    {{- toYaml .Values.cassandraSchemaJob.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.cassandraSchemaJob.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.cassandraSchemaJob.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.cassandraSchemaJob.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.cassandraSchemaJob.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for collector pod
*/}}
{{- define "collector.securityContext" -}}
  {{- if .Values.collector.securityContext }}
    {{- toYaml .Values.collector.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.collector.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.collector.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.collector.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.collector.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for hotrod pod
*/}}
{{- define "hotrod.securityContext" -}}
  {{- if .Values.hotrod.securityContext }}
    {{- toYaml .Values.hotrod.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.hotrod.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.hotrod.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.hotrod.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.hotrod.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for elasticsearch rollover job
*/}}
{{- define "elasticsearch.rolloverjob.securityContext" -}}
  {{- if .Values.elasticsearch.rollover.securityContext }}
    {{- toYaml .Values.elasticsearch.rollover.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.elasticsearch.rollover.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.elasticsearch.rollover.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.elasticsearch.rollover.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.elasticsearch.rollover.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for elasticsearch rollover cronjob
*/}}
{{- define "elasticsearch.rollovercronjob.securityContext" -}}
  {{- if .Values.elasticsearch.rollover.securityContext }}
    {{- toYaml .Values.elasticsearch.rollover.securityContext | nindent 12 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.elasticsearch.rollover.securityContext.runAsUser }}
            runAsUser: 2000
      {{- end }}
      {{- if not .Values.elasticsearch.rollover.securityContext.fsGroup }}
            fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.elasticsearch.rollover.securityContext.runAsNonRoot | toString) "false") }}
            runAsNonRoot: false
    {{- else }}
            runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.elasticsearch.rollover.securityContext.seccompProfile) }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
            runAsUser: 2000
            fsGroup: 2000
    {{- end }}
            runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for elasticsearch rollover cronjob
*/}}
{{- define "elasticsearch.indexCleaner.securityContext" -}}
  {{- if .Values.elasticsearch.indexCleaner.securityContext }}
    {{- toYaml .Values.elasticsearch.indexCleaner.securityContext | nindent 12 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.elasticsearch.indexCleaner.securityContext.runAsUser }}
            runAsUser: 2000
      {{- end }}
      {{- if not .Values.elasticsearch.indexCleaner.securityContext.fsGroup }}
            fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.elasticsearch.indexCleaner.securityContext.runAsNonRoot | toString) "false") }}
            runAsNonRoot: false
    {{- else }}
            runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.elasticsearch.indexCleaner.securityContext.seccompProfile) }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
            runAsUser: 2000
            fsGroup: 2000
    {{- end }}
            runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for elasticsearch lookback cronjob
*/}}
{{- define "elasticsearch.lookback.securityContext" -}}
  {{- if .Values.elasticsearch.lookback.securityContext }}
    {{- toYaml .Values.elasticsearch.lookback.securityContext | nindent 12 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.elasticsearch.lookback.securityContext.runAsUser }}
            runAsUser: 2000
      {{- end }}
      {{- if not .Values.elasticsearch.lookback.securityContext.fsGroup }}
            fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.elasticsearch.lookback.securityContext.runAsNonRoot | toString) "false") }}
            runAsNonRoot: false
    {{- else }}
            runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.elasticsearch.lookback.securityContext.seccompProfile) }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
            runAsUser: 2000
            fsGroup: 2000
    {{- end }}
            runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
            seccompProfile:
              type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for query
*/}}
{{- define "query.securityContext" -}}
  {{- if .Values.query.securityContext }}
    {{- toYaml .Values.query.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.query.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.query.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.query.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.query.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for integration tests pod
*/}}
{{- define "integrationTests.securityContext" -}}
  {{- if .Values.integrationTests.securityContext }}
    {{- toYaml .Values.integrationTests.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.integrationTests.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.integrationTests.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.integrationTests.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.integrationTests.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return securityContext section for status provisioner pod
*/}}
{{- define "statusProvisioner.securityContext" -}}
  {{- if .Values.statusProvisioner.securityContext }}
    {{- toYaml .Values.statusProvisioner.securityContext | nindent 8 }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
      {{- if not .Values.statusProvisioner.securityContext.runAsUser }}
        runAsUser: 2000
      {{- end }}
      {{- if not .Values.statusProvisioner.securityContext.fsGroup }}
        fsGroup: 2000
      {{- end }}
    {{- end }}
    {{- if (eq (.Values.statusProvisioner.securityContext.runAsNonRoot | toString) "false") }}
        runAsNonRoot: false
    {{- else }}
        runAsNonRoot: true
    {{- end }}
    {{- if and (ge .Capabilities.KubeVersion.Minor "25") (not .Values.statusProvisioner.securityContext.seccompProfile) }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- else }}
    {{- if not (.Capabilities.APIVersions.Has "apps.openshift.io/v1") }}
        runAsUser: 2000
        fsGroup: 2000
    {{- end }}
        runAsNonRoot: true
    {{- if ge .Capabilities.KubeVersion.Minor "25" }}
        seccompProfile:
          type: "RuntimeDefault"
    {{- end }}
  {{- end }}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Calculates resources that should be monitored during deployment by Deployment Status Provisioner.
*/}}
{{- define "jaeger.monitoredResources" -}}
    {{- if .Values.collector.install }}
        {{- printf "Deployment %s-collector, " .Values.jaeger.serviceName -}}
    {{- end }}
    {{- if .Values.query.install }}
        {{- printf "Deployment %s-query, " .Values.jaeger.serviceName -}}
    {{- end }}
    {{- if .Values.hotrod.install }}
        {{- printf "Deployment %s-hotrod, " .Values.jaeger.serviceName -}}
    {{- end }}
    {{- if .Values.integrationTests.install }}
        {{- printf "Deployment %s, " .Values.integrationTests.service.name -}}
    {{- end }}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Prepare args for readiness-probe container.
*/}}
{{- define "readinessProbe.args" -}}
  {{- if .Values.readinessProbe.args }}
    {{- range .Values.readinessProbe.args }}
            - {{ . | quote }}
      {{- end }}
  {{- else }}
            - "-namespace={{ .Values.NAMESPACE | default .Release.Namespace }}"
    {{- if eq .Values.jaeger.storage.type "cassandra" }}
            - "-storage=cassandra"
            - "-authSecretName=jaeger-cassandra"
            - "-datacenter={{ include "cassandraSchemaJob.datacenter" . }}"
      {{- if .Values.cassandraSchemaJob.keyspace }}
            - "-keyspace={{ .Values.cassandraSchemaJob.keyspace }}"
      {{- end }}
            - "-host={{ include "cassandraSchemaJob.host" . }}"
            - "-port={{ include "cassandraSchemaJob.port" . }}"
      {{- if .Values.cassandraSchemaJob.tls.enabled }}
            - "-tlsEnabled=true"
        {{- if .Values.cassandraSchemaJob.tls.insecureSkipVerify }}
            - "-insecureSkipVerify=true"
        {{- else }}
            - "-caPath=/cassandra-tls/ca-cert.pem"
            - "-crtPath=/cassandra-tls/client-cert.pem"
            - "-keyPath=/cassandra-tls/client-key.pem"
        {{- end }}
      {{- end }}
    {{- else }}
            - "-storage=opensearch"
            - "-host={{ include "elasticsearch.url" . }}"
            - "-authSecretName=jaeger-elasticsearch"
      {{- if .Values.elasticsearch.client.tls.enabled }}
            - "-tlsEnabled=true"
        {{- if .Values.elasticsearch.client.tls.insecureSkipVerify }}
            - "-insecureSkipVerify=true"
        {{- else }}
            - "-caPath=/es-tls/ca-cert.pem"
            - "-crtPath=/es-tls/client-cert.pem"
            - "-keyPath=/es-tls/client-key.pem"
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Generate list of args for collector
*/}}
{{- define "collector.args" -}}
    {{- if .Values.collector.args }}
        {{- range .Values.collector.args }}
            - {{ . | quote }}
        {{- end }}
    {{- else }}
            - "--config=/conf/config.yaml"
    {{- end }}
{{- end -}}

{{/*
Generate certificate volumes for TLS configuration
*/}}
{{- define "jaeger.certificateVolumes" -}}
{{- if .Values.cassandraSchemaJob.tls.enabled }}
- name: "cassandra-tls-assets"
  projected:
    sources:
    - secret:
        name: {{ template "cassandraSchemaJob.tls.secretName" . }}
        items:
        - key: ca-cert.pem
          path: ca-cert.pem
        - key: client-cert.pem
          path: client-cert.pem
        - key: client-key.pem
          path: client-key.pem
{{- end }}
{{- if and .Values.elasticsearch.client.tls.enabled (not .Values.elasticsearch.client.tls.insecureSkipVerify) }}
- name: "es-tls-assets"
  projected:
    sources:
    - secret:
        name: {{ template "elasticsearch.tls.secretName" . }}
        items:
        - key: ca-cert.pem
          path: ca-cert.pem
        - key: client-cert.pem
          path: client-cert.pem
        - key: client-key.pem
          path: client-key.pem
{{- end }}
{{- if and .Values.remotegRPC.tls.enabled (not .Values.remotegRPC.tls.insecureSkipVerify) }}
- name: "grpc-tls-assets"
  projected:
    sources:
    - secret:
        name: {{ if .Values.remotegRPC.existingSecret }}{{ .Values.remotegRPC.existingSecret }}{{ else }}{{ default "jaeger-remotegrpc-tls-assets" .Values.collector.tlsConfig.newSecretName }}{{- end -}}
        items:
        - key: ca-cert.pem
          path: ca-cert.pem
        - key: client-cert.pem
          path: client-cert.pem
        - key: client-key.pem
          path: client-key.pem
{{- end }}
{{- if or .Values.collector.tlsConfig.otelHttp.enabled
        .Values.collector.tlsConfig.otelgRPC.enabled
        .Values.collector.tlsConfig.jaegerHttp.enabled
        .Values.collector.tlsConfig.jaegergRPC.enabled
        .Values.collector.tlsConfig.zipkin.enabled }}
- name: "http-tls-secret"
  projected:
    sources:
    - secret:
        name: {{ if .Values.collector.tlsConfig.existingSecret }}{{ .Values.collector.tlsConfig.existingSecret }}{{ else }}{{ default "jaeger-collector-tls-secret" .Values.collector.tlsConfig.newSecretName }}{{ end }}
        items:
        - key: ca.crt
          path: ca.crt
        - key: tls.crt
          path: tls.crt
        - key: tls.key
          path: tls.key
{{- end }}
{{- end -}}

{{/*
Generate certificate volume mounts for TLS configuration
*/}}
{{- define "jaeger.certificateVolumeMounts" -}}
{{- if .Values.cassandraSchemaJob.tls.enabled }}
- name: "cassandra-tls-assets"
  mountPath: "/cassandra-tls"
  readOnly: true
{{- end }}
{{- if and .Values.elasticsearch.client.tls.enabled (not .Values.elasticsearch.client.tls.insecureSkipVerify) }}
- name: "es-tls-assets"
  mountPath: "/es-tls"
  readOnly: true
{{- end }}
{{- if and .Values.remotegRPC.tls.enabled (not .Values.remotegRPC.tls.insecureSkipVerify) }}
- name: "grpc-tls-assets"
  mountPath: "/grpc-tls"
  readOnly: true
{{- end }}
{{- if or .Values.collector.tlsConfig.otelHttp.enabled
        .Values.collector.tlsConfig.otelgRPC.enabled
        .Values.collector.tlsConfig.jaegerHttp.enabled
        .Values.collector.tlsConfig.jaegergRPC.enabled
        .Values.collector.tlsConfig.zipkin.enabled }}
- name: "http-tls-secret"
  mountPath: "/http-tls"
  readOnly: true
{{- end }}
{{- end -}}

{{/*
Generate certificate volumes for OpenSearch jobs TLS configuration
*/}}
{{- define "jaeger.opensearchCertificateVolumes" -}}
{{- if and .Values.elasticsearch.client.tls.enabled (not .Values.elasticsearch.client.tls.insecureSkipVerify) }}
- name: "es-tls-assets"
  projected:
    sources:
    - secret:
        name: {{ template "elasticsearch.tls.secretName" . }}
        items:
        - key: ca-cert.pem
          path: ca-cert.pem
        - key: client-cert.pem
          path: client-cert.pem
        - key: client-key.pem
          path: client-key.pem
{{- end }}
{{- end -}}

{{/*
Generate certificate volume mounts for OpenSearch jobs TLS configuration
*/}}
{{- define "jaeger.opensearchCertificateVolumeMounts" -}}
{{- if and .Values.elasticsearch.client.tls.enabled (not .Values.elasticsearch.client.tls.insecureSkipVerify) }}
- name: "es-tls-assets"
  mountPath: "/es-tls"
  readOnly: true
{{- end }}
{{- end -}}

{{/*
Generate certificate volumes for Cassandra schema job TLS configuration
*/}}
{{- define "jaeger.cassandraCertificateVolumes" -}}
{{- if .Values.cassandraSchemaJob.tls.enabled }}
- name: "cassandra-tls-assets"
  projected:
    sources:
    - secret:
        name: {{ template "cassandraSchemaJob.tls.secretName" . }}
        items:
        - key: ca-cert.pem
          path: ca-cert.pem
        - key: client-cert.pem
          path: client-cert.pem
        - key: client-key.pem
          path: client-key.pem
        - key: cqlshrc
          path: cqlshrc
{{- end }}
{{- end -}}

{{/*
Generate certificate volume mounts for Cassandra schema job TLS configuration
*/}}
{{- define "jaeger.cassandraCertificateVolumeMounts" -}}
{{- if .Values.cassandraSchemaJob.tls.enabled }}
- name: "cassandra-tls-assets"
  mountPath: "/cassandra-tls"
  readOnly: true
{{- end }}
{{- end -}}

{{/******************************************************************************************************************/}}

{{/*
Generate list of images for tests
*/}}
{{- define "jaeger.monitoredImages" -}}
    {{- if .Values.collector.install -}}
      {{- printf "deployment %s-collector %s %s, " .Values.jaeger.serviceName .Values.collector.name "jaegertracing/jaeger:2.9.0" -}}
      {{- if .Values.readinessProbe.install }}
        {{- printf "deployment %s-collector readiness-probe %s, " .Values.jaeger.serviceName "qubership/jaeger-readiness-probe:0.24.0" -}}
      {{- end -}}
    {{- end -}}
    {{- if .Values.query.install -}}
      {{- printf "deployment %s-query jaeger-query %s, " .Values.jaeger.serviceName "jaegertracing/jaeger:2.9.0" -}}
      {{- if .Values.readinessProbe.install }}
        {{- printf "deployment %s-query readiness-probe %s, " .Values.jaeger.serviceName "qubership/jaeger-readiness-probe:0.24.0" -}}
      {{- end -}}
      {{- if .Values.proxy.install }}
        {{- printf "deployment %s-query proxy %s, " .Values.jaeger.serviceName "envoyproxy/envoy:v1.30.7" -}}
      {{- end -}}
    {{- end -}}
    {{- if .Values.hotrod.install -}}
      {{- printf "deployment %s-hotrod %s %s, " .Values.jaeger.serviceName .Values.hotrod.name "jaegertracing/example-hotrod:1.72.0" -}}
    {{- end -}}
    {{- if .Values.integrationTests.install -}}
      {{- printf "deployment %s %s %s, " .Values.integrationTests.service.name .Values.integrationTests.service.name "qubership/integration-tests" -}}
    {{- end -}}
{{- end -}}

{{/*
Generate custom resource path for integration tests
This path built as "apps/v1/<namespace_name>/deployments/<deployment_name>"
*/}}
{{- define "integrationTests.customResourcePath" -}}
  {{- if .Values.integrationTests.statusWriting.customResourcePath -}}
    {{- .Values.integrationTests.statusWriting.customResourcePath -}}
  {{- else -}}
    {{- printf "apps/v1/%s/deployments/%s" .Release.Namespace .Values.integrationTests.service.name -}}
  {{- end -}}
{{- end -}}
