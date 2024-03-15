extends Node3D

var stepL: bool = true
@export var charCon: Node3D
@export var footsteps: ClipBundle
@export var audioPlayers: Array[AudioStreamPlayer3D]
var timeSinceLastStep: float = 0.0

func _process(delta):
	timeSinceLastStep += delta

func playStepL():
	if !stepL:
		playStep()
		stepL = true
	pass

func playStepR():
	if stepL:
		playStep()
		stepL = false
	pass

func playStep():
	if "stepStr" in charCon:
		if charCon.stepStr > .3 && timeSinceLastStep > .2:
			footsteps.playRandomNoPrevious(GetFreePlayer())
			timeSinceLastStep = 0

func GetFreePlayer() -> AudioStreamPlayer3D:
	var complete = false
	for player: AudioStreamPlayer3D in audioPlayers:
		if !player.playing && !complete:
			complete = true
			return player
	return audioPlayers[0]
