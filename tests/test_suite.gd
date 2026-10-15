class_name TestSuite
extends RefCounted
## Base de las suites de prueba headless. Cada suite implementa run() (puede usar await).

var tree: SceneTree
var title := ""
var passed := 0
var failed := 0
var failures := PackedStringArray()


func run() -> void:
	pass


func check(ok: bool, what: String) -> void:
	if ok:
		passed += 1
		print("  [OK]    " + what)
	else:
		failed += 1
		failures.append(title + ": " + what)
		print("  [FALLO] " + what)


func frames(n: int) -> void:
	for i in n:
		await tree.physics_frame


## Espera hasta que cond() sea true o se agoten max_frames. Devuelve si se cumplió.
func wait_until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await tree.physics_frame
	return cond.call()


func cleanup(node: Node) -> void:
	if is_instance_valid(node):
		node.get_parent().remove_child(node)
		node.free()
	Input.action_release(&"p1_left")
	Input.action_release(&"p1_right")
	Input.action_release(&"p1_jump")
	await tree.physics_frame
