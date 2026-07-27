#!/usr/bin/env python3
"""Repository-level static checks used while Godot runtime validation is deferred."""
from __future__ import annotations
import re
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
EXPECTED_LOCI = ["PNT","PDL","WBC","WDL","WRM","GRY","CRL","FLF","LEN","PPG","PPT","WPG","WPT","AMT","SIZ","BLD","LEG","FAC","EAR","ERS","HRN","HSH","LAV","ROS","STR"]
EXPECTED_FILES = ["project.godot", "scenes/debug/genetics_lab.tscn", "scenes/debug/flock_archive_lab.tscn", "scripts/genetics/sheep_genome.gd", "scripts/flock/flock_repository.gd", "scripts/flock/flock_persistence.gd", "scripts/flock/pedigree_service.gd"]
EXPECTED_FILES += ["scenes/debug/sheep_identity_lab.tscn", "scripts/identity/personality_profile.gd", "scripts/identity/sheep_life_event.gd"]
EXPECTED_FILES += ["scenes/debug/husbandry_lab.tscn", "scripts/husbandry/husbandry_config.gd", "scripts/husbandry/husbandry_simulation_service.gd", "scripts/husbandry/feeding_service.gd", "scripts/husbandry/petting_service.gd", "scripts/husbandry/grooming_service.gd", "scripts/husbandry/washing_service.gd", "scripts/husbandry/mood_resolver.gd", "scripts/husbandry/care_interaction_result.gd"]
EXPECTED_FILES += ["scenes/debug/lifecycle_lab.tscn", "scripts/simulation/game_time.gd", "scripts/simulation/game_clock.gd", "scripts/simulation/lifecycle_service.gd", "scripts/simulation/breeding_service.gd", "scripts/simulation/pregnancy_service.gd", "scripts/simulation/wool_growth_service.gd", "scripts/simulation/shearing_service.gd", "scripts/simulation/simulation_coordinator.gd"]
EXPECTED_FILES += ["scripts/simulation/archive_transition_service.gd"]
EXPECTED_TRAITS = ["CALM", "SOCIAL", "SHY", "GREEDY", "CURIOUS", "INDEPENDENT", "CUDDLY", "MISCHIEVOUS", "SLEEPY", "ZOOMY"]
EXPECTED_EVENTS = ["BORN", "FIRST_FEEDING", "FIRST_SHEAR", "FIRST_BREEDING", "OFFSPRING_BORN", "BECAME_JUVENILE", "BECAME_ADULT", "BECAME_ELDER", "ARCHIVED_TO_BARN", "RETURNED_FROM_BARN", "MARKED_FAVORITE", "UNMARKED_FAVORITE", "MUTATION_DISCOVERED", "GENETIC_TRAIT_CONFIRMED", "ASSIGNED_ELDER_ROLE", "BREEDER_NOTE_ADDED", "BREEDING", "SHEARED", "PREGNANCY_STARTED", "BIRTH_GIVEN", "FED", "PETTED", "GROOMED", "WASHED", "TREAT_GIVEN"]
EXPECTED_ELDER_ROLES = ["NONE", "NANNY", "COMFORTER", "GROOMER", "SHEPHERD", "FORAGER", "STORYKEEPER"]

def fail(message: str) -> None:
    raise AssertionError(message)

for relative in EXPECTED_FILES:
    path = GODOT / relative
    if not path.is_file() or path.stat().st_size == 0: fail(f"missing or empty: {relative}")

scripts = list(GODOT.rglob("*.gd"))
classes: list[str] = []
for script in scripts:
    text = script.read_text()
    classes += re.findall(r"(?m)^class_name\s+(\w+)", text)
    if re.search(r"(?<!@)\b(onready|export)\s+var\b", text): fail(f"Godot 3 property syntax: {script}")
duplicates = [name for name, count in Counter(classes).items() if count > 1]
if duplicates: fail(f"duplicate class_name declarations: {duplicates}")

all_files = [p for p in GODOT.rglob("*") if p.is_file()]
for source in all_files:
    text = source.read_text(errors="ignore")
    for reference in re.findall(r'res://[^"\s\)]+', text):
        if not (GODOT / reference.removeprefix("res://")).exists(): fail(f"missing {reference} referenced by {source}")
    for reference in re.findall(r'(?:preload|load)\(["\'](res://[^"\']+)', text):
        if not (GODOT / reference.removeprefix("res://")).exists(): fail(f"missing load target {reference}")

registry = (GODOT / "scripts/genetics/gene_registry.gd").read_text()
registry_block = registry.split("const LOCI: Dictionary = {", 1)[1].split("\n}", 1)[0]
found_loci = re.findall(r'^\s*"([A-Z]{3})":', registry_block, re.MULTILINE)
if found_loci != EXPECTED_LOCI: fail(f"registry mismatch: {found_loci}")

