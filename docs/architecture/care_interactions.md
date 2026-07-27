# Care interactions

Focused `FeedingService`, `PettingService`, `GroomingService`, and `WashingService` receive a repository, stable sheep ID, and `GameTime`. Each rejects missing and archived sheep with a structured `CareInteractionResult`; feeding also rejects unknown food IDs. Results contain before/after needs, interaction ID, preference classification, applied modifier IDs, and a reason code—not UI prose.

The food registry preserves APPLE, CARROT, CLOVER, OATS, PUMPKIN, and BERRIES. Foods restore hunger and may be treats. Favorites add emotional happiness/bond bonuses; dislikes remain edible and only soften the response. GREEDY strengthens feeding happiness and CURIOUS enjoys neutral novelty.

Petting primarily raises happiness/bond: CUDDLY and SOCIAL strengthen it, INDEPENDENT reduces only the happiness gain, and SHY uses deterministic receptivity `0.45 + 0.55 × current_bond`. Grooming strongly restores cleanliness with CALM happiness and CUDDLY bond bonuses. Washing restores 0.80 cleanliness; CALM/CUDDLY are mildly positive while SHY has a small temporary happiness reduction. Every value is clamped and every negative response is safe and recoverable.
