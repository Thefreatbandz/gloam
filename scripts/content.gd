extends RefCounted
# GLOAM — all writing, monsters, rooms. Horror rogue RPG.

const INTRO := [
	{"art": "title", "text": "GLOAM.\n\nA horror rogue RPG.\n\nNine floors down. One way out.\n\nTap to begin your descent."},
	{"art": "intro1", "text": "Three nights ago, the bells of Vesper stopped ringing.\n\nNo screams. No smoke. Just silence — and then the whispering from below the chapel floor."},
	{"art": "intro2", "text": "You pried up the chapel stones and found the stair going down.\n\nIt does not end. It only gets worse.\n\nYour lantern is lit. Your blade is sharp. Go."},
]

const MONSTERS := [
	# tier 0 — floors 1-3
	{"name": "Gutter Wretch", "hp": 14, "atk": 4, "gold": [8, 14], "art": "beast",
		"desc": "It was a person, once. Now it drags itself along the gutter-stones, begging with a mouth full of black teeth."},
	{"name": "Pale Crawler", "hp": 12, "atk": 5, "gold": [8, 14], "art": "beast",
		"desc": "It moves wrong — joints bending the other way. It has been waiting in the dark a long, long time."},
	{"name": "Bell Ringer", "hp": 16, "atk": 3, "gold": [10, 16], "art": "beast",
		"desc": "It carries a cracked chapel bell and rings it as it comes. The sound makes your teeth ache."},
	# tier 1 — floors 4-6
	{"name": "Flayed Choir", "hp": 26, "atk": 6, "gold": [15, 24], "art": "beast",
		"desc": "Three voices, one body, no skin. It sings the hymn they sang upstairs, before the silence."},
	{"name": "Marrow Hound", "hp": 24, "atk": 7, "gold": [15, 24], "art": "beast",
		"desc": "It smells the marrow in your bones. It is patient. It does not need to hurry."},
	{"name": "Weeping Knight", "hp": 30, "atk": 5, "gold": [18, 28], "art": "beast",
		"desc": "Armor rusted shut around something that still breathes. It weeps as it raises its sword. It cannot stop."},
	# tier 2 — floors 7-9
	{"name": "Gristle Titan", "hp": 40, "atk": 9, "gold": [25, 38], "art": "beast",
		"desc": "The ceiling is too low for it, so it crawls. The stones crack under its knuckles."},
	{"name": "The Unraveled", "hp": 36, "atk": 10, "gold": [25, 38], "art": "beast",
		"desc": "It is coming apart and it wants you to hold it together. Its hands are so cold."},
	{"name": "Choir Master", "hp": 44, "atk": 8, "gold": [28, 42], "art": "beast",
		"desc": "It conducts with a spine for a baton. The song it is building needs one more voice. Yours."},
]

const BOSSES := [
	{"name": "WARDEN OF TEETH", "hp": 65, "atk": 8, "gold": 60, "art": "boss",
		"text": "The stair ends at a door made of teeth. It opens like a mouth.\n\nThe Warden unfolds from the dark — tall as the room, grinning with a hundred borrowed smiles.\n\n\"ANOTHER ONE,\" it says, with everyone's voice at once. \"COME. BE COUNTED.\""},
	{"name": "THE STARVED SAINT", "hp": 95, "atk": 11, "gold": 100, "art": "boss",
		"text": "The chapel below the chapel. Candles that burn black.\n\nThe Saint hangs above the altar, thin as a prayer, eyes like embers.\n\n\"I fasted,\" she whispers, \"so that I would never hunger again. Look how well it worked.\""},
	{"name": "GLOAM ITSELF", "hp": 135, "atk": 14, "gold": 200, "art": "boss",
		"text": "There is no floor nine. There is only the dark, and the dark has a face now.\n\nIt wears the village. It wears the chapel. It is wearing your shape, poorly.\n\n\"STAY,\" it says, in your voice. \"IT'S WARM DOWN HERE.\""},
]

