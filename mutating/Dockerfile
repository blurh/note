FROM golang:1.17.7-alpine3.15 as builder
LABEL version="1.0" description="mutatingBuilder"
WORKDIR /opt/mutating
ADD mutating.go /opt/mutating/
ADD go.mod /opt/mutating
ADD go.sum /opt/mutating
RUN go mod tidy
RUN CGO_ENABLED=0 go build mutating_webhook_server.go -o mutating

FROM alpine:latest
LABEL version="1.0" description="mutatingRunner"
RUN mkdir -p /opt/mutating/tls
COPY --from=builder /opt/mutating/mutating /opt/mutating
WORKDIR /opt/mutating/
ENV TZ Asia/Shanghai
EXPOSE 443
CMD ["/opt/mutating/mutating"]
