# Process Flow Diagram

Visual representation of the complete New Relic Synthetics → Terraform → Multi-Environment deployment process.

---

## High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                   New Relic Production Account                   │
│                    (18 Synthetic Monitors)                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ ① Fetch via NerdGraph API
                           │    (get-all-synthetics-guid.py)
                           ▼
                    ┌─────────────┐
                    │  imports.tf │
                    │  (18 import │
                    │   blocks)   │
                    └──────┬──────┘
                           │
                           │ ② Terraform Import
                           │    (terraform plan -generate-config-out)
                           ▼
                   ┌───────────────┐
                   │ generated.tf  │
                   │ (Full config  │
                   │  for all 18)  │
                   └───────┬───────┘
                           │
                           │ ③ Set Up Variables
                           │    (use var.account_id)
                           ▼
        ┌──────────────────┴──────────────────┐
        │                                     │
        ▼                                     ▼
┌───────────────┐                    ┌───────────────┐
│  Workspace:   │                    │  Workspace:   │
│     prod      │                    │     dev       │
│               │                    │               │
│ Account:      │                    │ Account:      │
│  1234567      │                    │  9876543      │
│               │                    │               │
│ Status:       │                    │ Status:       │
│  Imported     │                    │  Created      │
│  (existing)   │                    │  (new)        │
└───────────────┘                    └───────────────┘
```

---

## Detailed Step-by-Step Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: DISCOVERY                                              │
└─────────────────────────────────────────────────────────────────┘

  New Relic Production (Account: 1234567)
  ├─ 1 SIMPLE monitor
  ├─ 3 BROWSER monitors
  ├─ 6 SCRIPT_API monitors
  ├─ 6 SCRIPT_BROWSER monitors
  └─ 2 STEP_MONITOR monitors
          │
          │ Python Script (get-all-synthetics-guid.py)
          │   • Uses NerdGraph API
          │   • Query: entitySearch(domain='SYNTH')
          │   • Fetches: GUID, name, type
          ▼
  Output Files:
  ├─ imports.tf (18 import blocks)
  └─ JSON list (monitor inventory)


┌─────────────────────────────────────────────────────────────────┐
│  PHASE 2: IMPORT TO TERRAFORM                                    │
└─────────────────────────────────────────────────────────────────┘

  imports.tf
  ├─ import { to = newrelic_synthetics_monitor.test_emanuele ... }
  ├─ import { to = newrelic_synthetics_script_monitor.api_check ... }
  └─ ... (18 total)
          │
          │ terraform plan -generate-config-out=generated.tf
          │   • Connects to New Relic
          │   • Fetches full configuration
          │   • Generates Terraform resources
          ▼
  generated.tf (432 lines)
  ├─ resource "newrelic_synthetics_monitor" { ... }
  ├─ resource "newrelic_synthetics_script_monitor" { ... }
  └─ resource "newrelic_synthetics_step_monitor" { ... }
          │
          │ Clean up (remove null values)
          ▼
  ├─ python3 cleanup_terraform.py
  └─ Replace hardcoded account_id with var.account_id
          │
          │ terraform apply -var-file=terraform.tfvars.prod
          ▼
  Terraform State (Production)
  └─ 18 monitors imported ✓


┌─────────────────────────────────────────────────────────────────┐
│  PHASE 3: MULTI-ENVIRONMENT SETUP                                │
└─────────────────────────────────────────────────────────────────┘

  Create Infrastructure:

  provider.tf
  ├─ Uses var.account_id
  └─ Uses var.region

  variables.tf
  ├─ variable "account_id" { type = number }
  └─ variable "region" { type = string }

  terraform.tfvars.prod
  ├─ account_id = 1234567
  └─ region = "EU"

  terraform.tfvars.dev
  ├─ account_id = 9876543
  └─ region = "EU"

  Create Workspaces:
  ├─ terraform workspace new prod
  └─ terraform workspace new dev


┌─────────────────────────────────────────────────────────────────┐
│  PHASE 4: DEPLOY TO DEV                                          │
└─────────────────────────────────────────────────────────────────┘

  terraform workspace select dev
  export NEW_RELIC_API_KEY="dev-key"
  terraform apply -var-file=terraform.tfvars.dev
          │
          │ Creates all 18 monitors in dev account
          ▼
  New Relic Dev Account (9876543)
  ├─ test_emanuele (SIMPLE)
  ├─ online_boutique_frontend (BROWSER)
  ├─ irish_rail_live_train_tracker (SCRIPT_API)
  ├─ nr_login (SCRIPT_BROWSER)
  ├─ again_dummy (STEP_MONITOR)
  └─ ... (18 total) ✓


┌─────────────────────────────────────────────────────────────────┐
│  PHASE 5: ONGOING MANAGEMENT                                     │
└─────────────────────────────────────────────────────────────────┘

  Workflow for Changes:

  1. Edit Code
     └─ vim generated.tf
          (Change frequency, locations, scripts, etc.)

  2. Test in Dev
     ├─ terraform workspace select dev
     ├─ export NEW_RELIC_API_KEY="dev-key"
     ├─ terraform plan -var-file=terraform.tfvars.dev
     └─ terraform apply -var-file=terraform.tfvars.dev

  3. Deploy to Prod
     ├─ terraform workspace select prod
     ├─ export NEW_RELIC_API_KEY="prod-key"
     ├─ terraform plan -var-file=terraform.tfvars.prod
     └─ terraform apply -var-file=terraform.tfvars.prod

  4. Version Control
     ├─ git add generated.tf
     ├─ git commit -m "Update monitor frequency"
     └─ git push
```

