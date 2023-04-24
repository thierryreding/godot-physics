extends CharacterBody3D

const MOUSE_SENSITIVITY := 0.25
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const PUSH_FORCE := 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var joint = $Head/Hand/Joint
@onready var head = $Head

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate(Vector3.RIGHT, deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, -PI / 2, PI / 2)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("grab"):
		var target : Object = raycast.get_collider()
		if target is RigidBody3D:
			print("grabbing object %s" % target)
			joint.node_b = target.get_path()
	
	if Input.is_action_just_released("grab"):
		joint.node_b = ""
	
	if Input.is_action_just_pressed("push"):
		var target : Object = raycast.get_collider()
		if target is RigidBody3D:
			var point : Vector3 = raycast.get_collision_point()
			#var normal : Vector3 = raycast.get_collision_normal()
			#var force : Vector3 = -normal * PUSH_FORCE
			#var force = (target.global_position - camera.global_position).normalized() * PUSH_FORCE
			var force = (point - camera.global_position).normalized() * PUSH_FORCE
			print("pushing object %s at point %s: %s" % [target, point, force])
			target.apply_impulse(force, target.to_local(point))
			print("local point: %s" % target.to_local(point))

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
