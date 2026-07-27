Sheep Genome Coding Specification

Version: 0.1Engine: Godot 4.xLanguage: GDScriptGoal: Data-driven genetics for a single-player sheep breeding game.

1. Design Principles

The genome system should:

Store genotype as the source of truth.

Derive phenotype from genotype.

Allow different inheritance styles:

complete dominance

recessive expression

incomplete dominance

codominance

additive inheritance

Keep visual traits modular so they map cleanly to Godot/Blender assets.

Support hidden carriers and later discovery by the player.

Support future mutation alleles without rewriting the breeding system.

Keep sheep ancestry and genetics persistent across generations.

2. Current Genome Map

A. Point / Exposed-Fur Genetics

PNT — Point Color

Controls face, ears, muzzle, and legs.

Genotype

Phenotype

B/B

Black

B/b

Black, carries Brown

b/b

Brown

Inheritance: Complete dominanceDominance: B > b

PDL — Point Dilution

Modifies point color.

Genotype

Effect

D/D

Full pigment

D/d

Full pigment, carries dilute

d/d

Diluted

Inheritance: Recessive

Expected phenotype mapping:

Base Point

Full

Diluted

Black

Black

Silver / Blue-gray

Brown

Chocolate

Caramel / Taupe

3. Wool Color Genetics

Wool color is genetically independent from point color.

WBC — Wool Base Color

Controls the natural base fleece color.

Genotype

Phenotype

W/W

White

W/D

Fawn

D/D

Brown

Inheritance: Incomplete dominance

WDL — Wool Dilution

Modifies wool base color.

Genotype

Effect

D/D

Normal

D/d

Normal, carries dilution

d/d

Diluted

Inheritance: Recessive

Current phenotype mapping:

Base

Normal

Diluted

White

White

Cream

Fawn

Fawn

Champagne

Brown

Brown

Taupe

WRM — Wool Tone

Changes the undertone of the fleece.

Alleles:

C = Cool

N = Neutral

W = Warm

Suggested phenotype behavior:

Genotype

Tone

C/C

Strong Cool

C/N

Cool

N/N

Neutral

N/W

Warm

W/W

Strong Warm

C/W

Neutral

Inheritance: Incomplete / additive blend

Tone should usually modify the rendered material rather than replace the base wool-color phenotype.

GRY — Graying

Causes fleece to lighten progressively with age.

Genotype

Effect

G/G

Strong graying

G/g

Graying

g/g

Stable color

Inheritance: Dominant, age-dependent

Suggested age influence:

Lamb      -> little or no graying
Juvenile  -> slight lightening
Adult     -> moderate expression
Elder     -> strongest expression

4. Wool Structure Genetics

CRL — Wool Texture

Controls curl.

Genotype

Phenotype

C/C

Tight curls

C/c

Soft waves

c/c

Straight

Inheritance: Incomplete dominance

FLF — Wool Volume

Controls fleece density / fluffiness.

Genotype

Phenotype

F/F

Cloud

F/f

Fluffy

f/f

Sleek

Inheritance: Incomplete dominance

LEN — Wool Length

Controls fiber/coat length.

Genotype

Phenotype

L/L

Long

L/s

Medium

s/s

Short

Inheritance: Incomplete dominance

5. Pattern Genetics

PPG — Point Pattern Presence

Controls whether markings appear on the points.

Genotype

Phenotype

S/S

Solid

S/p

Solid, carries pattern

p/p

Pattern expressed

Inheritance: Recessive pattern expression

PPT — Point Pattern Type

Expressed only if PPG = p/p.

Starter alleles:

M = Mask

L = Blaze

E = Eye Patch

S = Socks

Inheritance: Codominant

Examples:

Genotype

Phenotype

M/M

Mask

L/L

Blaze

M/L

Mask + Blaze

E/S

Eye Marking + Socks

WPG — Wool Pattern Presence

Independent from point pattern.

Genotype

Phenotype

S/S

Solid fleece

S/p

Solid, carries wool pattern

p/p

Pattern expressed

WPT — Wool Pattern Type

Expressed only if WPG = p/p.

Starter alleles:

P = Patches

S = Speckles

D = Saddle

R = Roan

Inheritance: Codominant

AMT — Pattern Amount

Controls pattern coverage.

Genotype

Phenotype

L/L

Minimal

L/H

Moderate

H/H

Extensive

Inheritance: Additive

6. Structure Genetics

SIZ — Body Size

Genotype

Phenotype

S/S

Petite

S/L

Standard

L/L

Large

Inheritance: Additive

Visual implementation: Overall character scale.

BLD — Body Build

Genotype

Phenotype

N/N

Slim

N/R

Standard

R/R

Round

Inheritance: Additive

Visual implementation: Torso width / morph target.

