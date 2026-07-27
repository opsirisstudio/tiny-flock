# Personality architecture

Personality is persistent gameplay identity, separate from the 25-locus genome and phenotype. `PersonalityProfile` stores eight normalized axes: sociability, energy, boldness, affection, food drive, curiosity, mischief, and calmness. `PersonalityResolver` deterministically derives an ordered, non-exclusive trait list. High means `>= 0.70`, low means `<= 0.30`, and independent additionally requires boldness `>= 0.50`; these values live in `PersonalityConfig` rather than resolver branches.

Founder axes are uniform seeded RNG draws. An offspring axis is the parental mean plus a seeded variation in `[-0.15, +0.15]`, clamped to `[0, 1]`. Thus siblings can differ without losing parental influence. The source label and seed are diagnostic metadata, not a second source of truth.

Food preference is independent of inheritance in version 2. A seeded choice assigns APPLE, CARROT, CLOVER, OATS, PUMPKIN, or BERRIES as favorite and may choose a distinct dislike. Bonding and elder-role affinity resolvers compute future behavior hooks from axes and persist nothing. Elder suitability is ranked; it never automatically changes the manually assigned role.
