@tool
extends ImmediateMesh

@export var steps_lat: int = 16
@export var steps_lon: int = 16

@export var draw_a: bool = true
@export var draw_b: bool = true


func add_ellipsoid(a, b, c):
	
	
	if draw_a:
		draw_latitudes(a, b, c)
	if draw_b:
		draw_longitudes(a, b, c)
	
		
func draw_fill(a, b, c):
	
	surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var lat_frac = 1/float(steps_lat)
	var lon_frac = 1/float(steps_lon)
	
	for lat_p in range(steps_lat):
		var lat = lat_p + 1
		
		var lat_radians = (((lat * lat_frac) * 0.5 ) - 0.25) * TAU
		var lat_p_radians = (((lat_p * lat_frac) * 0.5 ) - 0.25) * TAU
		# 0.5 because we only care about half turns, from -tau/4 to tau/4
		
		var lat_sin = sin(lat_radians)
		var lat_cos = cos(lat_radians)
		var lat_p_sin = sin(lat_p_radians)
		var lat_p_cos = cos(lat_p_radians)
		
		var prev_z = c * lat_p_sin
		var curr_z = c * lat_sin
		
		for lon_p in range(steps_lon):
			var lon = lon_p + 1
		
			var lon_radians = (lon * lon_frac) * TAU
			var lon_p_radians = (lon_p * lon_frac) * TAU
			
			var lon_sin = sin(lon_radians)
			var lon_cos = cos(lon_radians)
			var lon_p_sin = sin(lon_p_radians)
			var lon_p_cos = cos(lon_p_radians)
			
			var point_aa = Vector3(a * lat_p_cos * lon_p_cos, b * lat_p_cos * lon_p_sin, prev_z)
			var point_ab = Vector3(a * lat_cos   * lon_p_cos, b * lat_cos   * lon_p_sin, curr_z)
			var point_ba = Vector3(a * lat_p_cos * lon_cos,   b * lat_p_cos * lon_sin,   prev_z)
			var point_bb = Vector3(a * lat_cos   * lon_cos,   b * lat_cos   * lon_sin,   curr_z)
			
			surface_set_color(Color(lon * lon_frac, lat * lat_frac, 0))
			
			var uv_aa = Vector2(0.5 + lon_p * lon_frac, 1 - lat_p * lat_frac)
			var uv_ab = Vector2(0.5 + lon_p * lon_frac, 1 - lat   * lat_frac)
			var uv_ba = Vector2(0.5 + lon   * lon_frac, 1 - lat_p * lat_frac)
			var uv_bb = Vector2(0.5 + lon   * lon_frac, 1 - lat   * lat_frac)
			
			surface_set_uv(uv_aa)
			surface_set_normal(point_aa.normalized())
			surface_add_vertex(point_aa)
			
			surface_set_uv(uv_ab)
			surface_set_normal(point_ab.normalized())
			surface_add_vertex(point_ab)
			
			surface_set_uv(uv_bb)
			surface_set_normal(point_bb.normalized())
			surface_add_vertex(point_bb)
			
			surface_set_uv(uv_bb)
			surface_set_normal(point_bb.normalized())
			surface_add_vertex(point_bb)
			
			surface_set_uv(uv_ba)
			surface_set_normal(point_ba.normalized())
			surface_add_vertex(point_ba)
			
			surface_set_uv(uv_aa)
			surface_set_normal(point_aa.normalized())
			surface_add_vertex(point_aa)
			
			
	surface_end()
	
	
func draw_latitudes(a, b, c):
	surface_set_color(Color(0, 0, 0))
	
	var prev_z: float = c
	for lat_p in range(steps_lat):
		var lat = lat_p + 1
		
		var lat_relative = lat/float(steps_lat)
		# 0.5 because we only care about half turns, from -tau/4 to tau/4
		
		var lat_radians = ((lat_relative * 0.5) - 0.25) * TAU
		var lat_sin = sin(lat_radians)
		var lat_cos = cos(lat_radians)
		var curr_z = c * lat_sin
		
		var prev_x = a * lat_cos
		var prev_y = 0
		
		for lon_p in range(steps_lon):
			var lon = lon_p + 1
			var lon_relative = lon/float(steps_lon)
			var lon_radians = (lon_relative) * TAU
			
			var curr_x = a * cos(lon_radians) * lat_cos
			var curr_y = b * sin(lon_radians) * lat_cos
			
			surface_add_vertex(Vector3(prev_x, prev_y, curr_z) * 1.001)
			surface_add_vertex(Vector3(curr_x, curr_y, curr_z) * 1.001)
			
			prev_x = curr_x
			prev_y = curr_y
			
		prev_z = curr_z

func draw_longitudes(a, b, c):
	surface_set_color(Color(0, 0, 0))
	
	for lon_p in range(steps_lon):
		var lon = lon_p + 1
		
		var lon_relative = lon/float(steps_lon)
		var lon_radians = (lon/float(steps_lon)) * TAU
		
		var lon_cos = cos(lon_radians)	
		var lon_sin = sin(lon_radians)	
			
		var prev_z = -c
		var prev_x = 0
		var prev_y = 0
		
		for lat_p in range(steps_lat):
			var lat = lat_p + 1
		
			var lat_relative = lat/float(steps_lat)
			# 0.5 because we only care about half turns, from -tau/4 to tau/4
			var lat_radians = ((lat/float(steps_lat) * 0.5) - 0.25) * TAU
			var lat_sin = sin(lat_radians)
			var lat_cos = cos(lat_radians)
			
			var curr_x = a * lon_cos * lat_cos
			var curr_y = b * lon_sin * lat_cos
			var curr_z = c * lat_sin
		
			surface_add_vertex(Vector3(prev_x, prev_y, prev_z) * 1.001)
			surface_add_vertex(Vector3(curr_x, curr_y, curr_z) * 1.001)
			
			prev_x = curr_x
			prev_y = curr_y
			prev_z = curr_z
			
