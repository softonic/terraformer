FROM hashicorp/terraform:0.13.7

ENV SOPS_VERSION=v3.7.1

RUN apk add --upgrade --no-cache gomplate bash &&\
 wget https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux &&\
 chmod +x sops-${SOPS_VERSION}.linux &&\
 mv sops-${SOPS_VERSION}.linux /usr/local/bin/sops

ADD terraformer /usr/local/bin/

ENTRYPOINT ["terraformer"]
