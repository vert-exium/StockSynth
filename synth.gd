extends Node2D

# Node References
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer2D
@onready var beat_timer: Timer = $Timer

@onready var ticker_input: LineEdit = $ChartUI/TickerInput
@onready var fetch_button: Button = $ChartUI/FetchButton
@onready var cooldown_timer: Timer = $ChartUI/CooldownTimer

@onready var graph_rect: ColorRect = $ChartUI/GraphRect
@onready var graph_line: Line2D = $ChartUI/GraphRect/GraphLine
@onready var scanline: Line2D = $ChartUI/GraphRect/Scanline
@onready var status_label: Label = $ChartUI/GraphRect/StatusLabel

# Twelve Data Configuration for 1 Month (~1600 points of 5min bars)
const INTERVAL = "5min"
const OUTPUTSIZE = 1600
# test edit
# Local Cache to save API credits (Stores: {"AAPL": [150.2, 150.8, ...]})
var stock_cache: Dictionary = {}

var stock_pitches: Array[float] = []
var raw_prices: Array[float] = []
var current_note_index: int = 0

func _ready() -> void:
	# Connect UI Signals
	fetch_button.pressed.connect(_on_fetch_button_pressed)
	http_request.request_completed.connect(_on_data_received)
	beat_timer.timeout.connect(_on_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	
	scanline.visible = false
	status_label.text = "Type a ticker symbol (e.g. AAPL, TSLA, BTC/USD) and click Load!"

func _on_fetch_button_pressed() -> void:
	var symbol = ticker_input.text.strip_edges().to_upper()
	if symbol.is_empty():
		status_label.text = "Please enter a valid stock symbol!"
		return
		
	fetch_stock_month(symbol)

func fetch_stock_month(symbol: String) -> void:
	# Stop timer and audio while fetching new data
	beat_timer.stop()
	audio_player.stop()
	
	# 1. Check local cache first to save API credits
	if stock_cache.has(symbol):
		status_label.text = "Loaded " + symbol + " from cache!"
		raw_prices = stock_cache[symbol]
		process_and_start_song()
		return

	# 2. If not cached, check key and make API call
	var api_key = Global.apiKey.strip_edges()
	if api_key.is_empty():
		status_label.text = "Error: No API Key found in Global script!"
		return

	# Apply a 5-second button cooldown to keep players from spamming requests
	fetch_button.disabled = true
	cooldown_timer.start(5.0)

	status_label.text = "Fetching 1-month high-res data for " + symbol + "..."
	
	var url = "https://api.twelvedata.com/time_series?symbol=%s&interval=%s&outputsize=%d&apikey=%s" % [
		symbol, INTERVAL, OUTPUTSIZE, api_key
	]
	
	http_request.request(url)

func _on_data_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 429:
		status_label.text = "Rate limit reached (8 credits/min). Wait a minute!"
		return
	elif response_code != 200:
		status_label.text = "HTTP Error: " + str(response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# Twelve Data Error Handling
	if json and json.has("status") and json["status"] == "error":
		status_label.text = "API Error: " + json["message"]
		return

	if json and json.has("values"):
		raw_prices.clear()
		for val in json["values"]:
			raw_prices.append(float(val["close"]))
		
		# Reverse array so oldest point (1 month ago) is left, newest point is right
		raw_prices.reverse()
		
		if raw_prices.size() > 0:
			# Cache prices for this symbol
			var symbol = ticker_input.text.strip_edges().to_upper()
			stock_cache[symbol] = raw_prices.duplicate()
			
			status_label.text = "" # Clear status label on success
			process_and_start_song()
		else:
			status_label.text = "No price data found for symbol."
	else:
		status_label.text = "Invalid response from API."

func process_and_start_song() -> void:
	draw_stock_graph(raw_prices)
	convert_prices_to_pitches(raw_prices)
	start_music_sequencer()

func draw_stock_graph(prices: Array[float]) -> void:
	graph_line.clear_points()
	
	var min_price = prices.min()
	var max_price = prices.max()
	if min_price == max_price: max_price += 0.01

	var num_points = prices.size()
	var rect_size = graph_rect.size
	
	# Map prices to 2D graph points
	for i in range(num_points):
		var x_pos = (float(i) / float(num_points - 1)) * rect_size.x
		var norm_y = remap(prices[i], min_price, max_price, 0.0, 1.0)
		var y_pos = rect_size.y - (norm_y * rect_size.y) # Invert Y for screen space
		
		graph_line.add_point(Vector2(x_pos, y_pos))

func convert_prices_to_pitches(prices: Array[float]) -> void:
	stock_pitches.clear()
	
	var min_price = prices.min()
	var max_price = prices.max()
	if min_price == max_price: max_price += 0.01

	for price in prices:
		var norm = remap(price, min_price, max_price, 0.0, 1.0)
		
		# Continuous pitch mapping: maps price range to pitch_scale ratios (0.5 to 2.0)
		# Low stock price = half pitch (1 octave down)
		# High stock price = double pitch (1 octave up)
		var smooth_pitch = remap(norm, 0.0, 1.0, 0.5, 2.0)
		stock_pitches.append(smooth_pitch)

func start_music_sequencer() -> void:
	scanline.visible = true
	var rect_size = graph_rect.size
	
	# Setup vertical scanline
	scanline.clear_points()
	scanline.add_point(Vector2(0, 0))
	scanline.add_point(Vector2(0, rect_size.y))
	
	current_note_index = 0
	_update_scanline_position()
	
	# Start audio player ONCE (letting it loop without re-triggering)
	if not audio_player.playing:
		audio_player.play()
	
	# Update position/pitch every 0.03 seconds for a smooth 48-second scan across the month
	beat_timer.wait_time = 0.03
	beat_timer.start()

func _on_timer_timeout() -> void:
	if stock_pitches.is_empty(): return
		
	# Smoothly adjust pitch_scale on the currently playing loop (No play() call!)
	audio_player.pitch_scale = stock_pitches[current_note_index]
	
	# Move scanline right and wrap back to start at the end of the graph
	current_note_index = (current_note_index + 1) % stock_pitches.size()
	_update_scanline_position()

func _update_scanline_position() -> void:
	var num_points = stock_pitches.size()
	var rect_size = graph_rect.size
	
	# Calculate horizontal position for scanline
	var x_pos = (float(current_note_index) / float(num_points - 1)) * rect_size.x
	scanline.position.x = x_pos

func _on_cooldown_finished() -> void:
	fetch_button.disabled = false
