#!/bin/bash

# Script to generate charts names and versions in README.md
# This script reads the index.yaml file and updates the README.md with available charts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
INDEX_FILE="$REPO_ROOT/index.yaml"
README_FILE="$REPO_ROOT/README.md"

# Check if required tools are available
if ! command -v yq &> /dev/null; then
    echo "Error: yq is required but not installed. Please install yq first."
    echo "You can install it with: brew install yq"
    exit 1
fi

if [ ! -f "$INDEX_FILE" ]; then
    echo "Error: index.yaml not found at $INDEX_FILE"
    exit 1
fi

# Create a temporary file for the new README content
TEMP_README=$(mktemp)

# Function to generate charts section
generate_charts_section() {
    echo "## Available Charts"
    echo ""
    echo "The following charts are available in this repository:"
    echo ""

    # Create table header
    echo "| Chart Name | Latest Version | All Versions |"
    echo "|------------|----------------|--------------|"

    # Extract chart names and their latest versions from index.yaml
    chart_names=$(yq eval '.entries | keys | .[]' "$INDEX_FILE")

    for chart_name in $chart_names; do
        # Get the latest version (first entry in the array)
        latest_version=$(yq eval ".entries.\"$chart_name\"[0].version" "$INDEX_FILE")

        # Get all available versions
        versions=$(yq eval ".entries.\"$chart_name\"[].version" "$INDEX_FILE")

        # Format versions as comma-separated list
        versions_list=$(echo "$versions" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')

        # Create table row
        echo "| $chart_name | $latest_version | $versions_list |"
    done

    echo ""
}

# Read the existing README and replace the charts section
{
    # Copy everything before the charts section (if it exists)
    if grep -q "## Available Charts" "$README_FILE"; then
        sed '/## Available Charts/,$d' "$README_FILE"
    else
        cat "$README_FILE"
    fi

    # Add the new charts section
    generate_charts_section

} > "$TEMP_README"

# Replace the original README with the new content
mv "$TEMP_README" "$README_FILE"

echo "Successfully updated README.md with charts information"
echo "Charts section has been generated from index.yaml"
