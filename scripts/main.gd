extends Control


# Size for stock lists:
# 209 x 1080
# First list default pos:
# 1708 x 0 y
# Second list default pos:
# 1708 x - 1080 y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	$StockList1.position.y += 0.5
	$StockList2.position.y += 0.5
	if $StockList1.position.y >= 1080:
		$StockList1.position.y = -1080
	if $StockList2.position.y >= 1080:
		$StockList2.position.y = -1080
