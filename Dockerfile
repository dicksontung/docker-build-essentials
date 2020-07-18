FROM getsentry/sentry-cli as sentry-cli
FROM garethr/kubeval as kubeval-cli
FROM mikefarah/yq as yq-cli
FROM docker:stable

## Install build essentials like `make`
RUN apk update
RUN apk add --virtual build-base

## Install bash
RUN apk add bash

## Install curl & wget
RUN apk add curl
RUN apk add wget
RUN apk add git
RUN apk add jq

## Install aws cli
RUN apk -Uuv add groff less python py-pip python-dev libffi-dev openssl-dev gcc musl-dev
RUN pip install awscli
RUN pip install ansible
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

## Install kubectl
ENV KUBE_LATEST_VERSION="v1.16.2"
ENV HELM_LATEST_VERSION="v2.15.1"

RUN apk add --update ca-certificates \
 && apk add --update -t deps \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator \
 && chmod +x ./usr/local/bin/aws-iam-authenticator \
 && wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
 && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
 && mv linux-amd64/helm /usr/local/bin \
 && apk del --purge deps \
 && rm /var/cache/apk/* \
 && rm helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz

##
RUN wget https://github.com/dicksontung/yaml-extract/raw/master/yaml-extract -O /usr/local/bin/yaml-extract
RUN chmod +x /usr/local/bin/yaml-extract

## Install cloudflare-cli
COPY ./cloudflare-cli.sh /usr/local/bin/cloudflare-cli.sh
RUN chmod +x /usr/local/bin/cloudflare-cli.sh

COPY --from=sentry-cli /bin/sentry-cli /usr/local/bin/sentry-cli
RUN chmod +x /usr/local/bin/sentry-cli

## Install kubeval
COPY --from=kubeval-cli kubeval /usr/local/bin/kubeval

## Install yq
COPY --from=yq-cli /usr/bin/yq /usr/local/bin/yq

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
