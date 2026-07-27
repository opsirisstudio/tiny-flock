# Derived mood

Mood is recalculated and never persisted. It is temporary state, while personality remains persistent identity. Canonical moods are JOYFUL, CONTENT, CALM, NEUTRAL, HUNGRY, DIRTY, LONELY, GRUMPY, SLEEPY, and EXCITED.

Priority is deterministic: hunger below 0.25, cleanliness below 0.25, happiness below 0.30, then low-bond loneliness are checked before positive/cosmetic moods. Next come JOYFUL (happiness at least 0.75 and bond at least 0.65), ZOOMY/EXCITED, CONTENT, SLEEPY, CALM, and NEUTRAL. Thus serious care state always wins over personality flavor.
