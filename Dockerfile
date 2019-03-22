FROM hashicorp/terraform:0.11.13

RUN apk add --upgrade --no-cache gomplate bash

ADD terraformer /usr/local/bin/

ENTRYPOINT ["terraformer"]
