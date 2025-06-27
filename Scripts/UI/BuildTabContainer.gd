extends TabContainer

func _ready():
	var drills_icon = preload("res://Assets/UI/TheNounProject/Drill.png")
	var factories_icon = preload("res://Assets/UI/TheNounProject/Factory.png")
	var logistics_icon = preload("res://Assets/UI/TheNounProject/Logistics.png")
	
	set_tab_icon(0, drills_icon)
	set_tab_icon(1, factories_icon)
	set_tab_icon(2, logistics_icon)

	# Optional: remove tab text for clean icons-only look
	set_tab_title(0, "")
	set_tab_title(1, "")
	set_tab_title(2, "")
	
	
	set_tab_icon_max_width(0, 64)
	set_tab_icon_max_width(1, 64)
	set_tab_icon_max_width(2, 64)
