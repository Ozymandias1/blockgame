extends Object

class_name Constants

# Menu Page Related Enumeration Type
enum MenuPage { MainMenu, SetGameCondition, Gameplay, Option }

# Location enumeration type related to block destruction effect
enum BlockVFXLocation { LEFT_BOTTOM = 0, LEFT_TOP, RIGHT_TOP, RIGHT_BOTTOM }
# Location offset value to be used when creating block destruction effect
static var BlockVFXOffsets = [
	Vector2(7.5, 22.5),
	Vector2(7.5, 7.5),
	Vector2(22.5, 7.5),
	Vector2(22.5, 22.5),
]
