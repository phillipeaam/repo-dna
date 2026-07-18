extends CharacterBody2D
class_name PlayerController

signal attacked
@export var speed := 200.0

func _physics_process(_delta):
    velocity.x = Input.get_axis("move_left", "move_right") * speed
    move_and_slide()
