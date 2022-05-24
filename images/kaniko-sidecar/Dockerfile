FROM gcr.io/kaniko-project/executor:v1.8.1-debug

COPY kaniko-entrypoint.sh /kaniko/kaniko-entrypoint.sh
WORKDIR /
ENTRYPOINT ["/kaniko/kaniko-entrypoint.sh"]
