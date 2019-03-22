# Terraformer

Use templating for terraform manifest.
Templates use go template syntax and must have `.tf.tpl` extension.

`-f` defines config file, it is mandatory.
`-s` defines secrets extensions if set (optional)

### Files structure

```bash
$ tree .
.
├── backend.tf
├── service-account.json
├── main.tf
├── modules
│   └── sql
│       ├── main.tf.tpl
│       ├── secrets.tf.production.enc
│       └── variables.tf
├── provider.tf
├── sites.yaml
└── variables.tf
```

### Docker

Run `terraformer` with `GOOGLE_APPLICATION_CREDENTIALS`.

```bash
docker run -v ~/.terraform:/root/.terraform -v ~/.terraform.d:/root/.terraform.d -v $(pwd):/app -w /app --rm -e GOOGLE_APPLICATION_CREDENTIALS=/app/service-account.json softonic/terraformer:latest -f sites.yaml -s .production.enc init
```

Run `terraformer` Use gcloud host credentials.

```bash
docker run -v ~/.config:/root/.config -v ~/.terraform:/root/.terraform -v ~/.terraform.d:/root/.terraform.d -v $(pwd):/app -w /app --rm softonic/terraformer:latest -f sites.yaml -s .production.enc init
```

Set alias:
```bash
alias terraformer="docker run -v ~/.config:/root/.config -v ~/.terraform:/root/.terraform -v ~/.terraform.d:/root/.terraform.d -v $(pwd):/app -w /app --rm softonic/terraformer:latest"
```

Use aliased command:
```bash
terraformer -f sites.yaml -s .production.enc init
```

### Templates

`main.tf.tpl` could look like below:

```bash
{{ range (ds "sites").site }}
resource "google_sql_database_instance" "myapp-db-{{ . }}" {
  name = "myapp-db"
  database_version = "MYSQL_5_7"
  region = "europe-west1"

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled = "false"
      private_network = "${var.mynetwork}"
    }
    backup_configuration {
      binary_log_enabled = true
      enabled = true
    }
    user_labels {
      app = "myapp"
    }
  }
}
{{ end }}
```
And `sites.yaml`:

```bash
$ cat sites.yaml
site:
- foo
- bar
```

And then run `terraformer`:

```bash
terraformer -f sites.yaml
```

The manifest applied would be equivalent of the following:

```bash
resource "google_sql_database_instance" "myapp-db-foo" {
  name = "myapp-db"
  database_version = "MYSQL_5_7"
  region = "europe-west1"

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled = "false"
      private_network = "${var.mynetwork}"
    }
    backup_configuration {
      binary_log_enabled = true
      enabled = true
    }
    user_labels {
      app = "myapp"
    }
  }
}

resource "google_sql_database_instance" "myapp-db-bar" {
  name = "myapp-db"
  database_version = "MYSQL_5_7"
  region = "europe-west1"

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled = "false"
      private_network = "${var.mynetwork}"
    }
    backup_configuration {
      binary_log_enabled = true
      enabled = true
    }
    user_labels {
      app = "myapp"
    }
  }
}
```

### Secrets

`main.tf.tpl`

```bash
{{ range (ds "sites").site }}
resource "google_sql_database_instance" "myapp-db-{{ . }}" {
  name = "myapp-db"
  database_version = "MYSQL_5_7"
  region = "europe-west1"

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled = "false"
      private_network = "${var.mynetwork}"
    }
    backup_configuration {
      binary_log_enabled = true
      enabled = true
    }
    user_labels {
      app = "myapp"
    }
  }
}

resource "google_sql_user" "myapp-db-{{ . }}" {
  name     = "${var.{{ . }}_root_user}"
  instance = "${google_sql_database_instance.myapp-db-{{ . }}.name}"
  host     = "%"
  password = "${var.{{ . }}_root_password}"
}
{{ end }}
```

We need to generate an encrypted file. Generate a temporary file: `plain.text.tf`

```bash
variable "foo_root_user" {
    default = "fooroot"
}

variable "foo_root_password" {
    default = "tooroof"
}

variable "bar_root_user" {
    default = "barroot"
}

variable "bar_root_password" {
    default = "toorrab"
}
```

Then we need to encrypt it with a well-known extensions, that we will use later (`secrets.tf.production.enc`):
```bash
sops -e plain.text.tf > secrets.tf.production.enc
```

Then we need to remove the plain text file:
```bash
rm -f plain.text.tf
```

Now we can apply the templating + secrets:

```bash
terraformer -f sites.yaml -s .production.enc
```

### Known issues

Terraformer must initialize the manifest, or at least it must be initialized with a container with the same parameters, as the directory `.terraform` contains symbolic links, and it would change depending how it's mounted.

In the case host `terraform` is already initialized, `terraformer` would not work. In this case, please delete `.terraform` directory and initialize with `terraformer`.
