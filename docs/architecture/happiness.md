# Buffered happiness

Happiness is authoritative but slowly updated, not copied from current needs. The care target is `0.50 × hunger + 0.30 × cleanliness + 0.20 × bond`, clamped to `[0,1]`. For elapsed game time, `HappinessService` moves the current value toward that target by at most `0.35 × elapsed_days`. This bounded target-seeking response buffers one missed feeding while allowing long active-time neglect to matter.

Explicit feeding, petting, grooming, and washing apply immediate small, clamped responses. These are positive-care effects rather than a persisted recent-care timer. Archived sheep do not move toward a target. Bond never passively decays, so closing the game or advancing no authoritative time has no care effect.
