#!/bin/bash

# Google Workspace CMMC Audit Tool - One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/install.sh | bash

set -e

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "   Google Workspace CMMC Audit Tool - Installer"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Step 1: Check Platform
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 1: Checking Prerequisites"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "✗ This installer is designed for macOS"
    echo "  Detected platform: $OSTYPE"
    echo ""
    echo "For Linux/WSL, see manual installation:"
    echo "  https://github.com/sean-m-sweeney/GoogleWorkspaceAudit#manual-installation"
    echo ""
    read -p "Attempt installation anyway? (not recommended) (y/N): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "⚠ Proceeding on unsupported platform"
else
    echo "✓ macOS detected"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found"
    echo ""
    echo "Please install Node.js 18 or higher first:"
    echo "  Download: https://nodejs.org"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "✗ Node.js 18 or higher required (you have $(node --version))"
    echo "  Download latest: https://nodejs.org"
    exit 1
fi

echo "✓ Node.js $(node --version) detected"

# Check Claude Desktop
if [ ! -d "/Applications/Claude.app" ]; then
    echo "⚠  Claude Desktop not detected at /Applications/Claude.app"
    echo "   The installer will configure Claude Desktop integration,"
    echo "   but you'll need to install Claude Desktop to use it."
    echo "   Download from: https://claude.ai/download"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        echo "Install Claude Desktop first, then run this installer again."
        exit 0
    fi
else
    echo "✓ Claude Desktop detected"
fi

echo ""
echo "✓ All prerequisites met!"
echo ""

# Step 2: Setup Project Directory
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 2: Setting Up Project Directory"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

INSTALL_DIR="$HOME/workspace-cmmc-audit"
echo "Installing to: $INSTALL_DIR"
echo ""

# Check for existing installation
if [ -d "$INSTALL_DIR" ]; then
    if [ -f "$INSTALL_DIR/server.js" ] || [ -f "$INSTALL_DIR/credentials.json" ]; then
        echo "⚠  Existing installation detected!"
        echo "   Location: $INSTALL_DIR"
        [ -f "$INSTALL_DIR/server.js" ] && echo "   - server.js found"
        [ -f "$INSTALL_DIR/credentials.json" ] && echo "   - credentials.json found (will be preserved)"
        [ -f "$INSTALL_DIR/.env" ] && echo "   - .env found (will be preserved)"
        echo ""
        read -p "Upgrade existing installation? (y/N): " -n 1 -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
        echo "✓ Upgrading existing installation (credentials and .env will be preserved)"
        UPGRADE_MODE=true
    else
        echo "✓ Project directory exists"
    fi
else
    mkdir -p "$INSTALL_DIR"
    echo "✓ Created project directory"
fi

# Download or copy installer files
cd "$INSTALL_DIR"

# If we're already in the repo (local install), just use the files
if [ -f "../installer/install.sh" ]; then
    echo "✓ Using local repository files"
    cp ../installer/server.js .
    cp ../installer/uninstall.sh .
    cp ../installer/README.md .
    chmod +x uninstall.sh
else
    echo "Downloading latest version from GitHub..."
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/server.js -o server.js
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/uninstall.sh -o uninstall.sh
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/README.md -o README.md
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/package.json -o package.json
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/package-lock.json -o package-lock.json
    chmod +x uninstall.sh
    echo "✓ Downloaded files"
fi

# Verify package.json exists (should have been downloaded or copied)
if [ ! -f "package.json" ]; then
    echo "✗ package.json not found - creating it..."
    cat > package.json << 'PACKAGE_EOF'
{
  "name": "workspace-cmmc-audit",
  "version": "1.0.0",
  "type": "module",
  "description": "Google Workspace CMMC Level 2 Compliance Audit Tool",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.6.0",
    "googleapis": "^166.0.0",
    "dotenv": "^16.4.5"
  }
}
PACKAGE_EOF
fi
echo "✓ package.json ready"

# Create .gitignore
cat > .gitignore << 'GITIGNORE_EOF'
# CRITICAL: Never commit credentials!
credentials.json
*.json.key
*-key.json

