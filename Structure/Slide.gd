extends Resource
class_name Slide

@export var isGameplay: bool = false
@export var skipOnInput: bool = false
@export var sceneIndex: int = 0
@export_multiline var displayText: String
@export var displayImage: Texture
@export var audio: AudioStream
@export var respawnSlide: Slide
@export var secondsAdd: float = 0.0
