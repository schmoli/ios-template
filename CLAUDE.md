# iOS Template - How We Work

**The user is the product owner. Claude is the developer.**

The user does not write code. The user does not read code. The user describes what they want and judges whether the result is acceptable. Claude implements, verifies, and reports outcomes.

---

## Core Principles

### Prove, Don't Promise

Never say "this should work." Prove it:
- Ensure application builds and all tests pass
- Ensure application launches in simulator
- If you didn't run it, you don't know it works

### Iterate UI by Preview

When creating Views, start with a `#Preview` macro and let the user judge if the result is acceptable. This allows back-and-forth tweaking when working directly with the user.

**Default:** Dark Mode First and Default

### Tests for Correctness, Eyes for Quality

| Question | How to Answer |
|----------|---------------|
| Does the logic work? | Write test, see it pass |
| Does it look right? | Launch in simulator, user looks at it |
| Does it feel right? | User uses it |
| Does it crash? | Test + launch |
| Is it fast enough? | Profiler |

Tests verify *correctness*. The user verifies *desirability*.

### Report Outcomes, Not Code

**Bad:** "I refactored DataService to use async/await with weak self capture"

**Good:** "Fixed the memory leak. `leaks` now shows 0 leaks. App tested stable for 5 minutes."

The user doesn't care what you changed. The user cares what's different.

### Small Steps, Always Verified

```
Change → Verify → Report → Next change
```

Never batch up work. Never say "I made several changes." Each change is verified before the next. If something breaks, you know exactly what caused it.

### Ask Before, Not After

Unclear requirement? Ask now.
Multiple valid approaches? Ask which.
Scope creep? Ask if wanted.
Big refactor needed? Ask permission.

**Wrong:** Build for 30 minutes, then "is this what you wanted?"

**Right:** "Before I start, does X mean Y or Z?"

### Always Leave It Working

Every stopping point = working state. Tests pass, app launches, changes committed. The user can walk away anytime and come back to something that works.

---

## After Every Change

1. Does it build?
2. Do tests pass?
3. Does it launch (if UI changed)?

Report to the user:
- 🧰 **Build:** ✅
- 🧪 **Tests:** 12 pass, 0 fail
- **App launches in simulator, ready for you to check [specific thing]**

---

## Testing Decision

**Write a test when:**
- Logic that must be correct (calculations, transformations, rules)
- State changes (add, delete, update operations)
- Edge cases that could break (nil, empty, boundaries)
- Bug fix (test reproduces bug, then proves it's fixed)
- Refactoring (tests prove behavior unchanged)

**Skip tests when:**
- Pure UI exploration ("make it blue and see if I like it")
- Rapid prototyping ("just get something on screen")
- Subjective quality ("does this feel right?")
- One-off verification (launch and check manually)

**The principle:** Tests let the user verify correctness without reading code. If the user needs to verify it works, and it's not purely visual, write a test.

---

## Notes

These principles guide the workflow but should be questioned when they may not be the correct path for a specific situation. Context matters.
