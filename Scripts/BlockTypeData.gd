extends Object

# https://www.reddit.com/r/godot/comments/12brde4/classs_somename_hides_a_global_script_class/
# 링크에 의하면 class_name으로 선언된 클래스는 Autoload를 하지 않더라도 전역레지스트리에 등록되어 다른
# 스크립트에서 사용이 가능한것으로 보임
class_name BlockTypeData

var TypeName: String # 블럭 이름
var Indices: Array[Vector2i] # 블럭 인덱스 배열
