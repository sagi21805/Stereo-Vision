#!/bin/sh


install_path=$(python3 -m site --user-site)

pip3 install maturin

maturin build --manifest-path source/algorithms/Cargo.toml --release

pip3 install source/algorithms/target/wheels/* --force-reinstall

pybind11-stubgen algorithms -o $install_path




