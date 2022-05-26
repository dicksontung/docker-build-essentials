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
RUN apk -Uuv add groff less py-pip libffi-dev openssl-dev gcc musl-dev
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

## Install kubectl
ENV KUBE_LATEST_VERSION="v1.24.0"

RUN apk add --update ca-certificates \
 && apk add --update -t deps \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && curl -o /usr/local/bin/aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
 && chmod +x ./usr/local/bin/aws-iam-authenticator \
 && apk del --purge deps \
 && rm /var/cache/apk/*

##
RUN wget https://github.com/dicksontung/yaml-extract/raw/master/yaml-extract -O /usr/local/bin/yaml-extract
RUN chmod +x /usr/local/bin/yaml-extract

COPY --from=sentry-cli /bin/sentry-cli /usr/local/bin/sentry-cli
RUN chmod +x /usr/local/bin/sentry-cli

## Install kubeval
COPY --from=kubeval-cli kubeval /usr/local/bin/kubeval

## Install yq
COPY --from=yq-cli /usr/bin/yq /usr/local/bin/yq

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
