from setuptools import setup, Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("maxim_fft",
              sources=["maxim_fft.pyx"],
              # libraries=["Numeric"]
              )
]


setup(ext_modules=cythonize(ext_modules, annotate=True))
