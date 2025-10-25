FROM golang:1.25 AS builder

WORKDIR /root/src/app

COPY go.mod go.sum ./

RUN go mod download

COPY . /root/src/app    

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM  golang:1.25-alpine

# Criar usuário não-root
RUN addgroup -g 1001 -S nonroot && \
    adduser -u 1001 -S nonroot -G nonroot

# Criar diretório da aplicação
WORKDIR /app

# Copiar binário e definir permissões
COPY --from=builder /root/src/app/main ./
RUN chown nonroot:nonroot /app/main

# Mudar para usuário não-root
USER nonroot

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["./main"]