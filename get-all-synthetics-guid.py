import requests
import json
import os

# --- CONFIGURATION ---
# SECURITY: Never commit your actual API key to version control!
# Set via environment variable: export NEW_RELIC_API_KEY="your-key-here"
NEW_RELIC_API_KEY = os.environ.get("NEW_RELIC_API_KEY", "YOUR_API_KEY_HERE")
ACCOUNT_ID = int(os.environ.get("NEW_RELIC_ACCOUNT_ID", "0000000"))
API_URL = "https://api.eu.newrelic.com/graphql"  # Use https://api.newrelic.com/graphql for US region
# ---------------------

headers = {
    "Content-Type": "application/json",
    "API-Key": NEW_RELIC_API_KEY
}

# NerdGraph query using entity search for synthetic monitors
query = """
query($cursor: String) {
  actor {
    entitySearch(query: "domain = 'SYNTH' AND type = 'MONITOR'") {
      results(cursor: $cursor) {
        nextCursor
        entities {
          guid
          name
          ... on SyntheticMonitorEntityOutline {
            monitorType
          }
        }
      }
    }
  }
}
"""

def fetch_all_monitors():
    monitors = []
    cursor = None
    has_next = True

    print("Fetching Synthetic monitors from New Relic...")

    while has_next:
        variables = {
            "cursor": cursor
        }

        response = requests.post(API_URL, headers=headers, json={"query": query, "variables": variables})

        if response.status_code != 200:
            raise Exception(f"Query failed with status code {response.status_code}: {response.text}")

        result = response.json()

        # Check for GraphQL errors
        if "errors" in result:
            raise Exception(f"GraphQL Errors: {result['errors']}")

        search_results = result["data"]["actor"]["entitySearch"]["results"]

        # Append current page of monitors
        for entity in search_results["entities"]:
            monitor_info = {
                "guid": entity["guid"],
                "name": entity["name"],
                "type": entity.get("monitorType", "UNKNOWN")
            }
            monitors.append(monitor_info)

        # Update cursor pagination
        cursor = search_results.get("nextCursor")
        has_next = cursor is not None

    return monitors

def get_terraform_resource_type(monitor_type):
    """Map New Relic monitor type to Terraform resource type"""
    type_mapping = {
        'SIMPLE': 'newrelic_synthetics_monitor',
        'BROWSER': 'newrelic_synthetics_monitor',
        'SCRIPT_API': 'newrelic_synthetics_script_monitor',
        'SCRIPT_BROWSER': 'newrelic_synthetics_script_monitor',
        'STEP_MONITOR': 'newrelic_synthetics_step_monitor'
    }
    return type_mapping.get(monitor_type, 'newrelic_synthetics_monitor')

def generate_terraform_import_blocks(monitors):
    """Generate Terraform import blocks for each monitor"""
    import_blocks = []

    for monitor in monitors:
        # Sanitize the name for use as a Terraform resource identifier
        resource_name = monitor['name'].lower()
        resource_name = resource_name.replace(' ', '_').replace('-', '_').replace('.', '_')
        # Remove any non-alphanumeric characters except underscore
        resource_name = ''.join(c for c in resource_name if c.isalnum() or c == '_')

        # Get the correct Terraform resource type
        resource_type = get_terraform_resource_type(monitor['type'])

        import_block = f"""
import {{
  to = {resource_type}.{resource_name}
  id = "{monitor['guid']}"
}}
"""
        import_blocks.append(import_block)

    return '\n'.join(import_blocks)

def generate_terraform_resources(monitors):
    """Generate empty Terraform resource blocks for each monitor"""
    resource_blocks = []

    for monitor in monitors:
        resource_name = monitor['name'].lower()
        resource_name = resource_name.replace(' ', '_').replace('-', '_').replace('.', '_')
        resource_name = ''.join(c for c in resource_name if c.isalnum() or c == '_')

        # Get the correct Terraform resource type
        resource_type = get_terraform_resource_type(monitor['type'])

        resource_block = f"""
resource "{resource_type}" "{resource_name}" {{
  # Configuration will be populated after import
  # Monitor: {monitor['name']}
  # Type: {monitor['type']}
  # GUID: {monitor['guid']}
}}
"""
        resource_blocks.append(resource_block)

    return '\n'.join(resource_blocks)

if __name__ == "__main__":
    try:
        all_monitors = fetch_all_monitors()
        print(f"\nSuccessfully retrieved {len(all_monitors)} monitors.\n")

        # Output as neat JSON format
        print("Monitor Data:")
        print(json.dumps(all_monitors, indent=2))

        # Generate Terraform import blocks
        print("\n" + "="*60)
        print("Generating Terraform configuration...")
        print("="*60)

        # Write imports to a file
        with open('imports.tf', 'w') as f:
            f.write(generate_terraform_import_blocks(all_monitors))
        print("\n✓ Created 'imports.tf' with import blocks")

        # Write empty resource blocks to a file
        with open('synthetics_monitors.tf', 'w') as f:
            f.write(generate_terraform_resources(all_monitors))
        print("✓ Created 'synthetics_monitors.tf' with resource skeletons")

        print(f"\n{'='*60}")
        print("Next steps:")
        print("="*60)
        print("1. Initialize Terraform: terraform init")
        print("2. Plan the import: terraform plan -generate-config-out=generated.tf")
        print("3. Review generated.tf and merge with synthetics_monitors.tf")
        print("4. Apply: terraform apply")
        print("\nNote: Terraform will generate the full configuration during plan.")

    except Exception as e:
        print(f"Error: {e}")