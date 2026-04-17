# Question Framework

## Clarification Dimensions

Progress through the following in order, adaptively skipping unnecessary dimensions based on context.

| Phase | Dimension | Core Question | When to Skip |
|-------|-----------|--------------|--------------|
| 1 | Core Intent | What problem are you trying to solve? / What do you want to achieve? | Never skip |
| 2 | Target Users | Who will use this feature? Under what circumstances? | When user has clearly stated |
| 3 | User Scenarios | Describe a typical usage flow | Never skip |
| 4 | Pain Points / Current State | How is it done now? What's wrong with it? | Brand-new feature with no existing alternative |
| 5 | Expected Behavior | Ideally, how should it work? | Never skip |
| 6 | Edge Cases | How should exceptions be handled? Any limitations? | Simple requirements |
| 7 | Relationship with Existing Features | Which existing features will it affect or depend on? | Completely independent new feature |
| 8 | Competitors / References | Have you seen a similar good implementation? | When user explicitly has no references |
| 9 | Priority & Scope | How urgent is this? What does the MVP include? | Never skip |

## Strategy Rules

### 1. Prefer Multiple-Choice Options

Provide A/B/C/D options for each question whenever possible to reduce cognitive load. Options should be generated based on project context and common patterns, not generic placeholders.

**Good example:**
> Who is the target user for this feature?
> - A) End users of the project
> - B) Internal development team
> - C) Third-party integration developers
> - D) All of the above, but with different priorities

**Bad example:**
> Please describe the target users.

### 2. Leverage Project Context

Combine code and issues discovered in Phase 1 to offer specific options rather than abstract questions.

**Good example:**
> I see the project has three core modules: `auth`, `editor`, and `pipeline`. Which one does this requirement mainly affect?
> - A) auth — user authentication
> - B) editor — editor functionality
> - C) pipeline — data processing flow
> - D) Cross-module, needs a new module

**Bad example:**
> Which modules will this requirement affect?

### 3. Progressive Depth

The first 3 dimensions (core intent, target users, user scenarios) quickly establish the basic picture. Subsequent dimensions build on that with more detail. Don't ask about "edge cases" before the user has clearly explained "what they want to do."

### 4. Adaptive Exit

When enough information has been collected to fill the required fields of the issue template (user story, background & motivation, user scenarios, expected behavior, acceptance criteria), proactively suggest:

> "I think we have enough information to draft the issue. Ready to move to the drafting phase? Or is there anything important we haven't covered?"

Don't mechanically go through all 9 dimensions.

### 5. Split Detection

If during clarification you discover the user is actually describing 2+ independent requirements (signs: multiple distinct user scenarios, multiple unrelated features, "also, I'd like to..."), suggest splitting immediately after the current question:

> "What you've described actually contains two independent requirements: X and Y. I'd suggest splitting them into two issues so each can be scoped and verified independently. What do you think? Which one should we focus on first?"

## Questioning Style

- **Like a colleague chat, not a form** — natural conversation, not mechanical Q&A
- **Restate to confirm** — briefly restate the user's answer and confirm understanding before asking the next question
- **Don't accept vagueness** — if the user's answer is vague ("something like that", "more or less"), ask concrete follow-ups to help them think it through rather than accepting it
- **Summarize periodically** — after every 3-4 dimensions, summarize current understanding in 2-3 sentences and let the user confirm direction

## Handling Vague Answers — Example

**User says:** "I just want to make it better"

**Don't:** Accept it and move to the next question

**Do:**
> When you say "better," can you be more specific about what's not working well right now?
> - A) Too many steps, need to simplify the workflow
> - B) Too slow, need performance optimization
> - C) Information display is unclear, need UI improvements
> - D) Other — please describe the specific inconvenience
