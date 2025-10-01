MKDOCS_LANG ?= zh
MKDOCS_YML  := mkdocs_$(MKDOCS_LANG).yml

PY_VENV_DIR := .venv
PY_ACTIVATE := $(PY_VENV_DIR)/bin/activate
PY_REQUIREMENTS := tpl/pkg/requirements.txt

serve: | check-venv
	@echo "Starting MkDocs server..."
	. $(PY_ACTIVATE) && mkdocs serve -f $(MKDOCS_YML)

build: | check-venv
	@echo "Building documentation..."
	. $(PY_ACTIVATE) && mkdocs build -f $(MKDOCS_YML)

clean:
	@echo "Deleting documentation..."
	rm -rf site

clean-link:
	@echo "Cleaning up..."
	@for target in $(LINK_TARGET); do \
		if [ -L "$$target/res" ]; then \
			echo "Removing symlink: $$target/res"; \
			rm $$target/res; \
		fi; \
	done

check-venv: $(PY_VENV_DIR)/bin/python

$(PY_VENV_DIR)/bin/python:
	@echo "Creating virtual environment..."
	python3 -m venv $(PY_VENV_DIR)
	@echo "Installing requirements..."
	. $(PY_ACTIVATE) && pip install -r $(PY_REQUIREMENTS)

.PHONY: serve build clean-link check-venv
