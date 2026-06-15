#!/usr/bin/env python3
"""
Clean up generated.tf to remove problematic null values and empty strings
that cause the New Relic Terraform provider to crash.
"""

import re
import sys

def clean_terraform_file(input_file, output_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # Remove lines that set attributes to null
    # Pattern: any_attribute = null
    content = re.sub(r'^\s+\w+\s*=\s*null\s*$', '', content, flags=re.MULTILINE)

    # Fix values arrays that have empty strings
    # Pattern: values = ["something", ""]
    # Replace with: values = ["something"]
    content = re.sub(r'values\s*=\s*\[(.*?),\s*""\s*\]', r'values = [\1]', content)

    # Remove empty lines (3+ consecutive newlines)
    content = re.sub(r'\n{3,}', '\n\n', content)

    # Write cleaned content
    with open(output_file, 'w') as f:
        f.write(content)

    print(f"✓ Cleaned Terraform configuration written to {output_file}")
    print(f"✓ Removed null values and fixed empty strings in arrays")

if __name__ == "__main__":
    input_file = "generated.tf"
    output_file = "generated_clean.tf"

    try:
        clean_terraform_file(input_file, output_file)
        print(f"\nNext steps:")
        print(f"1. Review the cleaned file: cat {output_file}")
        print(f"2. Replace original: mv {output_file} {input_file}")
        print(f"3. Try deployment again: ./deploy.sh dev apply")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
