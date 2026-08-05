extends Node2D

# variables to reference nodes
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var beat_timer: Timer = $Timer
@onready var ticker_input: LineEdit = $ChartUI/TickerInput
@onready var fetch_button: Button = $ChartUI/FetchButton
@onready var cooldown_timer: Timer = $ChartUI/CooldownTimer
@onready var graph_rect: ColorRect = $ChartUI/GraphRect
@onready var graph_line: Line2D = $ChartUI/GraphRect/GraphLine
@onready var scanline: Line2D = $ChartUI/GraphRect/Scanline
@onready var status_label: Label = $ChartUI/GraphRect/StatusLabel
@onready var time_label_start: Label = $ChartUI/GraphRect/TimeLabelStart
@onready var vol_slider: Slider = $ChartUI/GraphRect/VolSlider
@onready var pitch_slider: Slider = $ChartUI/GraphRect/PitchSlider # New Pitch Slider!
@onready var time_option: OptionButton = $ChartUI/OptionButton
@onready var rhythm_slider: Slider = $ChartUI/RythymSlider
@onready var rate_label: Label = $ChartUI/rateLabel
@onready var sound_option: OptionButton = $ChartUI/SoundOption
@onready var line: Line2D = $ChartUI/WaveformLine

# Variables for each effect on the bus (except for capture which is used for the visualizer)
var reverb_effect
var distortion_effect
var delay_effect


# Assigns a bus variable to each synth node in the main scene. Each synth node needs to
# be assigned to a different bus so we can capture audio from each audio player and not one
# for the master bus as then all graphs would be exactly the same
@export var bus_name: String = "synth1Bus"


@export var line_position: Vector2 = Vector2(610, 65) # tells us where to start the line
var capture_effect: AudioEffectCapture
var sample_count: int = 256    # resolution of the wave
var wave_width: float = 200   # width
var wave_height: float = 35.0  # height scale of the wave


# preloads all of the sound files for instruments
var sound_library: Array[AudioStream] = [
	preload("res://audio/hihat.wav"),
	preload("res://audio/kick.wav"),
	preload("res://audio/c5woodblock.wav"),
	preload("res://audio/c4pad.wav"),
	preload("res://audio/C4noteshort.wav"),
	preload("res://audio/c4otherplucknum3.wav"),
	preload("res://audio/c4retropluck.wav"),
	preload("res://audio/c4squaresynth.wav")
]

# Local cache for stocks (format: {"AAPL_0": [150.2, 150.8, ...]})
var stock_cache: Dictionary = {}

var stock_pitches: Array[float] = []
var raw_prices: Array[float] = []
var current_note_index: int = 0

# Rhythm tracking
var trigger_interval: int = 8
var tick_counter: int = 0

# Pitch & vol offset tracking variables
var current_pitch: float = 1.0
var user_db_offset: float = 0.0     # Range: e.g. -5.0 to +5.0 dB sound offset
var user_pitch_offset: float = 0.0  # Range: -60% to +60% pitch offset

