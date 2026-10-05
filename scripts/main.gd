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
var room_queue := []
var intro_idx := 0
var enemy := {}
var enemy_hp := 0
var guarding := false
var best_depth := 0
var keeper_met := 0
var fight_is_boss := false
var endings_found: Array = []
var whispers_found: Array = []

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
	floor_label = _mk_label("", 24, Vector2(20, 494), Vector2(340, 36), DIM)
	gold_label = _mk_label("", 24, Vector2(360, 494), Vector2(340, 36), GOLD_C)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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
	hp_label = _mk_label("", 22, Vector2(20, 560), Vector2(680, 30), INK)
	# text (tap to skip typewriter)
	text_label = RichTextLabel.new()
	text_label.position = Vector2(20, 596)
	text_label.custom_minimum_size = Vector2(680, 300)
	text_label.size = Vector2(680, 300)
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
	hp_label.text = "HP %d/%d   ATK %d   Potions %d" % [hp, max_hp, atk, potions]
	floor_label.text = "FLOOR %d/9 — %s" % [floor_num, Content.FLOOR_NAMES[floor_num]]
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
	for w in Content.WHISPERS:
		var wd: Dictionary = w
		if String(wd["id"]) in whispers_found:
			_choice(String(wd["title"]), "codex:" + String(wd["id"]))
		else:
			_choice("? ? ?", "codex:locked")
	_choice("Back", "title")
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
	_set_art("title")
	_refresh_status()
	var extra := ""
	if best_depth > 0:
		extra += "\n\nBest depth: floor %d" % best_depth
	if not endings_found.is_empty():
		extra += "\nEndings found: %d/6" % endings_found.size()
	_say("GLOAM\n\nA horror rogue RPG.\n\nNine floors down. One way out." + extra)
	_pending_choices = []
	_choice("DESCEND", "start")
	_choice("CODEX (%d/12)" % whispers_found.size(), "codex")

func _start_run() -> void:
	hp = 30
	max_hp = 30
	atk = 6
	gold = 0
	potions = 2
	floor_num = 1
	intro_idx = 0
	keeper_met = 0
	fight_is_boss = false
	guarding = false
	_show_intro()

func _show_intro() -> void:
	mode = "intro"
	if intro_idx >= Content.INTRO.size():
		_maybe_whisper("first_bell", func(): _play_cutscene(Content.TIER_CUTSCENES[1], _begin_floor))
		return
	var p: Dictionary = Content.INTRO[intro_idx]
	_set_art(String(p["art"]))
	_say(String(p["text"]))
	_pending_choices = []
	_choice("Continue", "intro_next")
	intro_idx += 1

func _begin_floor() -> void:
	mode = "room"
	room_queue = _gen_floor(floor_num)
	_next_room()

func _gen_floor(f: int) -> Array:
	var rooms := []
	if Content.KEEPER_BEATS.has(f):
		rooms.append({"kind": "keeper"})
	var pool: Array = Content.ROOMS.duplicate()
	pool.shuffle()
	# 1 combat guaranteed, then 3 mixed, then stairs
	rooms.append({"kind": "fight"})
	var added := 0
	for r in pool:
		var rd: Dictionary = r
		if String(rd["kind"]) == "fight":
			continue
		rooms.append(rd)
		added += 1
		if added >= 3:
			break
	# boss floors: boss replaces last room before stairs
	if f % 3 == 0:
		rooms.append({"kind": "boss"})
	rooms.append({"kind": "stairs"})
	return rooms

func _next_room() -> void:
	_refresh_status()
	if room_queue.is_empty():
		floor_num += 1
		if floor_num > 9:
			_win()
			return
		if floor_num - 1 > best_depth:
			best_depth = floor_num - 1
			_save_best()
		var after: Callable = _begin_floor
		if floor_num == 4:
			after = func(): _maybe_whisper("hollow_choir", _begin_floor)
		elif floor_num == 9:
			after = func(): _maybe_whisper("the_gloam", _begin_floor)
		_play_cutscene(Content.TIER_CUTSCENES[floor_num], after)
		return
	var r: Dictionary = room_queue.pop_front()
	var kind := String(r["kind"])
	match kind:
		"fight":
			_start_fight(_pick_monster())
		"boss":
			_start_boss(floor_num / 3 - 1)
		"keeper":
			_visit_keeper()
		"stairs":
			_set_art("intro2")
			_say(Content.STAIR_TEXT)
			_pending_choices = []
			_choice("Descend to floor %d" % (floor_num + 1), "stairs_go")
		_:
			_set_art(String(r["art"]))
			_say(String(r["text"]))
			_pending_choices = []
			for ch in r["choices"]:
				var cd: Dictionary = ch
				# hide unaffordable gamble/offer
				if String(cd["do"]).begins_with("gamble:") and gold < 15:
					continue
				if String(cd["do"]).begins_with("offer:") and gold < 20:
					continue
				_choice(String(cd["label"]), String(cd["do"]))

