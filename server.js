#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { google } from 'googleapis';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env from the same directory as server.js (not cwd)
dotenv.config({ path: join(__dirname, '.env') });

const credentials = JSON.parse(fs.readFileSync(join(__dirname, 'credentials.json'), 'utf8'));
const ADMIN_EMAIL = process.env.GOOGLE_WORKSPACE_ADMIN_EMAIL;

if (!ADMIN_EMAIL) {
  console.error('ERROR: GOOGLE_WORKSPACE_ADMIN_EMAIL environment variable is not set');
  console.error('Please create a .env file with: GOOGLE_WORKSPACE_ADMIN_EMAIL=your-admin@yourdomain.com');
  process.exit(1);
}

const server = new Server(
  {
    name: 'workspace-cmmc-audit',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

function getAdminClient(scopes) {
  const auth = new google.auth.JWT({
    email: credentials.client_email,
    key: credentials.private_key,
    scopes: scopes,
    subject: ADMIN_EMAIL
  });
  return google.admin({ version: 'directory_v1', auth });
}

function getReportsClient(scopes) {
  const auth = new google.auth.JWT({
    email: credentials.client_email,
    key: credentials.private_key,
    scopes: scopes,
    subject: ADMIN_EMAIL
  });
  return google.admin({ version: 'reports_v1', auth });
}

function getDriveClient(scopes) {
  const auth = new google.auth.JWT({
    email: credentials.client_email,
    key: credentials.private_key,
    scopes: scopes,
    subject: ADMIN_EMAIL
  });
  return google.drive({ version: 'v3', auth });
}

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      // WORKFLOW ORCHESTRATION
      {
        name: 'start_cmmc_audit',
        description: 'Start a comprehensive CMMC Level 2 audit with guided interactive workflow. Use this tool when the user requests a full audit.',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to audit' }
          },
          required: ['domain']
        }
      },
      // ACCESS CONTROL
      {
        name: 'check_2fa_status',
        description: 'Check if 2FA is enforced for all users in the domain',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_admin_roles',
        description: 'List all users with admin privileges and their role assignments',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_session_settings',
        description: 'Check session length and timeout settings',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_external_sharing',
        description: 'Check external sharing settings and restrictions',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_api_access',
        description: 'Check third-party API access and OAuth app permissions',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_groups_external_members',
        description: 'Check for Google Groups that include external members',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      // AUTHENTICATION
      {
        name: 'check_password_policy',
        description: 'Check password strength and policy requirements',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_inactive_accounts',
        description: 'Identify user accounts that have not logged in for 90+ days',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      // AUDIT & ACCOUNTABILITY
      {
        name: 'check_audit_log_settings',
        description: 'Check audit log retention and monitoring configuration',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_suspicious_activity',
        description: 'Check for recent security alerts and suspicious login attempts',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      // SYSTEM PROTECTION
      {
        name: 'check_mobile_devices',
        description: 'Check mobile device management enrollment and encryption status',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_email_authentication',
        description: 'Check SPF, DKIM, and DMARC email authentication status',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_email_forwarding',
        description: 'Check for email forwarding rules to external addresses',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_calendar_sharing',
        description: 'Check calendar external sharing settings',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_data_regions',
        description: 'Check data residency and storage regions',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      // MSP OPERATIONS
      {
        name: 'check_shared_drives',
        description: 'Check shared drive permissions and external access',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_license_utilization',
        description: 'Check license assignment and utilization',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      {
        name: 'check_storage_usage',
        description: 'Check storage quota usage across users',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain to check' }
          },
          required: ['domain']
        }
      },
      // REPORTING
      {
        name: 'generate_comprehensive_report',
        description: 'Generate a comprehensive CMMC audit report from collected findings',
        inputSchema: {
          type: 'object',
          properties: {
            domain: { type: 'string', description: 'The Google Workspace domain audited' },
            findings: {
              type: 'object',
              description: 'Collected audit findings from all checks (as JSON object)'
            },
            context_notes: {
              type: 'string',
              description: 'Optional additional context gathered during Q&A sessions'
            }
          },
          required: ['domain', 'findings']
        }
      }
    ]
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const toolName = request.params.name;
  const domain = request.params.arguments.domain;

  try {
    // WORKFLOW ORCHESTRATION
    if (toolName === 'start_cmmc_audit') {
      const workflowInstructions = `
# CMMC Level 2 Audit Workflow Started for ${domain}

Follow this structured workflow to conduct a comprehensive audit:

## PHASE 0: BUSINESS CONTEXT (START HERE - DO NOT SKIP)

Before running ANY checks, ask the user these questions:

1. "Can you describe in a couple of sentences what your business does?"
2. "How many employees does your organization have?"

**Store this information** - you'll use it to contextualize findings and include in the final report.

---

## PHASE 1: ACCESS CONTROL (6 checks)

Run these tools:
- check_2fa_status
- check_admin_roles
- check_session_settings
- check_external_sharing
- check_api_access
- check_groups_external_members

**After displaying ALL results, STOP and ask:**
1. "Are there any users without 2FA that should be exceptions (service accounts)?"
2. "Can you provide context on external group members or sharing?"

**WAIT FOR THE USER'S RESPONSE. DO NOT PROCEED TO PHASE 2 UNTIL THE USER ANSWERS.**

Store their responses, then continue to Phase 2.

---

## PHASE 2: AUTHENTICATION (2 checks)

Run these tools:
- check_password_policy
- check_inactive_accounts

**After displaying results, STOP and ask:**
1. "Are any inactive accounts intentional (seasonal workers, extended leave)?"

**WAIT FOR THE USER'S RESPONSE. DO NOT PROCEED TO PHASE 3 UNTIL THE USER ANSWERS.**

Store responses, then continue to Phase 3.

---

## PHASE 3: AUDIT & ACCOUNTABILITY (2 checks)

Run these tools:
- check_audit_log_settings
- check_suspicious_activity

**After displaying results, STOP and ask:**
1. "Do you have a SIEM or log aggregation system?"
2. "Are you exporting audit logs for long-term retention (1+ year for CMMC)?"

**WAIT FOR THE USER'S RESPONSE. DO NOT PROCEED TO PHASE 4 UNTIL THE USER ANSWERS.**

Store responses, then continue to Phase 4.

---

## PHASE 4: SYSTEM PROTECTION (5 checks)

Run these tools:
- check_mobile_devices
- check_email_authentication
- check_email_forwarding
- check_calendar_sharing
- check_data_regions

**After displaying results, STOP and ask:**
1. "Do you have a BYOD policy or corporate device policy?"
2. "Are you handling ITAR-controlled data that requires US-only residency?"

**WAIT FOR THE USER'S RESPONSE. DO NOT PROCEED TO PHASE 5 UNTIL THE USER ANSWERS.**

Store responses, then continue to Phase 5.

---

## PHASE 5: MSP OPERATIONS (3 checks)

Run these tools:
- check_shared_drives
- check_license_utilization
- check_storage_usage

**After displaying results, STOP and ask:**
1. "Would you like recommendations on removing inactive licenses for cost savings?"
2. "Are external shared drive accesses business-critical?"

**WAIT FOR THE USER'S RESPONSE. DO NOT PROCEED TO PHASE 6 UNTIL THE USER ANSWERS.**

Store responses, then continue to Phase 6.

---

## PHASE 6: MANUAL VERIFICATION (CRITICAL - DO NOT SKIP)

**Say to the user:**
"Before generating the final report, I need to verify several settings that require manual checks in Google Admin Console. I'll walk you through each one."

For EACH manual check that returned "Manual verification required", request a screenshot:

### Session Settings (if applicable)
"Let's verify your session control settings:
1. Go to: Google Admin Console > Security > Session control
2. Take a screenshot showing session length and idle timeout
3. Share the screenshot

This verifies CMMC's 15-minute idle timeout requirement."

**When screenshot provided:**
- Analyze it carefully
- Note actual values (e.g., "Web: 8 hours, Idle: 15 min")
- Determine: PASS or FAIL

### External Sharing (if applicable)
"Let's verify external sharing:
1. Go to: Google Admin Console > Apps > Google Workspace > Drive and Docs
2. Click Sharing settings
3. Screenshot the sharing configuration
4. Share it"

**When provided:** Analyze and store findings.

### Password Policy (if applicable)
"Let's verify password policy:
1. Go to: Google Admin Console > Security > Password management
2. Screenshot minimum length and reuse prevention settings
3. Share it"

**When provided:** Check if ≥12 chars and ≥24 password history.

### Email Authentication (if applicable)
"Let's verify email authentication (SPF/DKIM/DMARC):

**For DNS records, you'll need to check manually:**

Option 1 (Recommended) - Use MXToolbox:
1. Go to https://mxtoolbox.com/SuperTool.aspx
2. Enter your domain: ${domain}
3. Check: SPF Record, DKIM Record, DMARC Record
4. Copy and paste the results here

Option 2 - Command line (if you have access):
Run these commands:
- nslookup -type=TXT ${domain}
- nslookup -type=TXT google._domainkey.${domain}
- nslookup -type=TXT _dmarc.${domain}

Option 3 - Google Admin Console:
1. Go to Admin Console > Apps > Gmail > Authenticate email
2. Screenshot the DKIM and SPF settings
3. Share the screenshot

**Note:** I cannot perform DNS lookups directly. Please use one of the methods above and share the results."

**Continue this pattern for all manual checks.**

After ALL screenshots collected, say:
"Thank you! I've verified all manual settings. Now generating your comprehensive report..."

---

## PHASE 7: GENERATE COMPREHENSIVE REPORT

Compile everything:
1. Business context (Phase 0)
2. All automated check results (Phases 1-5)
3. Manual verification findings from screenshots (Phase 6)
4. All Q&A responses

**IMPORTANT: Create a findings object structured like this:**

findings = {
  "check_2fa_status": { result from that check },
  "check_admin_roles": { result from that check },
  "check_password_policy": { result from that check, including manual verification if done },
  ... (all 18 checks)
}

**Then call: generate_comprehensive_report**

Parameters:
- domain: ${domain}
- findings: The findings object above (as a JSON object, not a string)
- context_notes: Text containing all context:

"BUSINESS CONTEXT:
Organization: [from Phase 0]
Employees: [from Phase 0]

PHASE 1-5 CONTEXT:
[All Q&A responses]

MANUAL VERIFICATION RESULTS:
Session Settings: [findings from screenshot]
Password Policy: [findings from screenshot]
Email Authentication: [findings from DNS lookup or screenshot]
... [other manual verifications]
"

Present the final report with:
- Executive summary (include business context)
- Compliance score
- Findings by control area
- Priority recommendations
- Cost optimization opportunities
- Next steps

---

## IMPORTANT REMINDERS

✓ DO NOT skip Phase 0 (business context)
✓ DO NOT skip Phase 6 (screenshot verification)
✓ DO request screenshots with specific navigation instructions
✓ DO analyze screenshots when provided
✓ DO include ALL context in the final report
✓ DO tailor recommendations to organization size and industry

Start with Phase 0 now!
`;

      return {
        content: [{
          type: 'text',
          text: workflowInstructions
        }]
      };
    }

    // ACCESS CONTROL CHECKS
    if (toolName === 'check_2fa_status') {
      const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.user.readonly']);
      const users = await admin.users.list({ customer: 'my_customer', maxResults: 500 });

      let usersWithout2FA = 0;
      let totalUsers = 0;
      let adminWithout2FA = 0;

      for (const user of users.data.users || []) {
        totalUsers++;
        if (!user.isEnrolledIn2Sv) {
          usersWithout2FA++;
          if (user.isAdmin) adminWithout2FA++;
        }
      }

      const result = {
        domain: domain,
        total_users: totalUsers,
        mfa_enforced: usersWithout2FA === 0,
        users_without_mfa: usersWithout2FA,
        admin_accounts_without_mfa: adminWithout2FA,
        cmmc_control: 'IA.L2-3.5.3',
        recommendation: usersWithout2FA > 0
          ? 'Enable 2FA enforcement for all users. Require hardware security keys for admin accounts.'
          : 'All users have 2FA enabled. Consider requiring hardware security keys for privileged accounts.',
        licensing_note: '2FA is included in all Google Workspace editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_admin_roles') {
      const admin = getAdminClient([
        'https://www.googleapis.com/auth/admin.directory.user.readonly',
        'https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly'
      ]);

      const users = await admin.users.list({ customer: 'my_customer', maxResults: 500 });
      const adminUsers = users.data.users?.filter(u => u.isAdmin) || [];

      const result = {
        domain: domain,
        total_admin_users: adminUsers.length,
        super_admins: adminUsers.filter(u => u.isAdmin && !u.isDelegatedAdmin).length,
        delegated_admins: adminUsers.filter(u => u.isDelegatedAdmin).length,
        admin_accounts: adminUsers.map(u => ({
          email: u.primaryEmail,
          name: u.name?.fullName,
          is_super_admin: u.isAdmin && !u.isDelegatedAdmin,
          has_2fa: u.isEnrolledIn2Sv,
          suspended: u.suspended
        })),
        cmmc_control: 'AC.L2-3.1.5',
        recommendation: adminUsers.length > 2
          ? 'Review admin access. Limit super admin privileges to essential personnel only.'
          : 'Admin account count is reasonable. Ensure all admins have hardware security keys.',
        licensing_note: 'Admin role management is included in all Google Workspace editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_groups_external_members') {
      const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.group.readonly']);

      const groups = await admin.groups.list({ customer: 'my_customer' });
      const groupsWithExternal = [];

      for (const group of groups.data.groups || []) {
        try {
          const members = await admin.members.list({ groupKey: group.email });
          const externalMembers = members.data.members?.filter(m =>
            !m.email.endsWith(`@${domain}`)
          ) || [];

          if (externalMembers.length > 0) {
            groupsWithExternal.push({
              group_email: group.email,
              group_name: group.name,
              external_member_count: externalMembers.length,
              external_members: externalMembers.map(m => m.email)
            });
          }
        } catch (error) {
          // Skip groups we can't access
        }
      }

      const result = {
        domain: domain,
        total_groups: groups.data.groups?.length || 0,
        groups_with_external_members: groupsWithExternal.length,
        external_access_details: groupsWithExternal,
        cmmc_control: 'AC.L2-3.1.20',
        recommendation: groupsWithExternal.length > 0
          ? 'Review groups with external members. Ensure external access is authorized and necessary. Remove external members from groups that handle CUI.'
          : 'No groups found with external members.',
        licensing_note: 'Group management included in all Google Workspace editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_session_settings') {
      const result = {
        domain: domain,
        cmmc_control: 'AC.L2-3.1.11',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Security > Session control',
          'Session length for web applications',
          'Session length for mobile devices',
          'Idle timeout settings'
        ],
        cmmc_requirement: 'Sessions should terminate after 15 minutes of inactivity or 8 hours maximum',
        recommendation: 'Set session length to 8 hours maximum. Enable idle timeout at 15 minutes.',
        licensing_note: 'Session controls require Google Workspace Enterprise editions.',
        licensing_impact: 'Requires Enterprise Standard, Enterprise Plus, or Education Plus (~$18-23/user/month).'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_external_sharing') {
      const result = {
        domain: domain,
        cmmc_control: 'AC.L2-3.1.20',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Apps > Google Workspace > Drive and Docs',
          'Sharing settings > Sharing outside of organization',
          'Default link sharing setting',
          'Who can publish files to web',
          'Warning when sharing outside domain'
        ],
        cmmc_requirement: 'Control external sharing. Restrict CUI to authorized personnel only.',
        recommendation: 'Set sharing to organization only OR require approval for external shares. Enable warnings for external sharing.',
        licensing_note: 'Basic sharing controls included in all editions.',
        licensing_impact: 'Data Loss Prevention (DLP) for automated CUI detection requires Enterprise editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_api_access') {
      const result = {
        domain: domain,
        cmmc_control: 'AC.L2-3.1.2',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Security > API controls',
          'App access control settings',
          'Third-party apps with access to Google Workspace',
          'OAuth app verification status',
          'Risky apps with access to sensitive scopes'
        ],
        cmmc_requirement: 'Limit system access to authorized users, processes, or devices.',
        recommendation: 'Review all third-party apps. Remove unnecessary apps. Consider restricting to allow-listed apps only.',
        licensing_note: 'API controls included in all editions.',
        licensing_impact: 'Context-aware access policies require Enterprise editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    // AUTHENTICATION CHECKS
    if (toolName === 'check_password_policy') {
      const result = {
        domain: domain,
        cmmc_control: 'IA.L2-3.5.7',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Security > Password management',
          'Minimum password length (should be 12+ characters)',
          'Password strength requirements',
          'Password reuse prevention',
          'Password expiration policy'
        ],
        cmmc_requirement: 'Passwords must be minimum 12 characters. Prevent password reuse for last 24 passwords.',
        recommendation: 'Configure: 12+ character minimum, enable password reuse prevention for 24 passwords.',
        licensing_note: 'Basic password policies included in all editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_inactive_accounts') {
      const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.user.readonly']);
      const users = await admin.users.list({ customer: 'my_customer', maxResults: 500 });

      const ninetyDaysAgo = new Date();
      ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

      const inactiveAccounts = [];
      for (const user of users.data.users || []) {
        if (user.lastLoginTime) {
          const lastLogin = new Date(user.lastLoginTime);
          if (lastLogin < ninetyDaysAgo && !user.suspended) {
            const daysSinceLogin = Math.floor((new Date() - lastLogin) / (1000 * 60 * 60 * 24));
            inactiveAccounts.push({
              email: user.primaryEmail,
              name: user.name?.fullName,
              last_login: user.lastLoginTime,
              days_since_login: daysSinceLogin,
              is_admin: user.isAdmin || false
            });
          }
        } else if (!user.suspended) {
          inactiveAccounts.push({
            email: user.primaryEmail,
            name: user.name?.fullName,
            last_login: 'Never',
            days_since_login: 'N/A',
            is_admin: user.isAdmin || false
          });
        }
      }

      const result = {
        domain: domain,
        total_users: users.data.users?.length || 0,
        inactive_accounts: inactiveAccounts.length,
        inactive_account_details: inactiveAccounts,
        cmmc_control: 'AC.L2-3.1.1',
        recommendation: inactiveAccounts.length > 0
          ? `Found ${inactiveAccounts.length} inactive accounts. Suspend or remove accounts that are no longer needed. This reduces security risk and may save on licensing costs.`
          : 'No inactive accounts found.',
        licensing_note: 'Inactive accounts still consume licenses and cost money.',
        msp_value: `Potential cost savings: ~$6-12/month per inactive license removed.`
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    // AUDIT & ACCOUNTABILITY
    if (toolName === 'check_audit_log_settings') {
      const result = {
        domain: domain,
        cmmc_control: 'AU.L2-3.3.1',
        status: 'Partial - Manual verification required',
        automatic_checks: {
          audit_logs_enabled: true,
          note: 'Google Workspace automatically maintains audit logs for admin actions, login events, and data access'
        },
        what_to_check_manually: [
          'Google Admin Console > Reporting > Audit and investigation',
          'Verify audit logs are being generated',
          'Check retention period (Google Workspace keeps logs for varying periods)',
          'Admin audit logs: Indefinite retention',
          'Login audit logs: 6 months',
          'Drive audit logs: 6 months'
        ],
        cmmc_requirement: 'Create and retain audit records. Logs must be retained for at least 1 year for CMMC Level 2.',
        recommendation: 'Export and archive critical audit logs to meet 1-year retention requirement. Consider third-party SIEM for long-term log retention.',
        licensing_note: 'Basic audit logs included in all editions.',
        licensing_impact: 'Extended log retention via Google Vault requires Business Plus or Enterprise editions. Third-party SIEM integration may be needed for full CMMC compliance.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_suspicious_activity') {
      try {
        const reports = getReportsClient(['https://www.googleapis.com/auth/admin.reports.audit.readonly']);

        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const loginEvents = await reports.activities.list({
          userKey: 'all',
          applicationName: 'login',
          startTime: sevenDaysAgo.toISOString()
        });

        const suspiciousEvents = loginEvents.data.items?.filter(event =>
          event.events?.some(e =>
            e.name === 'login_failure' ||
            e.name === 'suspicious_login' ||
            e.name === 'account_disabled_suspicious_activity'
          )
        ) || [];

        const result = {
          domain: domain,
          check_period: 'Last 7 days',
          suspicious_events_found: suspiciousEvents.length,
          event_details: suspiciousEvents.slice(0, 10).map(e => ({
            user: e.actor?.email,
            event_type: e.events?.[0]?.name,
            timestamp: e.id?.time,
            ip_address: e.ipAddress
          })),
          cmmc_control: 'AU.L2-3.3.4',
          recommendation: suspiciousEvents.length > 0
            ? 'Review suspicious login attempts. Investigate failed logins and implement account lockout policies if needed.'
            : 'No suspicious activity detected in the last 7 days.',
          licensing_note: 'Security alerts included in all editions.'
        };

        return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
      } catch (error) {
        return {
          content: [{ type: 'text', text: JSON.stringify({
            domain: domain,
            error: 'Unable to retrieve security events. May require additional API permissions.',
            cmmc_control: 'AU.L2-3.3.4'
          }, null, 2) }]
        };
      }
    }

    // SYSTEM PROTECTION
    if (toolName === 'check_mobile_devices') {
      try {
        const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.device.mobile.readonly']);

        const devices = await admin.mobiledevices.list({ customerId: 'my_customer' });
        const mobileDevices = devices.data.mobiledevices || [];

        const unapprovedDevices = mobileDevices.filter(d => d.status !== 'APPROVED').length;
        const unencryptedDevices = mobileDevices.filter(d => !d.encryptionStatus || d.encryptionStatus === 'NOT_ENCRYPTED');

        const result = {
          domain: domain,
          total_mobile_devices: mobileDevices.length,
          approved_devices: mobileDevices.filter(d => d.status === 'APPROVED').length,
          unapproved_devices: unapprovedDevices,
          unencrypted_devices: unencryptedDevices.length,
          unencrypted_device_details: unencryptedDevices.slice(0, 10).map(d => ({
            model: d.model || 'Unknown',
            os: d.os || 'Unknown',
            type: d.type,
            email: d.email?.[0],
            last_sync: d.lastSync,
            device_id: d.resourceId
          })),
          cmmc_control: 'SC.L2-3.13.11',
          recommendation: unapprovedDevices > 0 || unencryptedDevices.length > 0
            ? 'Review and approve all devices. Enforce encryption on all mobile devices accessing company data.'
            : 'All mobile devices are approved and encrypted.',
          licensing_note: 'Mobile device management is included in all Google Workspace editions.'
        };

        return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
      } catch (error) {
        return {
          content: [{ type: 'text', text: JSON.stringify({
            domain: domain,
            error: 'Unable to access mobile devices. Verify mobile device management API is enabled.',
            cmmc_control: 'SC.L2-3.13.11'
          }, null, 2) }]
        };
      }
    }

    if (toolName === 'check_email_authentication') {
      const result = {
        domain: domain,
        cmmc_control: 'SC.L2-3.13.8',
        status: 'Manual verification required',
        what_to_check: [
          'Verify SPF record exists in DNS',
          'Verify DKIM is enabled in Google Admin Console',
          'Verify DMARC policy is configured',
          'Check for proper alignment of SPF and DKIM'
        ],
        why_important: 'Email authentication prevents spoofing and phishing attacks. Critical for defense contractors.',
        recommendation: 'Ensure SPF, DKIM, and DMARC are all properly configured. Set DMARC policy to "quarantine" or "reject" for maximum protection.',
        dns_check_instructions: 'Use DNS lookup tools to verify: SPF TXT record, DKIM TXT record (google._domainkey), DMARC TXT record (_dmarc)',
        licensing_note: 'Email authentication is included in all Google Workspace editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_email_forwarding') {
      const result = {
        domain: domain,
        cmmc_control: 'AC.L2-3.1.20',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Apps > Google Workspace > Gmail',
          'Advanced settings > Routing',
          'Check for forwarding rules',
          'Review per-user forwarding via Vault or admin reports'
        ],
        security_concern: 'Email forwarding to external addresses can leak sensitive CUI data.',
        recommendation: 'Disable automatic forwarding to external addresses. Implement approval workflow for any necessary forwarding.',
        licensing_note: 'Forwarding controls available in all editions.',
        licensing_impact: 'Gmail data loss prevention (DLP) to block forwarding of sensitive content requires Enterprise editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_calendar_sharing') {
      const result = {
        domain: domain,
        cmmc_control: 'AC.L2-3.1.20',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Apps > Google Workspace > Calendar',
          'Sharing settings > External sharing',
          'Check if calendars can be shared outside organization',
          'Check default sharing settings for new calendars'
        ],
        security_concern: 'Calendar information can reveal operational patterns, meeting schedules with government customers, and other sensitive information.',
        recommendation: 'Restrict calendar sharing to internal only. Disable public calendar sharing.',
        licensing_note: 'Calendar sharing controls included in all editions.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_data_regions') {
      const result = {
        domain: domain,
        cmmc_control: 'SC.L2-3.13.16',
        status: 'Manual verification required',
        what_to_check: [
          'Google Admin Console > Account > Account settings',
          'Data region settings',
          'Verify data is stored in approved regions'
        ],
        itar_note: 'For ITAR-controlled data, data must remain in the United States. Google Workspace allows data region selection.',
        recommendation: 'If handling ITAR or export-controlled data, ensure data region is set to United States only.',
        licensing_note: 'Data region selection available in Enterprise Plus only.',
        licensing_impact: 'Enterprise Plus required (~$23/user/month) for data region controls.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    // MSP OPERATIONS
    if (toolName === 'check_shared_drives') {
      try {
        const drive = getDriveClient(['https://www.googleapis.com/auth/drive.readonly']);

        const sharedDrives = await drive.drives.list({ pageSize: 100 });
        const drivesWithExternal = [];

        for (const drv of sharedDrives.data.drives || []) {
          try {
            const permissions = await drive.permissions.list({
              fileId: drv.id,
              fields: 'permissions(emailAddress,type,role,domain)',
              supportsAllDrives: true
            });

            const externalPerms = permissions.data.permissions?.filter(p =>
              p.type === 'user' && p.emailAddress && !p.emailAddress.endsWith(`@${domain}`)
            ) || [];

            if (externalPerms.length > 0) {
              drivesWithExternal.push({
                drive_name: drv.name,
                drive_id: drv.id,
                external_users: externalPerms.length,
                external_emails: externalPerms.map(p => p.emailAddress)
              });
            }
          } catch (err) {
            // Skip drives we can't access
          }
        }

        const result = {
          domain: domain,
          total_shared_drives: sharedDrives.data.drives?.length || 0,
          drives_with_external_access: drivesWithExternal.length,
          external_access_details: drivesWithExternal,
          cmmc_control: 'AC.L2-3.1.20',
          recommendation: drivesWithExternal.length > 0
            ? 'Review shared drives with external access. Remove external users from drives containing CUI.'
            : 'No shared drives found with external access.',
          licensing_note: 'Shared drives available in Business Standard and above.'
        };

        return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
      } catch (error) {
        return {
          content: [{ type: 'text', text: JSON.stringify({
            domain: domain,
            error: 'Unable to access shared drives. Verify Drive API scope is enabled.',
            cmmc_control: 'AC.L2-3.1.20'
          }, null, 2) }]
        };
      }
    }

    if (toolName === 'check_license_utilization') {
      const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.user.readonly']);
      const users = await admin.users.list({ customer: 'my_customer', maxResults: 500 });

      const activeUsers = users.data.users?.filter(u => !u.suspended).length || 0;
      const suspendedUsers = users.data.users?.filter(u => u.suspended).length || 0;

      // Calculate inactive users (not logged in for 90+ days)
      const ninetyDaysAgo = new Date();
      ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

      const inactiveButLicensed = users.data.users?.filter(u => {
        if (u.suspended) return false;
        if (!u.lastLoginTime) return true;
        const lastLogin = new Date(u.lastLoginTime);
        return lastLogin < ninetyDaysAgo;
      }).length || 0;

      const estimatedMonthlyCost = activeUsers * 12; // Assuming ~$12/user/month average
      const wastedLicenseCost = inactiveButLicensed * 12;

      const result = {
        domain: domain,
        total_users: users.data.users?.length || 0,
        active_users: activeUsers,
        suspended_users: suspendedUsers,
        inactive_but_licensed: inactiveButLicensed,
        estimated_monthly_cost: `$${estimatedMonthlyCost}`,
        potential_savings: `$${wastedLicenseCost}/month`,
        msp_recommendation: inactiveButLicensed > 0
          ? `Remove or suspend ${inactiveButLicensed} inactive licenses to save approximately $${wastedLicenseCost}/month.`
          : 'License utilization is optimal.',
        licensing_note: 'All users with accounts consume licenses, even if inactive.'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    if (toolName === 'check_storage_usage') {
      const admin = getAdminClient(['https://www.googleapis.com/auth/admin.directory.user.readonly']);
      const users = await admin.users.list({ customer: 'my_customer', maxResults: 500 });

      const storageUsers = users.data.users?.map(u => ({
        email: u.primaryEmail,
        name: u.name?.fullName,
        storage_used_bytes: u.quotaBytesUsed ? parseInt(u.quotaBytesUsed) : 0,
        storage_used_gb: u.quotaBytesUsed ? (parseInt(u.quotaBytesUsed) / (1024**3)).toFixed(2) : '0.00'
      })).sort((a, b) => b.storage_used_bytes - a.storage_used_bytes) || [];

      const totalStorageBytes = storageUsers.reduce((sum, u) => sum + u.storage_used_bytes, 0);
      const totalStorageGB = (totalStorageBytes / (1024**3)).toFixed(2);
      const topUsers = storageUsers.slice(0, 10);

      const result = {
        domain: domain,
        total_users: users.data.users?.length || 0,
        total_storage_used_gb: totalStorageGB,
        average_per_user_gb: (totalStorageBytes / users.data.users?.length / (1024**3)).toFixed(2),
        top_storage_consumers: topUsers,
        msp_recommendation: 'Monitor storage growth. Consider archival policies for users approaching quota limits.',
        licensing_note: 'Storage quotas vary by edition: Business Starter (30GB/user), Business Standard (2TB/user), Business Plus/Enterprise (5TB+ pooled).'
      };

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
    }

    // REPORTING
    if (toolName === 'generate_comprehensive_report') {
      let findings = request.params.arguments.findings;
      const contextNotes = request.params.arguments.context_notes || '';

      // Parse findings if it's a string
      if (typeof findings === 'string') {
        try {
          findings = JSON.parse(findings);
        } catch (error) {
          return {
            content: [{
              type: 'text',
              text: JSON.stringify({
                error: 'Failed to parse findings. Findings must be a valid JSON object.',
                help: 'Pass findings as: {"check_2fa_status": {...}, "check_admin_roles": {...}, ...}',
                received_type: typeof findings
              }, null, 2)
            }]
          };
        }
      }

      // Validate findings is an object
      if (!findings || typeof findings !== 'object') {
        return {
          content: [{
            type: 'text',
            text: JSON.stringify({
              error: 'Invalid findings format. Expected an object with check results.',
              received: findings
            }, null, 2)
          }]
        };
      }

      // Categorize findings by control area
      const accessControlFindings = [];
      const authenticationFindings = [];
      const auditFindings = [];
      const systemProtectionFindings = [];
      const mspFindings = [];

      // Risk scoring
      let criticalIssues = 0;
      let highIssues = 0;
      let mediumIssues = 0;
      let licensingImpacts = [];

      // Process findings
      for (const [checkName, data] of Object.entries(findings)) {
        const control = data.cmmc_control || 'Unknown';
        const finding = {
          check: checkName,
          control: control,
          status: data.mfa_enforced === false || data.users_without_mfa > 0 ||
                  data.inactive_accounts > 0 || data.groups_with_external_members > 0 ||
                  data.drives_with_external_access > 0 || data.unencrypted_devices > 0 ||
                  data.suspicious_events_found > 0 ? 'FAIL' : 'PASS',
          recommendation: data.recommendation,
          data: data
        };

        // Categorize by control family
        if (control.startsWith('AC.')) accessControlFindings.push(finding);
        else if (control.startsWith('IA.')) authenticationFindings.push(finding);
        else if (control.startsWith('AU.')) auditFindings.push(finding);
        else if (control.startsWith('SC.')) systemProtectionFindings.push(finding);

        // Track MSP findings
        if (data.msp_recommendation || data.msp_value || data.potential_savings) {
          mspFindings.push({
            check: checkName,
            value: data.msp_recommendation || data.msp_value,
            savings: data.potential_savings
          });
        }

        // Risk scoring
        if (finding.status === 'FAIL') {
          if (checkName.includes('2fa') || checkName.includes('admin')) criticalIssues++;
          else if (checkName.includes('inactive') || checkName.includes('external')) highIssues++;
          else mediumIssues++;
        }

        // Track licensing impacts
        if (data.licensing_impact) {
          licensingImpacts.push({
            check: checkName,
            impact: data.licensing_impact
          });
        }
      }

      const totalIssues = criticalIssues + highIssues + mediumIssues;
      const passedChecks = Object.keys(findings).length - totalIssues;

      // Generate report
      const report = {
        report_metadata: {
          domain: domain,
          generated_at: new Date().toISOString(),
          audit_scope: 'CMMC Level 2 - Google Workspace',
          total_checks: Object.keys(findings).length,
          passed: passedChecks,
          failed: totalIssues
        },
        executive_summary: {
          overall_status: criticalIssues === 0 && highIssues === 0 ? 'ACCEPTABLE' : 'NEEDS ATTENTION',
          critical_issues: criticalIssues,
          high_priority_issues: highIssues,
          medium_priority_issues: mediumIssues,
          compliance_score: `${Math.round((passedChecks / Object.keys(findings).length) * 100)}%`,
          key_findings: [
            criticalIssues > 0 ? `${criticalIssues} critical security issues require immediate attention` : null,
            highIssues > 0 ? `${highIssues} high-priority issues identified` : null,
            mspFindings.length > 0 ? `${mspFindings.length} opportunities for cost optimization identified` : null
          ].filter(Boolean)
        },
        findings_by_control_area: {
          access_control: {
            control_family: 'AC - Access Control',
            total_checks: accessControlFindings.length,
            passed: accessControlFindings.filter(f => f.status === 'PASS').length,
            failed: accessControlFindings.filter(f => f.status === 'FAIL').length,
            findings: accessControlFindings
          },
          authentication: {
            control_family: 'IA - Identification and Authentication',
            total_checks: authenticationFindings.length,
            passed: authenticationFindings.filter(f => f.status === 'PASS').length,
            failed: authenticationFindings.filter(f => f.status === 'FAIL').length,
            findings: authenticationFindings
          },
          audit_accountability: {
            control_family: 'AU - Audit and Accountability',
            total_checks: auditFindings.length,
            passed: auditFindings.filter(f => f.status === 'PASS').length,
            failed: auditFindings.filter(f => f.status === 'FAIL').length,
            findings: auditFindings
          },
          system_protection: {
            control_family: 'SC - System and Communications Protection',
            total_checks: systemProtectionFindings.length,
            passed: systemProtectionFindings.filter(f => f.status === 'PASS').length,
            failed: systemProtectionFindings.filter(f => f.status === 'FAIL').length,
            findings: systemProtectionFindings
          }
        },
        priority_recommendations: [
          criticalIssues > 0 ? 'CRITICAL: Address 2FA and admin access issues immediately' : null,
          highIssues > 0 ? 'HIGH: Review external sharing and inactive accounts' : null,
          licensingImpacts.length > 0 ? 'LICENSING: Enterprise features required for full CMMC compliance' : null
        ].filter(Boolean),
        msp_value_summary: {
          total_opportunities: mspFindings.length,
          cost_optimization: mspFindings,
          licensing_recommendations: licensingImpacts
        },
        additional_context: contextNotes ? contextNotes : 'No additional context provided',
        next_steps: [
          'Review all FAIL findings and prioritize remediation by risk level',
          'Address critical issues (2FA, admin access) within 24-48 hours',
          'Develop remediation plan for high-priority issues',
          'Schedule manual verification checks for items requiring admin console review',
          'Consider licensing upgrades if Enterprise features are needed for compliance',
          'Implement continuous monitoring for ongoing compliance'
        ]
      };

      return {
        content: [{
          type: 'text',
          text: JSON.stringify(report, null, 2)
        }]
      };
    }

    throw new Error(`Unknown tool: ${toolName}`);

  } catch (error) {
    return {
      content: [{ type: 'text', text: JSON.stringify({
        error: error.message,
        tool: toolName,
        domain: domain
      }, null, 2) }]
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Workspace CMMC Audit MCP server running on stdio');
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
