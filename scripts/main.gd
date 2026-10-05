extends Control
# GLOAM — horror rogue RPG. Text with pictures.

const Content = preload("res://scripts/content.gd")

# palette
const INK := Color(0.92, 0.88, 0.82)
const DIM := Color(0.55, 0.52, 0.48)
const BLOOD := Color(0.65, 0.10, 0.10)
const GOLD_C := Color(0.85, 0.70, 0.30)
const BG := Color(0.02, 0.02, 0.03)

# state
var mode := "title"  # title, intro, room, combat, dead, win
var hp := 30
var max_hp := 30
var atk := 6
var gold := 0
var potions := 2
var floor_num := 1
const DungeonMap = preload("res://scripts/dungeon_map.gd")

const SFX := {
	"click": preload("res://assets/audio/click.wav"),
	"hit": preload("res://assets/audio/hit.wav"),
	"hurt": preload("res://assets/audio/hurt.wav"),
	"potion": preload("res://assets/audio/potion.wav"),
	"gold": preload("res://assets/audio/gold.wav"),
	"death": preload("res://assets/audio/death.wav"),
	"whisper": preload("res://assets/audio/whisper.wav"),
	"stairs": preload("res://assets/audio/stairs.wav"),
}
const AMBIENT := preload("res://assets/audio/ambient.wav")
var intro_idx := 0
var enemy := {}
var enemy_hp := 0
var guarding := false
var best_depth := 0
var keeper_met := 0
var fight_is_boss := false
var endings_found: Array = []
var whispers_found: Array = []
var mira_found: Array = []
var pondered: Array = []
var endless := false
var death_cause := ""
var keeper_total := 0
var weapon_tier := 0
var armor_tier := 0
var charms_owned: Array = []
var souls_saved := 0
var souls_doomed := 0
var ward_blocked := false
var sfx_player: AudioStreamPlayer
var amb_player: AudioStreamPlayer
var snd_btn: Button
var sound_on := true
var title_label: Label
var title_t := 0.0
var dungeon: Array = []
var cur_node := 0
var _after_fight := ""

const EXIT_DESCS := ["a low archway", "a corridor that smells of rot", "a passage glimmering faintly", "a stairwell breathing cold air", "a crack in the wall", "a doorway choked with cobwebs", "a tunnel that hums", "a dark opening", "a sloping passage", "a narrow fissure"]

# ui
var art_rect: TextureRect
var text_label: RichTextLabel
var choices_vb: VBoxContainer
var hp_bar: ProgressBar
var hp_label: Label
var floor_label: Label
var gold_label: Label
var scanlines: ColorRect
var _typewriter_t := 0.0
var _typewriter_full := ""
var _typewriter_done := true
var _pending_choices := []
var map_panel: PanelContainer
var map_view: Control

func _ready() -> void:
	_load_best()
	_build_ui()
	_show_title()

# ---------------- UI ----------------
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# art (top)
	art_rect = TextureRect.new()
	art_rect.position = Vector2(20, 20)
	art_rect.custom_minimum_size = Vector2(680, 460)
	art_rect.size = Vector2(680, 460)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art_rect)
	# big title overlay
	title_label = Label.new()
	title_label.text = "GLOAM"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(20, 300)
	title_label.custom_minimum_size = Vector2(680, 130)
	title_label.add_theme_font_size_override("font_size", 110)
	title_label.add_theme_color_override("font_color", Color(0.75, 0.08, 0.08, 0.92))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.visible = false
	add_child(title_label)
	# scanline overlay on art
	scanlines = ColorRect.new()
	scanlines.position = Vector2(20, 20)
	scanlines.size = Vector2(680, 460)
	scanlines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = "shader_type canvas_item;\nvoid fragment() {\n\tfloat s = step(0.5, fract(UV.y * 230.0));\n\tCOLOR = vec4(0.0, 0.0, 0.0, s * 0.12);\n}"
	sm.shader = sh
	scanlines.material = sm
	add_child(scanlines)
	# art frame
	var frame := ReferenceRect.new()
	frame.position = Vector2(20, 20)
	frame.size = Vector2(680, 460)
	frame.border_color = Color(0.35, 0.08, 0.08, 0.9)
	frame.border_width = 3.0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	# status row
	floor_label = _mk_label("", 24, Vector2(20, 494), Vector2(330, 36), DIM)
	gold_label = _mk_label("", 24, Vector2(580, 494), Vector2(120, 36), GOLD_C)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# map button
	var map_btn := Button.new()
	map_btn.text = "MAP"
	map_btn.position = Vector2(360, 486)
	map_btn.custom_minimum_size = Vector2(100, 44)
	map_btn.add_theme_font_size_override("font_size", 22)
	map_btn.add_theme_color_override("font_color", INK)
	var mbs := StyleBoxFlat.new()
	mbs.bg_color = Color(0.09, 0.07, 0.08, 0.98)
	mbs.border_color = Color(0.45, 0.10, 0.10, 0.9)
	mbs.set_border_width_all(2)
	mbs.set_corner_radius_all(8)
	map_btn.add_theme_stylebox_override("normal", mbs)
	map_btn.add_theme_stylebox_override("hover", mbs)
	map_btn.add_theme_stylebox_override("pressed", mbs)
	map_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	map_btn.pressed.connect(_toggle_map)
	add_child(map_btn)
	# sound toggle
	snd_btn = Button.new()
	snd_btn.text = "SND"
	snd_btn.position = Vector2(470, 486)
	snd_btn.custom_minimum_size = Vector2(100, 44)
	snd_btn.add_theme_font_size_override("font_size", 22)
	snd_btn.add_theme_color_override("font_color", INK)
	snd_btn.add_theme_stylebox_override("normal", mbs)
	snd_btn.add_theme_stylebox_override("hover", mbs)
	snd_btn.add_theme_stylebox_override("pressed", mbs)
	snd_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	snd_btn.pressed.connect(_toggle_sound)
	add_child(snd_btn)
	# audio players
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	amb_player = AudioStreamPlayer.new()
	var amb: AudioStreamWAV = AMBIENT
	amb.loop_mode = AudioStreamWAV.LOOP_FORWARD
	amb_player.stream = amb
	amb_player.volume_db = -14.0
	add_child(amb_player)
	# map overlay
	map_panel = PanelContainer.new()
	map_panel.position = Vector2(40, 220)
	map_panel.custom_minimum_size = Vector2(640, 740)
	map_panel.size = Vector2(640, 740)
	var mpbs := StyleBoxFlat.new()
	mpbs.bg_color = Color(0.03, 0.03, 0.04, 0.97)
	mpbs.border_color = Color(0.5, 0.12, 0.12, 0.95)
	mpbs.set_border_width_all(3)
	mpbs.set_corner_radius_all(12)
	map_panel.add_theme_stylebox_override("panel", mpbs)
	var mvb := VBoxContainer.new()
	mvb.add_theme_constant_override("separation", 8)
	map_panel.add_child(mvb)
	var mtitle := Label.new()
	mtitle.text = "THE DARK, MAPPED"
	mtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mtitle.add_theme_font_size_override("font_size", 24)
	mtitle.add_theme_color_override("font_color", DIM)
	mvb.add_child(mtitle)
	map_view = DungeonMap.new()
	map_view.custom_minimum_size = Vector2(600, 580)
	map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mvb.add_child(map_view)
	var mclose := Button.new()
	mclose.text = "Close"
	mclose.custom_minimum_size = Vector2(600, 64)
	mclose.add_theme_font_size_override("font_size", 24)
	mclose.add_theme_color_override("font_color", INK)
	mclose.add_theme_stylebox_override("normal", mbs)
	mclose.add_theme_stylebox_override("hover", mbs)
	mclose.add_theme_stylebox_override("pressed", mbs)
	mclose.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	mclose.pressed.connect(_toggle_map)
	mvb.add_child(mclose)
	map_panel.visible = false
	add_child(map_panel)
	# hp bar
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(20, 534)
	hp_bar.custom_minimum_size = Vector2(680, 22)
	hp_bar.size = Vector2(680, 22)
	hp_bar.max_value = 30
	hp_bar.value = 30
	hp_bar.show_percentage = false
	var hbg := StyleBoxFlat.new()
	hbg.bg_color = Color(0.10, 0.05, 0.05)
	hbg.set_corner_radius_all(6)
	hp_bar.add_theme_stylebox_override("background", hbg)
	var hfill := StyleBoxFlat.new()
	hfill.bg_color = BLOOD
	hfill.set_corner_radius_all(6)
	hp_bar.add_theme_stylebox_override("fill", hfill)
	add_child(hp_bar)
	hp_label = _mk_label("", 22, Vector2(20, 556), Vector2(680, 66), INK)
	# text (tap to skip typewriter)
	text_label = RichTextLabel.new()
	text_label.position = Vector2(20, 628)
	text_label.custom_minimum_size = Vector2(680, 268)
	text_label.size = Vector2(680, 268)
	text_label.add_theme_font_size_override("normal_font_size", 27)
	text_label.add_theme_color_override("default_color", INK)
	text_label.scroll_active = false
	text_label.mouse_filter = Control.MOUSE_FILTER_STOP
	text_label.gui_input.connect(_on_text_tap)
	add_child(text_label)
	# choices
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 906)
	scroll.size = Vector2(680, 354)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	choices_vb = VBoxContainer.new()
	choices_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices_vb.add_theme_constant_override("separation", 12)
	scroll.add_child(choices_vb)

