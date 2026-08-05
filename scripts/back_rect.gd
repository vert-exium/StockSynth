extends TextureRect

# color palletes, currently using 5 that transiiton between eachother
# each pair is a color pallete, you can add more by adding more lines in the list
const PALETTE_LIST = [
	{ # greens:
		"color_top": Color("66cc77"),
		"color_bottom": Color("33aa55")
	},
	{ # red:
		"color_top": Color("ee7766"),
		"color_bottom": Color("cc4433")
	},
	{ # blue:
		"color_top": Color("66aabb"),
		"color_bottom": Color("4488aa")
	},
	{ # pastel
		"color_top": Color("ee88aa"),
		"color_bottom": Color("aaaaaa")
	},
	{ # yellow/purple
		"color_top": Color("ddcc66"),
		"color_bottom": Color("aa88cc")
	}
]

# variables for the progress, current index (1-5)
var tween_progress: float = 0.0

var current_palette_index: int = 0
var target_palette_index: int = 1


@onready var gradient_resource: Gradient = self.texture.gradient

# Configuration
const TWEEN_SPEED_SECONDS: float = 30.0 # time in seconds to transition between each palette
const SMOOTHING_CURVE = Tween.TRANS_SINE # the pattern used in the tween, in this case a sine wave


func _ready():
	# gets the current index (0) and updates the gradient colors from the values in the list
	_update_gradient_colors(PALETTE_LIST[current_palette_index])
	
	# starts the chain of transitions
	_start_next_transition()

# constantly changes the color
func _process(_delta):
	_calculate_and_apply_colors()

# starts one transition to the next pallate 
func _start_next_transition():
	tween_progress = 0.0
	
	# advances the target/next pallate index # to 1 higher than the current one
	target_palette_index = (current_palette_index + 1) % PALETTE_LIST.size()
	
	# makes one tween that doesn't loop
	var tween = create_tween()
	tween.tween_property(self, "tween_progress", 1.0, TWEEN_SPEED_SECONDS).set_trans(SMOOTHING_CURVE)
	tween.tween_callback(_on_palette_transition_finished)

# interpolates the colors every frame (via. lerp)
func _calculate_and_apply_colors():
	var cur_pal = PALETTE_LIST[current_palette_index]
	var tar_pal = PALETTE_LIST[target_palette_index]
	
	var mixed_top: Color = cur_pal.color_top.lerp(tar_pal.color_top, tween_progress)
	var mixed_bottom: Color = cur_pal.color_bottom.lerp(tar_pal.color_bottom, tween_progress)
	
	_update_gradient_colors({ # sets the current color variables to the ones calculated above
		"color_top": mixed_top,
		"color_bottom": mixed_bottom
	})

func _update_gradient_colors(palette: Dictionary):
	if gradient_resource.get_point_count() >= 2:
		gradient_resource.set_color(0, palette.color_bottom)
		gradient_resource.set_color(1, palette.color_top)
	else:
		gradient_resource.offsets = [0.0, 1.0]
		gradient_resource.colors = [palette.color_bottom, palette.color_top]

func _on_palette_transition_finished():
	# sets the current index to the target, and then restarts the transition to the next one
	current_palette_index = target_palette_index
	_start_next_transition()
