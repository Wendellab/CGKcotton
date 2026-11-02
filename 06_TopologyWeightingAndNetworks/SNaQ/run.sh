#!/usr/bin/env bash
# Load Julia and R on your cluster before calling this script.
set -euo pipefail
: "${CGK_GENE_TREES:?Set CGK_GENE_TREES to the filtered rooted gene-tree file}"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
julia --project="$script_dir" "$script_dir/run.jl"
