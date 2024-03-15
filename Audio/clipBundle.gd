extends Resource
class_name ClipBundle

@export var clips: Array[AudioStream] = []

func playRandom(source: AudioStreamPlayer3D):
	source.stream = clips.pick_random()
	source.play()

func playRandomNoPrevious(source: AudioStreamPlayer3D):
	var NewStream = clips.pick_random()
	while source.stream == NewStream:
		NewStream = clips.pick_random()
	source.stream = NewStream
	source.play()
