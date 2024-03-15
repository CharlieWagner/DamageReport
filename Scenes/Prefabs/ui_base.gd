extends CanvasLayer

@export var clicks: ClipBundle

func _process(_delta):
	CheckForInput()

func loadSlide(newSlide: Slide):
	if newSlide != null:
		clicks.playRandomNoPrevious($SlideSound)
		if newSlide.isGameplay:
			$Container/Slide.hide()
			$Container/TutorialText.show()
			$Container/TutorialText.text = Globals.GetProcessedText(newSlide.displayText)
			AudioServer.set_bus_mute(2, false)
			AudioServer.set_bus_mute(1, true)
		else:
			$Container/Slide.show()
			$Container/TutorialText.hide()
			$Container/Slide/Text.text = Globals.GetProcessedText(newSlide.displayText)
			$Container/Slide/DisplayImage.texture = newSlide.displayImage
			AudioServer.set_bus_mute(2, true)
			AudioServer.set_bus_mute(1, false)
		
		if newSlide.audio != null:
			$AudioStreamPlayer.stream = newSlide.audio
			$AudioStreamPlayer.play()

func CheckForInput():
	if Globals.currSlide.skipOnInput:
		if Input.is_action_just_pressed("Next"):
			Globals.moveToNextSlide()

func HideTutorial():
	$Container/TutorialText.hide()
