FROM hashicorp/terraform:0.11.14

RUN apk add --upgrade --no-cache gomplate bash &&\
 wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux &&\
 chmod +x sops-3.2.0.linux &&\
 mv sops-3.2.0.linux /usr/local/bin/sops

ADD terraformer /usr/local/bin/

ENTRYPOINT ["terraformer"]
