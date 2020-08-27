extends Node

export(bool) var debugging = false

signal animation_started()
signal animation_step(character)
signal animation_step_proxy(character) # before actually sending the step up
signal animation_finished()


var characters_history: Array = []
var tag: String = ""

var has_started_tag: bool = false
var has_ended_tag: bool = false

var dialog_animation_delay_buffer: float # storing dialog_animation_delay 
var dialog_animation_delay: float = 0.05


func _ready():
	connect("animation_started", self, "_on_animation_started")
	connect("animation_step", self, "_on_animation_step")
	connect("animation_step_proxy", self, "_on_animation_step_proxy")
	connect("animation_finished", self, "_on_animation_finished")



func _on_animation_started():
	if debugging:
		print("Animation started")


func _on_animation_step(character):
	if debugging:
		print("Current character: %s" % character)


func _on_animation_step_proxy(character):
	if not has_started_tag and character == "[":
		dialog_animation_delay_buffer = dialog_animation_delay
		dialog_animation_delay = 0
		has_started_tag = true
	
	if has_started_tag and not has_ended_tag:
		tag += character
	
	if has_started_tag and character == "]":
		emit_signal("animation_step", tag)
		dialog_animation_delay = dialog_animation_delay_buffer
		tag = ""
		has_started_tag = false
		has_ended_tag = false
		return
	
	if not has_started_tag:
		# just plain text.
		emit_signal("animation_step", character)



func _on_animation_finished():
	if debugging:
		print("Animation finished")


func start_animation(target_text, delay=dialog_animation_delay):
	emit_signal("animation_started")
	
	dialog_animation_delay = delay
	var first_step = 0
	animate(target_text, first_step)


func animate(target_text, step):
	if target_text.length() == step:
		emit_signal("animation_finished")
		return
		
	step(target_text, step)


func step(target_text, step):
	yield(get_tree().create_timer(dialog_animation_delay), "timeout")
	emit_signal("animation_step_proxy", target_text[step])
	animate(target_text, step+1)



#
#func old_logic(character):
#	if not has_started_tag and character == "[":
#		print("Started a tag at %s" % str(characters_history.size()-1))
#
#		start_tag_index = characters_history.size()-1
#		has_started_tag = true
#		# Speed up, animating the text within the tag (not visible until the tag is finished)
#		dialog_animation_delay_buffer = dialog_animation_delay
#		dialog_animation_delay = 0
#		return
#
#	var last_character_index = characters_history.size()-1
#	if has_started_tag and character == "/" and characters_history[last_character_index-1] == "[":
#		has_ended_tag = true
#	if character == "]" and has_ended_tag:
#		var text_behind = ""
#		var text_behind_array = characters_history.slice(start_tag_index, characters_history.size()-2)
#
#		for c in text_behind_array:
#			text_behind += str(c)
#
#		emit_signal("animation_step", str(text_behind))
#		has_started_tag = false
#		start_tag_index = 0
#		dialog_animation_delay = dialog_animation_delay_buffer # Get the value back to normal
#
#	if not has_started_tag:
#		emit_signal("animation_step", character)
#
#	pass
#
#
#
