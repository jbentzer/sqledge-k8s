local params = import 'params.libsonnet';

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: params.name,
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: params.name,
          },
        },
        spec: {
          volumes: [
            {
              name: 'sqldata',
              persistentVolumeClaim: {
                claimName: 'mssql-data',
              },
            },
          ],
          containers: [
            {
              name: 'azuresqledge',
              image: params.image + ':' + params.tag,
              ports: [
                {
                  containerPort: 1433,
                },
              ],
              volumeMounts: [
                {
                  name: 'sqldata',
                  mountPath: '/var/opt/mssql',
                },
              ],
              env: [
                {
                  name: 'MSSQL_PID',
                  value: params.version,
                },
                {
                  name: 'ACCEPT_EULA',
                  value: 'Y',
                },
                {
                  name: 'MSSQL_SA_PASSWORD',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'mssql',
                      key: 'MSSQL_SA_PASSWORD',
                    },
                  },
                },
                {
                  name: 'MSSQL_AGENT_ENABLED',
                  value: 'TRUE',
                },
                {
                  name: 'MSSQL_COLLATION',
                  value: params.collation,
                },
                {
                  name: 'MSSQL_LCID',
                  value: params.lcid,
                },
              ],
            },
          ],
          terminationGracePeriodSeconds: 30,
          securityContext: {
            fsGroup: 10001,
          },
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: params.name,
    },
    spec: {
      selector: {
        app: 'sqledge',
      },
      ports: [
        {
          protocol: 'TCP',
          port: params.port,
          targetPort: 1433,
          name: 'sql',
        },
      ],
      type: params.service_type,
      loadBalancerIP: params.load_balancer_ip,
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: 'mssql',
    },
    stringData: {
      MSSQL_SA_PASSWORD: params.sa_password,
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'mssql-data',
    },
    spec: {
      storageClassName: params.storage_class,
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: params.storage_size,
        },
      },
    },
  },
]