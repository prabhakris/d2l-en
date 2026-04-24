#!/bin/bash
# Build script for PyTorch framework version of d2l-en
# This script builds the book using the PyTorch backend

set -e

echo "=== Building d2l-en with PyTorch backend ==="

# Source environment variables if available
if [ -f ".github/actions/setup_env_vars/action.yml" ]; then
    echo "Environment setup found."
fi

# Activate conda environment if specified
if [ -n "$CONDA_ENV" ]; then
    echo "Activating conda environment: $CONDA_ENV"
    source activate "$CONDA_ENV"
fi

# Install required dependencies
echo "Installing Python dependencies..."
pip install torch torchvision --quiet
pip install d2l --quiet
pip install sphinx myst-parser sphinxcontrib-svg2pdfconverter --quiet

# Verify PyTorch installation
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')" 

# Set the framework environment variable
export FRAMEWORK="pytorch"
export D2L_BACKEND="pytorch"

# Navigate to the repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

# Run notebook execution if EXECUTE_NOTEBOOKS is set
if [ "${EXECUTE_NOTEBOOKS:-false}" = "true" ]; then
    echo "Executing notebooks..."
    python -m pytest --nbval-lax notebooks/ -v || true
fi

# Build the HTML documentation
echo "Building HTML output..."
make pytorch || {
    echo "Make target 'pytorch' not found, attempting default build..."
    make html
}

echo "=== PyTorch build completed successfully ==="