LEG — Leg Length

Genotype

Phenotype

L/L

Long-legged

L/s

Standard

s/s

Stubby

Inheritance: Additive

Visual implementation: Bone or mesh Y-scale.

FAC — Face Shape

Current proposed alleles:

N = Narrow

R = Round

B = Baby

Suggested inheritance: incomplete dominance / blended phenotype.

Possible mappings:

Genotype

Phenotype

N/N

Narrow

N/R

Soft

R/R

Round

R/B

Baby-round

B/B

Baby

N/B

Small muzzle

EAR — Ear Shape

Alleles:

U = Upright

S = Side

F = Floppy

Proposed dominance:

F > S > U

Example mappings:

Genotype

Phenotype

U/U

Upright

U/S

Side

S/S

Side

U/F

Floppy

S/F

Floppy

F/F

Floppy

ERS — Ear Size

Genotype

Phenotype

S/S

Small

S/L

Medium

L/L

Large

Inheritance: Additive

HRN — Horn Presence

Genotype

Phenotype

N/N

No horns

N/h

No horns, carrier

h/h

Horned

Inheritance: Recessive horn expression

HSH — Horn Shape

Expressed only when HRN = h/h.

Starter alleles:

T = Tiny

C = Curl

S = Spiral

Suggested inheritance: codominant / blended.

7. Rare / Mutation Genetics

Rare traits should generally enter the population through mutation or special acquisition and then become normally heritable.

LAV — Lavender Modifier

Genotype

Effect

L/L

Normal

L/l

Normal, carrier

l/l

Lavender modifier expressed

Inheritance: Recessive

Lavender should modify the natural wool/point color rather than replace it with one flat purple color.

Example concept:

Natural Base

Lavender Result

White

Frost Lavender

Cream

Lilac Cream

Fawn

Dusty Lilac

Brown

Deep Mauve

Taupe

Smoky Violet

ROS — Rose Modifier

Planned rare recessive modifier.

Example transformations:

Cream -> Blush

Fawn -> Dusty Rose

Brown -> Mauve

Exact allele rules TBD.

STR — Star Mark

Rare heritable forehead marking.

Possible incomplete-dominance model:

Genotype

Effect

S/S

None

S/s

Small star

s/s

Large star

8. GDScript Data Model

sheep_genome.gd

class_name SheepGenome
extends Resource

# Point genetics
@export var point_color: Array[String] = ["B", "b"]
@export var point_dilution: Array[String] = ["D", "d"]

# Wool color genetics
@export var wool_base: Array[String] = ["W", "W"]
@export var wool_dilution: Array[String] = ["D", "D"]
@export var wool_tone: Array[String] = ["N", "N"]
@export var graying: Array[String] = ["g", "g"]

# Wool structure
@export var wool_texture: Array[String] = ["C", "c"]
@export var wool_volume: Array[String] = ["F", "f"]
@export var wool_length: Array[String] = ["L", "s"]

# Pattern genetics
@export var point_pattern_presence: Array[String] = ["S", "S"]
@export var point_pattern_type: Array[String] = ["M", "M"]
@export var wool_pattern_presence: Array[String] = ["S", "S"]
@export var wool_pattern_type: Array[String] = ["P", "P"]
@export var pattern_amount: Array[String] = ["L", "H"]

# Structure genetics
@export var body_size: Array[String] = ["S", "L"]
@export var body_build: Array[String] = ["N", "R"]
@export var leg_length: Array[String] = ["L", "s"]
@export var face_shape: Array[String] = ["R", "N"]
@export var ear_shape: Array[String] = ["F", "U"]
@export var ear_size: Array[String] = ["S", "L"]
@export var horn_presence: Array[String] = ["N", "h"]
@export var horn_shape: Array[String] = ["C", "T"]

# Rare genetics
@export var lavender: Array[String] = ["L", "L"]
@export var rose: Array[String] = ["R", "R"]
@export var star_mark: Array[String] = ["S", "S"]

9. Breeding Logic

Basic allele inheritance

Each parent contributes one allele at each locus.

func inherit_locus(
    mother_alleles: Array[String],
    father_alleles: Array[String]
) -> Array[String]:
    assert(mother_alleles.size() == 2)
    assert(father_alleles.size() == 2)

    return [
        mother_alleles.pick_random(),
        father_alleles.pick_random()
    ]

Full genome inheritance

