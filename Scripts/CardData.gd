extends Resource
class_name CardData

@export var card_name: String = "Unknown Unit"
@export var card_type: String = "Unit" # e.g., Commander, Unit, Spell, Tank, Boat
@export var cost: float = 3.0
@export var is_spell: bool = false
@export var spawn_count: int = 1
@export var max_hp: float = 100.0
@export var is_melee: bool = true
@export var description: String = "A standard unit."
@export var unit_scene: PackedScene # The actual 3D character to spawn

# In the future, you could add art here:
# @export var card_art: Texture2D
