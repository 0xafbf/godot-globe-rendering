extends Node3D



# Declare member variables here. Examples:
var aim_origin: Vector3
var aim_direction: Vector3


var cam_distance: float = Geo.size_x * 3
var cam_latitude: float = TAU/4
var cam_longitude: float = -TAU/4

var cam_orbiting: bool = false

var speed_lonlat: Vector2
var marker_lonlat: Vector2 = Vector2(-74.08175, 4.60972) * TAU / 360


@export var cam_speed: float = TAU/360*0.5
@export var cam_zoom_speed: float = 1.04


const Globe = preload("globe.gd")
@onready var globe: Globe = $"../Globe"
@onready var cam: Camera3D = $"../Camera3D"
@onready var cursor: Node3D = $"../Cursor"
@onready var marker: Node3D = $"../Marker"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(input):
	if input is InputEventMouseMotion:
		if cam_orbiting:
			cam_latitude += input.relative.y * cam_speed
			cam_latitude = clamp(cam_latitude, 0, TAU/4)
			cam_longitude += input.relative.x * cam_speed
	elif input is InputEventMouseButton:
		if input.button_index == MOUSE_BUTTON_MIDDLE:
			cam_orbiting = input.pressed
		elif input.button_index == MOUSE_BUTTON_WHEEL_UP:
			var cam_factor = pow(cam_zoom_speed, -input.factor)
			cam_distance *= cam_factor
		elif input.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var cam_factor = pow(cam_zoom_speed, input.factor)
			cam_distance *= cam_factor
	
func _process(delta):
	
	var cam_x = cam_distance * cos(cam_latitude) * cos(cam_longitude)
	var cam_z = cam_distance * cos(cam_latitude) * sin(cam_longitude)
	var cam_y = cam_distance * sin(cam_latitude)
	
	var cam_position = Vector3(cam_x, cam_y, cam_z) 
	cam.position = cam_position
	
	cam.near = cam_distance * 0.001
	cam.far = cam_distance * 1000
	
	var cam_fwd = -cam_position.normalized()
	var cam_right = cam_fwd.cross(Vector3.UP)
	var cam_up = cam_right.cross(cam_fwd)
	
	cam.transform.basis = Basis(cam_right, cam_up, -cam_fwd)
	
	
	
	aim_origin = cam.position
	var mouse_pos = get_viewport().get_mouse_position()
	aim_direction = cam.project_ray_normal(mouse_pos)
	
	var aim_direction_ecef = globe.engine_dir_to_ecef(aim_direction)
	var aim_position_ecef = globe.engine_pos_to_ecef(aim_origin)
	
	var ecef = globe.trace_cartesian(aim_position_ecef, aim_direction_ecef)
	var eus = globe.eus_at_ecef(ecef)
	
	cursor.transform = globe.ecef_tx_to_engine(Transform3D(eus, ecef))

	marker_lonlat += speed_lonlat * delta
	globe.center_at_lonlat(marker_lonlat.x, marker_lonlat.y)
	
	var cam_ecef = globe.engine_pos_to_ecef(cam_position)
	globe.refine_from_ecef(cam_ecef)
	


func _on_LatitudeSpinner_value_changed(value):
	var lat_radians = value * TAU / 360
	speed_lonlat.y = lat_radians

func _on_LongitudeSpinner_value_changed(value):
	var lon_radians = value * TAU / 360
	speed_lonlat.x = lon_radians