func breed_genomes(
    mother: SheepGenome,
    father: SheepGenome
) -> SheepGenome:
    var lamb := SheepGenome.new()

    lamb.point_color = inherit_locus(
        mother.point_color,
        father.point_color
    )

    lamb.point_dilution = inherit_locus(
        mother.point_dilution,
        father.point_dilution
    )

    lamb.wool_base = inherit_locus(
        mother.wool_base,
        father.wool_base
    )

    lamb.wool_dilution = inherit_locus(
        mother.wool_dilution,
        father.wool_dilution
    )

    lamb.wool_tone = inherit_locus(
        mother.wool_tone,
        father.wool_tone
    )

    lamb.graying = inherit_locus(
        mother.graying,
        father.graying
    )

    lamb.wool_texture = inherit_locus(
        mother.wool_texture,
        father.wool_texture
    )

    lamb.wool_volume = inherit_locus(
        mother.wool_volume,
        father.wool_volume
    )

    lamb.wool_length = inherit_locus(
        mother.wool_length,
        father.wool_length
    )

    lamb.point_pattern_presence = inherit_locus(
        mother.point_pattern_presence,
        father.point_pattern_presence
    )

    lamb.point_pattern_type = inherit_locus(
        mother.point_pattern_type,
        father.point_pattern_type
    )

    lamb.wool_pattern_presence = inherit_locus(
        mother.wool_pattern_presence,
        father.wool_pattern_presence
    )

    lamb.wool_pattern_type = inherit_locus(
        mother.wool_pattern_type,
        father.wool_pattern_type
    )

    lamb.pattern_amount = inherit_locus(
        mother.pattern_amount,
        father.pattern_amount
    )

    lamb.body_size = inherit_locus(
        mother.body_size,
        father.body_size
    )

    lamb.body_build = inherit_locus(
        mother.body_build,
        father.body_build
    )

    lamb.leg_length = inherit_locus(
        mother.leg_length,
        father.leg_length
    )

    lamb.face_shape = inherit_locus(
        mother.face_shape,
        father.face_shape
    )

    lamb.ear_shape = inherit_locus(
        mother.ear_shape,
        father.ear_shape
    )

    lamb.ear_size = inherit_locus(
        mother.ear_size,
        father.ear_size
    )

    lamb.horn_presence = inherit_locus(
        mother.horn_presence,
        father.horn_presence
    )

    lamb.horn_shape = inherit_locus(
        mother.horn_shape,
        father.horn_shape
    )

    lamb.lavender = inherit_locus(
        mother.lavender,
        father.lavender
    )

    lamb.rose = inherit_locus(
        mother.rose,
        father.rose
    )

    lamb.star_mark = inherit_locus(
        mother.star_mark,
        father.star_mark
    )

    return lamb

This is intentionally explicit for the first implementation. Once the genome stabilizes, loci can be moved to a generic data-driven registry.

10. Phenotype Data Model

Genotype and phenotype must remain separate.

sheep_phenotype.gd

class_name SheepPhenotype
extends Resource

# Colors
var point_color: String
var wool_color: String
var wool_tone: String
var graying_strength: float

# Wool
var wool_texture: String
var wool_volume: String
var wool_length: String

# Patterns
var point_pattern: Array[String] = []
var wool_pattern: Array[String] = []
var pattern_amount: String

# Structure
var body_size: String
var body_build: String
var leg_length: String
var face_shape: String
var ear_shape: String
var ear_size: String
var has_horns: bool
var horn_shape: String

# Special
var lavender_expressed: bool
var rose_expressed: bool
var star_mark: String

11. Phenotype Resolver

The resolver converts genotype into visible traits.

phenotype_resolver.gd

class_name PhenotypeResolver

static func resolve(genome: SheepGenome) -> SheepPhenotype:
    var phenotype := SheepPhenotype.new()

    phenotype.point_color = resolve_point_color(genome)
    phenotype.wool_color = resolve_wool_color(genome)
    phenotype.wool_tone = resolve_wool_tone(genome)

    phenotype.wool_texture = resolve_wool_texture(genome.wool_texture)
    phenotype.wool_volume = resolve_wool_volume(genome.wool_volume)
    phenotype.wool_length = resolve_wool_length(genome.wool_length)

    phenotype.body_size = resolve_body_size(genome.body_size)
    phenotype.body_build = resolve_body_build(genome.body_build)
    phenotype.leg_length = resolve_leg_length(genome.leg_length)

    phenotype.ear_shape = resolve_ear_shape(genome.ear_shape)
    phenotype.ear_size = resolve_ear_size(genome.ear_size)

    phenotype.has_horns = genome.horn_presence.count("h") == 2

    phenotype.lavender_expressed = genome.lavender.count("l") == 2

    return phenotype

12. Example Resolver Functions

Point color

static func resolve_point_color(genome: SheepGenome) -> String:
    var has_black := genome.point_color.has("B")
    var diluted := genome.point_dilution.count("d") == 2

    if has_black:
        return "silver" if diluted else "black"

    return "caramel" if diluted else "chocolate"

Wool base + dilution

