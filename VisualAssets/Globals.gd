extends Node

var PlayerPos: Vector3
var TargetPos: Vector3
var RespawnPos: Vector3
var currObjective: Vector3 = Vector3(0,0,0)
var currSlide: Slide
var currSlideIndex: int = 0
var allSlidesList: SlideList = preload("res://Structure/AllSlideList.tres")
signal NoiseEvent(str: float, pos: Vector3)
var SceneList: Array[PackedScene] = [preload("res://Scenes/Levels/Level01.tscn"),
preload("res://Scenes/Levels/Level02.tscn"),preload("res://Scenes/Levels/Level03.tscn"),
preload("res://Scenes/Levels/Level04.tscn"),preload("res://Scenes/Levels/Level05.tscn")]
var CurrSceneIndex: int = 0

var MissionTime: float = 0.0
var SlideTime: float = 0.0

signal doRespawn(pos: Vector3)

func _ready():
	currSlide = allSlidesList.slides[0]
	UiBase.loadSlide(currSlide)

func _process(delta):
	SlideTime += delta
	if Input.is_key_pressed(KEY_KP_0):
		ForceSlide(allSlidesList.debugSlides[0])
	if Input.is_key_pressed(KEY_KP_1):
		ForceSlide(allSlidesList.debugSlides[1])
	if Input.is_key_pressed(KEY_KP_2):
		ForceSlide(allSlidesList.debugSlides[2])
	if Input.is_key_pressed(KEY_KP_3):
		ForceSlide(allSlidesList.debugSlides[3])
	if Input.is_key_pressed(KEY_KP_4):
		ForceSlide(allSlidesList.debugSlides[4])

func moveToNextSlide():
	currSlideIndex += 1
	if currSlide.isGameplay:
		MissionTime += SlideTime
	else:
		MissionTime += currSlide.secondsAdd
	SlideTime = 0.0
	
	
	if currSlideIndex < len(allSlidesList.slides):
		loadSlide(allSlidesList.slides[currSlideIndex])
	else:
		if OS.get_name() != "Web":
			get_tree().quit()

func ForceSlide(newSlide: Slide):
	currSlideIndex = allSlidesList.slides.find(newSlide)
	loadSlide(newSlide)

func loadSlide(newSlide: Slide):
		currSlide = newSlide
		if currSlide.sceneIndex != CurrSceneIndex:
			get_tree().change_scene_to_packed(SceneList[currSlide.sceneIndex])
			CurrSceneIndex = currSlide.sceneIndex
			RespawnPos = PlayerPos
		
		UiBase.loadSlide(currSlide)

func completeSpecific(slide: Slide):
	if currSlide == slide:
		moveToNextSlide()

func KillPlayer():
	get_tree().reload_current_scene()
	doRespawn.emit(RespawnPos)
	SlideTime = 0.0
	if currSlide.respawnSlide != null:
		currSlideIndex = allSlidesList.slides.find(currSlide.respawnSlide)
		loadSlide(currSlide.respawnSlide)
	else:
		loadSlide(currSlide)

func GetMissionHour() -> String:
	var timestamp = 8 * 3600 + 35 * 60 + MissionTime
	return GetHourMinString(timestamp)

func GetMissionTime() -> String:
	var timestamp = int(MissionTime)
	#return GetHourMinString(timestamp)
	var minutes = timestamp/60
	return str(minutes)

func GetHourMinString(value: float) -> String:
	var baseTime = int(value)
	var hours = baseTime / 3600
	var minutes = (baseTime % 3600)/60
	var output = str(hours) + ":" + str(minutes)
	return output

func GetProcessedText(value: String) -> String:
	value = value.replace("<MissionHour>", GetMissionHour())
	value = value.replace("<MissionTime>", GetMissionTime())
	return value
