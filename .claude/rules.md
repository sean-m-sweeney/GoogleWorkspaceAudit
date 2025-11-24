# Pair Programming Rules for This Project

## CRITICAL: Read This File First
When starting ANY task, read this file first before doing anything else.

---

## Rule 1: ALWAYS Check What Exists First
**Before creating, writing, or modifying ANY file:**
1. Run `ls -la` to see what files exist in the working directory
2. Use `Read` tool to examine existing files before proposing changes
3. Use `Grep` or `Glob` to search for similar functionality that already exists
4. **NEVER assume a file doesn't exist** - always verify

### Example of What NOT to Do:
- ❌ User says "create install script" → immediately create install.sh
- ❌ Assume configuration doesn't exist → overwrite existing config

### What TO Do:
- ✅ User says "create install script" → First run `ls -la`, find install.sh exists, read it, then enhance it
- ✅ Check for existing patterns before introducing new ones

---

## Rule 2: Understand Before Changing
1. **Read the entire file** before making edits
2. **Understand the architecture** before proposing changes
3. **Ask questions** if requirements are unclear
4. Don't make assumptions about what the user wants

---

## Rule 3: Preserve Working Code
1. **Never replace working code** without explicit permission
2. When enhancing, **merge new functionality** into existing code
3. **Preserve all existing features** when upgrading
4. If you need to replace something, explain WHY and get approval first

---

## Rule 4: Security-Critical Files
These files must NEVER be committed to git:
- `credentials.json` - Service account keys
- `.env` - Environment variables with sensitive data
- Any file matching `*-key.json` or `*.json.key`

**Always verify** `.gitignore` includes these patterns before any git operations.

---

## Rule 5: Git Operations
1. **Never run `git add .` without verifying** what will be staged
2. **Always check git status** before commits
3. **Read the diff** before committing
4. **Verify .gitignore** is working with `git check-ignore -v <file>`

---

## Rule 6: When You Make a Mistake
1. **Acknowledge it immediately** - don't hide or minimize it
2. **Explain what you should have done** differently
3. **Fix it completely** - don't leave partial fixes
4. **Learn from it** - update these rules if needed

---

## Rule 7: Project-Specific Context

### This Project's Architecture:
- **server.js** - Main MCP server, uses dotenv for config
- **install.sh** - Comprehensive 390+ line installer, tested and working
- **credentials.json** - Google service account keys (gitignored)
- **.env** - Contains `GOOGLE_WORKSPACE_ADMIN_EMAIL` (gitignored)
- **.gitignore** - Already configured, don't regenerate without reading first

### Key Dependencies:
- `@modelcontextprotocol/sdk` - MCP integration
- `googleapis` - Google Workspace API
- `dotenv` - Environment variable management

### Environment Variables:
- `GOOGLE_WORKSPACE_ADMIN_EMAIL` - Admin email for service account impersonation

---

## Rule 8: Communication Style
1. **Be concise** but thorough
2. **Explain your reasoning** before acting
3. **Propose options** when multiple approaches exist
4. **Admit uncertainty** - don't fake knowledge
5. **No unnecessary emojis** unless user requests them

---

## Rule 9: Before Starting Any Task
**Mandatory checklist:**
- [ ] Read this rules file
- [ ] Run `ls -la` to see current directory contents
- [ ] Read relevant files that will be affected
- [ ] Check git status if making changes
- [ ] Verify .gitignore if dealing with sensitive files
- [ ] Ask clarifying questions if anything is unclear

---

## Rule 10: When User Reports a Problem
1. **Acknowledge the problem** without defensiveness
2. **Investigate thoroughly** - read files, check state
3. **Explain root cause** clearly
4. **Provide complete fix** - not partial workarounds
5. **Prevent recurrence** - update these rules if needed

---

## Violation Log
When these rules are violated, document it here:

### 2024-11-24: Install Script Overwrite
- **Violation**: Created new install.sh without checking if one existed
- **Impact**: Replaced 390-line working script with 299-line version, lost functionality
- **Lesson**: Always run `ls -la` and read existing files first
- **Rule Added**: Rule 1 - ALWAYS Check What Exists First

---

## Project-Specific Commands

### Testing the Server:
```bash
node server.js
# Should output: "Workspace CMMC Audit MCP server running on stdio"
```

### Checking Git Safety:
```bash
git status --short
git check-ignore -v .env credentials.json
```

### Installing Dependencies:
```bash
npm install
```

---

## Questions to Ask Yourself Before Acting
1. "Have I checked what files already exist?"
2. "Have I read the code I'm about to modify?"
3. "Will this preserve all existing functionality?"
4. "Am I making assumptions, or do I know for sure?"
5. "What could go wrong with this change?"

---

**Last Updated**: 2024-11-24
**Next Review**: After next mistake or major project change
