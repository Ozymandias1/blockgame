extends Object

class_name Constants

# 메뉴 페이지 관련 열거형
enum MenuPage { MainMenu, SetGameCondition, Gameplay, Option }

# 블럭 파괴효과 관련 위치 열거형
enum BlockVFXLocation { LEFT_BOTTOM = 0, LEFT_TOP, RIGHT_TOP, RIGHT_BOTTOM }
# 블럭 파괴효과 생성시 사용할 위치 오프셋 값
static var BlockVFXOffsets = [
	Vector2(7.5, 22.5),
	Vector2(7.5, 7.5),
	Vector2(22.5, 7.5),
	Vector2(22.5, 22.5),
]
