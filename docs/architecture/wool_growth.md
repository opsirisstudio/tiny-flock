# Wool growth and shearing

`wool_growth` is a validated, clamped fraction: `0.0` freshly shorn and `1.0` fully grown. `WoolGrowthService` adds elapsed minutes divided by the prototype five-day duration; it never performs frame updates or minute loops. Lamb wool is not advanced. Juveniles grow wool but cannot be sheared; adults and elders can be sheared when not archived. `BARN_ARCHIVE` freezes growth, and only future active elapsed time grows wool after restoration.

`ShearingService` requires a repository sheep, adult/elder stage, non-archive location, and full wool. Success returns phenotype-derived wool color, texture, and length, resets growth to zero, appends repeatable `SHEARED`, and ensures `FIRST_SHEAR` exists exactly once. Inventory, quality, economics, meshes, and animations remain deferred.