# Dependencies
node_modules/

# OS Files
.DS_Store

# Logs
*.log

# Environment
.env
GITIGNORE_EOF
echo "✓ Created .gitignore"

# Create .env.example template
cat > .env.example << 'ENV_EXAMPLE_EOF'
# Google Workspace Admin Email
# This is the email address of a Google Workspace admin account
# that the service account will impersonate for API calls
GOOGLE_WORKSPACE_ADMIN_EMAIL=admin@yourdomain.com
ENV_EXAMPLE_EOF
echo "✓ Created .env.example"

# Step 3: Install Dependencies
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 3: Installing Dependencies"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

# Proactively fix npm cache permissions (common issue on Macs)
# This prevents EACCES errors before they happen
if [ -d "$HOME/.npm" ]; then
    # Check if there are any root-owned files in npm cache
    if find "$HOME/.npm" -user root -print -quit 2>/dev/null | grep -q .; then
        echo "Fixing npm cache permissions (root-owned files detected)..."
        sudo chown -R $(whoami) "$HOME/.npm" 2>/dev/null || {
            echo "⚠ Could not fix npm cache permissions automatically."
            echo "  Please run: sudo chown -R \$(whoami) ~/.npm"
            echo "  Then run the installer again."
            exit 1
        }
        echo "✓ npm cache permissions fixed"
        echo ""
    fi
fi

echo "Running npm install..."
echo ""

# Run npm install and capture output
npm install 2>&1 | tee /tmp/npm-install.log
NPM_EXIT_CODE=${PIPESTATUS[0]}

# Check if npm install failed
if [ $NPM_EXIT_CODE -ne 0 ] || grep -q "npm error" /tmp/npm-install.log; then
    echo ""
    echo "⚠ npm install encountered errors"

    # Check if it's a permissions/EACCES error
    if grep -q "EACCES" /tmp/npm-install.log; then
        echo ""
        echo "Detected npm permissions issue. Attempting fix..."
        echo ""

        sudo chown -R $(whoami) "$HOME/.npm" 2>/dev/null || {
            echo "✗ Could not fix npm permissions."
            echo ""
            echo "Please run this command manually, then try the installer again:"
            echo "  sudo chown -R \$(whoami) ~/.npm"
            echo ""
            rm -f /tmp/npm-install.log
            exit 1
        }

        echo "✓ Permissions fixed. Retrying npm install..."
        echo ""

        if ! npm install; then
            echo ""
            echo "✗ Failed to install dependencies after fixing permissions"
            rm -f /tmp/npm-install.log
            exit 1
        fi
    else
        echo ""
        echo "✗ Failed to install dependencies"
        echo "Check the error messages above for details."
        rm -f /tmp/npm-install.log
        exit 1
    fi
fi

rm -f /tmp/npm-install.log

# Verify critical dependencies were installed
echo ""
echo "Verifying dependencies..."
if [ ! -d "node_modules/@modelcontextprotocol/sdk" ]; then
    echo "✗ Critical dependency @modelcontextprotocol/sdk not found!"
    echo ""
    echo "Attempting to reinstall..."
    rm -rf node_modules package-lock.json
    npm install

    if [ ! -d "node_modules/@modelcontextprotocol/sdk" ]; then
        echo "✗ Failed to install @modelcontextprotocol/sdk"
        echo ""
        echo "Please try manually:"
        echo "  cd $INSTALL_DIR"
        echo "  npm install"
        exit 1
    fi
fi

if [ ! -d "node_modules/googleapis" ]; then
    echo "✗ Critical dependency googleapis not found!"
    exit 1
fi

echo "✓ All dependencies verified"
echo ""

# Step 4: Google Cloud Setup Guide
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 4: Google Cloud & Workspace Setup"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "You need to set up a Google Service Account with domain-wide delegation."
echo ""
read -p "Press Enter when ready to continue..." < /dev/tty

