extends AudioStreamPlayer3D

@export var charCon: Node3D
@export var startSound: AudioStream
@export var loopSound: AudioStream
@export var stopSound: AudioStream

var wasAiming: bool = false

func _process(_delta):
	if charCon.isAiming && !wasAiming:
		stream = startSound
		play()
	if !charCon.isAiming && wasAiming:
		stream = stopSound
		play()
	
	if charCon.isAiming && stream == startSound && playing == false:
		stream = loopSound
		play()
	
	wasAiming = charCon.isAiming
