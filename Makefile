.PHONY: all binary test image vet lint clean

SRCS = $(shell git ls-files *.go | grep -v vendor)
PKGS = ./core/. ./broker/. ./authz/.

default: binary

all: image
	docker build .

fmt:
	gofmt -w $(SRCS)

vet:
	for pkg in $(PKGS); do go vet $$pkg; done

lint:
	@ go get -v github.com/golang/lint/golint
	for file in $(SRCS); do golint $$file || exit; done

image: test
	docker build -t twistlock/authz-broker .

binary: lint fmt vet
	CGO_ENABLED=0 go build -o authz-broker -a -installsuffix cgo ./broker/main.go

test:  binary
	go test -v ./...

clean:
	rm authz_broker
