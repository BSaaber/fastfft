.PHONY: build dist redist install install-from-source clean uninstall

build:
	CYTHONIZE=1 python3 setup.py build

dist:
	CYTHONIZE=1 python3 setup.py sdist bdist_wheel

push_pypi:
	python3 -m twine upload --repository pypi dist/*

redist: clean dist

install:
	CYTHONIZE=1 pip install .

install-from-source: dist
	pip install dist/fastfft-0.1.8.tar.gz

clean:
	$(RM) -r build dist src/*.egg-info
	$(RM) -r src/fft2/main.cpp
	$(RM) -r .pytest_cache
	find . -name __pycache__ -exec rm -r {} +

uninstall:
	pip uninstall fastfft