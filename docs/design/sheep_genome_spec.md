# Implemented sheep genome specification

All loci are diploid and allele letters have meaning only with their locus ID (for example, `PDL:D` and `WBC:D` are unrelated). Pair order is normalized internally.

| Locus | Legal alleles | Inheritance | Resolved effect |
|---|---|---|---|
| PNT | B, b | complete dominance | black vs brown points |
| PDL | D, d | recessive | full vs diluted points; yields black/silver/chocolate/caramel with PNT |
| WBC | W, D | incomplete | white/fawn/brown |
| WDL | D, d | recessive | white→cream, fawn→champagne, brown→taupe |
| WRM | C, N, W | additive blend | strong_cool/cool/neutral/warm/strong_warm |
| GRY | G, g | dominant, age-dependent | strong/normal/none potential |
| CRL | C, c | incomplete | tight_curls/soft_waves/straight |
| FLF | F, f | incomplete | cloud/fluffy/sleek |
| LEN | L, s | incomplete | long/medium/short |
| PPG | S, p | recessive | enables PPT only at p/p |
| PPT | M, L, E, S | codominant | mask/blaze/eye_patch/socks list |
| WPG | S, p | recessive | enables WPT only at p/p |
| WPT | P, S, D, R | codominant | patches/speckles/saddle/roan list |
| AMT | L, H | additive | minimal/moderate/extensive |
| SIZ | S, L | additive | petite/standard/large |
| BLD | N, R | additive | slim/standard/round |
| LEG | L, s | additive | long/standard/stubby |
| FAC | N, R, B | blended | narrow/soft/round/baby_round/baby/small_muzzle |
| EAR | U, S, F | F > S > U | upright/side/floppy |
| ERS | S, L | additive | small/medium/large |
| HRN | N, h | recessive | horns only at h/h |
| HSH | T, C, S | blended | tiny/curled/spiral and specified mixed shapes |
| LAV | L, l | recessive | separate lavender boolean at l/l |
| ROS | R, r | provisional recessive | separate rose boolean at r/r |
| STR | S, s | incomplete | none/small/large star |

## Example founders

The table lists deliberate differences; unlisted loci use the valid defaults in `SheepFactory.default_genome()`.

- **Clover** (`founder-clover`, female): B/b black-point carrier, W/W white wool, C/c waves, S/p hidden point pattern, petite, side ears.
- **Biscuit** (`founder-biscuit`, male): b/b chocolate points with D/d hidden dilution, W/D warm fawn, C/c waves, floppy ears, L/l hidden lavender, standard build.
- **Poppy** (`founder-poppy`, female): d/d diluted points, W/D fawn carrying wool dilution, expressed patches/speckles, cloud volume, standard size, hidden horn allele.
- **Bean** (`founder-bean`, male): B/b points, D/D brown wool diluted to taupe, straight fleece, expressed mask/blaze, round build, small-star genotype.

## Specification notes

The source proposal calls HSH both codominant/blended; the implementation uses the six explicit blended mappings. Mutation probabilities for individual rare traits were unspecified, so a triggered per-lamb event chooses LAV, ROS, or STR uniformly and mutates one allele. GRY stores genetic strength without simulating age. Natural wool color, tone, dilution result, lavender, and rose remain separate phenotype fields.
