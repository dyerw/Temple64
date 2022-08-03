extends Node2D

export(int) var movement
export(int) var attacks
export(bool) var allied
export(int) var max_health
export(int) var attack_range
export(int) var damage

var pathing = Pathing.new()
var remaining_movement: int
var remaining_attacks: int
var current_health: int setget set_current_health

# While units do things that should disable controls
# they can request and release controls
signal request_lock
signal release_lock
signal died

func set_current_health(h: int):
	current_health = h
	$HealthPips.health = h

# Called when the node enters the scene tree for the first time.
func _ready():
	remaining_movement = movement
	remaining_attacks = attacks
	set_current_health(max_health)

func take_damage(d: int):
	# Did we die???
	if d >= current_health:
		var screen_lock = ScreenLock.new()
		screen_lock.request(self)
		set_current_health(0)
		$AnimatedSprite.animation = "die"
		yield($AnimatedSprite, "animation_finished")
		emit_signal("died", self)
		screen_lock.release(self)
		
		self.queue_free()
	else:
		set_current_health(current_health - d)

func move(to: Vector2, cost: int):
	var screen_lock = ScreenLock.new()
	screen_lock.request(self)
	remaining_movement -= cost
	$AnimatedSprite.animation = "move"
	$MovementTween.interpolate_property(
		self, 
		"position",
		position, 
		to, 
		1,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	$MovementTween.start()
	yield($MovementTween, "tween_completed")
	$AnimatedSprite.animation = "default"
	screen_lock.release(self)

func attack():
	var screen_lock = ScreenLock.new()
	screen_lock.request(self)
	remaining_attacks -= 1
	$AnimatedSprite.animation = "attack"
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.animation = "default"
	screen_lock.release(self)

func end_turn():
	remaining_attacks = attacks
	remaining_movement = movement
