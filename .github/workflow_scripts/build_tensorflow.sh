#!/bin/bash
# Build script for TensorFlow version of d2l-en
# This script sets up the environment and builds the TensorFlow edition

set -e

echo "=== Starting TensorFlow build ==="

# Activate the conda environment if it exists
if [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo "Using existing conda environment: $CONDA_DEFAULT_ENV"
else
    echo "No conda environment detected, using system Python"
fi

# Install required dependencies
echo "=== Installing dependencies ==="
pip install tensorflow>=2.0.0
pip install d2l
pip install sphinx
pip install sphinxcontrib-svg2pdfconverter
pip install matplotlib
pip install numpy
pip install pandas

# Verify TensorFlow installation
python -c "import tensorflow as tf; print('TensorFlow version:', tf.__version__)"

# Set environment variables for TensorFlow build
export BACKEND=tensorflow
export TF_CPP_MIN_LOG_LEVEL=2  # Suppress TensorFlow C++ logging

# Navigate to the project root
cd "$(dirname "$0")/../.."

echo "=== Building TensorFlow edition ==="

# Check if the tensorflow directory exists
if [ ! -d "tensorflow" ]; then
    echo "Error: tensorflow source directory not found"
    exit 1
fi

# Run the build process
cd tensorflow

# Execute notebook conversion if needed
if command -v jupyter &> /dev/null; then
    echo "Jupyter found, converting notebooks..."
    jupyter nbconvert --to notebook --execute --inplace *.ipynb 2>/dev/null || true
fi

# Build the HTML documentation
echo "=== Building HTML documentation ==="
make html 2>&1 | tee build.log

# Check build status
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Error: HTML build failed. Check build.log for details."
    cat build.log
    exit 1
fi

echo "=== TensorFlow build completed successfully ==="

# Report build artifacts
if [ -d "_build/html" ]; then
    echo "Build output available at: tensorflow/_build/html"
    echo "Number of HTML files: $(find _build/html -name '*.html' | wc -l)"
fi