func _ready() -> void:
	# connects all required signals
	graph_rect.gui_input.connect(_on_graph_rect_gui_input)
	graph_rect.mouse_exited.connect(_on_graph_rect_mouse_exited)
	fetch_button.pressed.connect(_on_fetch_button_pressed)
	http_request.request_completed.connect(_on_data_received)
	beat_timer.timeout.connect(_on_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	vol_slider.value_changed.connect(_on_vol_slider_changed)
	pitch_slider.value_changed.connect(_on_pitch_slider_changed)
	time_option.item_selected.connect(_on_time_option_selected)
	rhythm_slider.value_changed.connect(_on_rhythm_slider_changed)
	_setup_sound_dropdown()
	sound_option.item_selected.connect(_on_sound_option_selected)
	
	# Maps variables to effects on the audio busses
	var bus_index = AudioServer.get_bus_index(bus_name)
	reverb_effect = AudioServer.get_bus_effect(bus_index, 1)
	distortion_effect = AudioServer.get_bus_effect(bus_index, 2)
	delay_effect = AudioServer.get_bus_effect(bus_index, 3)
	
	# Assign audio player bus
	audio_player.bus = bus_name

	line.clear_points()
	
	# makes sure line position is relative to this panel
	line.top_level = true
	line.global_position = global_position + line_position
	
	# looks for the audio bus specified and the capture effect
	# that's assigned to the audio bus
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_error("Audio bus not found: " + bus_name)
		return
		
	for i in range(AudioServer.get_bus_effect_count(bus_idx)):
		var effect = AudioServer.get_bus_effect(bus_idx, i)
		if effect is AudioEffectCapture:
			capture_effect = effect
			break

	# Initial setup of variables
	user_db_offset = vol_slider.value
	user_pitch_offset = pitch_slider.value
	trigger_interval = int(rhythm_slider.value)
	_update_rate_label_text(rhythm_slider.value)
	update_time_labels(time_option.selected)
	
	# sets the default sound stream, in this case 0 which corresponds to the hihat
	if not sound_library.is_empty():
		audio_player.stream = sound_library[0]
	
	# hides the scanline and sets status label text
	scanline.visible = false
	status_label.text = "Type a ticker symbol and click Load Graph!"
	
	# fixes a weird bug where the bar would randomly decide to be in the top left
	$ChartUI/particleToggleBar.position.x = 365
	$ChartUI/particleToggleBar.position.y = 60
	
	delay_effect.tap1_level_db = -60
	delay_effect.feedback_level_db = -60
# adds all options to the sound selector dropdown menu
func _setup_sound_dropdown() -> void:
	sound_option.clear()
	sound_option.add_item("Hihat")
	sound_option.add_item("Kick")
	sound_option.add_item("Woodblock")
	sound_option.add_item("Pluck")
	sound_option.add_item("Calm Synth")
	sound_option.add_item("Digital Pluck")
	sound_option.add_item("Retro Pluck")
	sound_option.add_item("Square Synth")

# when called, checks if the selected option fits in the index and starts the sound
func _on_sound_option_selected(index: int) -> void:
	if index >= 0 and index < sound_library.size():
		var was_playing = audio_player.playing
		audio_player.stop()
		audio_player.stream = sound_library[index]
		if was_playing:
			audio_player.play()

# this & the function below (pitch slider changed) set the offset variables to the value of the pitch/vol slider that was set
func _on_vol_slider_changed(value: float) -> void:
	user_db_offset = value

func _on_pitch_slider_changed(value: float) -> void:
	user_pitch_offset = value

# when an option for time scale is selected, calls the function to update the label on bottom left
func _on_time_option_selected(index: int) -> void:
	update_time_labels(index)

# same thing as above, updates the rythym label AND updates the rhythym 
func _on_rhythm_slider_changed(value: float) -> void:
	trigger_interval = int(value)
	_update_rate_label_text(value)

# calculates the ms interval (converted from the raw slider value) and sets the label
func _update_rate_label_text(slider_val: float) -> void:
	var ms_interval = int(slider_val * 30.0)
	rate_label.text = "Update Rate: %d ms" % ms_interval


# checks if a ticker has been entered and then calls a function to grab the data for that stock
func _on_fetch_button_pressed() -> void:
	var symbol = ticker_input.text.strip_edges().to_upper()
	if symbol.is_empty():
		status_label.text = "Please enter a valid stock symbol!"
		return
	fetch_stock_data(symbol)

#     index for all of the time options. Each one is assigned to a number (1-7)
#     and is given the interval between each data point (e.g. 1 hr), and then 
#     specifies the number of nodes (resolution) of the graph. This data is used
#     to let the API know how to serve the requested data/how we should request it

func get_timeframe_config(index: int) -> Dictionary:
	match index:
		0: return {"interval": "1min", "outputsize": 390}   # 1 day
		1: return {"interval": "5min", "outputsize": 234}   # 3 days
		2: return {"interval": "15min", "outputsize": 195}  # 1 week
		3: return {"interval": "30min", "outputsize": 195}  # 2 weeks
		4: return {"interval": "1h", "outputsize": 160}     # 1 month
		5: return {"interval": "2h", "outputsize": 160}     # 2 months
		6: return {"interval": "4h", "outputsize": 240}     # 6 months
		7: return {"interval": "1day", "outputsize": 252}   # 1 yr
		_: return {"interval": "1h", "outputsize": 160}     # default to 1 month



# index specifies different labels for the label on the bottom left, so we can 
# easily refer to the label text with a simple number. also if necessary updates
# the label to match the index number called
func update_time_labels(index: int) -> void:
	var label_text = ""
	match index:
		0: label_text = "1 day ago"
		1: label_text = "3 days ago"
		2: label_text = "1 week ago"
		3: label_text = "2 weeks ago"
		4: label_text = "1 month ago"
		5: label_text = "2 months ago"
		6: label_text = "6 months ago"
		7: label_text = "1 year ago"
		_: label_text = "Start"
	
	if time_label_start:
		time_label_start.text = label_text

#  stops all audio, grabs the currently selected timeframe and stores it in a variable, and then proceeds to check
#  cache, if so it will start the song. checks for API key, starts a timer to prevent spamming the get stock button
#  and then requests the data from the server with all relevant info (api key, interval, resolution, and ticker)

func fetch_stock_data(symbol: String) -> void:
	beat_timer.stop()
	audio_player.stop()
	
	var time_idx = time_option.selected
	var config = get_timeframe_config(time_idx)
	var cache_key = symbol + "_" + str(time_idx)
	
	if stock_cache.has(cache_key):
		status_label.text = "Loaded " + symbol + " from cache!"
		raw_prices = stock_cache[cache_key]
		process_and_start_song()
		return

	var api_key = Global.api_key.strip_edges()
	if api_key.is_empty():
		status_label.text = "Error: No API Key found in Global script!"
		return

	fetch_button.disabled = true
	cooldown_timer.start(5.0)

	status_label.text = "Fetching stock data for " + symbol + "..."
	
	var url = "https://api.twelvedata.com/time_series?symbol=%s&interval=%s&outputsize=%d&apikey=%s" % [
		symbol, config.interval, config.outputsize, api_key
	]
	
	http_request.request(url)

# checks for errors (https & api) and prints and sets label text if so. Processes the data for pricing, saving 
# the closing price of every point into an array. it then reverses the array so it displays correctly.
# saves the pricing data for specified stock into cache and starts the song
func _on_data_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 429:
		status_label.text = "Rate limit reached (8 credits/min). Wait a minute!"
		print("WARN: Rate limit reached (8 credits/min). Wait a minute!")
		return
	elif response_code != 200:
		status_label.text = "HTTP Error: " + str(response_code)
		print("ERROR: HTTP Error: " + str(response_code))
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json and json.has("status") and json["status"] == "error":
		status_label.text = "API Error: " + json["message"]
		print("API Error: " + json["message"])
		return

	if json and json.has("values"):
		raw_prices.clear()
		for val in json["values"]:
			raw_prices.append(float(val["close"]))
		
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

# function to quickly refer to, it calls other functions to start 
# the song playing processes with relevant data sent to those functions
func process_and_start_song() -> void:
	update_time_labels(time_option.selected)
	draw_stock_graph(raw_prices)
	convert_prices_to_pitches(raw_prices)
	start_music_sequencer()

# clears the drawn points, checks if the max/min are equal (if so increases the max price ever so slightly),
# sets variables for the number of points (equal to the resolution specified earlier) and sets the rectangle
# to be drawn in. Then, goes through the stored data points for the stock in the array from earlier and draws
# the correct points
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

# converts raw price data to pitches to be played by the scanline
func convert_prices_to_pitches(prices: Array[float]) -> void:
	stock_pitches.clear()
	var min_price = prices.min()
	var max_price = prices.max()
	if min_price == max_price: max_price += 0.01

	for price in prices:
		var norm = remap(price, min_price, max_price, 0.0, 1.0)
		var smooth_pitch = remap(norm, 0.0, 1.0, 0.5, 2.0)
		stock_pitches.append(smooth_pitch)

# starts the scanline
func start_music_sequencer() -> void:
	scanline.visible = true
	var rect_size = graph_rect.size
	
	scanline.clear_points()
	scanline.add_point(Vector2(0, 0))
	scanline.add_point(Vector2(0, rect_size.y))
	
	current_note_index = 0
	tick_counter = 0
	
	if not stock_pitches.is_empty():
		current_pitch = stock_pitches[0]
		# applies the graph pitch and then adds user pitch offset safely (doesnt let it reach 0, min at 0.05)
		audio_player.pitch_scale = max(0.05, current_pitch + user_pitch_offset)
		
	_update_scanline_position()
	
	# makes sure audio is playing if stopped
	if not audio_player.playing:
		audio_player.play()
	
	# loop for the beat timer
	beat_timer.wait_time = 0.03
	beat_timer.start()


func _on_timer_timeout() -> void:
	if stock_pitches.is_empty(): return
	# sets target pitch to the current note its on
	var target_pitch = stock_pitches[current_note_index] 
	
	# interpolates the pitch so it isnt super rough, basically smooths it
	current_pitch = lerp(current_pitch, target_pitch, 0.25)
	
	# adds the user pitch offset and makes sure the pitch doesnt hit 0 (min at 0.05)
	var final_pitch = max(0.05, current_pitch + user_pitch_offset)
	audio_player.pitch_scale = final_pitch
	
	# applies volume pitch compensation, boosts bass and reduces treble
	var pitch_comp_db = remap(current_pitch, 0.5, 2.0, 2.0, -6.0)
	var final_target_db = pitch_comp_db + user_db_offset
	audio_player.volume_db = lerp(audio_player.volume_db, final_target_db, 0.25)
	
	# restart the sound 
	if tick_counter % trigger_interval == 0:
		audio_player.play()

	tick_counter += 1
	current_note_index = (current_note_index + 1) % stock_pitches.size()
	_update_scanline_position()

# moves the scanline to a calculated position based on the number of points
# and size of the rectangle behind the graph area
func _update_scanline_position() -> void:
	var num_points = stock_pitches.size()
	var rect_size = graph_rect.size
	
	var x_pos = (float(current_note_index) / float(num_points - 1)) * rect_size.x
	scanline.position.x = x_pos

# enables button after cooldown is over
func _on_cooldown_finished() -> void:
	fetch_button.disabled = false

# function to stop the playback of sound
func _on_stop_button_pressed() -> void:
	beat_timer.stop()
	audio_player.stop()
	scanline.visible = false

func _on_graph_rect_gui_input(event: InputEvent) -> void:
	# if no data is loaded dont do anything
	if raw_prices.is_empty():
		return
		
	# check if the mouse is over the textureRect
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var rect_width = graph_rect.size.x
		
		# limit mouse x (variable not the actual pos) to the boundaries of the graph
		var clamped_x = clamp(mouse_x, 0.0, rect_width)
		
		# translates the mouse x position into an index value
		var norm_x = clamped_x / rect_width
		var hover_index = int(round(norm_x * (raw_prices.size() - 1)))
		hover_index = clamp(hover_index, 0, raw_prices.size() - 1)
		
		# gets the values at the index
		var hovered_price = raw_prices[hover_index]
		var hovered_pitch = stock_pitches[hover_index]
		
		# displays that value as text
		status_label.text = "Point #%d | Price: $%.2f | Pitch Multiplier: %.2fx" % [hover_index, hovered_price, hovered_pitch]
		
		# sets the x position of the small tracker line to the mouse's local position constantly
		$trackerLine.position.x = get_local_mouse_position().x
		$trackerLine.visible = true


func _on_graph_rect_mouse_exited() -> void:
	# resets the status label if the mouse exits
	if not raw_prices.is_empty():
		$trackerLine.visible = false
		status_label.text = "Hover over chart to inspect points."


# translates state of the toggle bar to turn particle emitter on/off
func _on_particle_toggle_bar_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		$ChartUI/GraphRect/Scanline/LineGPUParticles.emitting = true
	elif toggled_on == false:
		$ChartUI/GraphRect/Scanline/LineGPUParticles.emitting = false


func _process(_delta: float) -> void:
	if not capture_effect: # checks that there is the capture effect applies
		return
		
	var available = capture_effect.get_frames_available() # gets all captured frames that are avaliable if any
	if available == 0:
		return
		
	var buffer = capture_effect.get_buffer(min(available, sample_count)) # stores buffer of frames
	if buffer.is_empty():
		return

	line.clear_points() # clears the current line

	for i in range(buffer.size()):
		var amplitude = buffer[i].x
		
		# draws the points (goes to x, y, adds point, repeats (for i in range)) 
		var x = (float(i) / buffer.size()) * wave_width
		var y = amplitude * wave_height
		
		line.add_point(Vector2(x, y))

# Applies the reverb (wet slider) when it's changed
func _on_reverb_slider_value_changed(value: float) -> void:
	reverb_effect.wet = value

# Applies the distortion effect when it's changed
func _on_distortion_slider_value_changed(value: float) -> void:
	distortion_effect.drive = value

# Applies the delay effect 
func _on_delay_slider_value_changed(value: float) -> void:
	delay_effect.tap1_level_db = value
	delay_effect.feedback_level_db = value