resolver = (GODOT / "scripts/identity/personality_resolver.gd").read_text()
traits = re.search(r"const TRAITS: Array\[String\] = \[(.*?)\]", resolver).group(1)
if re.findall(r'"([A-Z_]+)"', traits) != EXPECTED_TRAITS: fail("personality trait identifiers changed")
events = re.search(r"enum Type \{(.*?)\}", (GODOT / "scripts/identity/sheep_life_event.gd").read_text()).group(1)
if [item.strip() for item in events.split(",")] != EXPECTED_EVENTS: fail("life event identifiers changed")
record_text = (GODOT / "scripts/sheep/sheep_record.gd").read_text()
for enum_name, expected in [("AgeStage", ["LAMB", "JUVENILE", "ADULT", "ELDER"]), ("Location", ["ACTIVE_FLOCK", "ACTIVE_ELDER", "BARN_ARCHIVE"])]:
    body = re.search(rf"enum {enum_name} \{{(.*?)\}}", record_text).group(1)
    if [item.strip() for item in body.split(",")] != expected: fail(f"{enum_name} identifiers changed")
roles = re.search(r"enum ElderRole \{(.*?)\}", (GODOT / "scripts/sheep/sheep_record.gd").read_text()).group(1)
if [item.strip() for item in roles.split(",")] != EXPECTED_ELDER_ROLES: fail("elder role identifiers changed")
if "const SAVE_VERSION := 5" not in (GODOT / "scripts/flock/flock_persistence.gd").read_text(): fail("save version is not 5")
if "archived_at_game_minute" not in (GODOT / "scripts/sheep/sheep_record.gd").read_text(): fail("archive freeze bookkeeping field is missing")
if "sheep.location == SheepRecord.Location.BARN_ARCHIVE: return false" not in (GODOT / "scripts/simulation/lifecycle_service.gd").read_text(): fail("age-stage progression is not guarded against BARN_ARCHIVE")
if "mother.location == SheepRecord.Location.BARN_ARCHIVE" not in (GODOT / "scripts/simulation/pregnancy_service.gd").read_text(): fail("pregnancy resolution is not guarded against BARN_ARCHIVE")
persistence = (GODOT / "scripts/flock/flock_persistence.gd").read_text()
if "@export_range(0.0, 1.0) var hunger" not in record_text: fail("normalized husbandry ranges are not declared")
if "advance_needs" not in (GODOT / "scripts/simulation/simulation_coordinator.gd").read_text(): fail("husbandry simulation is not coordinated")
if "get_wool_growth_efficiency" not in (GODOT / "scripts/simulation/wool_growth_service.gd").read_text(): fail("care wool efficiency is missing")
if "TOO_HUNGRY" not in (GODOT / "scripts/simulation/breeding_eligibility_service.gd").read_text(): fail("care breeding reasons are missing")
if "clock: GameClock = null" in persistence or "clock != null else 0" in persistence: fail("Version 4 clock fallback is still present")
if "Type.SHEARED).size()" not in (GODOT / "scripts/identity/lifetime_statistics_service.gd").read_text(): fail("shearing statistics do not count repeatable SHEARED events")
if "advance_wool_growth_interval" not in (GODOT / "scripts/simulation/simulation_coordinator.gd").read_text(): fail("simulation is not using interval-aware wool growth")

for scene in GODOT.rglob("*.tscn"):
    text = scene.read_text()
    handlers = re.findall(r'method="([^"]+)"', text)
    script_refs = re.findall(r'ext_resource path="(res://[^"]+\.gd)"', text)
    if len(script_refs) == 1:
        script_text = (GODOT / script_refs[0].removeprefix("res://")).read_text()
        for handler in handlers:
            if not re.search(rf'(?m)^func\s+{re.escape(handler)}\s*\(', script_text): fail(f"missing handler {handler} for {scene}")
    unique_nodes = set(re.findall(r'\[node name="([^"]+)"[^\]]*\]\nunique_name_in_owner = true', text))
    for referenced in re.findall(r'=\s*%([A-Za-z0-9_]+)', (GODOT / script_refs[0].removeprefix("res://")).read_text() if script_refs else ""):
        if referenced not in unique_nodes: fail(f"missing unique node %{referenced} in {scene}")

subprocess.run(["git", "diff", "--check"], cwd=ROOT, check=True)
for document in ROOT.joinpath("docs").rglob("*.md"):
    for target in re.findall(r"\[[^]]+\]\(([^)#]+)(?:#[^)]+)?\)", document.read_text()):
        if "://" not in target and not (document.parent / target).resolve().exists(): fail(f"broken docs link {target} in {document}")
print(f"STATICALLY VERIFIED: {len(scripts)} GDScript files, {len(classes)} class_name declarations, {len(EXPECTED_LOCI)} loci, and all res:// references.")
print("RUNTIME VERIFICATION DEFERRED")
