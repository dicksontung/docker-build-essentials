FROM docker:stable

## Install build essentials like `make`
RUN apk update
RUN apk add --virtual build-base

## Install aws cli
RUN apk -Uuv add groff less python py-pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

## Install kubectl
ENV KUBE_LATEST_VERSION="v1.13.2"

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator \
 && chmod +x ./usr/local/bin/aws-iam-authenticator \
 && apk del --purge deps \
 && rm /var/cache/apk/*

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]

