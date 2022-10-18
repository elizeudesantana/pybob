.PHONY: install format lint test sec

install:
	@poetry install

format:
	@blue .
	@isort .

lint:
	@blue . --check
	@isort . --check
	@prospector --doc-warning

test:
	@pytest -v

sec:
	@pip-audit