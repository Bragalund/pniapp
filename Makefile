.PHONY: all test shellcheck deps setup

all: setup

test:
	./pniap --selftest

shellcheck:
	shellcheck pniap

deps:
	sudo apt update
	sudo apt install -y git p7zip-full shellcheck

setup: deps
	chmod +x pniap
	./pniap --help
