FROM golang:1.22-bookworm AS builder

WORKDIR /app

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /hello .

FROM debian:trixie-slim

COPY --from=builder /hello /hello

ENTRYPOINT ["/hello"]