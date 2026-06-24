# Attack Surface Risk Tracker
---------------------------------------------------------------------------------

## Purpose
Attack Surface Risk Tracker is a Bash-based tool that detects changes in an external attack surface and classifies risky exposures.
---------------------------------------------------------------------------------

## Module Responsibilities

### astrack.sh
Main controller. Runs all modules in order.

### modules/subdomain.sh
Discovers subdomains for the target domain.

### modules/ports.sh
Scans open ports for discovered subdomains.

### modules/web.sh
Collects HTTP status codes and page titles.

### modules/snapshot.sh
Builds and saves the current scan snapshot as JSON.

### modules/diff.sh
Compares the latest snapshot with the previous snapshot.

### modules/risk.sh
Classifies risky changes based on ports, titles, and services.
---------------------------------------------------------------------------------

## Data Flow

domain input
-> subdomain discovery
-> port scanning
-> web fingerprinting
-> snapshot creation
-> diff check
-> risk classification
-> report output
---------------------------------------------------------------------------------

## Snapshot Storage Strategy

snapshots/
└── target-domain/
    ├── timestamp.json
    ├── timestamp.json
    └── latest.json

latest.json always points to the newest scan.

Diff engine compares:

latest.json
vs
previous snapshot
---------------------------------------------------------------------------------

## Scan Lifecycle

User Input Domain
        │
        ▼
Subdomain Discovery
        │
        ▼
Port Scanning
        │
        ▼
Web Fingerprinting
        │
        ▼
Snapshot Creation
        │
        ▼
Snapshot Storage
        │
        ▼
Diff Analysis
        │
        ▼
Risk Classification
        │
        ▼
Report Generation
---------------------------------------------------------------------------------

## Module Interfaces

### subdomain.sh

Input:
- domain

Output:
- subdomain list

Example:
www.example.com
api.example.com

---

### ports.sh

Input:
- subdomain list

Output:
- host:ports

Example:
www.example.com:80,443
api.example.com:443

---

### web.sh

Input:
- subdomain list

Output:
- host:title

Example:
www.example.com|Homepage
api.example.com|API Gateway

---

### snapshot.sh

Input:
- subdomains
- ports
- titles

Output:
- snapshot json

---

### diff.sh

Input:
- previous snapshot
- current snapshot

Output:
- new assets
- removed assets
- changed assets

---

### risk.sh

Input:
- diff output

Output:
- severity
- host
- reason
---------------------------------------------------------------------------------

## Dependencies

### Required

- bash
- jq
- curl

### Network Discovery

- subfinder
- assetfinder

### Port Scanning

- nmap

### Web Fingerprinting

- httpx

### Optional

- rustscan

## Dependency Check

Tool startup:

check_dependency jq
check_dependency curl
check_dependency subfinder
check_dependency assetfinder
check_dependency nmap
check_dependency httpx

If dependency is missing:

[ERROR] Missing dependency: subfinder

Installation hint is displayed.
---------------------------------------------------------------------------------

## Dependency Validation

Before any scan starts:

- jq
- curl
- subfinder
- assetfinder
- nmap
- httpx

must be checked.

If a dependency is missing:

[ERROR] Missing dependency: <tool>

Tool exits safely.
---------------------------------------------------------------------------------

## Snapshot Mapping

subdomains.txt
→ subdomains[]

ports.txt
→ ports{}

titles.txt
→ titles{}

Example:

subdomains:
[
  "www.example.com",
  "api.example.com"
]

ports:
{
  "www.example.com": [80,443]
}

titles:
{
  "www.example.com": "Homepage"
}
---------------------------------------------------------------------------------

## Snapshot Engine

Input Files

tmp/subdomains.txt
tmp/ports.txt
tmp/titles.txt

Output

snapshots/<domain>/latest.json

Responsibilities

- Read collected data
- Convert TXT data into JSON
- Insert scan timestamp
- Insert target domain
- Save snapshot
---------------------------------------------------------------------------------

## Diff Engine

Purpose

Compare current snapshot with previous snapshot.

Checks

- New subdomains
- Removed subdomains

- New ports
- Removed ports

- New web services

- Title changes

Output

diff.json

Example

{
  "new_subdomains": [],
  "removed_subdomains": [],

  "new_ports": [],
  "removed_ports": [],

  "title_changes": []
}
---------------------------------------------------------------------------------

## Diff Engine Inputs

Current Snapshot

snapshots/<domain>/latest.json

Previous Snapshot

snapshots/<domain>/<previous>.json

Output

reports/diff.json

Structure

{
  "new_subdomains": [],
  "removed_subdomains": [],

  "new_ports": [],
  "removed_ports": [],

  "new_web_hosts": [],

  "title_changes": []
}
---------------------------------------------------------------------------------

## Port Diff Format

new_ports

[
  {
    "host": "example.com",
    "port": 8443
  }
]

removed_ports

[
  {
    "host": "example.com",
    "port": 8080
  }
]
---------------------------------------------------------------------------------

## Port Diff Logic

For every host:

Current Ports
-
Previous Ports

Result:

new_ports

removed_ports
---------------------------------------------------------------------------------

## Title Change Format

[
  {
    "host": "example.com",
    "old_title": "Welcome",
    "new_title": "Jenkins"
  }
]
---------------------------------------------------------------------------------
## Scan Flow

First Scan

Discovery
→ Snapshot

Second Scan+

Discovery
→ Snapshot
→ Diff
→ Risk

Previous Snapshot Source

snapshots/<domain>/latest.json
---------------------------------------------------------------------------------
Report Engine

Inputs:
- diff.json
- risk.json

Output:
- report.html
---------------------------------------------------------------------------------
