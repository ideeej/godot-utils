extends Control


onready var text_label = $Panel/Margin/RichTextLabel
onready var dialog_animator = $DialogAnimator
onready var dialog_saver = $DialogSaver

func _ready():
	dialog_animator.connect("animation_started", self, "_on_animation_started")
	dialog_animator.connect("animation_step", self, "_on_animation_step")
	dialog_animator.connect("animation_finished", self, "_on_animation_finished")
	
	var delay = 0.25
	dialog_animator.start_animation(text_label.bbcode_text, delay)


func _on_animation_started():
	text_label.bbcode_text = ""
	print("Animation started")


func _on_animation_step(character):
	print("Current character: %s" % character)
	text_label.bbcode_text += character


func _on_animation_finished():
	print("Animation finished")






