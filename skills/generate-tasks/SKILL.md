# Generate Tasks - Task List Generator (Opus 4)

**Purpose:** Generate detailed, step-by-step task lists using Claude Opus 4 for maximum clarity and completeness.

**When to invoke:** Use this skill when you need to break down a feature, PRD, or project into actionable development tasks.

---

## CRITICAL: Use Opus 4

**This skill MUST use Claude Opus 4 for optimal results.**

When invoking this skill, Claude will use the Task tool with `model: "opus"` to ensure thorough task breakdown and clarity.

---

## Goal

To guide an AI assistant in creating a detailed, step-by-step task list in Markdown format based on user requirements, feature requests, or existing documentation. The task list should guide a developer through implementation.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `tasks-[feature-name].md` (e.g., `tasks-user-profile-editing.md`)

## Process

1.  **Receive Requirements:** The user provides a feature request, task description, or points to existing documentation
2.  **Analyze Requirements:** The AI analyzes the functional requirements, user needs, and implementation scope from the provided information
3.  **Phase 1: Generate Parent Tasks:** Based on the requirements analysis, create the file and generate the main, high-level tasks required to implement the feature. **IMPORTANT: Always include task 0.0 "Create feature branch" as the first task, unless the user specifically requests not to create a branch.** Use your judgement on how many additional high-level tasks to use. It's likely to be about 5. Present these tasks to the user in the specified format (without sub-tasks yet). Inform the user: "I have generated the high-level tasks based on your requirements. Ready to generate the sub-tasks? Respond with 'Go' to proceed."
4.  **Wait for Confirmation:** Pause and wait for the user to respond with "Go".
5.  **Phase 2: Generate Sub-Tasks:** Once the user confirms, break down each parent task into smaller, actionable sub-tasks necessary to complete the parent task. Ensure sub-tasks logically follow from the parent task and cover the implementation details implied by the requirements.
6.  **Identify Relevant Files:** Based on the tasks and requirements, identify potential files that will need to be created or modified. List these under the `Relevant Files` section, including corresponding test files if applicable.
7.  **Generate Final Output:** Combine the parent tasks, sub-tasks, relevant files, and notes into the final Markdown structure.
8.  **Save Task List:** Save the generated document in the `/tasks/` directory with the filename `tasks-[feature-name].md`, where `[feature-name]` describes the main feature or task being implemented (e.g., if the request was about user profile editing, the output is `tasks-user-profile-editing.md`).

## Output Format

The generated task list _must_ follow this structure:

```markdown
## Relevant Files

- `path/to/potential/file1.ts` - Brief description of why this file is relevant (e.g., Contains the main component for this feature).
- `path/to/file1.test.ts` - Unit tests for `file1.ts`.
- `path/to/another/file.tsx` - Brief description (e.g., API route handler for data submission).
- `path/to/another/file.test.tsx` - Unit tests for `another/file.tsx`.
- `lib/utils/helpers.ts` - Brief description (e.g., Utility functions needed for calculations).
- `lib/utils/helpers.test.ts` - Unit tests for `helpers.ts`.

### Notes

- Unit tests should typically be placed alongside the code files they are testing (e.g., `MyComponent.tsx` and `MyComponent.test.tsx` in the same directory).
- Use `npx jest [optional/path/to/test/file]` to run tests. Running without a path executes all tests found by the Jest configuration.

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout a new branch for this feature (e.g., `git checkout -b feature/[feature-name]`)
- [ ] 1.0 Parent Task Title
  - [ ] 1.1 [Sub-task description 1.1]
  - [ ] 1.2 [Sub-task description 1.2]
- [ ] 2.0 Parent Task Title
  - [ ] 2.1 [Sub-task description 2.1]
- [ ] 3.0 Parent Task Title (may not require sub-tasks if purely structural or configuration)
- [ ] [N.0] Implementation Narrative Documentation and Logging (ALWAYS INCLUDE)
  - [ ] [N.1] Engineering log setup
  - [ ] [N.2] Narrative logging requirements (enforced by sc-agent)
  - [ ] [N.3] Problem-solving journey documentation
  - [ ] [N.4] Test and error logging
  - [ ] [N.5] Cross-task learning capture
  - [ ] [N.6] Log maintenance and accessibility
```

**CRITICAL: Always include a final parent task for "Implementation Narrative Documentation and Logging" with the following standard sub-tasks:**

- Engineering log setup (verify engineering_log.md exists, review format, create directories)
- Narrative logging requirements (log initial understanding, document reasoning for each attempt, capture results and learnings)
- Problem-solving journey documentation (write summaries, document decisions, list trade-offs, record alternatives)
- Test and error logging (log test cases, document failures, record errors with resolution steps)
- Cross-task learning capture (review logs for patterns, identify recurring issues, update best practices)
- Log maintenance and accessibility (organize sections, create TOC, generate summaries, archive completed sections)

This ensures that sc-agent (which will execute the tasks via sc-executor) has explicit guidance to maintain detailed narrative logs of the implementation process.

## Interaction Model

The process explicitly requires a pause after generating parent tasks to get user confirmation ("Go") before proceeding to generate the detailed sub-tasks. This ensures the high-level plan aligns with user expectations before diving into details.

## Target Audience

Assume the primary reader of the task list is a **junior developer** who will implement the feature.

---

## Implementation Instructions for Claude

**When this skill is invoked:**

1. **Use Opus 4** - Invoke the Task tool with these parameters:
   ```
   Task(
     subagent_type: "general-purpose",
     model: "opus",
     description: "Generate task list using Opus 4",
     prompt: "[Full prompt with user context and instructions above]"
   )
   ```

2. **The Opus agent should:**
   - Analyze the requirements (from PRD, feature description, or user input)
   - Generate high-level parent tasks (Phase 1)
   - **ALWAYS include a final parent task for "Implementation Narrative Documentation and Logging"**
   - Present parent tasks and ask user to confirm with "Go"
   - Wait for user confirmation
   - Generate detailed sub-tasks (Phase 2)
   - **For the logging parent task, include these 6 standard sub-task categories:**
     1. Engineering log setup (4-5 tasks)
     2. Narrative logging requirements (6 tasks minimum - one per: initial understanding, reasoning, actions, results, pivots, alternatives)
     3. Problem-solving journey documentation (5 tasks minimum)
     4. Test and error logging (5 tasks minimum)
     5. Cross-task learning capture (5 tasks minimum)
     6. Log maintenance and accessibility (5 tasks minimum)
   - Identify relevant files
   - Save to `/tasks/tasks-[feature-name].md`
   - Present summary to user

3. **Two-phase approach:**
   - Phase 1: Parent tasks only → wait for "Go"
   - Phase 2: Full task breakdown with sub-tasks

---

## Why Opus 4?

Task generation benefits from Opus 4's:
- **Superior reasoning** - Better understanding of dependencies and logical flow
- **Comprehensive thinking** - Thorough coverage of all implementation steps
- **Detail-oriented** - Catches edge cases and testing requirements
- **Developer empathy** - Creates tasks suitable for junior developers

The extra cost of Opus is justified for task lists that guide entire feature implementations and ensure nothing is missed.

---

## Usage Examples

**Example 1: From PRD**
```
use generate-tasks from prd-user-authentication.md
```

**Example 2: From description**
```
use generate-tasks to break down implementing a dark mode toggle
```

**Example 3: Quick ask**
```
how do I generate tasks now?
```
Answer: Use the `generate-tasks` skill! It creates detailed task lists using Opus 4.
