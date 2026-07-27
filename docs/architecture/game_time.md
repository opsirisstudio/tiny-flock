# Authoritative game time

Tiny Flock uses non-negative integer **total elapsed game minutes**. `GameTime` derives a player-facing one-based day, zero-based minute within the day, hour, and minute: minute 0 is Day 1 00:00 and minute 1440 is Day 2 00:00. `GameClock` advances only through explicit minute/hour/day calls and rejects negative advances. No wall clock, frame delta, offline progression, or persisted float is authoritative, so identical inputs produce identical time.