echo ""
echo "--- PART A: Create Service Account ---"
echo ""
echo "1. Open: https://console.cloud.google.com"
echo "2. Create a new project (or select existing)"
echo "3. Click ☰ menu → APIs & Services → Enable APIs and Services"
echo "4. Search 'Admin SDK API' → Enable it"
echo "5. Go back to ☰ → APIs & Services → Credentials"
echo "6. Click 'Create Credentials' → 'Service Account'"
echo "7. Name: workspace-audit"
echo "8. Click Create and Continue (skip optional steps)"
echo ""
read -p "Press Enter when you've completed Part A..." < /dev/tty

echo ""
echo "--- PART B: Download Credentials ---"
echo ""
echo "1. Click on the service account you just created"
echo "2. Go to the 'Keys' tab"
echo "3. Click 'Add Key' → 'Create New Key' → JSON"
echo "4. The file will download"
echo ""
read -p "Press Enter when you've downloaded the credentials file..." < /dev/tty

# Step 5: Configure Credentials
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 5: Configuring Credentials"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

# Check if credentials already exist (upgrade scenario)
if [ -f "$INSTALL_DIR/credentials.json" ] && [ "$UPGRADE_MODE" = true ]; then
    echo "✓ Existing credentials.json found"
    read -p "Use existing credentials? (Y/n): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "✓ Using existing credentials"
        SKIP_CREDENTIALS=true
    fi
fi

if [ "$SKIP_CREDENTIALS" != true ]; then
    echo "Enter the full path to your downloaded credentials JSON file"
    read -p "(or drag and drop it here): " CRED_PATH < /dev/tty
    CRED_PATH=$(echo $CRED_PATH | tr -d "'" | tr -d '"')

    if [ ! -f "$CRED_PATH" ]; then
        echo "✗ File not found: $CRED_PATH"
        echo "Please run the installer again with the correct path."
        exit 1
    fi

    cp "$CRED_PATH" credentials.json
    chmod 600 credentials.json
    echo "✓ Credentials copied and secured (chmod 600)"
fi

# Read Client ID for domain-wide delegation
CLIENT_ID=$(grep -o '"client_id": *"[^"]*"' credentials.json | cut -d'"' -f4)

echo ""
echo "--- PART C: Domain-Wide Delegation ---"
echo ""
echo "1. Copy this Client ID: $CLIENT_ID"
echo "2. Go to: https://admin.google.com"
echo "3. Navigate: Security → Access and data control → API controls"
echo "4. Click 'Manage Domain Wide Delegation'"
echo "5. Click 'Add new'"
echo "6. Paste the Client ID above"
echo "7. Copy and paste ALL these OAuth scopes:"
echo ""
echo "https://www.googleapis.com/auth/admin.directory.user.readonly,https://www.googleapis.com/auth/admin.directory.group.readonly,https://www.googleapis.com/auth/admin.directory.device.mobile.readonly,https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,https://www.googleapis.com/auth/admin.reports.audit.readonly,https://www.googleapis.com/auth/drive.readonly"
echo ""
echo "8. Click Authorize"
echo ""
read -p "Press Enter when you've completed domain-wide delegation..." < /dev/tty

# Step 6: Configure Admin Email
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 6: Configuring Admin Email"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

# Check if .env already exists (upgrade scenario)
EXISTING_EMAIL=""
if [ -f "$INSTALL_DIR/.env" ] && [ "$UPGRADE_MODE" = true ]; then
    # Extract existing email from .env
    EXISTING_EMAIL=$(grep "^GOOGLE_WORKSPACE_ADMIN_EMAIL=" .env | cut -d'=' -f2)
    if [ -n "$EXISTING_EMAIL" ]; then
        echo "✓ Existing admin email found: $EXISTING_EMAIL"
        read -p "Keep this email? (Y/n): " -n 1 -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            ADMIN_EMAIL="$EXISTING_EMAIL"
            echo "✓ Using existing admin email"
        fi
    fi
fi

