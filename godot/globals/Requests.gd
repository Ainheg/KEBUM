extends Node

const URL = "http://127.0.0.1"
const PORT = 5000
const HEADERS = ["Content-Type: application/json"]
var http

func _ready():
	http = HTTPClient.new()
	
func connect_to_server():
	var err = http.connect_to_host(URL, PORT)
	assert(err == OK)
	
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")
		if not OS.has_feature("web"):
			OS.delay_msec(50)
		else:
			yield(Engine.get_main_loop(), "idle_frame")
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.
	
func request_map(type, rng_seed):
	connect_to_server()
	
	var query = JSON.print(
		{
			"map_type" : type,
			"map_width" : 80,
			"map_height" : 80,
			"seed" : rng_seed
		}
	)
	
	var response = _request(HTTPClient.METHOD_GET, "/map", query)
	
	return parse_json(response)

func request_item(level, luck, rng_seed):
	connect_to_server()
	
	var query = JSON.print(
		{
			"level" : level,
			"luck" : luck,
			"seed" : rng_seed
		}
	)
	
	var response = _request(HTTPClient.METHOD_GET, "/item", query)
	
	return parse_json(response)

func request_boss(level, rng_seed):
	connect_to_server()
	
	var query = JSON.print(
		{
			"level" : level,
			"seed" : rng_seed
		}
	)
	
	var response = _request(HTTPClient.METHOD_GET, "/boss", query)
	
	return parse_json(response)

func _request(method, endpoint, query):
	
	var error = http.request(method, endpoint, HEADERS, query)
	
	assert(error == OK, "Error occured when making the request")
	
	print(http.get_status())
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		print("Requesting...")
		if OS.has_feature("web"):
			yield(Engine.get_main_loop(), "idle_frame")
		else:
			OS.delay_msec(50)
	
	print(http.get_status())
	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.
	
	var rb =  PoolByteArray()
	if http.has_response():
		if http.is_response_chunked():
				# Does it use chunks?
				print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)
			
		while http.get_status() == HTTPClient.STATUS_BODY:
			http.poll()
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				if not OS.has_feature("web"):
					OS.delay_usec(1000)
				else:
					yield(Engine.get_main_loop(), "idle_frame")
			else:
				rb += chunk
				
	return rb.get_string_from_ascii()
	
	
