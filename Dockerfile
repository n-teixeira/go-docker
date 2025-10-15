FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 \
    GOOS=linux \
    go build -ldflags="-s -w" -o desafio-1 main.go

FROM scratch

COPY --from=builder /app/desafio-1 /desafio-1

CMD ["/desafio-1"]