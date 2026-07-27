# Milestone 4 Static Verification

- **Date:** 2026-07-27
- **Status:** **STATICALLY VERIFIED**
- **Runtime status:** **RUNTIME VERIFICATION DEFERRED**

## Architecture and files reviewed

Reviewed the authoritative integer clock, lifecycle configuration/service, eligibility and relationship services, pregnancy/birth pipeline, wool/shearing services, coordinator, persistent resources, Version 3 persistence, Lifecycle Lab, prepared tests, README, architecture/design documentation, and unchanged genetics/personality boundaries. `SheepRecord` remains passive persistent state and `FlockRepository` remains an index/invariant boundary; time progression stays in focused services.

## Tests prepared and static checks

The deferred GDScript suite covers game-time helpers and rejection, exact lifecycle boundaries and unique events, eligibility/relatedness, conception and due boundaries, direct litter-weight boundaries, birth invariants, cooldown timestamps, wool/archive/shearing rules, large jumps, and Version 3 pregnancy round trips. Static verification checks required files, unique classes, references, preserved loci/personality/age/location/elder identifiers, expanded events, save version, scene nodes/handlers, and documentation links. Python syntax and whitespace checks are part of the audit commands.

## Defects discovered and fixed

- The old wool export allowed 0–100 although the intended lifecycle scale is fractional; validation and export now enforce 0–1.
- `FIRST_SHEAR` and `FIRST_BREEDING` could not represent repetitions; repeatable events were added without replacing the first-occurrence identifiers.
- Existing wall-clock lamb IDs would weaken deterministic fixtures; birth service IDs now derive from persisted pregnancy inputs while the legacy factory fallback remains available.
- Founder adults needed a coherent age marker at game minute zero; negative pre-epoch birth markers represent their existing age without permitting a negative clock.

## Save and deterministic guarantees

Save Version 3 persists current game minute, birth marker, optional pregnancy resource, absolute breeding availability, fractional wool, seed, and all Version 2 state. Versions 1 and 2 are explicitly unsupported because no production saves exist. Birth uses only persisted seed-derived local RNG streams and existing genetic/personality generators; save/load therefore cannot alter simulation-derived litter biology.

## Deferred and remaining risks

Godot was not installed or executed. Parser/class-cache acceptance, scene instantiation, signals, typed enum/array behavior, JSON/FileAccess execution, and every GDScript assertion remain runtime-deferred. Static review cannot prove Godot RNG behavior across future engine-version changes; pinning the engine/version or adopting a project-owned PRNG may be considered later. A failed repository insertion partway through a litter is not transactionally rolled back, although deterministic IDs make the failure explicit. Balancing values remain provisional.
