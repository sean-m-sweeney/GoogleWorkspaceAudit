# Google Workspace CMMC Compliance Audit Tool

An automated security audit tool for Google Workspace environments, specifically designed to assess compliance with CMMC (Cybersecurity Maturity Model Certification) Level 2 requirements. Built using Claude's Model Context Protocol (MCP) for AI-powered analysis with interactive Q&A workflows.

---

## Prerequisites & Platform Requirements

### ⚙️ System Requirements

**Supported Platforms:**
- ✅ **macOS** - Fully tested and supported
- ⚠️ **Linux** - Should work with minor path adjustments
- ❌ **Windows** - Not supported (use WSL - Windows Subsystem for Linux)

**Required Software:**
- **Node.js v18 or higher** - [Download from nodejs.org](https://nodejs.org/en/download/)
  - Check your version: `node --version`
  - Must show v18.0.0 or higher
- **Google Workspace domain** with admin access
- **Google Cloud Platform** account (free tier is sufficient)
- **Claude Desktop** application - [Download from claude.ai](https://claude.ai/download)

**Before You Start:**
```bash
# Verify Node.js is installed and version is correct
node --version
# Should output: v18.x.x or higher

# If not installed or too old:
# Download LTS version from https://nodejs.org
```

---

## Important Disclaimer

**This tool is for internal security assessment and compliance gap identification only.**

- ❌ **NOT an official CMMC compliance certification**
- ❌ **NOT a substitute for C3PAO (CMMC Third-Party Assessment Organization) assessment**
- ❌ **NOT a guarantee of CMMC compliance**

✅ **What this tool IS:**
- A self-assessment tool to identify potential compliance gaps
- A starting point for compliance preparation
- A way to understand your current security posture

**For official CMMC certification, you MUST work with:**
- A certified C3PAO (CMMC Third-Party Assessment Organization)
- Registered Practitioner (RP) or Registered Practitioner Organization (RPO)
- Official CMMC Assessment Body authorized by the Cyber Accreditation Body (Cyber-AB)

This tool provides automated assessment capabilities but does not replace professional compliance assessment and certification. Official CMMC Level 2 certification requires formal assessment by authorized organizations.

---

## Quick Start

### Already Installed?

1. **Open Claude Desktop**
2. **Type:** `Start a CMMC audit for yourdomain.com`
3. **Answer** the business context questions (what does your business do, how many employees)
4. **Claude will run 18 checks** across 5 phases with Q&A after each
5. **Provide screenshots** when asked for manual verification items
6. **Get your comprehensive report** with compliance score and recommendations

**Important:** Say "Start" not "Run" - this triggers the guided workflow!

### First Time? Install in 5 Minutes

Run this one command in your Mac terminal:

```bash
curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/install.sh | bash
```

The installer walks you through **everything** - Google Cloud setup, credentials, Claude Desktop config, and testing.

---

## Overview

This tool provides **18 automated checks** across **5 CMMC control areas** with comprehensive reporting:
- **Access Control (AC)** - 6 checks
- **Identification and Authentication (IA)** - 2 checks
- **Audit and Accountability (AU)** - 2 checks
- **System and Communications Protection (SC)** - 5 checks
- **MSP Operations** - 3 checks for cost optimization

### Key Features
- 18 comprehensive CMMC audit checks (automated + manual verification guides)
- Interactive Q&A workflow for gathering organizational context
- Comprehensive report generation with risk scoring
- MSP value identification (cost savings, license optimization)
- CMMC control mapping for each audit check
- Licensing impact assessment (identifies when compliance requires Enterprise editions)
- Conversational interface via Claude Desktop
- Read-only access (audit only, no modifications)

## Current Capabilities

### Implemented Audit Checks (18 Total)

#### Access Control (6 checks)
1. **2FA/MFA Status** (CMMC IA.L2-3.5.3)
   - Checks enforcement across all users
   - Identifies admin accounts without 2FA
   - Licensing: Included in all editions

2. **Admin Role Audit** (CMMC AC.L2-3.1.5)
   - Lists all super admins and delegated admins
   - Validates 2FA enrollment for privileged accounts
   - Licensing: Included in all editions

3. **Session Control Settings** (CMMC AC.L2-3.1.11)
   - Manual verification guide for session timeouts
   - Licensing: **Requires Enterprise editions** (~$18-23/user/month)

4. **External Sharing Settings** (CMMC AC.L2-3.1.20)
   - Manual verification guide for Drive sharing policies
   - Licensing: Basic controls included; DLP requires Enterprise

5. **API Access Control** (CMMC AC.L2-3.1.2)
   - Manual verification guide for third-party app access
   - Licensing: Context-aware access requires Enterprise

6. **Groups with External Members** (CMMC AC.L2-3.1.20)
   - Automatically identifies groups with external collaborators
   - Licensing: Included in all editions

#### Authentication (2 checks)
7. **Password Policy** (CMMC IA.L2-3.5.7)
   - Manual verification guide for password requirements
   - Licensing: Basic policies included in all editions

8. **Inactive Accounts** (CMMC AC.L2-3.1.1)
   - Identifies users not logged in for 90+ days
   - Calculates cost savings from license removal
   - Licensing: N/A (cost optimization)

#### Audit & Accountability (2 checks)
9. **Audit Log Settings** (CMMC AU.L2-3.3.1)
   - Explains log retention policies
   - Manual verification guide
   - Licensing: Vault for extended retention requires Business Plus+

10. **Suspicious Activity** (CMMC AU.L2-3.3.4)
    - Queries login failures and suspicious events (last 7 days)
    - Licensing: Included in all editions

#### System Protection (5 checks)
11. **Mobile Device Management** (CMMC SC.L2-3.13.11)
    - Lists devices and encryption status
    - Identifies unapproved/unencrypted devices
    - Licensing: Included in all editions

12. **Email Authentication** (CMMC SC.L2-3.13.8)
    - Manual verification guide for SPF/DKIM/DMARC
    - Licensing: Included in all editions

13. **Email Forwarding Rules** (CMMC AC.L2-3.1.20)
    - Manual verification guide
    - Licensing: DLP to block forwarding requires Enterprise

14. **Calendar Sharing** (CMMC AC.L2-3.1.20)
    - Manual verification guide for external calendar sharing
    - Licensing: Included in all editions

15. **Data Regions** (CMMC SC.L2-3.13.16)
    - Manual verification for ITAR/data residency
    - Licensing: **Enterprise Plus required** (~$23/user/month)

#### MSP Operations (3 checks)
16. **Shared Drives with External Access** (CMMC AC.L2-3.1.20)
    - Identifies shared drives with external users
    - Licensing: Shared drives require Business Standard+

17. **License Utilization**
    - Calculates active/inactive/suspended users
    - Estimates monthly costs and potential savings
    - Licensing: N/A (cost optimization)

18. **Storage Usage**
    - Reports per-user storage consumption
    - Identifies top storage consumers
    - Licensing: N/A (capacity planning)

### Report Generation
19. **Comprehensive Report Generator**
    - Aggregates all findings by control area
    - Calculates compliance score
    - Prioritizes recommendations by risk level
    - Includes MSP value summary
    - Incorporates Q&A context from interactive sessions

## Architecture

### Components
- **MCP Server** (`server.js`): Node.js application that interfaces with Google Workspace Admin SDK
- **Google Service Account**: Read-only authentication with domain-wide delegation
- **Claude Desktop**: Provides conversational interface to the audit tools

### Security Model
- Service account uses read-only OAuth scopes only
- Domain-wide delegation restricted to specific Admin SDK APIs
- Credentials stored locally with restrictive file permissions (600)
- No modification capabilities - audit only

---

## Installation

### Automated Installation (5 minutes)

Run this single command:

```bash
curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/install.sh | bash
```

The installer will:
- ✓ Check prerequisites (macOS, Node.js 18+, Claude Desktop)
- ✓ Set up project directory at `~/workspace-cmmc-audit`
- ✓ Install dependencies automatically
- ✓ Guide you through Google Cloud setup step-by-step
- ✓ Configure credentials
- ✓ Set up Claude Desktop integration
- ✓ Test everything
- ✓ Show you exactly what to do next

**After installation completes:**
1. Restart Claude Desktop (Cmd+Q, then reopen)
2. Type: `Start a CMMC audit for yourdomain.com`

---

### Manual Installation

If you prefer complete control over each step:

---

## Manual Installation Steps

### Step 1: Install Node.js (if you don't have it)
```bash
# Check if you have Node.js
node --version

# If not installed, download from: https://nodejs.org
# Install the LTS version (20.x or later)
```

### Step 2: Clone the Repository
```bash
git clone https://github.com/sean-m-sweeney/GoogleWorkspaceAudit.git
cd GoogleWorkspaceAudit
```

### Step 3: Install Dependencies

```bash
npm install
```

This will install the required dependencies:
- `@modelcontextprotocol/sdk` - For MCP integration with Claude
- `googleapis` - For Google Workspace Admin SDK access

---

## Understanding Authentication

**IMPORTANT: This tool uses Service Account authentication, NOT user OAuth.**

### What This Means:
- ✅ **No login prompts** - The tool authenticates using a service account key file
- ✅ **No 2FA/MFA prompts** - Service accounts don't require interactive authentication
- ✅ **No browser pop-ups** - All authentication happens silently in the background
- ❌ **If you see login prompts or 2FA requests** - Your service account is misconfigured

### How Service Accounts Work:
1. You create a service account in Google Cloud (a special non-human account)
2. You download a credentials file (JSON key) for that service account
3. You grant the service account permission to access your Google Workspace data (domain-wide delegation)
4. The tool uses this key file to authenticate automatically - no user interaction needed

### Why This Matters:
- **Security**: The service account has read-only access limited to specific Admin SDK APIs
- **Automation**: The tool can run unattended without requiring you to log in
- **Audit Trail**: All API calls are logged under the service account name in Google Workspace audit logs

If you're seeing authentication prompts, skip to the [Troubleshooting](#troubleshooting) section.

---

### Step 4: Configure Google Cloud & Service Account

**PREREQUISITE: Check GCP Organization Policy**

Before creating a service account, you may need to disable an organization policy that blocks service account key creation:

1. Go to https://console.cloud.google.com
2. Navigate to: **IAM & Admin** → **Organization Policies**
3. Search for: `iam.disableServiceAccountKeyCreation`
   - You may see either the "Managed" or "Legacy" version of this policy
4. If this policy exists and is enforced, click on it
5. Click **Edit Policy** or **Manage Policy**
6. Set the policy to **Inactive** or **Not Enforced**
7. Click **Save**

**Important Notes:**
- This requires **Organization Policy Administrator** permissions at the GCP organization level
- This is **separate from** Google Workspace Super Admin permissions
- This policy is part of Google's "Secure by Default" enforcement
- Some organizations may require approval to disable this policy for compliance testing
- If you don't have these permissions, contact your GCP organization administrator

**If you don't see this policy or it's already inactive, you can skip this step and proceed to create the service account.**

---

**A. Create Service Account:**
1. Go to https://console.cloud.google.com
2. Create a new project (name it "CMMC Audit" or similar)
3. Click the hamburger menu (☰) → **APIs & Services** → **Enable APIs and Services**
4. Search for "Admin SDK API" → Click it → Click **Enable**
5. Go back to hamburger menu → **APIs & Services** → **Credentials**
6. Click **Create Credentials** → **Service Account**
7. Name: `workspace-audit` (click Create and Continue)
8. Skip the optional steps (click Continue, then Done)

**B. Download Credentials File:**
1. Click on the service account you just created
2. Go to the **Keys** tab
3. Click **Add Key** → **Create New Key** → **JSON** → **Create**
4. A file downloads - **rename it to `credentials.json`**
5. Move it to your project folder:
```bash
mv ~/Downloads/your-project-12345-abc.json ~/workspace-cmmc-audit/credentials.json
chmod 600 ~/workspace-cmmc-audit/credentials.json
```

**C. Setup Domain-Wide Delegation:**
1. Copy the **Client ID** from your service account page (long number)
2. Go to https://admin.google.com
3. Go to: **Security** → **Access and data control** → **API controls**
4. Click **Manage Domain Wide Delegation**
5. Click **Add new**
6. Paste the Client ID
7. Add these OAuth scopes (copy-paste all at once):
```
https://www.googleapis.com/auth/admin.directory.user.readonly,https://www.googleapis.com/auth/admin.directory.group.readonly,https://www.googleapis.com/auth/admin.directory.device.mobile.readonly,https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,https://www.googleapis.com/auth/admin.reports.audit.readonly,https://www.googleapis.com/auth/drive.readonly
```
8. Click **Authorize**

### Step 5: Get the Server Code
Download `server.js` from this repository and put it in `~/workspace-cmmc-audit/`

**IMPORTANT:** Open `server.js` and find this line (around line 31):
```javascript
subject: 'YOUR-ADMIN-EMAIL@yourdomain.com'
```
Change it to **YOUR actual admin email address**.

### Step 6: Setup Claude Desktop

**A. Find your username:**
```bash
whoami
```
Remember this - you'll need it.

**B. Edit Claude Desktop config:**
```bash
# Create the config if it doesn't exist
mkdir -p ~/Library/Application\ Support/Claude
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**C. Paste this config (replace YOUR_USERNAME with your actual username from step A):**
```json
{
  "mcpServers": {
    "workspace-audit": {
      "command": "/usr/local/bin/node",
      "args": ["/Users/YOUR_USERNAME/workspace-cmmc-audit/server.js"]
    }
  }
}
```

**D. Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

### Step 7: Test It
```bash
cd ~/workspace-cmmc-audit
node server.js
```

You should see: `Workspace CMMC Audit MCP server running on stdio`

Press `Ctrl+C` to stop.

### Step 8: Restart Claude Desktop
1. Quit Claude Desktop completely: **Cmd+Q**
2. Open Claude Desktop again
3. Start a new conversation

### Step 9: Run Your First Audit

In Claude Desktop, type:
```
Run a CMMC audit on yourdomain.com
```

Claude will ask you about your business, then run the full audit!

---

## Security Best Practices

### Service Account Management

**Keep for Recurring Use**
- The service account and credentials should be kept long-term if you plan to run audits regularly
- Store credentials.json securely with 600 permissions (owner read/write only)
- Never commit credentials.json to version control
- Back up the credentials file in a secure, encrypted location

**Key Rotation**
- Rotate service account keys every 90 days as a security best practice
- To rotate: Create a new key in Google Cloud Console, test it, then delete the old key
- Document key creation dates in your security procedures

### When to Delete the Service Account

**Only delete the service account when:**
- You are permanently decommissioning this tool
- The Google Workspace domain is being shut down
- You are migrating to a different audit solution

**Do NOT delete if:**
- You're just taking a break from audits (keep the service account)
- You're troubleshooting issues (fix the configuration instead)
- You're upgrading or reinstalling the tool (reuse the same service account)

### Read-Only Security Model

**Understanding the Limited Scope:**
- The service account has **read-only access ONLY** - it cannot modify any Google Workspace settings
- Access is limited to specific Admin SDK APIs (users, groups, devices, audit logs)
- Cannot create, update, or delete users, groups, or any workspace data
- Cannot change security settings or administrative configurations
- All API calls are logged in Google Workspace audit logs for accountability

**OAuth Scopes Explained:**
```
https://www.googleapis.com/auth/admin.directory.user.readonly          - Read user data
https://www.googleapis.com/auth/admin.directory.group.readonly         - Read group data
https://www.googleapis.com/auth/admin.directory.device.mobile.readonly - Read mobile device data
https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly - Read admin roles
https://www.googleapis.com/auth/admin.reports.audit.readonly            - Read audit logs
https://www.googleapis.com/auth/drive.readonly                         - Read Drive metadata
```

Notice the `.readonly` suffix - this guarantees no modification capabilities.

---

## Uninstall

### Quick Uninstall

Run the uninstall script:
```bash
cd ~/workspace-cmmc-audit  # or wherever you installed it
chmod +x uninstall.sh
./uninstall.sh
```

The script will:
1. Remove the MCP server configuration from Claude Desktop
2. Provide instructions for deleting the service account in Google Cloud (optional)
3. Ask if you want to delete project files

### Manual Uninstall

If you prefer to uninstall manually:

**Step 1: Remove Claude Desktop Configuration**
```bash
# Edit the config file
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Remove the "workspace-audit" entry from mcpServers
# Save and exit (Ctrl+X, Y, Enter)

# Restart Claude Desktop
```

**Step 2: Delete Service Account (Optional)**

Only do this if you're permanently decommissioning the tool:

1. Go to https://console.cloud.google.com
2. Select your project
3. Go to **IAM & Admin** → **Service Accounts**
4. Find the `workspace-audit` service account
5. Click the three dots → **Delete**
6. Go to **Google Workspace Admin Console** → **Security** → **API Controls** → **Domain-wide Delegation**
7. Find and remove the delegation for this service account

**Step 3: Remove Project Files (Optional)**
```bash
# This deletes everything including credentials
rm -rf ~/workspace-cmmc-audit

# Or if you want to keep credentials for later:
rm ~/workspace-cmmc-audit/node_modules -rf
rm ~/workspace-cmmc-audit/server.js
# Keep credentials.json for reinstallation later
```

---

## Troubleshooting

### Login Prompts or 2FA Requests

**Symptom:** Browser opens asking you to log in, or you see 2FA/MFA prompts

**Cause:** Service account authentication is not configured correctly

**Fixes:**
1. **Verify credentials.json exists** in your project directory
   ```bash
   ls -la ~/workspace-cmmc-audit/credentials.json
   # Should show a file with 600 permissions
   ```

2. **Check domain-wide delegation is configured:**
   - Go to https://admin.google.com
   - Navigate to **Security** → **API Controls** → **Domain-wide Delegation**
   - Verify your service account Client ID is listed with all required scopes

3. **Verify the subject email in server.js:**
   - Open `server.js` and find the `subject:` line (around line 35)
   - Must be a valid Google Workspace admin email address
   - Example: `subject: 'admin@yourdomain.com'`

4. **Check the credentials file format:**
   ```bash
   cat ~/workspace-cmmc-audit/credentials.json | grep type
   # Should show: "type": "service_account"
   ```

### Node.js Not Found or Version Too Old

**Symptom:** `node: command not found` or version check fails

**Fix:**
1. Install Node.js from https://nodejs.org/en/download/
2. Download the LTS version (v20 or higher recommended)
3. After installation, close and reopen your terminal
4. Verify: `node --version` (should show v18.0.0 or higher)

### Cannot Create Service Account Keys

**Symptom:** Error when trying to create service account keys: "Service account key creation is disabled by an organization policy"

**Cause:** GCP organization has the `iam.disableServiceAccountKeyCreation` policy enforced

**Fix:**
1. Go to https://console.cloud.google.com
2. Navigate to **IAM & Admin** → **Organization Policies**
3. Search for: `iam.disableServiceAccountKeyCreation`
4. Click on the policy
5. Click **Edit Policy** or **Manage Policy**
6. Set to **Inactive** or **Not Enforced**
7. Click **Save**

**Important:**
- Requires **Organization Policy Administrator** permissions (GCP org-level, not Workspace admin)
- This is separate from Google Workspace Super Admin permissions
- If you don't have these permissions, contact your GCP organization administrator
- Some organizations require approval to disable this policy due to security policies
- Alternative: Use Workload Identity Federation instead of service account keys (advanced)

### "Server disconnected" error

**Cause:** Claude Desktop cannot connect to the MCP server

**Fixes:**
- Check that your username in the config file is correct
- Make sure the path `/Users/YOUR_USERNAME/workspace-cmmc-audit/server.js` exists
- Try using the full path to node: `which node` to find it
- Verify server.js is executable: `ls -la ~/workspace-cmmc-audit/server.js`

### "Authentication failed" error

**Cause:** Service account cannot authenticate with Google Workspace

**Fixes:**
- Make sure you changed the `subject` email in server.js to YOUR admin email
- Verify domain-wide delegation is set up correctly (see "Login Prompts" section above)
- Check that all OAuth scopes were added exactly as specified
- Verify the Admin SDK API is enabled in Google Cloud Console

### "API not enabled" error

**Cause:** Required Google Cloud APIs are not enabled

**Fix:**
- Go to https://console.cloud.google.com
- Select your project
- Navigate to **APIs & Services** → **Library**
- Search for "Admin SDK API" and enable it
- May also need to enable "Google Drive API"

---

## Usage

### Quick Start - Interactive Audit

The recommended way to use this tool is through the interactive audit workflow:

```
User: "Run a CMMC audit on valleytechpartners.com"
```

Claude will:
1. Run all 18 audit checks organized into 5 phases
2. Present findings after each phase
3. Ask clarifying questions to gather organizational context
4. Generate a comprehensive report with all findings and context

See **WORKFLOW.md** for detailed guidance on the interactive audit process.

### Individual Check Usage

You can also run individual checks conversationally:
```
Check the 2FA status for yourdomain.com
Check the admin roles for yourdomain.com
Check inactive accounts for yourdomain.com
Check license utilization for yourdomain.com
```

### Example Workflow

```
User: "Start a CMMC audit for valleytechpartners.com"

Claude:
"I'll conduct a comprehensive CMMC Level 2 audit of valleytechpartners.com.

PHASE 0: BUSINESS CONTEXT

Before we begin, I need some context:
1. Can you describe in a couple of sentences what your business does?
2. How many employees does your organization have?"

User: "We're an IT managed service provider focused on defense contractors. We have 15 employees."

Claude:
"Perfect! That context will help me tailor the findings.

Let's begin. I'll run this in 5 phases with Q&A after each section...

PHASE 1: ACCESS CONTROL CHECKS
Running 6 checks...

Results:
- 2FA Status: 3 users without 2FA
- Admin Roles: 2 super admins, 1 delegated admin
- Groups: 1 group with external members
- Session Settings: Manual verification required
- External Sharing: Manual verification required
- API Access: Manual verification required

Questions:
1. Are any of the 3 users without 2FA service accounts or other exceptions?
2. The 'Marketing' group has contractor@vendor.com. Is this authorized access?"

User: "The contractor is authorized until Q4 2024. One user without 2FA is a service account."

Claude: [Records context, moves to Phases 2-5...]

[After Phase 5]

Claude:
"Before I generate the final report, I need to verify several settings that require manual
checks in the Google Admin Console. I'll walk you through each one.

Let's verify your session control settings:

1. Go to: Google Admin Console > Security > Session control
2. Take a screenshot showing session length and idle timeout settings
3. Share the screenshot with me

This helps verify compliance with CMMC's 15-minute idle timeout requirement."

User: [Provides screenshot]

Claude: "Thank you! I can see:
- Web session: 8 hours ✓
- Idle timeout: 15 minutes ✓
- COMPLIANT with CMMC AC.L2-3.1.11

Let's check the next item - external sharing settings..."

[After all screenshots collected]

Claude:
"Thank you for providing those screenshots. I've verified all manual configuration items.
Let me generate your comprehensive report...

EXECUTIVE SUMMARY:
Organization: IT MSP for defense contractors (15 employees)
Domain: valleytechpartners.com
Compliance Score: 85%

Critical Issues: 1
- 2FA not enforced (2 users without 2FA - excluding service account)

High Priority: 2
- 12 inactive accounts identified
- 1 group with external member (authorized contractor)

Medium Priority: 0

Strengths:
- Session controls properly configured (8hr max, 15min idle timeout)
- Password policy compliant (12 char minimum, 24 password history)
- Email authentication configured (SPF, DKIM, DMARC=quarantine)

Cost Optimization:
- Potential savings: $144/month from removing 12 inactive licenses

Would you like me to:
1. Export this report to JSON or Markdown?
2. Provide detailed remediation steps for the 2FA critical finding?
3. Generate a licensing upgrade recommendation?"
```

### Example Individual Check Output
```json
{
  "domain": "example.com",
  "total_users": 25,
  "mfa_enforced": false,
  "users_without_mfa": 8,
  "admin_accounts_without_mfa": 0,
  "cmmc_control": "IA.L2-3.5.3",
  "recommendation": "Enable 2FA enforcement for all users...",
  "licensing_note": "2FA is included in all Google Workspace editions."
}
```

## Project Structure
```
workspace-cmmc-audit/
├── server.js              # MCP server implementation (18 checks + report generator)
├── credentials.json       # Google service account credentials (gitignored)
├── WORKFLOW.md           # Interactive audit workflow guide for Claude
├── README.md             # This file (setup and usage)
├── package.json          # Node.js dependencies
└── .gitignore           # Prevents credential exposure
```

## Security Considerations

### Credential Management
- Credentials file has 600 permissions (owner read/write only)
- Never commit `credentials.json` to version control
- Service account has read-only scopes only
- Consider key rotation every 90 days for production use

### Audit Trail
- All API calls are logged in Google Workspace audit logs
- Service account activity is visible to super admins
- No ability to modify configurations (read-only by design)

### Organizational Policies
- Some organizations may restrict service account key creation
- May require org policy exemption for development projects
- Production deployments should use Workload Identity Federation instead of service account keys

## Licensing Impact on CMMC Compliance

### No Upgrade Required
- 2FA/MFA enforcement
- Admin role management
- Basic password policies (length, complexity, reuse prevention)

### Enterprise Edition Required
- **Session control policies** (idle timeout, max session length)
  - Required for CMMC AC.L2-3.1.11
  - Enterprise Standard: ~$18/user/month
  - Enterprise Plus: ~$23/user/month
- Advanced context-aware access policies

## Roadmap

### Completed (v1.0)
- 18 comprehensive CMMC audit checks
- Interactive Q&A workflow for context gathering
- Comprehensive report generation with risk scoring
- MSP value identification (cost optimization)
- Mobile device management checks
- External sharing detection (groups, shared drives)
- Audit log guidance and suspicious activity monitoring
- License utilization and storage analysis

### Planned Additions (v2.0)
- Automated report export to PDF/HTML/Markdown
- Scheduled audit runs with change detection
- Historical compliance tracking (trend analysis)
- Integration with CISA ScubaGear assessments
- Automated remediation scripts (optional)
- Custom control framework mapping (NIST 800-171, ISO 27001)

### Under Consideration
- Microsoft 365 support (parallel audit capability)
- Multi-tenant reporting dashboard for MSPs
- Webhook notifications for compliance drift
- Integration with ticketing systems (Jira, ServiceNow)
- Continuous monitoring mode (real-time alerts)

## CMMC Control Mapping

### Full Coverage (18 checks across 10 CMMC controls):

**Access Control (AC)**
- **AC.L2-3.1.1**: Authorized Access Control (inactive accounts)
- **AC.L2-3.1.2**: Transaction & Function Control (API access)
- **AC.L2-3.1.5**: Principle of Least Privilege (admin roles)
- **AC.L2-3.1.11**: Session Lock/Termination (session settings)
- **AC.L2-3.1.20**: External Connections (sharing, groups, drives, email, calendar)

**Identification and Authentication (IA)**
- **IA.L2-3.5.3**: Multi-factor Authentication
- **IA.L2-3.5.7**: Password Complexity & Management

**Audit and Accountability (AU)**
- **AU.L2-3.3.1**: System Auditing (audit log settings)
- **AU.L2-3.3.4**: Alert Generation (suspicious activity)

**System and Communications Protection (SC)**
- **SC.L2-3.13.8**: Transmission Confidentiality (email authentication)
- **SC.L2-3.13.11**: Cryptographic Protection (mobile device encryption)
- **SC.L2-3.13.16**: Data at Rest Protection (data regions/ITAR)

## Troubleshooting

### "Server disconnected" in Claude Desktop
- Check MCP server logs: `tail -f ~/Library/Logs/Claude/mcp-server-workspace-audit.log`
- Verify credentials.json path is absolute, not relative
- Ensure service account has domain-wide delegation configured

### "Invalid grant" errors
- Verify domain-wide delegation scopes are correct
- Check that subject email in server.js is a valid admin
- Confirm service account's Unique ID matches Client ID in delegation

### Node module errors
- Run `npm install` in project directory
- Verify Node.js version: `node --version` (should be v18+)

## Contributing

This is an open learning project. Feedback and contributions welcome.

### Development Setup
```bash
# Test authentication separately
node test-auth.js

# Check for syntax errors
node --check server.js

# Monitor server logs
tail -f ~/Library/Logs/Claude/mcp*.log
```

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Built with Anthropic's Model Context Protocol (MCP)
- Uses Google Workspace Admin SDK
- CMMC control mappings based on CMMC Model v2.0

## Author

Sean Sweeney  
Valley Technology Partners  
[valleytechpartners.com](https://valleytechpartners.com)

## Disclaimer

This tool provides automated assessment capabilities but does not guarantee CMMC compliance. Professional compliance assessment and C3PAO certification are required for official CMMC compliance validation. This tool is intended to support internal security assessments and identify potential compliance gaps.
