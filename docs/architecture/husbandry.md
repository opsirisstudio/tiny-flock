# Husbandry architecture

`SheepRecord` persists four authoritative normalized values in `[0.0, 1.0]`: hunger (`1` fully fed), cleanliness (`1` clean), happiness (`1` excellent), and player bond (`1` maximally bonded). New sheep, including lambs, begin fully fed, clean, and happy with zero bond. They need no nursing simulation. Validation rejects mixed 0–100 or out-of-range state.

`HusbandrySimulationService` receives elapsed authoritative game minutes from `SimulationCoordinator`. It calculates hunger and cleanliness decay directly, then delegates buffered happiness movement to `HappinessService`; it never loops over minutes or uses `_process`, system time, or offline time. Bond has no passive decay.

`BARN_ARCHIVE` is an absolute simulation boundary: care values, wool, age stage, and pregnancy are all frozen; direct care is rejected; and restoration (via `ArchiveTransitionService`, see [archive transitions](archive_transitions.md)) resumes future simulation without catch-up. Active lambs, juveniles, adults, and elders can receive care. Lambs gain 20% more care bond and elders gain 10% more petting bond; neither has illness or age punishment.

Neglect cannot kill, delete, injure, permanently alter, or critically sicken a sheep. Its only consequences are recoverable mood/happiness changes, reduced wool efficiency, and temporary breeding readiness failure. Persistent records remain Resources separate from future active-world Nodes.