---

## File Structure

```
project/
├── get-all-synthetics-guid.py       # Python script to fetch monitors
├── cleanup_terraform.py             # Cleanup script for generated.tf
├── provider.tf                      # Terraform provider config
├── variables.tf                     # Variable definitions
├── generated.tf                     # Monitor configurations (432 lines)
├── terraform.tfvars.prod            # Production values
├── terraform.tfvars.dev             # Development values
├── imports.tf.prod.backup           # Backup of import blocks (not needed after import)
├── .gitignore                       # Git ignore file
├── COMPLETE_GUIDE.md                # Full documentation
├── CHEAT_SHEET.md                   # Quick reference
└── .terraform/                      # Terraform working directory
    └── terraform.tfstate.d/
        ├── prod/                    # Production state
        │   └── terraform.tfstate
        └── dev/                     # Development state
            └── terraform.tfstate
```

---

## Data Flow

```
Production NR Account          Terraform State Files           Dev NR Account
     (1234567)                                                    (9876543)
         │                                                             │
         │                                                             │
    ┌────▼────┐                                                  ┌────▼────┐
    │ Monitor │              ┌──────────────┐                    │ Monitor │
    │    1    │◄────Import───┤ Workspace:   │────Create─────────►│    1    │
    └─────────┘              │    prod      │                    └─────────┘
         │                   └──────────────┘                         │
    ┌────▼────┐                    │                            ┌────▼────┐
    │ Monitor │                    │                            │ Monitor │
    │    2    │◄───────────────────┤                            │    2    │
    └─────────┘                    │                            └─────────┘
         │                         │                                 │
       ...                         │                               ...
         │                         │                                 │
    ┌────▼────┐              ┌─────▼────────┐                  ┌────▼────┐
    │ Monitor │              │ Workspace:   │                  │ Monitor │
    │   18    │              │    dev       │                  │   18    │
    └─────────┘              └──────────────┘                  └─────────┘
                                    ▲
                                    │
                              generated.tf
                         (Single source of truth)
```

---

## Key Concepts

### Terraform Workspaces
```
Workspaces isolate state files per environment:

terraform.tfstate.d/
  ├── prod/
  │   └── terraform.tfstate    ← Tracks prod resources
  └── dev/
      └── terraform.tfstate    ← Tracks dev resources

Same code (generated.tf) + Different variables = Different environments
```

### Resource Type Mapping
```
New Relic Monitor Type → Terraform Resource Type

SIMPLE              →  newrelic_synthetics_monitor
BROWSER             →  newrelic_synthetics_monitor
SCRIPT_API          →  newrelic_synthetics_script_monitor
SCRIPT_BROWSER      →  newrelic_synthetics_script_monitor
STEP_MONITOR        →  newrelic_synthetics_step_monitor
```

### Variables Pattern
```
Code:                 generated.tf uses var.account_id
Environment-specific: terraform.tfvars.prod has account_id = 1234567
                      terraform.tfvars.dev has account_id = 9876543
Result:              Same code deploys to different accounts
```

---

## Success Criteria

✅ All 18 monitors fetched from production
✅ Successfully imported into Terraform (prod workspace)
✅ Generated configuration cleaned and using variables
✅ Dev workspace created with separate state
✅ All 18 monitors deployed to dev account (9876543)
✅ Changes can be made to generated.tf and deployed to either environment
✅ Infrastructure as Code established

**Final State:**
- Production: 18 monitors managed by Terraform (imported)
- Development: 18 monitors managed by Terraform (created)
- Single source of truth: generated.tf
- Version controlled and repeatable deployments
