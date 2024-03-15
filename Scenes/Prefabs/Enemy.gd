extends CharacterBody3D

var speed = 0
var maxSpeed = 5
var accel = 10
@onready var Visual = $MeshInstance3D/Armature/Skeleton3D/Entity
@onready var VisualRoot = $MeshInstance3D
@onready var Anim = $MeshInstance3D/AnimationTree
@onready var nav: NavigationAgent3D = $NavigationAgent3D
var playerInRange: bool = false
var targetPos: Vector3

var canHear: bool = true
@export var SlideTriggerRef: EndSlideTrigger

@export var chirpBundle: ClipBundle
@onready var chirpTimer:Timer = $ChirpSource/ChirpTimer
@export var aggroBundle: ClipBundle
@onready var aggroTimer:Timer = $AggroSource/AggroTimer
var canAggroSound: bool = true
var canKill: bool = false

var headingVector: Vector3
var TargetVector: Vector3

var PlayerRef: player_controller

@export var AggroRange: float = 25.0

func _ready():
	if (SlideTriggerRef != null):
		canHear = false
		SlideTriggerRef.connect("onTrigger",makeCanHear)
	Globals.connect("NoiseEvent", OnHearNoise)
	headingVector = basis.z
	playChirp()

func _process(_delta):
	if canKill:
		PlayerRef.health -= _delta * 6
		if !$KillSound.playing:
			Globals.KillPlayer() # kill player once sound is done playing
	AnimUpdate()
	RotateToTarget()

func makeCanHear():
	canHear = true

func _physics_process(_delta):
	if Globals.currSlide.isGameplay:
		ManageMovement()
	move_and_slide()

func OnHearNoise(_str: float, _pos: Vector3):
	#if (_pos.distance_squared_to(position) < pow(AggroRange, 2)):
	if (canHear):
		playAggro()
		speed += _str * 1
		targetPos = Globals.PlayerPos

func ManageMovement():
	var direction: Vector3
	
	nav.target_position = targetPos
	
	speed -= get_process_delta_time() * .5
	speed = clamp(speed, 0, maxSpeed)
	
	if playerInRange:
		speed += get_process_delta_time() * 1
		targetPos = Globals.PlayerPos
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	#Visual.get_surface_override_material().set_shader_parameter("IntensityMult,speed * .2")
	#Visual.material_override.set_shader_param("IntensityMult", speed * .2)
	
	velocity = velocity.lerp(direction * speed, accel * get_process_delta_time())


func _on_area_3d_body_entered(body):
	if body is player_controller:
		playerInRange = true
		aggroBundle.playRandomNoPrevious($AggroSource)

func _on_area_3d_body_exited(body):
	if body is player_controller:
		playerInRange = false

func _on_death_trigger_body_entered(body):
	if body is player_controller:
		PlayerRef = body
		Anim.set("parameters/CallHigh/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		$KillSound.play()
		canKill = true

func playChirp():
	chirpBundle.playRandomNoPrevious($ChirpSource)
	chirpTimer.wait_time = randf_range(2.0,4.0)
	chirpTimer.start()

func _on_timer_timeout():
	playChirp()
	
func playAggro():
	if canAggroSound:
		aggroBundle.playRandomNoPrevious($AggroSource)
		aggroTimer.wait_time = randf_range(1,3)
		canAggroSound = false
		aggroTimer.start()

func _on_aggro_timer_timeout():
	canAggroSound = true

func RotateToTarget():
	if velocity.length_squared() > .1:
		TargetVector = -Vector3(velocity.x, 0, velocity.z).normalized()
	headingVector = lerp(headingVector, TargetVector, get_process_delta_time() * 2).normalized()
	if headingVector.length_squared() > .01:
		VisualRoot.look_at(VisualRoot.global_position + headingVector, Vector3.UP)

func AnimUpdate():
	#var turn = clamp(VisualRoot.basis.z.angle_to(TargetVector) * sign(VisualRoot.basis.z.dot(TargetVector.cross(Vector3.UP))),-1,1)
	#var turn = clamp(sign(VisualRoot.basis.x.dot(TargetVector)),-1,1)
	#Anim.set("parameters/Rotation/add_amount",turn)
	var vel = velocity.length() / maxSpeed
	Anim.set("parameters/WalkBlend/blend_amount",clamp(vel * 2,0,1))
	Anim.set("parameters/MoveSpeed/blend_position",vel * 5)
