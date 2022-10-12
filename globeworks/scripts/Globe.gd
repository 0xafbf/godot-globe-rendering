
extends Node3D


@export var steps_lat: int = 16
@export var steps_lon: int = 16

@export var lat = 4.60972
@export var lon = -74.08175

@export var material: Material

var all_tiles: Dictionary = {}
var root_tiles: Array = []
var all_loaders: Array = []
var free_loaders: Array = []

func _ready():
	root_tiles.append(queue_tile("0"))
	root_tiles.append(queue_tile("1"))
	root_tiles.append(queue_tile("2"))
	root_tiles.append(queue_tile("3"))

func queue_tile(quadkey: String) -> MapTileMesh:
	var existing = all_tiles.get(quadkey)
	if existing:
		return
	
	
	var tile_loader: MapTileRequest = free_loaders.pop_back()
	if tile_loader == null:
		tile_loader = MapTileRequest.new()
		all_loaders.push_back(tile_loader)
		add_child(tile_loader)
		tile_loader.tile_loaded.connect(on_tile_ready)
		
	tile_loader.load_tile(quadkey)
	print(quadkey)
	
	var mesh_inst: MapTileMesh = MapTileMesh.new()
	mesh_inst.quadkey = quadkey
	all_tiles[quadkey] = mesh_inst
	return mesh_inst

var prev_ecef: Vector3 = Vector3.ZERO

func refine_from_ecef(eye_ecef: Vector3):
	if eye_ecef == prev_ecef:
		return
	for tile in root_tiles:
		refine_tile(tile, eye_ecef)
	prev_ecef = eye_ecef
		
	
func refine_tile(tile: MapTileMesh, eye_ecef: Vector3):
	var quadkey = tile.quadkey
	var tile_bounds = Geo.get_tile_coords(tile.quadkey)
	var tile_bounds_min = Geo.mercator_to_lonlat(tile_bounds[0], tile_bounds[3])
	var tile_bounds_max = Geo.mercator_to_lonlat(tile_bounds[2], tile_bounds[1])
	var tile_interest_point = Geo.ecef_to_lonlat(eye_ecef)
	var tile_center_x: float = clamp(tile_interest_point.x, tile_bounds_min.x, tile_bounds_max.x)
	var tile_center_y: float = clamp(tile_interest_point.y, tile_bounds_min.y, tile_bounds_max.y)
	var tile_pos_ecef = Geo.lonlat_to_ecef(tile_center_x, tile_center_y)
	var dist = eye_ecef.distance_to(tile_pos_ecef)
	
	var scale_factor: float = 32
	var tile_size = Geo.size_x * scale_factor / (2 << len(quadkey))
	#print ("refining tile %s bounds %s point %s dist %s" % [quadkey, tile_bounds, tile_interest_point, dist])
	
	var should_subtile = dist < tile_size
	
	set_subtile(tile, should_subtile, eye_ecef)

func set_subtile(tile: MapTileMesh, in_should_subtile: bool, eye_ecef: Vector3 = Vector3.ZERO):
	
	var should_subtile = in_should_subtile
	if len(tile.quadkey) > 18:
		should_subtile = false
	
	if not should_subtile:
		
		tile.visible = true
		if tile.subtiles:
			for subtile in tile.subtiles:
				set_subtile(subtile, false)
				subtile.visible = false
		
	else:
		tile.visible = false
		if len(tile.subtiles) == 0:
			var base_quadkey = tile.quadkey
			var new_subtiles: Array = []
			new_subtiles.append(queue_tile("%s0" % base_quadkey))
			new_subtiles.append(queue_tile("%s1" % base_quadkey))
			new_subtiles.append(queue_tile("%s2" % base_quadkey))
			new_subtiles.append(queue_tile("%s3" % base_quadkey))
			tile.subtiles = new_subtiles
			
		for subtile in tile.subtiles:
			refine_tile(subtile, eye_ecef)

func on_tile_ready(tile_loader: MapTileRequest):
	
	var mesh_inst: MapTileMesh = all_tiles[tile_loader.quadkey]
	mesh_inst.set_tile(tile_loader.quadkey, tile_loader.texture)
	add_child(mesh_inst)
	all_tiles[tile_loader.quadkey] = mesh_inst
	free_loaders.push_back(tile_loader)
	

func trace_cartesian(aim_origin: Vector3, aim_direction: Vector3):
		
	# based checked https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection
	var u = aim_direction
	var o = aim_origin
	var r = Geo.size_x
	
	var b = u.dot(o)
	var c = o.dot(o) - (r*r)
	var determinante = b*b - c
	if determinante < 0:
		return Vector3()
	var d = -b - sqrt(determinante)
	
	var pf = o + u*d
	return pf
	

var globe_lon: float
var globe_lat: float
var globe_ecef: Vector3
var globe_eus: Basis

func center_at_lonlat(lon: float, lat: float):
	globe_lon = lon
	globe_lat = lat
	globe_ecef = Geo.lonlat_to_ecef(lon, lat)
	globe_eus = eus_at_ecef(globe_ecef)
	
	var tx = Transform3D(globe_eus, globe_ecef)
	transform = tx.inverse()
	
	
func eus_at_ecef(ecef: Vector3) -> Basis:
	var up = ecef.normalized()
	var east = up.cross(Vector3(0, 0, 1))
	east = east.normalized()
	var south = east.cross(up)
	var result = Basis(east, up, south)
	return result
	
func ecef_tx_to_engine(in_tx: Transform3D) -> Transform3D:
	var tx = Transform3D(globe_eus, globe_ecef)
	#return in_tx * tx.inverse()
	return tx.inverse() * in_tx
	
func engine_pos_to_ecef(position: Vector3) -> Vector3:
	var tx = Transform3D(globe_eus, globe_ecef)
	return tx * position

func engine_dir_to_ecef(direction: Vector3) -> Vector3:
	return globe_eus * direction
