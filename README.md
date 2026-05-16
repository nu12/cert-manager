# cert-manager

Self-signed TLS certificates inventory system.

## Generator

Life is too short. Use the generator to quickly create certificates:

```
rails g certificate --country <country> --state <state> --location <location> --organization <org> --organization-unit <unit> --common-name <my.domain.name>
```

Files will be created under `storage/<my.domain.name>`, including root, intermediate and server certificates and their keys.

## Deployment (production)

### Helm

A secret with the following keys is needed, but is not managed by the chart. Create the secret manually with the following command and change the values as needed:

```
cat <<EOF | kubectl apply -n cert-manager -f -
apiVersion: v1
kind: Secret
metadata:
  name: cm
type: Opaque
data:
  SECRET_KEY_BASE: cGxhY2Vob2xkZXIK
  LOCKBOX_MASTER_KEY: cGxhY2Vob2xkZXIK
  MAILER_FROM_ADDRESS: cGxhY2Vob2xkZXIK
  SMTP_ADDRESS: cGxhY2Vob2xkZXIK
  SMTP_PASSWORD: cGxhY2Vob2xkZXIK
  SMTP_PORT: cGxhY2Vob2xkZXIK
  SMTP_USERNAME: cGxhY2Vob2xkZXIK
EOF
```

To deploy the chart:

```
helm upgrade --install cm helm/ -n cert-manager
```

### TLS with Gateway Api

When creating a HTTPS endpoint via the Kubernetes Gateway API, a secret with the certificate and key is needed. Create it with the following command:

```
cat <<EOF | kubectl apply -n cert-manager -f -
apiVersion: v1
kind: Secret
metadata:
  name: cert-manager-tls
type: Opaque
data:
  tls.crt: cGxhY2Vob2xkZXIK
  tls.key: cGxhY2Vob2xkZXIK
EOF
```

## Development

Install gems:

```
bundle install
```

Create the database, migrate and seed for local developpment:

```
rails db:create && rails db:prepare
```

Run the application locally:

```
rails s -b 0.0.0.0
```

Access `localhost:3000`.

## Release a new version

Change the version in `config/application` and run `git tag $(bundle exec rake version | tr -d '"') && git push --tags`.