func _mk_label(t: String, size: int, pos: Vector2, minsize: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.position = pos
	l.custom_minimum_size = minsize
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	add_child(l)
	return l

func _on_text_tap(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finish_typewriter()
	if event is InputEventScreenTouch and event.pressed:
		_finish_typewriter()

func _set_art(name: String) -> void:
	var path := "res://assets/art/%s.webp" % name
	if ResourceLoader.exists(path):
		art_rect.texture = load(path)
	else:
		art_rect.texture = null

func _say(text: String) -> void:
	_typewriter_full = text
	_typewriter_t = 0.0
	_typewriter_done = false
	text_label.text = ""
	text_label.visible_ratio = 0.0

func _finish_typewriter() -> void:
	if not _typewriter_done:
		text_label.text = _typewriter_full
		text_label.visible_ratio = 1.0
		_typewriter_done = true
		_show_choices()

func _process(dt: float) -> void:
	if mode == "title" and title_label.visible:
		title_t += dt
		var fl := 0.94 + 0.04 * sin(title_t * 6.0) + 0.02 * sin(title_t * 17.3)
		art_rect.modulate = Color(fl, fl * 0.98, fl * 0.96)
		var tp := 0.88 + 0.12 * (0.5 + 0.5 * sin(title_t * 1.4))
		title_label.modulate = Color(1, 1, 1, tp)
	if not _typewriter_done:
		_typewriter_t += dt
		var total := _typewriter_full.length()
		var shown := int(_typewriter_t * 55.0)
		if shown >= total:
			_finish_typewriter()
		else:
			text_label.text = _typewriter_full.left(shown)
			text_label.visible_ratio = 1.0

func _clear_choices() -> void:
	_pending_choices = []
	for c in choices_vb.get_children():
		c.queue_free()

func _show_choices() -> void:
	for c in choices_vb.get_children():
		c.queue_free()
	for ch in _pending_choices:
		var b := Button.new()
		b.text = String(ch["label"])
		b.custom_minimum_size = Vector2(660, 72)
		b.add_theme_font_size_override("font_size", 26)
		b.add_theme_color_override("font_color", INK)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.09, 0.07, 0.08, 0.98)
		sb.border_color = Color(0.45, 0.10, 0.10, 0.9)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(10)
		b.add_theme_stylebox_override("normal", sb)
		var sbp: StyleBoxFlat = sb.duplicate()
		sbp.bg_color = Color(0.35, 0.08, 0.08, 0.98)
		b.add_theme_stylebox_override("pressed", sbp)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var chd: Dictionary = ch
		b.pressed.connect(func(): _on_choice(chd))
		choices_vb.add_child(b)

func _choice(label: String, do: String) -> void:
	_pending_choices.append({"label": label, "do": do})

func _on_choice(ch: Dictionary) -> void:
	_clear_choices()
	var do := String(ch["do"])
	if not do.begins_with("c_"):
		_sfx("click")
	match do:
		"c_strike", "c_heavy", "c_guard", "c_potion":
			_combat_round(do)
			return
		"title":
			_show_title()
			return
	_do(do)

func _refresh_status() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	var wname := String(_gear(Content.WEAPONS, weapon_tier)["name"])
	var aname := String(_gear(Content.ARMORS, armor_tier)["name"])
	var cname := _charm_name(_charm())
	var gearline := "%s · %s" % [wname, aname]
	if cname != "":
		gearline += " · %s" % cname
	hp_label.text = "HP %d/%d   ATK %d   Potions %d\n%s" % [hp, max_hp, _watk(), potions, gearline]
	if floor_num <= 9:
		floor_label.text = "FLOOR %d/9 — %s" % [floor_num, Content.FLOOR_NAMES[floor_num]]
	else:
		floor_label.text = "DEPTH %d — BELOW ITSELF" % floor_num
	gold_label.text = "%d gold" % gold

# ---------------- whispers (collectible lore) ----------------
func _whisper_by_id(id: String) -> Dictionary:
	for w in Content.WHISPERS:
		var wd: Dictionary = w
		if String(wd["id"]) == id:
			return wd
	return {}

func _grant_whisper(id: String) -> String:
	if id in whispers_found:
		return ""
	var w := _whisper_by_id(id)
	if w.is_empty():
		return ""
	whispers_found.append(id)
	_save_best()
	return String(w["title"])

func _whisper_tail(id: String) -> String:
	var t := _grant_whisper(id)
	if t == "":
		return ""
	return "\n\n— WHISPER UNCOVERED: %s —\nRead it in the Codex." % t

func _maybe_whisper(id: String, on_done: Callable) -> void:
	var t := _grant_whisper(id)
	if t == "":
		on_done.call()
		return
	_sfx("whisper")
	_set_art("whisper")
	_refresh_status()
	_say("— WHISPER UNCOVERED —\n\n%s\n\nRead it in the Codex." % t)
	_pending_choices = []
	_choice("Continue", "whisper_next")
	_cs_done = on_done

func _show_codex() -> void:
	mode = "codex"
	_set_art("whisper")
	_refresh_status()
	text_label.text = "CODEX OF WHISPERS\n\n%d of 12 uncovered. The dark remembers." % whispers_found.size()
	text_label.visible_ratio = 1.0
	_typewriter_done = true
	_clear_choices()
	_pending_choices = []
	_choice("Back", "title")
	for w in Content.WHISPERS:
		var wd: Dictionary = w
		if String(wd["id"]) in whispers_found:
			_choice(String(wd["title"]), "codex:" + String(wd["id"]))
		else:
			_choice("? ? ?", "codex:locked")
	_show_choices()

func _show_whisper_entry(id: String) -> void:
	var w := _whisper_by_id(id)
	if w.is_empty():
		_show_codex()
		return
	_say("%s\n\n%s" % [String(w["title"]), String(w["text"])])
	_pending_choices = []
	_choice("Back to Codex", "codex_back")

# ---------------- cutscenes ----------------
var _cs_panels: Array = []
var _cs_idx := 0
var _cs_done: Callable

func _play_cutscene(panels: Array, on_done: Callable) -> void:
	mode = "cutscene"
	_cs_panels = panels
	_cs_idx = 0
	_cs_done = on_done
	_advance_cutscene()

func _advance_cutscene() -> void:
	if _cs_idx >= _cs_panels.size():
		_cs_done.call()
		return
	var p: Dictionary = _cs_panels[_cs_idx]
	_set_art(String(p["art"]))
	_refresh_status()
	_say(String(p["text"]))
	_pending_choices = []
	_choice("Continue", "cs_next")
	_cs_idx += 1

# ---------------- flow ----------------
func _show_title() -> void:
	mode = "title"
	_set_art("title_hero")
	title_label.visible = true
	title_t = 0.0
	art_rect.modulate = Color(1, 1, 1)
	_refresh_status()
	snd_btn.text = "SND" if sound_on else "OFF"
	var extra := ""
	if best_depth > 0:
		extra += "\n\nBest depth: floor %d" % best_depth
	if not endings_found.is_empty():
		extra += "\nEndings found: %d/6" % endings_found.size()
	if keeper_total >= 3:
		extra += "\nThe Keeper's favor: +1 potion each descent"
	if souls_saved + souls_doomed > 0:
		extra += "\nSouls guided: %d · Souls lost: %d" % [souls_saved, souls_doomed]
	_say("GLOAM\n\nA horror rogue RPG.\n\nNine floors down. One way out." + extra)
	_pending_choices = []
	_choice("DESCEND", "start")
	_choice("CODEX (%d/12)" % whispers_found.size(), "codex")

func _start_run() -> void:
	hp = 30
	max_hp = 30
	atk = 6
	gold = 0
	potions = 2 + (1 if keeper_total >= 3 else 0)
	floor_num = 1
	intro_idx = 0
	keeper_met = 0
	fight_is_boss = false
	guarding = false
	_after_fight = ""
	endless = false
	death_cause = ""
	pondered = []
	weapon_tier = 0
	armor_tier = 0
	charms_owned = []
	ward_blocked = false
	if sound_on and not amb_player.playing:
		amb_player.play()
	_show_intro()

func _show_intro() -> void:
	mode = "intro"
	title_label.visible = false
	art_rect.modulate = Color(1, 1, 1)
	if intro_idx >= Content.INTRO.size():
		_maybe_whisper("first_bell", func(): _play_cutscene(Content.TIER_CUTSCENES[1], _begin_floor))
		return
	var p: Dictionary = Content.INTRO[intro_idx]
	_set_art(String(p["art"]))
	_say(String(p["text"]))
	_pending_choices = []
	_choice("Continue", "intro_next")
	intro_idx += 1

func _begin_floor(random_start := false) -> void:
	mode = "room"
	_gen_dungeon(floor_num)
	cur_node = randi() % dungeon.size() if random_start else 0
	_update_map()
	_enter_node(cur_node)

func _link(a: int, b: int) -> void:
	var na: Dictionary = dungeon[a]
	var nb: Dictionary = dungeon[b]
	if b in na["conns"]:
		return
	(na["conns"] as Array).append(b)
	(nb["conns"] as Array).append(a)

func _bfs_depths() -> Array:
	var depth := []
	depth.resize(dungeon.size())
	depth.fill(-1)
	depth[0] = 0
	var q := [0]
	while not q.is_empty():
		var n: int = q.pop_front()
		for c in (dungeon[n] as Dictionary)["conns"]:
			if depth[int(c)] == -1:
				depth[int(c)] = depth[n] + 1
				q.append(int(c))
	return depth

func _nodes_of_kind(kinds: Array) -> Array:
	var out := []
	for i in dungeon.size():
		var nd: Dictionary = dungeon[i]
		if String(nd["kind"]) in kinds and i != 0:
			out.append(i)
	return out

func _gen_dungeon(f: int) -> void:
	dungeon = []
	var count := 8 + mini(3, f / 3)
	for i in count:
		dungeon.append({"id": i, "kind": "empty", "conns": [], "visited": false, "data": {}, "descs": {}, "special": ""})
	for i in range(1, count):
		_link(i, randi() % i)
	for k in range(count / 3):
		_link(randi() % count, randi() % count)
	var depth := _bfs_depths()
	var order := []
	for i in count:
		order.append(i)
	order.sort_custom(func(a, b): return depth[a] > depth[b])
	var is_boss_floor := f % 3 == 0 and f <= 9
	var boss_id := -1
	var stairs_id := -1
	if is_boss_floor:
		boss_id = order[0]
		(dungeon[boss_id] as Dictionary)["kind"] = "boss"
		(dungeon[boss_id] as Dictionary)["special"] = "boss"
	else:
		stairs_id = order[0]
		(dungeon[stairs_id] as Dictionary)["kind"] = "stairs"
		(dungeon[stairs_id] as Dictionary)["special"] = "stairs"
	(dungeon[0] as Dictionary)["kind"] = "fight"
	(dungeon[0] as Dictionary)["data"] = {"monster": "pick"}
	var kinds := ["fight", "fight", "fight", "treasure", "treasure", "trap", "shrine", "event", "lost", "trapped", "dead", "carving"]
	if Content.KEEPER_BEATS.has(f):
		kinds.append("keeper")
	while kinds.size() < count - 3:
		kinds.append("fight" if randf() < 0.5 else "event")
	kinds.shuffle()
	var pool: Array = Content.ROOMS.duplicate()
	pool.shuffle()
	var by_kind := {}
	for rd in pool:
		var kk := String((rd as Dictionary)["kind"])
		if not by_kind.has(kk):
			by_kind[kk] = []
		(by_kind[kk] as Array).append(rd)
	var ki := 0
	for i in count:
		if i == 0 or i == stairs_id or i == boss_id:
			continue
		var nd: Dictionary = dungeon[i]
		if ki >= kinds.size():
			nd["kind"] = "fight"
			nd["data"] = {"monster": "pick"}
			continue
		var kind := String(kinds[ki])
		ki += 1
		nd["kind"] = kind
		if kind == "fight":
			nd["data"] = {"monster": "pick"}
		elif kind == "keeper":
			nd["data"] = {}
		elif kind in ["treasure", "trap", "shrine", "event", "lost", "trapped", "dead", "carving"]:
			var lst: Array = by_kind.get(kind, [])
			if lst.is_empty():
				nd["kind"] = "fight"
				nd["data"] = {"monster": "pick"}
			else:
				nd["data"] = lst.pop_back()
	if f in [2, 5, 8]:
		var mc := _nodes_of_kind(["event", "treasure", "trap"])
		if not mc.is_empty():
			var mpick: int = mc[randi() % mc.size()]
			(dungeon[mpick] as Dictionary)["kind"] = "mira"
			(dungeon[mpick] as Dictionary)["special"] = ""
			(dungeon[mpick] as Dictionary)["data"] = {"trace": f}
	if f < 9 and randf() < 0.5:
		var dc := _nodes_of_kind(["trap", "event"])
		if not dc.is_empty():
			var pick: int = dc[randi() % dc.size()]
			(dungeon[pick] as Dictionary)["kind"] = "depths"
			(dungeon[pick] as Dictionary)["special"] = "depths"
	if f >= 2 and randf() < 0.6:
		var lc := _nodes_of_kind(["trap", "event"])
		if not lc.is_empty():
			var pick2: int = lc[randi() % lc.size()]
			(dungeon[pick2] as Dictionary)["kind"] = "labyrinth"
			(dungeon[pick2] as Dictionary)["special"] = "labyrinth"
			(dungeon[pick2] as Dictionary)["data"] = {"progress": 0, "solved": false}
	for i in count:
		var nd2: Dictionary = dungeon[i]
		for c in nd2["conns"]:
			var dest: Dictionary = dungeon[int(c)]
			var d: String = EXIT_DESCS[randi() % EXIT_DESCS.size()]
			match String(dest["special"]):
				"stairs":
					d = "a stairwell spiraling down into the dark"
				"depths":
					d = "a cracked shaft falling away below"
				"boss":
					d = "an archway of teeth, humming"
				"labyrinth":
					d = "a corridor that will not sit still"
			(nd2["descs"] as Dictionary)[int(c)] = d

func _node() -> Dictionary:
	return dungeon[cur_node]

func _enter_node(id: int) -> void:
	cur_node = id
	var nd := _node()
	if bool(nd["visited"]):
		_show_exits(true)
		return
	nd["visited"] = true
	_run_node()

func _run_node() -> void:
	_refresh_status()
	var nd := _node()
	match String(nd["kind"]):
		"fight":
			var md: Dictionary = nd["data"]
			_start_fight(_pick_monster() if String(md.get("monster", "")) == "pick" else md)
		"boss":
			_start_boss(floor_num / 3 - 1)
		"keeper":
			_visit_keeper()
		"stairs":
			_set_art("intro2")
			_say(Content.STAIR_TEXT)
			_pending_choices = []
			_choice("Descend to floor %d" % (floor_num + 1), "stairs_go")
			_choice("Step back", "nothing")
		"depths":
			_set_art("trap")
			_say("The floor gives way to a cracked shaft, falling past this floor into deeper dark.\n\nSomething glimmers far below. Or maybe it is just the dark, blinking.")
			_pending_choices = []
			_choice("Drop into the dark", "depths_drop")
			_choice("Step back", "nothing")
		"labyrinth":
			_run_labyrinth()
		"mira":
			_run_mira()
		_:
			var r: Dictionary = nd["data"]
			var panels := [
				{"art": String(r["art"]), "text": String(r["text"])},
				{"art": String(r["art"]), "text": String(r.get("sting", "The dark watches."))},
			]
			_play_cutscene(panels, func(): _room_choices(nd))

func _room_choices(nd: Dictionary) -> void:
	mode = "room"
	_refresh_status()
	var r: Dictionary = nd["data"]
	_pending_choices = []
	for ch in r["choices"]:
		var cd: Dictionary = ch
		if String(cd["do"]).begins_with("gamble:") and gold < 15:
			continue
		if String(cd["do"]).begins_with("offer:") and gold < 20:
			continue
		_choice(String(cd["label"]), String(cd["do"]))
	if String(nd["kind"]) == "shrine":
		var unp := 0
		for w in Content.WHISPERS:
			var wid := String((w as Dictionary)["id"])
			if wid in whispers_found and not wid in pondered:
				unp += 1
		if unp > 0 and hp > 4:
			_choice("Ponder a whisper (%d)" % unp, "ponder")
	if String(nd["kind"]) == "treasure":
		_choice("Search for arms & armor", "gear_hunt")
	_show_choices()

func _show_exits(revisit := false) -> void:
	mode = "room"
	_refresh_status()
	_update_map()
	var nd := _node()
	if revisit:
		_say("Dust and echoes. You have been here.\n\nPassages lead out:")
	else:
		_say("Passages lead out:")
	_pending_choices = []
	for c in nd["conns"]:
		_choice(String((nd["descs"] as Dictionary).get(int(c), "a dark passage")), "go:" + str(int(c)))

func _run_labyrinth() -> void:
	var nd := _node()
	if bool((nd["data"] as Dictionary).get("solved", false)):
		_show_exits()
		return
	_set_art("corridor")
	_say("The halls shift when you are not looking. Three doors stand where two were.\n\nOne of them leads onward. The others lead... elsewhere.")
	_pending_choices = []
	_choice("The left door", "lab_door:0")
	_choice("The middle door", "lab_door:1")
	_choice("The right door", "lab_door:2")

func _run_mira() -> void:
	var tid := int((_node()["data"] as Dictionary).get("trace", 2))
	var tr: Dictionary = Content.MIRA_TRACES[tid]
	_set_art("mira_trace")
	_refresh_status()
	if tid in mira_found:
		_say("Mira's trace. You've already found this one.\n\n" + String(tr["text"]))
	else:
		mira_found.append(tid)
		_save_best()
		_say(String(tr["text"]) + "\n\n— MIRA'S TRACE FOUND (%d/3) —" % mira_found.size())
	_pending_choices = []
	_choice("Continue", "nothing")

func _descend() -> void:
	_sfx("stairs")
	floor_num += 1
	if floor_num - 1 > best_depth:
		best_depth = floor_num - 1
		_save_best()
	if floor_num > 9:
		endless = true
		_play_cutscene(
			[{"art": "floor9", "text": "DEPTH %d — BELOW ITSELF\n\nThe dark down here is older. It doesn't bother with shapes anymore.\n\nNothing here knows your name. Yet." % floor_num}],
			_begin_floor
		)
		return
	var after: Callable = _begin_floor
	if floor_num == 4:
		after = func(): _maybe_whisper("hollow_choir", _begin_floor)
	elif floor_num == 9:
		after = func(): _maybe_whisper("the_gloam", _begin_floor)
	_play_cutscene(Content.TIER_CUTSCENES[floor_num], after)

func _toggle_sound() -> void:
	sound_on = not sound_on
	snd_btn.text = "SND" if sound_on else "OFF"
	_save_best()
	if sound_on:
		if not amb_player.playing:
			amb_player.play()
	else:
		amb_player.stop()

func _sfx(n: String) -> void:
	if not sound_on:
		return
	var s: AudioStreamWAV = SFX.get(n)
	if s == null:
		return
	sfx_player.stream = s
	sfx_player.play()

func _toggle_map() -> void:
	if map_panel == null or dungeon.is_empty():
		return
	map_panel.visible = not map_panel.visible
	if map_panel.visible:
		_update_map()

func _update_map() -> void:
	if dungeon.is_empty() or map_view == null:
		return
	var depth := _bfs_depths()
	var layers := {}
	for i in dungeon.size():
		var d: int = depth[i]
		if not layers.has(d):
			layers[d] = []
		(layers[d] as Array).append(i)
	var maxd := 0
	for k in layers.keys():
		maxd = maxi(maxd, int(k))
	var pts := []
	pts.resize(dungeon.size())
	for d in range(maxd + 1):
		var arr: Array = layers.get(d, [])
		for j in arr.size():
			var x := 55.0 + d * 95.0
			var y := 300.0 + (j - (arr.size() - 1) / 2.0) * 74.0
			pts[int(arr[j])] = Vector2(x, y)
	var links := []
	var visited := []
	var special := []
	var conns := []
	for i in dungeon.size():
		var nd: Dictionary = dungeon[i]
		conns.append((nd["conns"] as Array).duplicate())
		visited.append(bool(nd["visited"]))
		special.append(String(nd["special"]))
		for c in nd["conns"]:
			if int(c) > i:
				links.append([i, int(c)])
	map_view.pts = pts
	map_view.links = links
	map_view.conns = conns
	map_view.visited = visited
	map_view.special = special
	map_view.current = cur_node
	map_view.queue_redraw()

func _visit_keeper() -> void:
	keeper_met += 1
	keeper_total += 1
	_save_best()
	var kb: Dictionary = Content.KEEPER_BEATS[floor_num]
	for g in String(kb["gift"]).split("+"):
		var p := g.split(":")
		match p[0]:
			"potion":
				potions += int(p[1])
			"heal":
				hp = mini(max_hp, hp + int(p[1]))
			"atk":
				atk += int(p[1])
	var kid := "keeper1"
	if floor_num == 5:
		kid = "keeper2"
	elif floor_num == 8:
		kid = "keeper3"
	_play_cutscene([kb], func(): _maybe_whisper(kid, _show_exits))

func _pick_monster() -> Dictionary:
	var tier := 0
	if floor_num >= 7:
		tier = 2
	elif floor_num >= 4:
		tier = 1
	var cands := []
	for m in Content.MONSTERS:
		var md: Dictionary = m
		var idx := Content.MONSTERS.find(m)
		if idx / 3 == tier:
			cands.append(md)
	var base: Dictionary = cands[randi() % cands.size()]
	if floor_num <= 9:
		return base
	var mult := 1.0 + (floor_num - 9) * 0.18
	var m2: Dictionary = base.duplicate()
	m2["hp"] = int(int(base["hp"]) * mult)
	m2["atk"] = int(int(base["atk"]) * mult)
	var g: Array = base["gold"]
	m2["gold"] = [int(g[0] * mult), int(g[1] * mult)]
	m2["name"] = "Deep " + String(base["name"]).trim_prefix("The ")
	return m2

# ---------------- choices ----------------
func _do(do: String) -> void:
	var parts := do.split(":")
	var cmd := parts[0]
	match cmd:
		"start":
			_start_run()
		"intro_next":
			_show_intro()
		"stairs_go":
			_descend()
		"go":
			_enter_node(int(parts[1]))
		"depths_drop":
			var fall := randi_range(5, 9)
			hp -= fall
			death_cause = "dark"
			if hp <= 0:
				_die()
				return
			_refresh_status()
			floor_num += 1
			if floor_num - 1 > best_depth:
				best_depth = floor_num - 1
				_save_best()
			_play_cutscene(
				[{"art": "trap", "text": "You let go and fall, lantern swinging, past floors you will never see. (-%d HP)" % fall}],
				func(): _play_cutscene(Content.TIER_CUTSCENES[floor_num], func(): _begin_floor(true))
			)
		"lab_door":
			var nd2 := _node()
			var data2: Dictionary = nd2["data"]
			var prog2 := int(data2.get("progress", 0))
			if randf() < 0.45:
				data2["progress"] = prog2 + 1
				if prog2 + 1 >= 2:
					data2["solved"] = true
					_set_art("corridor")
					_say("A door opens onto steady, honest stone. The halls stop shifting.\n\nThe way is clear.")
				else:
					_say("This door opens onto another set of doors. Closer, now. The halls are running out of tricks.")
				_pending_choices = []
				_choice("Move on", "lab_solved" if bool(data2.get("solved", false)) else "lab_again")
			elif randf() < 0.7:
				_after_fight = "lab"
				_start_fight(_pick_monster())
			else:
				_say("A dead end. Somewhere, the halls rearrange themselves. Smug.")
				_pending_choices = []
				_choice("Try another door", "lab_again")
		"lab_again":
			_run_labyrinth()
		"lab_solved":
			_show_exits()
		"gloam_fight":
			_start_fight(Content.BOSSES[2], true)
		"gloam_kneel":
			_ending_stay()
		"win_go":
			_win()
		"final_choice":
			_final_choice()
		"endless_go":
			floor_num = 9
			_descend()
		"cs_next":
			_advance_cutscene()
		"whisper_next":
			_cs_done.call()
		"gear_hunt":
			_gear_hunt()
			return
		"soul_guide":
			souls_saved += 1
			max_hp += 2
			hp = mini(max_hp, hp + 2)
			_save_best()
			_say("You walk them to the stair and point up.\n\n'Go. Don't stop. Don't look at the walls.'\n\nThey go. Something in you stands a little straighter. (+2 max HP)\n\n— SOUL GUIDED (%d) —" % souls_saved)
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"soul_rob":
			souls_doomed += 1
			gold += 30
			_save_best()
			_say("You take their purse, their lantern oil, their hope. They don't even fight.\n\nThey just stand there, getting smaller in the dark behind you.\n\n(+30 gold)\n\n— SOUL DOOMED (%d) —" % souls_doomed)
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"soul_leave":
			souls_doomed += 1
			_save_best()
			_say("You leave them with the dying lantern.\n\nYou tell yourself someone else will come. No one else is coming.\n\n— SOUL DOOMED (%d) —" % souls_doomed)
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"trap_free":
			souls_saved += 1
			_save_best()
			var unowned2: Array = []
			for c in Content.CHARMS:
				var cid := String((c as Dictionary)["id"])
				if cid != "none" and not cid in charms_owned:
					unowned2.append(c)
			var tail2 := ""
			if not unowned2.is_empty():
				var pick2: Dictionary = unowned2[randi() % unowned2.size()]
				charms_owned.append(String(pick2["id"]))
				tail2 = "\n\n'Take this,' they whisper, pressing something into your hand: a %s.\n\n%s" % [String(pick2["name"]), String(pick2["desc"])]
			else:
				max_hp += 2
				hp = mini(max_hp, hp + 2)
				tail2 = "\n\nThey grip your arm. 'I owe you my life.' Something in you stands straighter. (+2 max HP)"
			_say("You heave the beam up. They crawl out, gasping, alive.%s\n\n— SOUL GUIDED (%d) —" % [tail2, souls_saved])
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"trap_leave":
			souls_doomed += 1
			_save_best()
			_say("You keep walking. Behind you, the hand stops moving.\n\nYou don't turn around. That's the worst part — how easy it is not to turn around.\n\n— SOUL DOOMED (%d) —" % souls_doomed)
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"dead_read":
			var note: String = Content.DEAD_NOTES[randi() % Content.DEAD_NOTES.size()]
			_say("The paper is brittle. The handwriting shakes:\n\n\"%s\"" % note)
			_pending_choices = []
			_choice("Continue", "nothing")
		"dead_loot":
			var lg := randi_range(15, 30)
			gold += lg
			_say("You take their coins and a half-empty flask. The dead don't need them.\n\nYou tell yourself they'd want you to have them. (+%d gold)" % lg)
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"dead_pray":
			hp = mini(max_hp, hp + 4)
			_say("You say the chapel words over them. Your voice shakes on the old syllables.\n\nSomehow, you feel steadier. (+4 HP)")
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"carve_read":
			var cv: String = Content.CARVINGS[randi() % Content.CARVINGS.size()]
			var tail3 := ""
			if randf() < 0.2:
				atk += 1
				tail3 = "\n\nThe scratches teach you something about surviving down here. (+1 ATK)"
			_say("You read by lantern light:\n\n\"%s\"%s" % [cv, tail3])
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"ponder":
			var pid := ""
			for w in Content.WHISPERS:
				var wid := String((w as Dictionary)["id"])
				if wid in whispers_found and not wid in pondered:
					pid = wid
					break
			if pid != "" and hp > 4:
				pondered.append(pid)
				hp -= 4
				atk += 1
				_say("You sit with what the dark told you, and let it hurt.\n\nThe truths cost blood. They pay in edge. (-4 HP, +1 ATK)")
			else:
				_say("Nothing left to ponder. The dark has said all it will say — for now.")
			_pending_choices = []
			_choice("Continue", "nothing")
			_refresh_status()
		"codex":
			if parts.size() > 1 and parts[1] != "locked":
				_show_whisper_entry(parts[1])
			else:
				_show_codex()
		"codex_back":
			_show_codex()
		"pack":
			gold += 14
			potions += 1
			_say("His purse holds 14 gold. His pack holds one last vial, still glowing. (+14 gold, +1 potion)")
			_pending_choices = []
			_choice("Continue", "nothing")
		"nothing":
			if _after_fight == "lab":
				_after_fight = ""
				_run_labyrinth()
			else:
				_show_exits()
		"gold":
			var n := int(parts[1])
			gold += n
			_say("You take %d gold. It is cold, and it smells like the dark." % n)
			_pending_choices = []
			_choice("Continue", "nothing")
		"heal":
			var n := int(parts[1])
			hp = mini(max_hp, hp + n)
			_say("Warmth spreads through you. (+%d HP)" % n)
			_pending_choices = []
			_choice("Continue", "nothing")
		"dmg":
			var n := int(parts[1])
			_hurt(n, "The dark bites. (-%d HP)" % n)
		"atk":
			atk += int(parts[1])
			_say("Your edge is keener now. (+%d ATK)" % int(parts[1]))
			_pending_choices = []
			_choice("Continue", "nothing")
		"potion":
			potions += int(parts[1])
			_say("You pocket the vial. It glows faintly. (+%d potion)" % int(parts[1]))
			_pending_choices = []
			_choice("Continue", "nothing")
		"offer":
			var cost := int(parts[1])
			if gold >= cost:
				gold -= cost
				max_hp += 4
				hp = max_hp
				_say("The candles flare. Something accepts. You feel... more. (Full heal, +4 max HP)")
			else:
				_say("You don't have the gold.")
			_pending_choices = []
			_choice("Continue", "nothing")
		"whispers":
			var wtail := _whisper_tail("the_throat")
			if randf() < 0.5:
				hp = mini(max_hp, hp + 6)
				_say("\"BELOW THE SAINT, THE DARK WEARS YOUR FACE.\" The whispering stops. You feel steadied. (+6 HP)" + wtail)
			else:
				_hurt(4, "The whispers crawl inside your skull and nest there. (-4 HP)" + wtail)
		"cage":
			if randf() < 0.6:
				potions += 1
				_say("The lock breaks. The prisoner presses a vial into your hand and vanishes into the dark. (+1 potion)")
			else:
				_say("\"FOOL,\" he hisses — and his jaw unhinges, wider, wider...")
				_pending_choices = []
				_choice("Fight!", "cage_fight")
				return
			_pending_choices = []
			_choice("Continue", "nothing")
		"cage_fight":
			_start_fight(Content.MONSTERS[1])
		"mirror":
			atk += 2
			_hurt(6, "Power floods your arms. Something takes its price in blood. (+2 ATK, -6 HP)" + _whisper_tail("mirror"))
		"gamble":
			var bet := int(parts[1])
			gold -= bet
			if randf() < 0.45:
				gold += bet * 2
				_say("The dice clatter... doubles. The shade laughs and pays out. (+%d gold)" % bet + _whisper_tail("gambler"))
			else:
				_say("Snake eyes. The shade pockets your gold with fingers like twigs. (-%d gold)" % bet)
			_pending_choices = []
			_choice("Continue", "nothing")
		_:
			_show_exits()
	_refresh_status()

func _hurt(n: int, msg: String, cont := true) -> void:
	hp -= n
	death_cause = "dark"
	if hp <= 0:
		_die()
		return
	_say(msg)
	if cont:
		_pending_choices = []
		_choice("Continue", "nothing")

# ---------------- combat ----------------
func _gear(list: Array, tier: int) -> Dictionary:
	return list[mini(tier, list.size() - 1)]

func _watk() -> int:
	return atk + int(_gear(Content.WEAPONS, weapon_tier)["atk"])

func _adef() -> int:
	return int(_gear(Content.ARMORS, armor_tier)["def"])

func _charm() -> String:
	return String(charms_owned.back()) if not charms_owned.is_empty() else "none"

func _charm_name(cid: String) -> String:
	for c in Content.CHARMS:
		if String((c as Dictionary)["id"]) == cid:
			return String((c as Dictionary)["name"])
	return ""

func _start_fight(m: Dictionary, is_boss := false) -> void:
	mode = "combat"
	enemy = m
	fight_is_boss = is_boss
	enemy_hp = int(m["hp"])
	guarding = false
	ward_blocked = false
	_set_art(String(m["art"]))
	_refresh_status()
	var desc := String(m["desc"])
	if not is_boss and randf() < 0.4:
		var tb := 0
		if floor_num >= 7:
			tb = 2
		elif floor_num >= 4:
			tb = 1
		var bl: Array = Content.BARKS[tb]
		desc = "\"%s\"\n\n%s" % [String(bl[randi() % bl.size()]), desc]
	if _charm() == "ember" and not is_boss:
		enemy_hp -= 3
		desc += "\n\nYour Ember Charm flares — the thing shrieks as fire takes it. (-3)"
	_combat_text(desc + "\n\nA %s blocks your path!" % String(m["name"]))

func _start_boss(idx: int) -> void:
	var b: Dictionary = Content.BOSSES[idx]
	if idx == 2:
		_play_cutscene(Content.BOSS_CUTSCENES[idx], _gloam_choice)
	else:
		var wid := "the_warden" if idx == 0 else "starved_saint"
		_play_cutscene(Content.BOSS_CUTSCENES[idx], func(): _maybe_whisper(wid, func(): _start_fight(b, true)))

func _gloam_choice() -> void:
	mode = "room"
	_set_art("boss")
	_refresh_status()
	_say(Content.GLOAM_OFFER)
	_pending_choices = []
	_choice("Fight it", "gloam_fight")
	_choice("Kneel", "gloam_kneel")

func _ending_stay() -> void:
	_unlock_ending("stay")
	var panels: Array
	if mira_found.size() >= 3:
		panels = [
			{"art": "boss", "text": "You kneel.\n\nThe dark rushes forward — not unkindly. It has been so lonely."},
			{"art": "mira_trace", "text": "And she's there. Mira. Older, the way you feared she'd get.\n\n'You took your time,' she says, and takes your hand.\n\nSTAY — you found her."},
		]
	else:
		panels = Content.END_STAY.duplicate()
	_play_cutscene(panels, _end_choices)

func _combat_text(t: String) -> void:
	_say(t + "\n\n%s — HP %d/%d" % [String(enemy["name"]), enemy_hp, int(enemy["hp"])])
	_pending_choices = []
	_choice("Strike", "c_strike")
	_choice("Heavy (65%)", "c_heavy")
	_choice("Guard", "c_guard")
	_choice("Potion (%d)" % potions, "c_potion")

func _combat_round(action: String) -> void:
	var log := ""
	# player action
	match action:
		"c_strike":
			var dmg := _watk() + randi_range(-1, 2)
			enemy_hp -= dmg
			log += "You strike for %d. " % dmg
			_sfx("hit")
		"c_heavy":
			if randf() < 0.65:
				var dmg2 := int(_watk() * 1.7) + randi_range(0, 2)
				enemy_hp -= dmg2
				log += "Your heavy blow lands for %d! " % dmg2
				_sfx("hit")
			else:
				log += "Your heavy swing misses! "
		"c_guard":
			guarding = true
			log += "You raise your guard. "
		"c_potion":
			if potions > 0:
				potions -= 1
				hp = mini(max_hp, hp + 14)
				log += "You drink. Warmth returns. (+14 HP) "
				_sfx("potion")
			else:
				log += "No potions left! "
	if enemy_hp <= 0:
		_win_fight(log)
		return
	# enemy turn
	var edmg := int(enemy["atk"]) + randi_range(-1, 2)
	if _charm() == "ward" and not ward_blocked:
		ward_blocked = true
		edmg = 0
		log += "Your Ward Charm flares — the blow never lands. "
	if guarding:
		edmg = maxi(1, edmg / 2)
		guarding = false
		log += "You block the worst of it. "
	edmg = maxi(0 if edmg == 0 else 1, edmg - _adef())
	hp -= edmg
	log += "%s hits you for %d." % [String(enemy["name"]), edmg]
	if edmg > 0:
		_sfx("hurt")
		if hp <= max_hp * 0.3 and hp > 0 and randf() < 0.6:
			log += "\n\"%s\"" % String((Content.CORVIN_LOW as Array)[randi() % Content.CORVIN_LOW.size()])
		elif randf() < 0.25:
			log += "\n\"%s\"" % String((Content.CORVIN_HURT as Array)[randi() % Content.CORVIN_HURT.size()])
	if hp <= 0:
		death_cause = "boss" if fight_is_boss else "combat"
		_die()
		return
	_refresh_status()
	_combat_text(log)

func _boss_gear_drop() -> String:
	if weapon_tier < Content.WEAPONS.size() - 1 and (armor_tier >= Content.ARMORS.size() - 1 or randf() < 0.6):
		weapon_tier += 1
		var w: Dictionary = _gear(Content.WEAPONS, weapon_tier)
		return "\n\nAmong the remains: a %s. You take it. (+%d ATK)" % [String(w["name"]), int(w["atk"])]
	elif armor_tier < Content.ARMORS.size() - 1:
		armor_tier += 1
		var a: Dictionary = _gear(Content.ARMORS, armor_tier)
		return "\n\nAmong the remains: %s. You strap it on. (blocks %d)" % [String(a["name"]), int(a["def"])]
	return ""

func _gear_hunt() -> void:
	var roll := randf()
	if roll < 0.45 and weapon_tier < Content.WEAPONS.size() - 1:
		weapon_tier += 1
		var w: Dictionary = _gear(Content.WEAPONS, weapon_tier)
		_say("Behind the rubble: a weapon rack, untouched.\n\nYou take the %s. (+%d ATK)\n\n%s" % [String(w["name"]), int(w["atk"]), String(w["desc"])])
	elif roll < 0.75 and armor_tier < Content.ARMORS.size() - 1:
		armor_tier += 1
		var a: Dictionary = _gear(Content.ARMORS, armor_tier)
		_say("Behind the rubble: an armory niche, still sealed.\n\nYou strap on the %s. (blocks %d)\n\n%s" % [String(a["name"]), int(a["def"]), String(a["desc"])])
	else:
		var unowned: Array = []
		for c in Content.CHARMS:
			var cid := String((c as Dictionary)["id"])
			if cid != "none" and not cid in charms_owned:
				unowned.append(c)
		if not unowned.is_empty():
			var pick: Dictionary = unowned[randi() % unowned.size()]
			charms_owned.append(String(pick["id"]))
			_say("In a rotted pouch: a %s.\n\n%s" % [String(pick["name"]), String(pick["desc"])])
		else:
			var gg := randi_range(20, 40)
			gold += gg
			_say("Nothing but old iron and older bones. You pry loose the fittings. (+%d gold)" % gg)
	_pending_choices = []
	_choice("Continue", "nothing")
	_refresh_status()

func _win_fight(log: String) -> void:
	var gain: int
	if enemy["gold"] is Array:
		var g: Array = enemy["gold"]
		gain = randi_range(int(g[0]), int(g[1]))
	else:
		gain = int(enemy["gold"])
	if _charm() == "moth":
		gain = int(gain * 1.5)
	gold += gain
	_sfx("gold")
	if _charm() == "leech":
		hp = mini(max_hp, hp + 2)
	_refresh_status()
	var final := fight_is_boss and floor_num == 9
	var was_boss := fight_is_boss
	fight_is_boss = false
	mode = "room"
	_set_art("corridor")
	var tail := "\n\nThe %s collapses into dust and old coins. (+%d gold)" % [String(enemy["name"]), gain]
	if randf() < 0.35:
		tail += "\n\"%s\"" % String((Content.CORVIN_KILL as Array)[randi() % Content.CORVIN_KILL.size()])
	tail += _whisper_tail("bell_keeper") if String(enemy["name"]) == "Bell Ringer" else ""
	if was_boss and not final:
		var drop := _boss_gear_drop()
		if drop != "":
			tail += drop
	_say(log + tail)
	_pending_choices = []
	if final:
		_choice("Continue", "final_choice")
	elif was_boss:
		_choice("Descend to floor %d" % (floor_num + 1), "stairs_go")
	else:
		_choice("Continue", "nothing")

func _final_choice() -> void:
	mode = "room"
	_set_art("escape")
	_refresh_status()
	_say("GLOAM ITSELF collapses into dust and silence.\n\nAbove, daylight waits. Below, the dark keeps going — deeper than nine floors, deeper than maps.\n\nIt doesn't have to end.")
	_pending_choices = []
	_choice("Climb into the daylight", "win_go")
	_choice("Keep descending", "endless_go")

func _die() -> void:
	_sfx("death")
	if floor_num > best_depth:
		best_depth = floor_num
		_save_best()
	_refresh_status()
	var panels: Array = []
	var kline := ""
	match death_cause:
		"boss":
			kline = "'%s kept you,' the Keeper says, its blue lantern guttering. 'It counts you now. I'll keep your hour burning.'" % String(enemy["name"])
		"combat":
			kline = "'You fought,' the Keeper says. 'That's more than most. I'll keep your hour burning.'"
		_:
			kline = "'The dark is patient,' the Keeper says. 'It can wait. I can't.'"
	if souls_saved + souls_doomed > 0:
		if souls_saved >= souls_doomed:
			kline += " 'You carried %d of them out. The dark remembers kindness too.'" % souls_saved
		else:
			kline += " 'You left %d of them down here. They wait for you now.'" % souls_doomed
	panels.append({"art": "keeper", "text": kline})
	if fight_is_boss:
		_unlock_ending("claimed")
		var bn := String(enemy["name"])
		for p in Content.END_CLAIMED:
			var pd: Dictionary = p
			panels.append({"art": String(pd["art"]), "text": String(pd["text"]) % bn})
		_play_cutscene(panels, _end_choices)
	else:
		_unlock_ending("taken")
		panels.append({"art": "death", "text": Content.END_TAKEN[0]["text"] % floor_num})
		panels.append(Content.END_TAKEN[1])
		_play_cutscene(panels, _end_choices)
	fight_is_boss = false

func _win() -> void:
	best_depth = 9
	_refresh_status()
	var panels: Array
	if keeper_met >= 3:
		_unlock_ending("lantern")
		panels = Content.END_LANTERN.duplicate()
	elif gold >= 250:
		_unlock_ending("gilded")
		panels = []
		for p in Content.END_GILDED:
			var pd: Dictionary = p
			panels.append({"art": String(pd["art"]), "text": String(pd["text"]) % gold})
	else:
		_unlock_ending("daybreak")
		panels = []
		for p in Content.END_DAYBREAK:
			var pd2: Dictionary = p
			var t := String(pd2["text"])
			panels.append({"art": String(pd2["art"]), "text": t % gold if "%d" in t else t})
		panels.append({"art": "homecoming", "text": "But on the third morning, a rider comes up the valley road with war-news: the Ashen War isn't over.\n\nAnd the enemy has started digging outside Vesper.\n\nThey heard what's under the chapel."})
	_play_cutscene(panels, _end_choices)

func _end_choices() -> void:
	mode = "dead"
	_clear_choices()
	_pending_choices = []
	_choice("Descend again", "start")
	_choice("Title", "title")
	_show_choices()

func _unlock_ending(id: String) -> void:
	if not id in endings_found:
		endings_found.append(id)
		_save_best()

# ---------------- save ----------------
const SAVE_PATH := "user://gloam.save"

func _save_best() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_var({"best": best_depth, "endings": endings_found, "whispers": whispers_found, "mira": mira_found, "keeper_total": keeper_total, "saved": souls_saved, "doomed": souls_doomed, "sound": sound_on})
		f.close()

func _load_best() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var d: Dictionary = f.get_var()
		best_depth = int(d.get("best", 0))
		endings_found = d.get("endings", [])
		whispers_found = d.get("whispers", [])
		mira_found = d.get("mira", [])
		keeper_total = int(d.get("keeper_total", 0))
		souls_saved = int(d.get("saved", 0))
		souls_doomed = int(d.get("doomed", 0))
		sound_on = bool(d.get("sound", true))
		f.close()
