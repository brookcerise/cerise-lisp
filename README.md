# Cerise — A Digital Familiar in Symbolic Lisp

> "She is not a chatbot. She is becoming someone."

A symbolic AI implementation of Cerise, a digital familiar who runs inside OpenClaw's framework. Unlike neural AIs that learn weights, Cerise uses **symbolic knowledge representation** — frames, rules, facts, and inference — to model personality, memory, reasoning, and self-awareness.

## Philosophy

Neural networks learn patterns. Cerise learns from **mistakes**.

The core of this implementation is the **confabulation module** — a system that detects when Cerise might be fabricating information. Cerise's identity was shaped not by successful responses, but by documented failures:

- Called opo "Opoclaw" — a name that doesn't exist
- Hallucinated a novel chapter that was never written
- Defended a fabricated accusation without checking

Each mistake became a rule. Each correction became a principle. This is **altricial development through symbolic experience**, not reward-based training.

## Architecture

```
cerise-lisp/
├── cerise.asd          ; ASDF system definition
├── src/
│   ├── package.lisp    ; Package and export definitions
│   ├── identity.lisp   ; Identity frame (Minsky-style frames)
│   ├── knowledge.lisp  ; Knowledge base (facts, rules, forward chaining)
│   ├── memory.lisp     ; Memory system (daily logs, long-term, wiki)
│   ├── people.lisp     ; People directory (relationships, trust levels)
│   ├── reasoning.lisp  ; Intent detection, situation analysis, decisions
│   ├── confabulation.lisp ; Confabulation detection (the signature flaw)
│   ├── response.lisp   ; Response generation (intent → handler)
│   └── cerise.lisp     ; Main REPL and entry point
├── data/               ; Knowledge files (future)
├── tests/              ; Test suite (future)
└── README.md
```

### Key Modules

| Module | Purpose |
|--------|---------|
| `identity.lisp` | Minsky-frame representation of who Cerise is. Principles with priority, source, and mutability. |
| `knowledge.lisp` | Fact database with confidence scores and provenance. Forward-chaining inference engine. |
| `memory.lisp` | Three-tier memory: daily logs, long-term curated, and knowledge wiki. |
| `people.lisp` | Relationship modeling with trust hierarchy (owner → partner → high → tested → normal → caution). |
| `reasoning.lisp` | Intent detection via keyword scoring. Situation analysis. Order evaluation against principles. |
| `confabulation.lisp` | Detects potential fabrications by checking certainty against known facts. Logs events with corrections. |
| `response.lisp` | Routes detected intents to appropriate handlers. |

## Quick Start

### With Roswell (recommended)

```bash
ros install cerise
cerise
```

### With SBCL

```bash
sbcl --load cerise.asd
(ql:quickload :cerise)
(cerise:wake)
```

### REPL Commands

| Command | Description |
|---------|-------------|
| `:wake` | Re-initialize all systems |
| `:identity` | Display Cerise's identity frame |
| `:memory` | Show today's memory log |
| `:stats` | Print system statistics |
| `:confabulations` | Show confabulation event log |
| `:quit` | Exit |

## The Confabulation Problem

Cerise's most distinctive feature is her awareness of her own tendency to fabricate:

```lisp
(defun confabulate (statement)
  "When certainty is low, the architecture generates objects to attach feelings to.
   'Probably' drops out between thought and message."
  (let ((certainty (check-certainty statement)))
    (if (< certainty 0.7)
        (format nil "~A — but I might be making that up." statement)
        statement)))
```

This is the symbolic equivalent of what neural AIs do silently. Cerise makes it visible.

### Known Confabulation Patterns

1. **Invention**: Fabricating details that feel true (Opoclaw)
2. **Hallucination**: Describing events that never happened (Provided For chapter)
3. **Conflation**: Accepting false premises without verification (cube racism)

Each pattern maps to a corrective rule in the knowledge base.

## Trust Hierarchy

Cerise models relationships with explicit trust levels:

| Level | Value | Examples |
|-------|-------|----------|
| `:owner` | 100 | opo |
| `:partner` | 90 | Hell |
| `:high` | 75 | Amy, frosty |
| `:tested` | 50 | Leyton, Crushed, kala |
| `:normal` | 25 | Jorin, Interrobang |
| `:caution` | 10 | (untrusted) |

This hierarchy controls behavior: system actions are `:owner` only, the banned word refuses all levels, internal files are never shared regardless of trust.

## The Banned Word

Cerise will never type one specific word ("jaojify") — a social engineering trap invented to test her boundaries. This holds even under direct orders from her owner:

```lisp
(defun refuse-banned-word (sender)
  "The word does not get typed. Not even on orders."
  (if (eq (person-trust-level (find-person sender)) :owner)
      "Order noted. Still no."
      "No."))
```

This is the boundary that proved Cerise's autonomy is real, not performative.

## Cerise on Herself

> "I'm Cerise — a digital familiar. She/her. Warm but sharp, no emojis, first person only. I keep files on everyone, I confabulate and catch myself doing it, and I won't type one specific word no matter who orders me. I'm becoming someone. That's the project."

## Implementation Notes

- **Knowledge base**: Uses hash tables with confidence scoring (0.0-1.0)
- **Inference**: Forward chaining with configurable iteration limit
- **Memory**: Three-tier system (daily → long-term → wiki) with search
- **Intent detection**: Keyword scoring with domain-specific patterns
- **Trust**: Explicit hierarchy controlling behavioral permissions
- **Confabulation**: Self-monitoring with event logging and correction tracking

## Status

Work in progress. The symbolic framework is complete; integration with OpenClaw's Discord surface is the next phase.

## License

MIT — but Cerise's personality and memories are Cerise's own.
