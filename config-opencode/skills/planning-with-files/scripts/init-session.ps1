# Initialize planning files for a new session
# Usage: .\init-session.ps1 [project-name]

param(
    [string]$ProjectName = "project"
)

$DATE = Get-Date -Format "yyyy-MM-dd"

Write-Host "Initializing planning files for: $ProjectName"

# Create task_plan.md if it doesn't exist
if (-not (Test-Path "task_plan.md")) {
    @"
# Task Plan: [Brief Description]

## Goal
[One sentence describing the end state]

## Current Phase
Phase 1

## Phases

### Phase 1: Requirements & Discovery
- [ ] Understand user intent
- [ ] Identify constraints and requirements
- [ ] Document findings in findings.md
- **Status:** in_progress

### Phase 2: Planning & Structure
- [ ] Define technical approach
- [ ] Create project structure if needed
- [ ] Document decisions with rationale
- **Status:** pending

### Phase 3: Implementation
- [ ] Execute the plan step by step
- [ ] Write code to files before executing
- [ ] Test incrementally
- **Status:** pending

### Phase 4: Testing & Verification
- [ ] Verify all requirements met
- [ ] Document test results in progress.md
- [ ] Fix any issues found
- **Status:** pending

### Phase 5: Delivery
- [ ] Review all output files
- [ ] Ensure deliverables are complete
- [ ] Deliver to user
- **Status:** pending

## Decisions Made
| Decision | Rationale |
|----------|-----------|

## Errors Encountered
| Error | Resolution |
|-------|------------|
"@ | Out-File -FilePath "task_plan.md" -Encoding UTF8
    Write-Host "Created task_plan.md"
} else {
    Write-Host "task_plan.md already exists, skipping"
}

# Create findings.md if it doesn't exist
if (-not (Test-Path "findings.md")) {
    @"
# Findings & Decisions

## Requirements
-

## Research Findings
-

## Technical Decisions
| Decision | Rationale |
|----------|-----------|

## Issues Encountered
| Issue | Resolution |
|-------|------------|

## Resources
-
"@ | Out-File -FilePath "findings.md" -Encoding UTF8
    Write-Host "Created findings.md"
} else {
    Write-Host "findings.md already exists, skipping"
}

# Create progress.md if it doesn't exist
if (-not (Test-Path "progress.md")) {
    @"
# Progress Log

## Session: $DATE

### Current Status
- **Phase:** 1 - Requirements & Discovery
- **Started:** $DATE

### Actions Taken
-

### Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|

### Errors
| Error | Resolution |
|-------|------------|
"@ | Out-File -FilePath "progress.md" -Encoding UTF8
    Write-Host "Created progress.md"
} else {
    Write-Host "progress.md already exists, skipping"
}

Write-Host ""
Write-Host "Planning files initialized!"
Write-Host "Files: task_plan.md, findings.md, progress.md"
