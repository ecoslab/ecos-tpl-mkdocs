MKDOCS_LANG ?= zh
MKDOCS_YML  := mkdocs_$(MKDOCS_LANG).yml

PY_VENV_DIR := .venv
PY_ACTIVATE := $(PY_VENV_DIR)/bin/activate
PY_REQUIREMENTS := tpl/pkg/requirements.txt

serve: | check-env
	@echo "Starting MkDocs server..."
	. $(PY_ACTIVATE) && mkdocs serve -f $(MKDOCS_YML)

build: | check-env
	@echo "Building documentation..."
	. $(PY_ACTIVATE) && mkdocs build -f $(MKDOCS_YML)
	python3 tpl/script/compress_image.py

clean:
	@echo "Deleting documentation..."
	rm -rf site

clean-link:
	@echo "Cleaning up..."
	@for target in $(LINK_TARGETS); do \
		if [ -L "$$target/res" ]; then \
			echo "Removing symlink: $$target/res"; \
			rm $$target/res; \
		fi; \
	done
	@echo "Run 'make clean-repo' to remove res and tpl directories."

check-env: $(PY_VENV_DIR)/bin/python

$(PY_VENV_DIR)/bin/python:
	@echo "Creating virtual environment..."
	python3 -m venv $(PY_VENV_DIR)
	@echo "Installing requirements..."
	. $(PY_ACTIVATE) && pip install -r $(PY_REQUIREMENTS)
	@echo "Installing system dependencies..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "macOS detected, installing dependencies via Homebrew..."; \
		brew install cairo freetype libffi libjpeg libpng zlib pngquant; \
	elif [ "$$(uname)" = "Linux" ] && { command -v apt-get >/dev/null 2>&1 || which apt-get >/dev/null 2>&1; }; then \
		echo "Ubuntu detected, checking sudo privileges..."; \
		if sudo -n true 2>/dev/null; then \
			echo "User has sudo privileges, installing dependencies..."; \
			sudo apt-get install -y libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev pngquant jpegoptim; \
		else \
			echo "Not sudoer, please install dependencies manually:"; \
			exit 1; \
		fi; \
	else \
		echo "Unsupported system, please install dependencies manually."; \
		exit 1; \
	fi

.PHONY: serve build clean-link check-env
