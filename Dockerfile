FROM python:3.4-alpine

ARG TAG_VERSION_ARG
ENV TAG_VERSION ${TAG_VERSION_ARG:-1.0.0}

RUN apk update && apk add curl && rm -rf /var/cache/apk/*

ADD application /application
WORKDIR /application
RUN pip install -r requirements.txt

HEALTHCHECK --interval=25s --timeout=10s --retries=3 \
      CMD curl -f http://0.0.0.0:80 || exit 1

CMD ["python", "app.py"]
EXPOSE 80
