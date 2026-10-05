extends Control
# Mini-map for the dungeon web. Nodes positioned by main.gd.

var pts: Array = []        # Vector2 per node
var links: Array = []      # [a, b] pairs
var conns: Array = []      # conns[i] = [neighbor ids]
var visited: Array = []    # bool per node
var current := 0
var special: Array = []    # per node: "" | "stairs" | "boss" | "depths" | "labyrinth"

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.03, 0.05))
	if pts.is_empty():
		return
	for l in links:
		var a: int = l[0]
		var b: int = l[1]
		var known: bool = visited[a] or visited[b]
		if not known:
			continue
		var col := Color(0.72, 0.58, 0.3, 0.9) if (visited[a] and visited[b]) else Color(0.5, 0.42, 0.3, 0.65)
		draw_line(pts[a], pts[b], col, 3.0)
	for i in pts.size():
		var revealed: bool = visited[i] or _glimpsed(i)
		if not revealed:
			continue
		var c := Color(0.5, 0.52, 0.6)
		if i == current:
			c = Color(0.8, 0.12, 0.12)
		elif special[i] == "stairs":
			c = Color(0.92, 0.9, 0.85)
		elif special[i] == "boss":
			c = Color(0.55, 0.06, 0.06)
		elif special[i] == "depths":
			c = Color(0.35, 0.2, 0.5)
		elif special[i] == "labyrinth":
			c = Color(0.2, 0.45, 0.5)
		elif visited[i]:
			c = Color(0.78, 0.62, 0.3)
		draw_circle(pts[i], 11.0, c)
		if i == current:
			draw_arc(pts[i], 16.0, 0, TAU, 24, Color(0.8, 0.12, 0.12, 0.7), 2.0)

func _glimpsed(i: int) -> bool:
	for n in conns[i]:
		if visited[n]:
			return true
	return false
