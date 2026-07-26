extends Node2D

# Node References
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var beat_timer: Timer = $Timer
@onready var time_label_start: Label = $ChartUI/GraphRect/TimeLabelStart

@onready var ticker_input: LineEdit = $ChartUI/TickerInput
@onready var fetch_button: Button = $ChartUI/FetchButton
@onready var cooldown_timer: Timer = $ChartUI/CooldownTimer
@onready var vol_slider: Slider = $ChartUI/GraphRect/VolSlider
@onready var time_option: OptionButton = $ChartUI/OptionButton

@onready var graph_rect: TextureRect = $ChartUI/GraphRect
@onready var graph_line: Line2D = $ChartUI/GraphRect/GraphLine
@onready var scanline: Line2D = $ChartUI/GraphRect/Scanline
@onready var status_label: Label = $ChartUI/GraphRect/StatusLabel

# Local Cache (Format: {"AAPL_0": [150.2, 150.8, ...]})
var stock_cache: Dictionary = {}

var stock_pitches: Array[float] = []
var raw_prices: Array[float] = []
var current_note_index: int = 0

# Pitch & Volume Offset Tracking
var current_pitch: float = 1.0
var user_db_offset: float = 0.0  # Range: -5.0 to +5.0 dB

func _ready() -> void:
	# Connect UI Signals
	fetch_button.pressed.connect(_on_fetch_button_pressed)
	http_request.request_completed.connect(_on_data_received)
	beat_timer.timeout.connect(_on_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	
	# Connect Volume Slider Signal
	vol_slider.value_changed.connect(_on_vol_slider_changed)
	user_db_offset = vol_slider.value
	
	scanline.visible = false
	status_label.text = "Type a ticker symbol (e.g. AAPL, TSLA, BTC/USD) and click Load!"

func _on_vol_slider_changed(value: float) -> void:
	user_db_offset = value

func _on_fetch_button_pressed() -> void:
	var symbol = ticker_input.text.strip_edges().to_upper()
	if symbol.is_empty():
		status_label.text = "Please enter a valid stock symbol!"
		return
		
	fetch_stock_data(symbol)

func get_timeframe_config(index: int) -> Dictionary:
	match index:
		0: return {"interval": "1min", "outputsize": 390}   # 1 Day (390 mins in 1 trading day)
		1: return {"interval": "5min", "outputsize": 234}   # 3 Days (78 bars/day * 3)
		2: return {"interval": "15min", "outputsize": 195}  # 1 Week (39 bars/day * 5 days)
		3: return {"interval": "30min", "outputsize": 195}  # 2 Weeks (19.5 bars/day * 10 days)
		4: return {"interval": "1h", "outputsize": 160}     # 1 Month (~6.5 trading hours/day * 21 days)
		5: return {"interval": "2h", "outputsize": 160}     # 2 Months (~3.25 bars/day * 42 days)
		6: return {"interval": "4h", "outputsize": 240}     # 6 Months (~1.9 bars/day * 126 days)
		7: return {"interval": "1day", "outputsize": 252}   # 1 Year (~252 trading days in 1 year)
		_: return {"interval": "1h", "outputsize": 160}

func fetch_stock_data(symbol: String) -> void:
	beat_timer.stop()
	audio_player.stop()
	
	var time_idx = time_option.selected
	var config = get_timeframe_config(time_idx)
	
	# Cache key includes timeframe (e.g. "AAPL_0", "TSLA_7")
	var cache_key = symbol + "_" + str(time_idx)
	
	# 1. Check local cache first to save API credits
	if stock_cache.has(cache_key):
		status_label.text = "Loaded " + symbol + " from cache!"
		raw_prices = stock_cache[cache_key]
		process_and_start_song()
		return

	# 2. Make API Call if not cached
	var api_key = Global.api_key.strip_edges()
	if api_key.is_empty():
		status_label.text = "Error: No API Key found in Global script!"
		return

	fetch_button.disabled = true
	cooldown_timer.start(5.0)

	status_label.text = "Fetching data for " + symbol + "..."
	
	var url = "https://api.twelvedata.com/time_series?symbol=%s&interval=%s&outputsize=%d&apikey=%s" % [
		symbol, config.interval, config.outputsize, api_key
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
	
	if json and json.has("status") and json["status"] == "error":
		status_label.text = "API Error: " + json["message"]
		return

	if json and json.has("values"):
		raw_prices.clear()
		for val in json["values"]:
			raw_prices.append(float(val["close"]))
		
		# Reverse array so oldest point is on the left, newest is on the right
		raw_prices.reverse()
		
		if raw_prices.size() > 0:
			var symbol = ticker_input.text.strip_edges().to_upper()
			var cache_key = symbol + "_" + str(time_option.selected)
			stock_cache[cache_key] = raw_prices.duplicate()
			
			status_label.text = "" 
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
	
	for i in range(num_points):
		var x_pos = (float(i) / float(num_points - 1)) * rect_size.x
		var norm_y = remap(prices[i], min_price, max_price, 0.0, 1.0)
		var y_pos = rect_size.y - (norm_y * rect_size.y)
		
		graph_line.add_point(Vector2(x_pos, y_pos))

func convert_prices_to_pitches(prices: Array[float]) -> void:
	stock_pitches.clear()
	
	var min_price = prices.min()
	var max_price = prices.max()
	if min_price == max_price: max_price += 0.01

	for price in prices:
		var norm = remap(price, min_price, max_price, 0.0, 1.0)
		var smooth_pitch = remap(norm, 0.0, 1.0, 0.5, 2.0)
		stock_pitches.append(smooth_pitch)

func start_music_sequencer() -> void:
	scanline.visible = true
	var rect_size = graph_rect.size
	
	scanline.clear_points()
	scanline.add_point(Vector2(0, 0))
	scanline.add_point(Vector2(0, rect_size.y))
	
	current_note_index = 0
	if not stock_pitches.is_empty():
		current_pitch = stock_pitches[0]
		audio_player.pitch_scale = current_pitch
		
	_update_scanline_position()
	
	if not audio_player.playing:
		audio_player.play()
	
	beat_timer.wait_time = 0.03
	beat_timer.start()

func _on_timer_timeout() -> void:
	if stock_pitches.is_empty(): return
		
	# Fallback restart if the audio loop finishes
	if not audio_player.playing:
		audio_player.play()

	var target_pitch = stock_pitches[current_note_index]
	
	# Interpolate pitch for smooth glides
	current_pitch = lerp(current_pitch, target_pitch, 0.25)
	audio_player.pitch_scale = current_pitch
	
	# Dynamic Pitch Compensation offset (+2.0 dB to -6.0 dB)
	var pitch_comp_db = remap(current_pitch, 0.5, 2.0, 2.0, -6.0)
	
	# Combine Pitch Compensation with the [-5dB to +5dB] slider offset via $VolSlider
	var final_target_db = pitch_comp_db + user_db_offset
	audio_player.volume_db = lerp(audio_player.volume_db, final_target_db, 0.25)
	
	current_note_index = (current_note_index + 1) % stock_pitches.size()
	_update_scanline_position()

func _update_scanline_position() -> void:
	var num_points = stock_pitches.size()
	var rect_size = graph_rect.size
	
	var x_pos = (float(current_note_index) / float(num_points - 1)) * rect_size.x
	scanline.position.x = x_pos

func _on_cooldown_finished() -> void:
	fetch_button.disabled = false
