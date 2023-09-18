FROM golang:1.20.0 AS build

COPY . /go/src/jsonnetd/
WORKDIR /go/src/jsonnetd/
RUN go mod tidy && go install

FROM debian:stretch-slim
COPY --from=build /go/bin/jsonnetd /jsonnetd/
WORKDIR /jsonnetd
ENTRYPOINT ["/jsonnetd/jsonnetd"]
EXPOSE 8080