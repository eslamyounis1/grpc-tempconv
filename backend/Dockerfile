FROM golang:1.22-alpine AS build

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/server .

FROM alpine:3.20

RUN adduser -D -g '' appuser
WORKDIR /app
COPY --from=build /out/server /app/server

USER appuser
EXPOSE 8080
ENV PORT=8080

ENTRYPOINT ["/app/server"]
