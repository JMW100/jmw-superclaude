# Multi-Agent Orchestration Technical Preferences

**System Type:** Multi-agent research/analysis systems using Claude Code agents

**Stack:** Claude Code agents (`.claude/agents/*.md`) + Task tool coordination (primary) / subprocess orchestration (advanced)

**Architecture:**
- Data collection agents defined as markdown files with declarative tool permissions
- Coordinated by Claude Code master agent (Task tool) OR Python/Node.js orchestrator script
- File-based data passing between agents
- MCP servers for token optimization

**Critical Context:** Claude Code's Task tool automatically summarizes subagent output to ~2KB. This guide shows how to work with or around this limitation.

---

## Decision Framework

**Start here and work down:**

```
Need full output (>2KB)?
├─ NO → Use Task tool (Pattern A)
└─ YES ↓

Processing how many items?
├─ 1-5 items, interactive → Task tool + Write workaround (Pattern B) ✅ PRIMARY
└─ 10+ items, batch → Subprocess orchestration (Tier 2)

Need automatic retry/resume?
├─ NO → Task tool + Write workaround (Pattern B)
└─ YES → Subprocess orchestration (Tier 2)

Running for hours unattended?
├─ NO → Task tool + Write workaround (Pattern B)
└─ YES → Subprocess orchestration (Tier 2)
```

**Rule of thumb:** Use simplest pattern that works. 80% of use cases = Pattern B (Write workaround).

---

## Tier 1: Claude Code + Task Tool (PRIMARY - Use This First)

### Pattern A: Summarization OK

**When to use:**
- Output naturally <2KB (single fact, brief analysis, summary-level work)
- Downstream work doesn't need comprehensive details
- Quick lookups or simple coordination

**Pattern:**
```markdown
# Master agent or user prompt
Use the {agent-name} subagent to research {topic}

# Agent does work, returns summary
# Task tool returns ~2KB summary to master
# Master proceeds with summarized info
```

**Example use cases:**
- "Get current stock price" (returns number)
- "Summarize company industry" (paragraph is sufficient)
- "Check if news exists" (yes/no with brief context)

---

### Pattern B: Write Tool Workaround (RECOMMENDED for Full Output)

**When to use (CRITICAL):**
- Need comprehensive output >2KB (detailed analysis, multiple data points, complete datasets)
- Processing 1-5 items interactively
- Want Claude Code UI experience
- Don't need complex retry/resume logic

**THIS IS YOUR DEFAULT PATTERN FOR FULL OUTPUT NEEDS**

**Agent Definition Pattern:**

```yaml
---
name: uk-market-data
description: Collects comprehensive market data for UK companies
tools: WebSearch, Read, Write, mcp__clean-web-fetch__fetch_clean_text
---

You are a financial data analyst. For the UK company provided:

1. Collect comprehensive market data using all available sources
2. Structure findings in detailed markdown format
3. Write COMPLETE output to file: outputs/{TICKER}/agents/uk-market-data.xml
4. Return brief confirmation (Task tool will summarize this anyway)

CRITICAL: Use Write tool to save full analysis. Do not truncate.
```

**File Naming Convention (REQUIRED):**
```
outputs/{ITEM_ID}/agents/{agent-name}.xml
```

**Master Agent Pattern:**

```markdown
# Invoke agent via Task tool
Use the uk-market-data subagent to research {company} ({ticker})

# Agent returns brief summary (will be summarized to 2KB by Task tool)
# Master agent reads the file the agent wrote
Read outputs/{ticker}/agents/uk-market-data.xml

# Now has full comprehensive data despite Task tool summarization
# Proceed with complete information
```

**Error Handling:**

```markdown
# Master agent checks if file exists
Read outputs/{ticker}/agents/{agent-name}.xml

If file not found:
- Agent may have failed
- Check for error in Task tool response
- Retry with clearer instructions
```

