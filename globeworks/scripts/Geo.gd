class_name Geo
extends Node


const size_x: float = 6378137 # times million for real scale
const size_y: float = 6356752 # times million for real scale

static func mercator_to_lat(mercator_y: float) -> float:
	return (2 * atan(exp(mercator_y * PI))) - (PI * 0.5)
	
# we use all mercator coordinates in the -1:1 range
static func mercator_to_lonlat(mercator_x: float, mercator_y: float) -> Vector2:
	
	var lon: float = mercator_x * PI
	var lat: float = mercator_to_lat(mercator_y)
	
	return Vector2(lon, lat)


static func ecef_to_lonlat(ecef: Vector3) -> Vector2:
	
	var relative = ecef / size_x
	
	var latitude = asin(relative.z)
	var longitude = atan2(relative.y, relative.x)
	
	return Vector2(longitude, latitude)

static func lonlat_to_ecef(lon: float, lat: float) -> Vector3:
	
	var lat_cos = cos(lat)
	var lat_sin = sin(lat)
	var lon_cos = cos(lon)
	var lon_sin = sin(lon)
	
	var x = lat_cos * lon_cos * size_x
	var y = lat_cos * lon_sin * size_x
	var z = lat_sin * size_x
	
	return Vector3(x, y, z)
	

static func parse_int(input: String) -> int:
	if (input == "0"): return 0
	if (input == "1"): return 1
	if (input == "2"): return 2
	if (input == "3"): return 3
	return -1


# returns geographic coordinates as left, top, right, bottom
static func get_tile_coords(quadkey: String) -> Vector4:
	var top: float = 1
	var bottom: float = -1
	var left: float = -1
	var right: float = 1
	
	for char in quadkey:
		var val: int = parse_int(char)
		var is_top: bool = val < 2
		var is_left: bool = (val & 1) == 0
		
		if is_top: 
			# is top, so move bottom to half
			bottom -= (bottom - top) * 0.5
		else:
			top += (bottom - top) * 0.5
		
		if is_left: 
			# is top, so move bottom to half
			right -= (right - left) * 0.5
		else:
			left += (right - left) * 0.5
	
	return Vector4(left, top, right, bottom)