const ROOMS := [
	# --- treasure ---
	{"art": "treasure", "kind": "treasure",
		"text": "A chest, banded in iron, half-buried in dust. The lock is already broken — someone left in a hurry.",
		"choices": [
			{"label": "Take the gold", "do": "gold:22"},
			{"label": "Leave it", "do": "nothing"},
		]},
	{"art": "corridor", "kind": "treasure",
		"text": "A dead delver slumps against the wall, pack still on. His lantern went out a long time ago. His coin purse didn't.",
		"choices": [
			{"label": "Search the pack", "do": "pack"},
			{"label": "Say a prayer, move on", "do": "heal:4"},
		]},
	{"art": "corridor", "kind": "treasure",
		"text": "An armory niche, miraculously untouched. A whetstone sits on the rack, still oiled.",
		"choices": [
			{"label": "Sharpen your blade (+1 ATK)", "do": "atk:1"},
			{"label": "Pry loose the fittings (gold)", "do": "gold:18"},
		]},
	# --- traps ---
	{"art": "trap", "kind": "trap",
		"text": "The floor clicks under your boot. Ahead, the tiles are wrong — too clean, too even.",
		"choices": [
			{"label": "Rush across", "do": "dmg:6"},
			{"label": "Pick your way through (slow, safe)", "do": "nothing"},
		]},
	{"art": "trap", "kind": "trap",
		"text": "Green vapor curls from a cracked pipe. It smells sweet, like rot and honey.",
		"choices": [
			{"label": "Hold breath, push through", "do": "dmg:4"},
			{"label": "Wait for it to thin", "do": "nothing"},
		]},
	# --- shrine ---
	{"art": "shrine", "kind": "shrine",
		"text": "A shrine to something with too many names. The candles are still lit. Someone tends this place.",
		"choices": [
			{"label": "Pray (heal 10)", "do": "heal:10"},
			{"label": "Offer 20 gold (full heal, +4 max HP)", "do": "offer:20"},
			{"label": "Leave", "do": "nothing"},
		]},
	{"art": "shrine", "kind": "shrine",
		"text": "A fountain of black water. It doesn't reflect your face — it reflects a face you almost remember.",
		"choices": [
			{"label": "Drink (heal 8)", "do": "heal:8"},
			{"label": "Fill a vial (+1 potion)", "do": "potion:1"},
			{"label": "Leave", "do": "nothing"},
		]},
	# --- events ---
	{"art": "corridor", "kind": "event",
		"text": "The walls are whispering. If you press your ear to the stone, you can almost make out words.",
		"choices": [
			{"label": "Listen", "do": "whispers"},
			{"label": "Keep walking", "do": "nothing"},
		]},
	{"art": "trap", "kind": "event",
		"text": "A rusted cage hangs from the ceiling. Inside, a prisoner — alive, somehow. \"Free me,\" he rasps, \"and I'll make it worth your while.\"",
		"choices": [
			{"label": "Break the lock", "do": "cage"},
			{"label": "Leave him", "do": "nothing"},
		]},
	{"art": "shrine", "kind": "event",
		"text": "A tall mirror, filmed with dust. Your reflection is already looking at you before you arrive.",
		"choices": [
			{"label": "Gaze into it (+2 ATK, -6 HP)", "do": "mirror"},
			{"label": "Smash it", "do": "gold:10"},
			{"label": "Walk away", "do": "nothing"},
		]},
	{"art": "corridor", "kind": "event",
		"text": "A shade in a gambler's coat shuffles bone dice. \"Double or nothing, delver. Feeling blessed?\"",
		"choices": [
			{"label": "Bet 15 gold", "do": "gamble:15"},
			{"label": "Refuse", "do": "nothing"},
		]},
]

const STAIR_TEXT := "A stair spirals down into deeper dark. The air gets colder. The whispering gets clearer."
const FLOOR_NAMES := ["", "The Throat", "The Gullet", "The Warden's Door", "The Hollow Choir", "The Drowned Chapel", "The Saint's Door", "The Marrow Deep", "The Unraveling", "ITSELF"]
const DEATH_TEXT := "The dark takes you the way it takes everyone — gently, then all at once.\n\nYour lantern gutters out. Somewhere above, a bell rings once, and stops."
const WIN_TEXT := "It lets go.\n\nYou climb with the last of your strength, up through the teeth-door, up through the chapels, up into grey morning light.\n\nVesper is still silent. But the whispering has stopped.\n\nYou walk out of the village and do not look back."
