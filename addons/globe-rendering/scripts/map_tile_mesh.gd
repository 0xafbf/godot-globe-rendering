class_name MapTileMesh

extends MeshInstance3D

var quadkey: String

var mesh_ref: Mesh
var texture: Texture

var subtiles: Array

func set_tile(in_quadkey: String, in_texture: Texture):
	texture = in_texture
	quadkey = in_quadkey
	name = quadkey
	
	var coords: Vector4 = Geo.get_tile_coords(quadkey)
	var topleft_lonlat = Geo.mercator_to_lonlat(coords.x, coords.y)
	var botright_lonlat = Geo.mercator_to_lonlat(coords.z, coords.w)
	mesh_ref = gen_geo_mesh(topleft_lonlat.x, topleft_lonlat.y, botright_lonlat.x, botright_lonlat.y)
	mesh = mesh_ref
	
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	material_override = mat


func gen_geo_mesh(left: float, top: float, right: float, bottom: float):
	
	var steps_lat: int = 4
	var steps_lon: int = 4
	
	var a = Geo.size_x
	var b = Geo.size_x
	var c = Geo.size_x
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	
	var lat_frac = 1/float(steps_lat)
	var lon_frac = 1/float(steps_lon)
	
	for lat_p in steps_lat:
		var lat = lat_p + 1
		var lat_rel = lat * lat_frac
		var lat_p_rel = lat_p * lat_frac
		
		var lat_radians = lerp(top, bottom, lat_rel)
		var lat_p_radians = lerp(top, bottom, lat_p_rel)
		# 0.5 because we only care about half turns, from -tau/4 to tau/4
		
		var lat_sin = sin(lat_radians)
		var lat_cos = cos(lat_radians)
		var lat_p_sin = sin(lat_p_radians)
		var lat_p_cos = cos(lat_p_radians)
		
		for lon_p in steps_lon:
			var lon = lon_p + 1
			
			var lon_rel = lon * lon_frac
			var lon_p_rel = lon_p * lon_frac
		
			var lon_radians = lerp(left, right, lon_rel)
			var lon_p_radians = lerp(left, right, lon_p_rel)
			
			var lon_sin = sin(lon_radians)
			var lon_cos = cos(lon_radians)
			var lon_p_sin = sin(lon_p_radians)
			var lon_p_cos = cos(lon_p_radians)
			
			# this math is WRONG! assumes spherical, not ellipsoid geometry
			var dir_aa = Vector3(lat_p_cos * lon_p_cos, lat_p_cos * lon_p_sin, lat_p_sin)
			var dir_ab = Vector3(lat_cos   * lon_p_cos, lat_cos   * lon_p_sin, lat_sin)
			var dir_ba = Vector3(lat_p_cos * lon_cos,   lat_p_cos * lon_sin,   lat_p_sin)
			var dir_bb = Vector3(lat_cos   * lon_cos,   lat_cos   * lon_sin,   lat_sin)
			
			var sizes = Vector3(a, b, c)
			
			var point_aa = dir_aa * sizes
			var point_ab = dir_ab * sizes
			var point_ba = dir_ba * sizes
			var point_bb = dir_bb * sizes
			
			#surface_set_color(Color(lon * lon_frac, lat * lat_frac, 0))
			
			var uv_aa = Vector2(0.5 + lon_p * lon_frac, 1 - lat_p * lat_frac)
			var uv_ab = Vector2(0.5 + lon_p * lon_frac, 1 - lat   * lat_frac)
			var uv_ba = Vector2(0.5 + lon   * lon_frac, 1 - lat_p * lat_frac)
			var uv_bb = Vector2(0.5 + lon   * lon_frac, 1 - lat   * lat_frac)
			
			var start_idx = verts.size()
			
			# TODO: optimize to avoid redundant vertices
			verts.append(point_aa) # aa
			verts.append(point_ab) # ab
			verts.append(point_ba) # ba
			verts.append(point_bb) # bb
			
			
			# fix for texture ranges, we need to offset half a pixel from each side
			var half_pixel = 0.5 / 256
			var uv_lon_p = lerp(half_pixel, 1 - half_pixel, lon_p_rel)
			var uv_lon   = lerp(half_pixel, 1 - half_pixel, lon_rel)
			var uv_lat_p = lerp(half_pixel, 1 - half_pixel, lat_p_rel)
			var uv_lat   = lerp(half_pixel, 1 - half_pixel, lat_rel)
			
			uvs.append(Vector2(uv_lon_p, uv_lat_p))
			uvs.append(Vector2(uv_lon_p, uv_lat))
			uvs.append(Vector2(uv_lon, uv_lat_p))
			uvs.append(Vector2(uv_lon, uv_lat))
			
			normals.append(dir_aa)
			normals.append(dir_ab)
			normals.append(dir_ba)
			normals.append(dir_bb)
			
				
			indices.append(start_idx + 0)
			indices.append(start_idx + 2)
			indices.append(start_idx + 1)
			indices.append(start_idx + 1)
			indices.append(start_idx + 2)
			indices.append(start_idx + 3)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return mesh
