FROM gcr.io/kaniko-project/executor:v1.9.1-debug

COPY kaniko-entrypoint.sh /kaniko/kaniko-entrypoint.sh
WORKDIR /
ENTRYPOINT ["/kaniko/kaniko-entrypoint.sh"]
