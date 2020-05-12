VERSION = $(shell python ./setup.py --version)
src = $(wildcard tletools/*.py)
dist = dist/TLE-tools-$(VERSION).tar.gz dist/TLE_tools-$(VERSION)-py2.py3-none-any.whl

-include .makerc

.PHONEY: help
help:
	@echo "Targets:"
	@echo "  clean:  Removes distribution folders and artifacts from building"
	@echo "  build:  Builds source and (universal) wheel distributions"
	@echo "  upload: Uploads built source and wheel distributions to devpi"
	@echo "          Requires env var `DEVPI_ROOT_PASSWORD`"

.PHONEY: clean
clean:
	rm -rf wheelhouse dist/ build/ __pycache__/ *.egg-info/ tletools/*.pyc venv .pytest_cache/

.PHONEY: build
build: $(dist)

dist/TLE-tools-%.tar.gz: $(src) setup.py
	python setup.py sdist

dist/TLE_tools-%-py2.py3-none-any.whl: $(src) setup.py
	python setup.py bdist_wheel

.PHONEY: test
test: $(src) setup.py venv
	. venv/bin/activate; pip install .; pytest -v

venv: venv/bin/activate
	virtualenv venv

.PHONEY: upload
upload: test build check-env
	twine upload --repository-url ${REPO} --username ${USER} --password "${PASSWORD}" dist/*

.PHONEY: check-env
check-env:
ifndef REPO
	$(error $REPO must be specified)
endif
ifndef USER
	$(error USER must be specified)
endif
ifndef PASSWORD
	$(error PASSWORD must be specified)
endif