**When to graduate to Tier 2:**
- Processing >10 items (too manual)
- Need overnight/unattended runs (Task tool sessions expire)
- Need automatic retry with progressive timeouts
- Need resume from partial completion
- Complex rate limit handling required

---

## Tier 2: Subprocess Orchestration (ADVANCED - Production Only)

**When you absolutely need this:**
- Batch processing many items (>10)
- Long-running workflows (hours)
- Production systems requiring reliability
- Automatic retry/resume logic
- Complex error handling and rate limiting
- Non-interactive execution (cron jobs, pipelines)

**Do NOT use this if:**
- Processing 1-5 items (overkill)
- Interactive/exploratory work (worse UX)
- Simple workflow (unnecessary complexity)

### Python Orchestrator Pattern

**Critical flags (REQUIRED):**
```python
import subprocess

result = subprocess.run(
    [
        'claude',
        '--model', 'sonnet',  # or haiku for cheap tasks
        '--session-id', unique_session_id,  # For debugging logs
        '--mcp-config', '.mcp.json',  # Load project MCP servers
        '--dangerously-skip-permissions'  # Skip prompts (safe with pre-approved tools)
    ],
    input=prompt_text,
    capture_output=True,
    text=True,
    timeout=timeout_seconds,
    cwd=project_root
)

# Access full output (NO summarization)
full_output = result.stdout
```

**Why these flags matter:**
- `--mcp-config .mcp.json`: Without this, subprocess agents can't use project MCP tools
- `--dangerously-skip-permissions`: Allows pre-approved tools to run without prompts (safe because tools declared in agent .md)
- `--session-id`: Creates trackable session for debugging

**Status Tracking Pattern:**

```python
status = {
    "item_id": item_id,
    "agents": {
        "agent-name": {
            "status": "success",  # or "failed", "timeout"
            "runtime_seconds": 123,
            "timestamp": "2025-11-22 14:30:00",
            "error": None  # or error message
        }
    }
}

# Save to file
with open(f"outputs/{item_id}/status.json", 'w') as f:
    json.dump(status, f)
```

**Resume Logic:**

```python
def collect_data(item_id, resume=False):
    status = load_status(item_id)  # Load previous run

    for agent_name in AGENTS:
        # Skip if previously successful
        if resume and status['agents'].get(agent_name, {}).get('status') == 'success':
            print(f"Skipping {agent_name} (already successful)")
            continue

        # Run agent
        run_agent(agent_name, item_id)
```

**Retry Logic with Progressive Timeouts:**

```python
# Tier timeouts based on empirical data
AGENT_TIMEOUTS = {
    'quick-agent': 600,      # 10 min
    'medium-agent': 1200,    # 20 min
    'slow-agent': 2400,      # 40 min
}

def run_agent_with_retry(agent_name, max_retries=3):
    base_timeout = AGENT_TIMEOUTS[agent_name]

    for attempt in range(max_retries):
        # Progressive timeout: 1x → 1.5x → 2x
        timeout = base_timeout * (1 + 0.5 * attempt)

        result = run_agent(agent_name, timeout=timeout)

        if result.returncode == 0:
            return result

        if attempt < max_retries - 1:
            # Exponential backoff for rate limits
            sleep(2 ** attempt * 60)  # 1min, 2min, 4min

    raise Exception(f"{agent_name} failed after {max_retries} retries")
```

**Rate Limit Detection:**

```python
def run_agent(agent_name, timeout):
    result = subprocess.run([...], timeout=timeout)

    # Check for rate limit in output
    if "rate limit" in result.stderr.lower() or "429" in result.stderr:
        print(f"Rate limit detected for {agent_name}")
        # Exponential backoff
        wait_seconds = 60 * (2 ** retry_count)
        print(f"Waiting {wait_seconds}s before retry...")
        time.sleep(wait_seconds)
        # Retry logic here

    return result
```

---

## Common Patterns (All Tiers)

### Agent Definition Format (CRITICAL)

**YAML frontmatter with declarative tool permissions:**

