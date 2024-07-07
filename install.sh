#!/bin/sh


install_path=$(python3 -m site --user-site)

pip3 install maturin

cd source/algorithms

cargo test

maturin build --release

pip3 install target/wheels/* --force-reinstall




