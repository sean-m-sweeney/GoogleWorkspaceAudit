#!/bin/bash

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "   Google Workspace CMMC Audit Tool - Uninstaller"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Detect OS for config path
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CLAUDE_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
else
    echo "WARNING: Unsupported OS: $OSTYPE"
    CLAUDE_CONFIG=""
fi

echo "This script will help you uninstall the CMMC Audit Tool."
echo ""

# Step 1: Remove Claude Desktop Configuration
echo "Step 1: Removing Claude Desktop MCP Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "$CLAUDE_CONFIG" ]; then
    # Check if the workspace-audit entry exists
    if grep -q "workspace-audit" "$CLAUDE_CONFIG"; then
        echo "Found workspace-audit configuration in Claude Desktop."
        echo ""
        read -p "Remove MCP server configuration from Claude Desktop? (y/n): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Create backup
            cp "$CLAUDE_CONFIG" "${CLAUDE_CONFIG}.backup"
            echo "✓ Created backup: ${CLAUDE_CONFIG}.backup"

            # Remove the workspace-audit entry using sed
            # This is complex because we need to handle JSON properly
            echo ""
            echo "Manual step required:"
            echo ""
            echo "Please edit the following file and remove the 'workspace-audit' entry:"
            echo "  $CLAUDE_CONFIG"
            echo ""
            echo "1. Open the file in a text editor"
            echo "2. Find and delete the 'workspace-audit' section under 'mcpServers'"
            echo "3. Save the file"
            echo ""
            read -p "Press Enter when you've completed this step..."
            echo ""
            echo "✓ Please restart Claude Desktop for changes to take effect (Cmd+Q or Ctrl+Q)"
        else
            echo "Skipped removing Claude Desktop configuration."
        fi
    else
        echo "✓ No workspace-audit configuration found in Claude Desktop."
    fi
else
    echo "✓ Claude Desktop config file not found (may not be installed)."
fi

echo ""

# Step 2: Service Account Cleanup Instructions
echo "Step 2: Service Account Cleanup (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "IMPORTANT: Only delete the service account if you are PERMANENTLY"
echo "   decommissioning this tool. If you plan to use it again in the future,"
echo "   keep the service account."
echo ""
read -p "Do you want instructions for deleting the service account? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "To delete the service account:"
    echo ""
    echo "1. Go to: https://console.cloud.google.com"
    echo "2. Select your project"
    echo "3. Navigate: IAM & Admin → Service Accounts"
    echo "4. Find 'workspace-audit' service account"
    echo "5. Click the three dots (⋮) → Delete"
    echo ""
    echo "6. Go to: https://admin.google.com"
    echo "7. Navigate: Security → API Controls → Domain-wide Delegation"
    echo "8. Find and remove the delegation for this service account"
    echo ""
    echo "After deleting the service account, you will need to create a new one"
    echo "   if you want to reinstall this tool in the future."
    echo ""
    read -p "Press Enter to continue..."
else
    echo "✓ Keeping service account (recommended for future use)."
fi

echo ""

# Step 3: Remove Project Files
echo "Step 3: Remove Project Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get the directory where this script is located
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installation directory: $INSTALL_DIR"
echo ""
echo "Choose what to delete:"
echo "  1) Delete everything (including credentials.json)"
echo "  2) Delete only application files (keep credentials.json for reinstall)"
echo "  3) Keep everything"
echo ""
read -p "Enter choice (1-3): " -n 1 -r
echo

case $REPLY in
    1)
        echo ""
        echo "WARNING: This will delete EVERYTHING including credentials.json"
        read -p "Are you absolutely sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            cd ..
            rm -rf "$INSTALL_DIR"
            echo "✓ Deleted: $INSTALL_DIR"
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            echo "   Uninstallation Complete!"
            echo "═══════════════════════════════════════════════════════════"
            exit 0
        else
            echo "Cancelled. Nothing deleted."
        fi
        ;;
    2)
        echo ""
        echo "Deleting application files (keeping credentials.json)..."
        rm -rf "$INSTALL_DIR/node_modules"
        rm -f "$INSTALL_DIR/server.js"
        rm -f "$INSTALL_DIR/package.json"
        rm -f "$INSTALL_DIR/package-lock.json"
        rm -f "$INSTALL_DIR/test-auth.js"
        rm -f "$INSTALL_DIR/setup.sh"
        echo "✓ Application files deleted"
        echo "✓ Kept: credentials.json (for future reinstall)"
        ls -la "$INSTALL_DIR"
        ;;
    3)
        echo "✓ Keeping all project files"
        ;;
    *)
        echo "Invalid choice. Keeping all files."
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "   Uninstallation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  • Claude Desktop: MCP configuration removed (restart required)"
echo "  • Service Account: Still exists in Google Cloud (delete manually if needed)"
echo "  • Project Files: $([[ $REPLY == "1" ]] && echo "Deleted" || echo "Kept")"
echo ""
echo "To reinstall in the future:"
echo "  • If you kept credentials.json, just run the installer again"
echo "  • If you deleted everything, you'll need to set up a new service account"
echo ""
echo "Thank you for using the CMMC Audit Tool!"
echo ""