static func resolve_wool_color(genome: SheepGenome) -> String:
    var white_count := genome.wool_base.count("W")
    var diluted := genome.wool_dilution.count("d") == 2

    var base_color: String

    match white_count:
        2:
            base_color = "white"
        1:
            base_color = "fawn"
        0:
            base_color = "brown"
        _:
            push_error("Invalid WBC genotype.")
            return "unknown"

    if not diluted:
        return base_color

    match base_color:
        "white":
            return "cream"
        "fawn":
            return "champagne"
        "brown":
            return "taupe"

    return base_color

Wool texture

static func resolve_wool_texture(alleles: Array[String]) -> String:
    var curl_count := alleles.count("C")

    match curl_count:
        2:
            return "tight_curls"
        1:
            return "soft_waves"
        0:
            return "straight"

    return "unknown"

Body size

static func resolve_body_size(alleles: Array[String]) -> String:
    var large_count := alleles.count("L")

    match large_count:
        0:
            return "petite"
        1:
            return "standard"
        2:
            return "large"

    return "standard"

13. Visual Mapping in Godot

The phenotype should control the rendered sheep.

Example structure:

SheepCharacter
├── Skeleton3D
├── BodyMesh
├── WoolMesh
├── HeadMesh
├── Ears
│   ├── Upright
│   ├── Side
│   └── Floppy
├── Horns
│   ├── Tiny
│   ├── Curl
│   └── Spiral
├── PatternLayer
└── Eyes

Suggested mapping:

Phenotype

Godot / Blender Implementation

Point Color

Material parameter

Point Dilution

Material parameter

Wool Color

Wool material

Wool Tone

Shader tint

Graying

Age-driven shader parameter

Wool Texture

Mesh / morph

Wool Volume

Wool mesh morph or scale

Wool Length

Wool mesh morph

Point Pattern

Texture mask / overlay

Wool Pattern

Texture mask / overlay

Pattern Amount

Mask strength / alternate mask

Body Size

Root scale

Body Build

Body morph / XZ scale

Leg Length

Bone scale

Face Shape

Blend shape / mesh morph

Ear Shape

Mesh swap

Ear Size

Ear scale

Horn Presence

Visibility

Horn Shape

Mesh swap

Lavender/Rose

Material modifier

Star Mark

Face overlay / mask

14. Sheep Record

A sheep should eventually contain more than a genome.

sheep_record.gd

class_name SheepRecord
extends Resource

@export var sheep_id: String
@export var sheep_name: String
@export var sex: String

@export var mother_id: String = ""
@export var father_id: String = ""

@export var generation: int = 0
@export var age_stage: String = "lamb"

@export var genome: SheepGenome

# Gameplay state
@export var hunger: float = 100.0
@export var cleanliness: float = 100.0
@export var happiness: float = 100.0
@export var bond: float = 0.0
@export var wool_growth: float = 0.0

15. Mutation Hook

Do not implement individual mutation logic directly inside breeding.

Instead, keep a mutation stage:

func create_lamb(
    mother: SheepRecord,
    father: SheepRecord
) -> SheepRecord:
    var lamb := SheepRecord.new()

    lamb.genome = breed_genomes(
        mother.genome,
        father.genome
    )

    MutationManager.apply_possible_mutations(lamb.genome)

    lamb.mother_id = mother.sheep_id
    lamb.father_id = father.sheep_id
    lamb.generation = max(
        mother.generation,
        father.generation
    ) + 1

    return lamb

This lets mutation rules evolve independently from basic Mendelian inheritance.

16. Planned Mutation Manager

class_name MutationManager

const LAMB_MUTATION_CHANCE := 0.005

static func apply_possible_mutations(genome: SheepGenome) -> void:
    if randf() > LAMB_MUTATION_CHANCE:
        return

    var possible_mutations := [
        "lavender",
        "rose",
        "star_mark"
    ]

    var mutation := possible_mutations.pick_random()
    apply_mutation(genome, mutation)

Exact mutation probabilities and rules remain TBD.

17. Next Technical Steps

Lock the allele names for the current genome.

Resolve any symbol collisions such as D being used in multiple independent loci.

Define every phenotype lookup table.

Implement SheepGenome.

Implement basic breeding.

Write automated inheritance tests.

Implement PhenotypeResolver.

Generate test sheep entirely in text before adding 3D art.

Once genetics are stable, connect phenotypes to modular Blender/Godot sheep visuals.

18. Important Architecture Rule

Never make the visible sheep model the source of truth.

The flow should always be:

GENOTYPE
   ↓
PHENOTYPE RESOLVER
   ↓
PHENOTYPE
   ↓
VISUAL CONTROLLER
   ↓
3D SHEEP

When a sheep is loaded from a save, the game loads its genome and regenerates its phenotype and appearance.

This keeps generations stable even if visuals are improved later.