```yaml
---
name: agent-name
description: What this agent does (one line)
tools: WebSearch, Read, Write, mcp__server-name__tool-name
---

You are a [role]. For the [item] provided:

1. [Step-by-step instructions]
2. Use [specific tools] to gather [specific data]
3. Structure output as [format]
4. Write to outputs/{ITEM}/agents/{agent-name}.xml

[Detailed prompt with examples and constraints]
```

**Why declarative tools matter:**
- Pre-approves tools (no interactive prompts needed)
- Works with `--dangerously-skip-permissions` flag
- Auditable and version-controlled
- Clear dependencies

### File-Based Data Passing (REQUIRED for Large Data)

**DON'T pass large data via CLI arguments:**
```bash
# ❌ WRONG - hits CLI limits (~32KB)
claude "Analyze this data: [50KB of text]..."
```

**DO use Read tool for inputs:**
```bash
# ✅ CORRECT - no size limits
# 1. Write data to file
echo "[50KB of data]" > /tmp/data.txt

# 2. Agent reads it
claude "Use Read tool to analyze /tmp/data.txt"
```

**Agent pattern:**
```markdown
1. Read the data file provided: {file_path}
2. Analyze the complete contents
3. Write results to output file
```

### MCP Integration (CRITICAL for Subprocesses)

**Problem:** MCP tools from `.mcp.json` unavailable in subprocess by default

**Solution:** Use `--mcp-config` flag

```python
# ❌ WRONG - MCP tools not loaded
subprocess.run(['claude'], input=prompt, ...)

# ✅ CORRECT - Project MCP tools loaded
subprocess.run(['claude', '--mcp-config', '.mcp.json'], input=prompt, ...)
```

**Verify MCP tools loaded:**
```markdown
# Agent should explicitly try to use MCP tools
Try to use mcp__clean-web-fetch__fetch_clean_text tool first.
If not available, fall back to WebFetch.
```

### Hybrid: Mix Direct APIs with LLM Agents

**When to bypass LLM (use direct API):**
- Structured data available (REST APIs, databases, libraries)
- No reasoning/analysis required
- Speed critical (API = seconds, LLM = minutes)
- High volume (API = cheap, LLM = expensive tokens)

**Pattern:**

```python
def collect_market_data(ticker):
    # Use direct API (yfinance, not LLM)
    import yfinance as yf
    stock = yf.Ticker(ticker)

    data = {
        'price': stock.info.get('currentPrice'),
        'market_cap': stock.info.get('marketCap'),
        # ... structured data
    }

    # Save to same format as agent output
    with open(f'outputs/{ticker}/agents/market-data.json', 'w') as f:
        json.dump(data, f)

    return data

def collect_news(ticker):
    # Use LLM agent (unstructured data, needs reasoning)
    result = subprocess.run(['claude', '--agent', 'uk-news-announcements'], ...)
    return result.stdout
```

**When LLM is better:**
- Unstructured data (web scraping, PDFs, articles)
- Requires reasoning/synthesis
- Natural language understanding needed
- Contextual judgment required

---

## What to AVOID

❌ **Using Task tool for >2KB output without Write workaround**
- You'll lose 95% of the data
- Agent writes comprehensive analysis → Task tool returns 51-line summary
- Master agent makes decisions on incomplete data

❌ **Subprocess orchestration for simple workflows**
- Overkill for 1-5 items
- Worse UX (no Claude Code interface)
- Unnecessary complexity

❌ **Write workaround for batch processing 25+ items**
- Should use subprocess orchestrator instead
- Better retry/resume logic
- Production reliability

❌ **Passing large data via CLI arguments**
```python
# ❌ WRONG - hits shell limits
subprocess.run(['claude', f'Analyze: {huge_data}'])

# ✅ CORRECT - use Read tool
with open('data.txt', 'w') as f:
    f.write(huge_data)
subprocess.run(['claude', 'Use Read tool on data.txt'])
```

