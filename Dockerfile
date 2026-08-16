# ---------------------------------------------------------------------------
# GENERATED FILE — managed by flake-hub (golden-service).
# Do not edit manually: `nix run .#generate` overwrites it.
# To change it, edit repo.nix, or the template in the pack that owns it.
# ---------------------------------------------------------------------------

FROM golang:1.23 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/flake-hub-example-service ./src/cmd/flake-hub-example-service

FROM gcr.io/distroless/static-debian12
COPY --from=build /out/flake-hub-example-service /flake-hub-example-service
EXPOSE 8080
ENTRYPOINT ["/flake-hub-example-service"]