func _visit_keeper() -> void:
	keeper_met += 1
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
	_play_cutscene([kb], func(): _maybe_whisper(kid, _next_room))

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
	return cands[randi() % cands.size()]

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
			_next_room()
		"gloam_fight":
			_start_fight(Content.BOSSES[2], true)
		"gloam_kneel":
			_ending_stay()
		"win_go":
			_win()
		"cs_next":
			_advance_cutscene()
		"whisper_next":
			_cs_done.call()
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
			_next_room()
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
			_next_room()
	_refresh_status()

func _hurt(n: int, msg: String, cont := true) -> void:
	hp -= n
	if hp <= 0:
		_die()
		return
	_say(msg)
	if cont:
		_pending_choices = []
		_choice("Continue", "nothing")

# ---------------- combat ----------------
func _start_fight(m: Dictionary, is_boss := false) -> void:
	mode = "combat"
	enemy = m
	fight_is_boss = is_boss
	enemy_hp = int(m["hp"])
	guarding = false
	_set_art(String(m["art"]))
	_refresh_status()
	_combat_text(String(m["desc"]) + "\n\nA %s blocks your path!" % String(m["name"]))

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
	_play_cutscene(Content.END_STAY, _end_choices)

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
			var dmg := atk + randi_range(-1, 2)
			enemy_hp -= dmg
			log += "You strike for %d. " % dmg
		"c_heavy":
			if randf() < 0.65:
				var dmg2 := int(atk * 1.7) + randi_range(0, 2)
				enemy_hp -= dmg2
				log += "Your heavy blow lands for %d! " % dmg2
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
			else:
				log += "No potions left! "
	if enemy_hp <= 0:
		_win_fight(log)
		return
	# enemy turn
	var edmg := int(enemy["atk"]) + randi_range(-1, 2)
	if guarding:
		edmg = maxi(1, edmg / 2)
		guarding = false
		log += "You block the worst of it. "
	hp -= edmg
	log += "%s hits you for %d." % [String(enemy["name"]), edmg]
	if hp <= 0:
		_die()
		return
	_refresh_status()
	_combat_text(log)

func _win_fight(log: String) -> void:
	var gain: int
	if enemy["gold"] is Array:
		var g: Array = enemy["gold"]
		gain = randi_range(int(g[0]), int(g[1]))
	else:
		gain = int(enemy["gold"])
	gold += gain
	_refresh_status()
	var final := fight_is_boss and floor_num == 9
	fight_is_boss = false
	mode = "room"
	_set_art("corridor")
	_say(log + "\n\nThe %s collapses into dust and old coins. (+%d gold)" % [String(enemy["name"]), gain] + (_whisper_tail("bell_keeper") if String(enemy["name"]) == "Bell Ringer" else ""))
	_pending_choices = []
	_choice("Continue", "win_go" if final else "nothing")

func _die() -> void:
	if floor_num > best_depth:
		best_depth = floor_num
		_save_best()
	_refresh_status()
	if fight_is_boss:
		_unlock_ending("claimed")
		var bn := String(enemy["name"])
		var panels := []
		for p in Content.END_CLAIMED:
			var pd: Dictionary = p
			panels.append({"art": String(pd["art"]), "text": String(pd["text"]) % bn})
		_play_cutscene(panels, _end_choices)
	else:
		_unlock_ending("taken")
		var panels2 := [{"art": "death", "text": Content.END_TAKEN[0]["text"] % floor_num}, Content.END_TAKEN[1]]
		_play_cutscene(panels2, _end_choices)
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
		f.store_var({"best": best_depth, "endings": endings_found, "whispers": whispers_found})
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
		f.close()