❌ **Missing `--mcp-config` flag for subprocess agents**
- MCP tools won't be available
- Falls back to expensive/slow alternatives
- Token optimization breaks

❌ **Interactive tools in subprocess agents**
```yaml
# ❌ WRONG - will hang waiting for user input
tools: AskUserQuestion, TodoWrite
```

❌ **Forgetting `--dangerously-skip-permissions` with pre-approved tools**
- Subprocess will hang waiting for permission prompts
- Only "dangerous" if tools NOT declared in agent .md
- Safe when tools are pre-approved in agent frontmatter

❌ **Not tracking agent status in production**
- Can't resume partial runs
- Can't identify which agent failed
- Wasted compute re-running successful agents

---

## What to EMBRACE

✅ **Start with simplest pattern that works**
- Try Pattern A (Task tool) first
- Graduate to Pattern B (Write workaround) when you need full output
- Only use Tier 2 (subprocess) when Pattern B insufficient

✅ **Write tool workaround as default for full output**
- Much simpler than subprocess orchestration
- Works for 80% of use cases
- Good UX (Claude Code interface)
- Easy to understand and maintain

✅ **File-based data passing**
- Inputs: Write to file → Agent reads with Read tool
- Outputs: Agent writes with Write tool → Master reads
- No size limits, clean separation

✅ **Direct APIs when available**
```python
# Market data: yfinance (instant) not LLM agent (9 min timeout)
# Structured data: Database query not LLM scraping
# Calculations: Python not LLM reasoning
```

✅ **Declarative tool permissions in agent .md**
```yaml
---
tools: WebSearch, Read, Write, mcp__server__tool
---
```
- Enables `--dangerously-skip-permissions`
- Auditable permissions
- No interactive prompts

✅ **Progressive timeouts based on empirical data**
```python
# Measure actual runtimes, then tier timeouts
quick_agents: 600s   (10 min)
medium_agents: 1200s (20 min)
slow_agents: 2400s   (40 min)

# Retry with 1.5x, then 2x timeout
```

✅ **Status tracking and resume capability**
```json
{
  "agents": {
    "agent-1": {"status": "success", "runtime": 123},
    "agent-2": {"status": "failed", "error": "..."}
  }
}
```
- Resume from last successful point
- Identify failure patterns
- Save compute on re-runs

✅ **Rate limit detection and exponential backoff**
```python
if "rate limit" in output:
    wait = 60 * (2 ** retry_count)  # 1min, 2min, 4min
    time.sleep(wait)
```

✅ **Mixing both tiers in one project**
```python
# Interactive exploration: Claude Code + Write workaround
claude --agent research-company

# Production batch: Subprocess orchestrator
python scripts/batch_research.py --tickers TICK1,TICK2,...
```

---

## Real-World Example: UK Stock Researcher

**Use case:** Research 25+ UK companies (16 data collection agents per company)

**What worked:**
- Subprocess orchestrator for batch processing (Tier 2)
- Progressive timeouts (600s → 2400s based on agent)
- Resume capability (overnight runs can fail and resume)
- Rate limit handling (exponential backoff)
- Mix direct APIs (yfinance instant) with LLM agents (web scraping)
- MCP token optimization (95-99% reduction via clean_web_fetch)

**What didn't work initially:**
- Task tool for master analysis (21x data loss: 51 lines vs 470 lines)
- Passing 45KB prompts via CLI (hit limits)
- Fixed timeouts (some agents fast, some slow)

**Lessons:**
- Write tool workaround would have worked for 1-5 companies interactively
- Subprocess orchestration necessary for 25+ company batch production
- Both patterns have their place

---

## Notes

- This file contains ONLY your specific preferences/opinions for multi-agent systems
- General Claude Code best practices are assumed
- Focus: architecture patterns and when to use each, not explaining basics
- Based on real production learnings from uk-stock-researcher project
- **Key insight:** Task tool's 2KB summarization is the critical constraint that drives all architectural decisions
