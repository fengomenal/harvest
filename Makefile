VERSION = ${shell cat VERSION}

build:
	docker build -t harvest:$(VERSION) .
