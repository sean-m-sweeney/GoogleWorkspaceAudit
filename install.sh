#!/bin/bash

# Google Workspace Compliance Audit Tool - One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/main/install.sh | bash
# Supports: Claude Desktop, ChatGPT Desktop

set -e

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "   Google Workspace Compliance Audit Tool - Installer"
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

# Detect available AI clients
CLAUDE_AVAILABLE=false
CHATGPT_AVAILABLE=false

if [ -d "/Applications/Claude.app" ]; then
    CLAUDE_AVAILABLE=true
    echo "✓ Claude Desktop detected"
fi

if [ -d "/Applications/ChatGPT.app" ]; then
    CHATGPT_AVAILABLE=true
    echo "✓ ChatGPT Desktop detected"
fi

if [ "$CLAUDE_AVAILABLE" = false ] && [ "$CHATGPT_AVAILABLE" = false ]; then
    echo "⚠  No supported AI clients detected"
    echo "   Supported clients:"
    echo "   - Claude Desktop: https://claude.ai/download"
    echo "   - ChatGPT Desktop: https://openai.com/chatgpt/download"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

echo ""
echo "✓ All prerequisites met!"
echo ""

# Step 2: Select AI Client(s)
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 2: Select AI Client(s)"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "Which AI client(s) would you like to configure?"
echo ""
echo "  1) Claude Desktop"
echo "  2) ChatGPT Desktop"
echo "  3) Both"
echo ""
read -p "Enter choice (1-3): " -n 1 -r CLIENT_CHOICE < /dev/tty
echo ""

CONFIGURE_CLAUDE=false
CONFIGURE_CHATGPT=false

case $CLIENT_CHOICE in
    1)
        CONFIGURE_CLAUDE=true
        echo "✓ Will configure Claude Desktop"
        ;;
    2)
        CONFIGURE_CHATGPT=true
        echo "✓ Will configure ChatGPT Desktop"
        ;;
    3)
        CONFIGURE_CLAUDE=true
        CONFIGURE_CHATGPT=true
        echo "✓ Will configure both Claude Desktop and ChatGPT Desktop"
        ;;
    *)
        echo "Invalid choice. Defaulting to Claude Desktop."
        CONFIGURE_CLAUDE=true
        ;;
esac

echo ""

# Step 3: Setup Project Directory
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 3: Setting Up Project Directory"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

INSTALL_DIR="$HOME/workspace-compliance-audit"
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
    BRANCH="main"
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/${BRANCH}/server.js -o server.js
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/${BRANCH}/uninstall.sh -o uninstall.sh
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/${BRANCH}/README.md -o README.md
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/${BRANCH}/package.json -o package.json
    curl -sSL https://raw.githubusercontent.com/sean-m-sweeney/GoogleWorkspaceAudit/${BRANCH}/package-lock.json -o package-lock.json
    chmod +x uninstall.sh
    echo "✓ Downloaded files"
fi