# Prompt for email if not already set
if [ -z "$ADMIN_EMAIL" ]; then
    echo "What is your Google Workspace admin email address?"
    echo "(This should be a super admin account in your domain)"
    read -p "Admin email: " ADMIN_EMAIL < /dev/tty

    if [[ ! "$ADMIN_EMAIL" == *"@"* ]]; then
        echo "✗ Invalid email address"
        exit 1
    fi
fi

# Create .env file with admin email
cat > .env << ENV_EOF
# Google Workspace Admin Email
# This is the email address of a Google Workspace admin account
# that the service account will impersonate for API calls
GOOGLE_WORKSPACE_ADMIN_EMAIL=${ADMIN_EMAIL}
ENV_EOF

chmod 600 .env
echo "✓ Created .env file with admin email: $ADMIN_EMAIL"
echo "✓ File permissions set to 600 (owner read/write only)"
echo ""
echo "🔒 SECURITY NOTE: Your email is now stored in .env which is:"
echo "   ✓ Excluded from git via .gitignore"
echo "   ✓ Protected with 600 permissions"
echo "   ✓ Never committed to version control"

# Step 7: Configure Claude Desktop
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 7: Configuring Claude Desktop"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
mkdir -p "$(dirname "$CLAUDE_CONFIG")"

# Find node path
NODE_PATH=$(which node)

# Create or update config
if [ -f "$CLAUDE_CONFIG" ]; then
    echo "✓ Loaded existing Claude Desktop config"
    # Use python to update JSON (safer than sed)
    python3 << PYTHON_EOF
import json
with open('$CLAUDE_CONFIG', 'r') as f:
    config = json.load(f)
if 'mcpServers' not in config:
    config['mcpServers'] = {}
config['mcpServers']['workspace-audit'] = {
    'command': '$NODE_PATH',
    'args': ['$INSTALL_DIR/server.js'],
    'cwd': '$INSTALL_DIR'
}
with open('$CLAUDE_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
PYTHON_EOF
else
    cat > "$CLAUDE_CONFIG" << CONFIG_EOF
{
  "mcpServers": {
    "workspace-audit": {
      "command": "$NODE_PATH",
      "args": ["$INSTALL_DIR/server.js"],
      "cwd": "$INSTALL_DIR"
    }
  }
}
CONFIG_EOF
fi

echo "✓ Claude Desktop configured"
echo "  Node: $NODE_PATH"
echo "  Server: $INSTALL_DIR/server.js"

# Step 8: Test Server
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 8: Testing Server"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "Starting server test..."
echo ""

# Test server (timeout after 2 seconds)
timeout 2 node server.js > /tmp/server-test.log 2>&1 || true

if grep -q "Workspace CMMC Audit MCP server running on stdio" /tmp/server-test.log; then
    echo "✓ Server started successfully!"
else
    echo "⚠ Server test completed (check for any errors above)"
fi

rm -f /tmp/server-test.log

# Step 9: Success!
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   Installation Complete! 🎉"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "Your Google Workspace CMMC Audit Tool is ready!"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. RESTART Claude Desktop (Cmd+Q, then reopen)"
echo "2. Start a new conversation in Claude Desktop"
echo "3. Type: 'Start a CMMC audit for yourdomain.com'"
echo "4. Answer the business context questions"
echo "5. Claude will run 18 checks and guide you through the audit"
echo ""
echo "SECURITY:"
echo ""
echo "  ✓ .env is gitignored (your email is protected)"
echo "  ✓ credentials.json is gitignored (your keys are protected)"
echo "  ✓ File permissions are 600 (owner-only access)"
echo "  ⚠ NEVER commit .env or credentials.json to git!"
echo ""
echo "DOCUMENTATION:"
echo ""
echo "  README:   $INSTALL_DIR/README.md"
echo ""
echo "TROUBLESHOOTING:"
echo ""
echo "  If Claude says 'Server disconnected':"
echo "  - Make sure you restarted Claude Desktop (Cmd+Q)"
echo "  - Check credentials.json is in: $INSTALL_DIR"
echo "  - Check .env file exists with your admin email"
echo "  - Verify domain-wide delegation is configured"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
