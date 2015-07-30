#!/usr/bin/make
PYTHON := /usr/bin/env python

lint:
	@flake8 --exclude hooks/charmhelpers hooks unit_tests tests
	@charm proof

test:
	@# Bundletester expects unit tests here.
	@echo Starting unit tests...
	@$(PYTHON) /usr/bin/nosetests --nologcapture --with-coverage  unit_tests

functional_test:
	@echo Starting Amulet tests...
ifndef AMULET_OS_VIP
	@echo "ERROR: HA tests require AMULET_OS_VIP set to usable vip address"
	@exit 1
endif
	@juju test -v -p AMULET_HTTP_PROXY,AMULET_OS_VIP --timeout 2700

bin/charm_helpers_sync.py:
	@mkdir -p bin
	@bzr cat lp:charm-helpers/tools/charm_helpers_sync/charm_helpers_sync.py \
	> bin/charm_helpers_sync.py

sync: bin/charm_helpers_sync.py
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-hooks.yaml
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-tests.yaml

publish: lint unit_test
	bzr push lp:charms/hacluster
	bzr push lp:charms/trusty/hacluster
