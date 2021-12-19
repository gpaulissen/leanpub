## -*- mode: make -*-

GIT = git
PYTHON = python
MYPY = mypy
PIP = $(PYTHON) -m pip
PROJECT = leanpub
SRC = leanpub

.PHONY: clean install test mypy pytest dist distclean tag

help: ## This help.
	@perl -ne 'printf(qq(%-30s  %s\n), $$1, $$2) if (m/^([a-zA-Z_-]+):.*##\s*(.*)$$/)' $(MAKEFILE_LIST)

clean: ## Cleanup output files.
	$(PYTHON) setup.py clean --all
	$(PYTHON) -Bc "import pathlib; [p.unlink() for p in pathlib.Path('.').rglob('*.py[co]')]"
	$(PYTHON) -Bc "import pathlib; [p.rmdir() for p in pathlib.Path('.').rglob('__pycache__')]"
	$(PYTHON) -Bc "import shutil; import os; [shutil.rmtree(d) for d in ['.pytest_cache', '.mypy_cache', 'dist', 'htmlcov', '.coverage'] if os.path.isdir(d)]"
#	cd $(SRC) && $(MAKE) clean

install: clean ## Install the Python (test) requirements.
	$(PIP) install -r requirements.txt
	$(PIP) install -r test_requirements.txt

test: mypy pytest ## Test the software.

mypy: ## Run mypy
	$(MYPY) --show-error-codes src

pytest: ## Run pytest
	$(PYTHON) -m pytest --exitfirst

dist: install test ## Build distribution.
#	cd $(SRC) && $(MAKE) dist

distclean: ## Runs clean first and then cleans up dependency include files. 
#	cd $(SRC) && $(MAKE) distclean

# This is GNU specific I guess
VERSION = $(shell $(PYTHON) setup.py)

TAG = v$(VERSION)

tag:
	$(GIT) tag -a $(TAG) -m "$(TAG)"
	$(GIT) push origin $(TAG)
