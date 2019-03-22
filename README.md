# Terraformer

Use templating for terraform manifest.
Templates use go template syntax and must have `.tf.tpl` extension.

`-f` defines config file, it is mandatory.
`-s` defines secrets extensions if set (optional)

```bash
$ tree .
.
├── backend.tf
├── service-account.json
├── main.tf
├── modules
│   └── sql
│       ├── main.tf
│       ├── secrets.tf.production.enc
│       └── variables.tf
├── provider.tf
├── sites.yaml
└── variables.tf
```

### Examples

Use gcloud service account.

```bash
$ cat sites.yaml
site:
- foo
- bar

docker run -v ~/.terraform:/root/.terraform -v ~/.terraform.d:/root/.terraform.d -v $(pwd):/app -w /app --rm -e GOOGLE_APPLICATION_CREDENTIALS=/app/service-account.json softonic/terraformer:edge -f sites.yaml -s .production.enc init
```

Use gcloud host credentials.

```bash
$ cat sites.yaml
site:
- foo
- bar

docker run -v ~/.config:/root/.config -v ~/.terraform:/root/.terraform -v ~/.terraform.d:/root/.terraform.d -v $(pwd):/app -w /app --rm softonic/terraformer:edge -f sites.yaml -s .production.enc init
```


### Known issues

Terraformer must initialize the manifest, or at least it must be initialized with a container with the same parameters, as the directory `.terraform` contains symbolic links, and it would change depending how it's mounted.

In the case host `terraform` is already initialized, `terraformer` would not work. In this case, please delete `.terraform` directory and initialize with `terraformer`.
