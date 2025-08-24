class_name Http
extends Node

static func request(method: HTTPClient.Method, route: String, body: Dictionary = {}) -> Response:
	var http_client := HTTPClient.new()
	var host := WS.host
	var port := WS.port
	var err := http_client.connect_to_host(host, port)
	if err != OK:
		return Response.new(500, "", "Unable to connect to host")
	
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
	
	var authorization = "Authorization:%s"%[WS.token]
	var headers := ["Content-Type: application/json", authorization]
	var body_str: String = ""
	match method:
		HTTPClient.METHOD_GET:
			body_str = http_client.query_string_from_dict(body)
		HTTPClient.METHOD_POST:
			body_str = JSON.stringify(body)
		HTTPClient.METHOD_DELETE:
			body_str = JSON.stringify(body)
	
	err = http_client.request(method, route, headers, body_str)
	if err != OK:
		return Response.new(500, "", "Unable to process request")
	
	while http_client.get_status() == HTTPClient.STATUS_REQUESTING:
		http_client.poll()
	
	if http_client.get_status() != HTTPClient.STATUS_BODY and http_client.get_status() != HTTPClient.STATUS_CONNECTED:
		return Response.new(500, "", "Unable to process response")
	
	var status_code := http_client.get_response_code()
	if not http_client.has_response():
		return Response.new(status_code, "", "Client has no response")
	
	var rb = PackedByteArray()
	while http_client.get_status() == HTTPClient.STATUS_BODY:
		http_client.poll()
		
		var chunk = http_client.read_response_body_chunk()
		if chunk.size() != 0:
			rb = rb + chunk
	
	var data = rb.get_string_from_ascii()
	return Response.new(status_code, data, "")