# Verify package.json exists (should have been downloaded or copied)
if [ ! -f "package.json" ]; then
    echo "✗ package.json not found - creating it..."
    cat > package.json << 'PACKAGE_EOF'
{
  "name": "workspace-compliance-audit",
  "version": "1.1.0",
  "type": "module",
  "description": "Google Workspace Compliance Audit Tool - Multi-Framework Support",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "0.6.1",
    "dotenv": "16.4.5",
    "googleapis": "166.0.0"
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

# Step 4: Install Dependencies
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 4: Installing Dependencies"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

# Proactively fix npm cache permissions (common issue on Macs)
# This prevents EACCES errors before they happen
if [ -d "$HOME/.npm" ]; then
    echo "Checking npm cache permissions..."

    # Check for root-owned files anywhere in the npm cache
    # This is a common issue from running npm with sudo previously
    ROOT_FILES=$(find "$HOME/.npm" -user 0 2>/dev/null | head -1)

    if [ -n "$ROOT_FILES" ]; then
        echo "⚠ Found root-owned files in npm cache. Fixing with sudo..."
        echo ""
        # Need to prompt for sudo password - requires TTY
        sudo chown -R $(whoami) "$HOME/.npm" < /dev/tty || {
            echo ""
            echo "✗ Could not fix npm cache permissions."
            echo ""
            echo "Please run this command manually, then try the installer again:"
            echo "  sudo chown -R \$(whoami) ~/.npm"
            echo ""
            exit 1
        }
        echo "✓ npm cache permissions fixed"
    else
        echo "✓ npm cache permissions OK"
    fi
    echo ""
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

# Step 5: Google Cloud Setup Guide
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 5: Google Cloud & Workspace Setup"
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

# Step 6: Configure Credentials
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 6: Configuring Credentials"
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

# Step 7: Configure Admin Email
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 7: Configuring Admin Email"
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
echo "SECURITY NOTE: Your email is now stored in .env which is:"
echo "   ✓ Excluded from git via .gitignore"
echo "   ✓ Protected with 600 permissions"
echo "   ✓ Never committed to version control"

# Find node path (used by both clients)
NODE_PATH=$(which node)

# Step 8: Configure AI Client(s)
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 8: Configuring AI Client(s)"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""

# Configure Claude Desktop
if [ "$CONFIGURE_CLAUDE" = true ]; then
    echo "Configuring Claude Desktop..."
    CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    mkdir -p "$(dirname "$CLAUDE_CONFIG")"

    if [ -f "$CLAUDE_CONFIG" ]; then
        echo "✓ Loaded existing Claude Desktop config"
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
    echo "  Config: $CLAUDE_CONFIG"
    echo ""
fi

# Configure ChatGPT Desktop
if [ "$CONFIGURE_CHATGPT" = true ]; then
    echo "Configuring ChatGPT Desktop..."
    CHATGPT_CONFIG="$HOME/Library/Application Support/com.openai.chat/mcp.json"
    mkdir -p "$(dirname "$CHATGPT_CONFIG")"

    if [ -f "$CHATGPT_CONFIG" ]; then
        echo "✓ Loaded existing ChatGPT Desktop config"
        python3 << PYTHON_EOF
import json
with open('$CHATGPT_CONFIG', 'r') as f:
    config = json.load(f)
if 'mcpServers' not in config:
    config['mcpServers'] = {}
config['mcpServers']['workspace-audit'] = {
    'command': '$NODE_PATH',
    'args': ['$INSTALL_DIR/server.js'],
    'cwd': '$INSTALL_DIR'
}
with open('$CHATGPT_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
PYTHON_EOF
    else
        cat > "$CHATGPT_CONFIG" << CONFIG_EOF
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
    echo "✓ ChatGPT Desktop configured"
    echo "  Config: $CHATGPT_CONFIG"
    echo ""
    echo "NOTE: ChatGPT requires MCP to be enabled in Developer Mode:"
    echo "  Settings → Connectors → Advanced → Developer Mode"
    echo ""
fi

# Step 9: Test Server
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   STEP 9: Testing Server"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "Starting server test..."
echo ""

# Test server (timeout after 2 seconds)
timeout 2 node server.js > /tmp/server-test.log 2>&1 || true

if grep -q "MCP server running on stdio" /tmp/server-test.log; then
    echo "✓ Server started successfully!"
else
    echo "⚠ Server test completed (check for any errors above)"
fi

rm -f /tmp/server-test.log

# Step 10: Success!
echo ""
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo "   Installation Complete!"
echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
echo ""
echo "Your Google Workspace Compliance Audit Tool is ready!"
echo ""
echo "NEXT STEPS:"
echo ""

if [ "$CONFIGURE_CLAUDE" = true ]; then
    echo "FOR CLAUDE DESKTOP:"
    echo "  1. Restart Claude Desktop (Cmd+Q, then reopen)"
    echo "  2. Start a new conversation"
    echo "  3. Type: 'Start a Google Workspace audit for yourdomain.com'"
    echo ""
fi

if [ "$CONFIGURE_CHATGPT" = true ]; then
    echo "FOR CHATGPT DESKTOP:"
    echo "  1. Enable MCP: Settings → Connectors → Advanced → Developer Mode"
    echo "  2. Restart ChatGPT Desktop (Cmd+Q, then reopen)"
    echo "  3. Start a new conversation"
    echo "  4. Type: 'Start a Google Workspace audit for yourdomain.com'"
    echo ""
fi

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
echo "  If your AI client says 'Server disconnected':"
echo "  - Make sure you restarted the application (Cmd+Q)"
echo "  - Check credentials.json is in: $INSTALL_DIR"
echo "  - Check .env file exists with your admin email"
echo "  - Verify domain-wide delegation is configured"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
