FROM alpine:latest

RUN apk add --no-cache python3

WORKDIR /app
COPY app.py .

ENV APP_ENV=docker-container
EXPOSE 8080

CMD ["python3", "app.py", "--serve"]
