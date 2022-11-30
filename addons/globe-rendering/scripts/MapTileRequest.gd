class_name MapTileRequest
extends HTTPRequest

signal tile_loaded(MapTileRequest)


var init: bool = false
var quadkey: String
var image: Image
var texture: ImageTexture

func _enter_tree():
	if !init:
		init = true
		request_completed.connect(on_request_completed)

func load_tile(in_quadkey: String):
	quadkey = in_quadkey
	var url = "http://ecn.t0.tiles.virtualearth.net/tiles/a%s.jpeg?g=12775" % quadkey
	var result = request(url)
	if result != OK:
		push_error("An error occurred in the HTTP request.")
	
func on_request_completed(result, response_code, headers, body):
	
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")

	image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	texture = ImageTexture.create_from_image(image)

	tile_loaded.emit(self)
	
