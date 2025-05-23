FROM golang:1.24.2-alpine AS builder

LABEL authors="subliker"
LABEL stage=gobuilder

RUN apk update --no-cache && apk add --no-cache tzdata

ENV CGO_ENABLED=0

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -ldflags="-s -w" -o build/app cmd/app/main.go

FROM alpine

WORKDIR /app

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /app/build .

EXPOSE 8080
CMD ["./app"]