class_name MoodResolver
extends RefCounted

enum Mood { JOYFUL, CONTENT, CALM, NEUTRAL, HUNGRY, DIRTY, LONELY, GRUMPY, SLEEPY, EXCITED }
static func resolve(sheep: SheepRecord) -> Mood:
	if sheep.hunger < HusbandryConfig.MOOD_CRITICAL_NEED_THRESHOLD: return Mood.HUNGRY
	if sheep.cleanliness < HusbandryConfig.MOOD_CRITICAL_NEED_THRESHOLD: return Mood.DIRTY
	if sheep.happiness < HusbandryConfig.MOOD_LOW_HAPPINESS: return Mood.GRUMPY
	if sheep.bond < HusbandryConfig.MOOD_LOW_BOND and sheep.happiness < 0.5: return Mood.LONELY
	var traits := sheep.personality.traits() if sheep.personality != null else []
	if sheep.happiness >= HusbandryConfig.MOOD_HIGH_HAPPINESS and sheep.bond >= HusbandryConfig.MOOD_HIGH_BOND: return Mood.JOYFUL
	if "ZOOMY" in traits and sheep.happiness >= HusbandryConfig.MOOD_HIGH_HAPPINESS: return Mood.EXCITED
	if sheep.happiness >= HusbandryConfig.MOOD_HIGH_HAPPINESS: return Mood.CONTENT
	if "SLEEPY" in traits: return Mood.SLEEPY
	if "CALM" in traits: return Mood.CALM
	return Mood.NEUTRAL
static func label(mood: Mood) -> String: return Mood.keys()[mood]
