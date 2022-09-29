class_name EntityHUD extends VBoxContainer

var bind : Entity

func _ready() -> void:
	add_to_group("cam-zoom")
	Game.connect("main_team_changed", self, "MainTeamChanged")

func MainTeamChanged() -> void:
	if bind: BindWith(bind)

func BindWith(w : Entity) -> void:
	if bind: Unbind()
	bind = w
	bind.connect("health_changed", self, "HealthChanged")
	$name.visible = w is Player
	$health.modulate = Color.lime if Game.MainTeam == w.Team else Color.tomato
	HealthChanged(0)

func Unbind() -> void:
	bind.disconnect("health_changed", self, "HealthChanged")

func HealthChanged(delta : float) -> void:
	$health.value = bind.Health
	$health.max_value = bind.MaxHealth

func CamZoomChanged(to : float) -> void:
	rect_scale = Vector2(to,to)
	if bind:
		UiLib.CenterOn(self, bind.data.HudOffset)
