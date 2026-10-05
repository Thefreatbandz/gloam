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

# cutscene panels: {"art":..., "text":...}
const BOSS_CUTSCENES := [
	[
		{"art": "boss1_approach", "text": "The corridor narrows. The walls here aren't stone — they're teeth, set in humming rows.\n\nAhead, a door grins at you."},
		{"art": "boss", "text": "The stair ends at a door made of teeth. It opens like a mouth.\n\nThe Warden unfolds from the dark — tall as the room, grinning with a hundred borrowed smiles.\n\n\"ANOTHER ONE,\" it says, with everyone's voice at once. \"COME. BE COUNTED.\""},
		{"art": "boss", "text": "\"COME. BE COUNTED.\"\n\nThe Warden lunges — teeth first."},
	],
	[
		{"art": "shrine", "text": "You smell wax and stagnant water.\n\nA drowned chapel opens before you — rows of black candles burning without melting. Something thin hangs above the altar.\n\nIt is breathing."},
		{"art": "boss", "text": "The chapel below the chapel. Candles that burn black.\n\nThe Saint hangs above the altar, thin as a prayer, eyes like embers.\n\n\"I fasted,\" she whispers, \"so that I would never hunger again. Look how well it worked.\""},
		{"art": "boss", "text": "\"Look how well it worked.\"\n\nThe Saint opens her eyes. Every candle goes out at once."},
	],
	[
		{"art": "corridor", "text": "The last corridor. Your lantern light doesn't reach the walls anymore — or there are no walls.\n\nThe dark presses close. Curious.\n\nIt is trying on your shape."},
		{"art": "boss", "text": "There is no floor nine. There is only the dark, and the dark has a face now.\n\nIt wears the village. It wears the chapel. It is wearing your shape, poorly.\n\n\"STAY,\" it says, in your voice. \"IT'S WARM DOWN HERE.\""},
		{"art": "boss", "text": "\"IT'S WARM DOWN HERE.\"\n\nThe dark rushes forward — wearing your face."},
	],
]

const TIER_CUTSCENES := {
	1: [{"art": "floor1", "text": "FLOOR ONE — THE THROAT\n\nThe stair lets you out into a tunnel that breathes. In. Out. In. Out.\n\nDon't think about it."}],
	2: [{"art": "floor2", "text": "FLOOR TWO — THE GULLET\n\nWater drips from somewhere overhead. The dark down here is thicker — it sticks to your lantern light and won't let go."}],
	3: [{"art": "floor3", "text": "FLOOR THREE — THE WARDEN'S DOOR\n\nTeeth in the walls now. The humming is louder. Something big waits at the end of this floor — you can feel it in your molars."}],
	4: [{"art": "deep4", "text": "FLOOR FOUR — THE HOLLOW CHOIR\n\nThe singing starts here. Not voices — the stones themselves, humming the hymn from the chapel upstairs.\n\nYour lantern burns lower, as if afraid."}],
	5: [{"art": "floor5", "text": "FLOOR FIVE — THE DROWNED CHAPEL\n\nYour boots splash. The chapel down here drowned a long time ago.\n\nBut the candles never went out."}],
	6: [{"art": "floor6", "text": "FLOOR SIX — THE SAINT'S DOOR\n\nStatues line the way, all weeping, all facing away.\n\nAt the end of this floor, she hangs and waits."}],
	7: [{"art": "trap", "text": "FLOOR SEVEN — THE MARROW DEEP\n\nThe dark stops pretending to be stone. Everything down here is sharp, or hungry, or both.\n\nThe whispering knows your name now."}],
	8: [{"art": "corridor", "text": "FLOOR EIGHT — THE UNRAVELING\n\nThe walls are bone now, fused and yellowed. The whispering is clear enough to understand.\n\nYou wish it wasn't."}],
	9: [{"art": "floor9", "text": "FLOOR NINE — ITSELF\n\nThere are no more stairs after this. No more doors.\n\nWhatever the Gloam is, it's done hiding. End it."}],
}

# the Keeper appears on floors 2, 5, 8: {"art","text","gift"} gift applied on visit
const KEEPER_BEATS := {
	2: {"art": "keeper", "gift": "potion:1",
		"text": "A figure tends a lantern that burns blue. It does not turn around.\n\n\"Delver,\" it says. \"The dark keeps what it catches. Keep moving — and don't listen to the walls.\"\n\nIt presses a cold vial into your hand. (+1 potion)"},
	5: {"art": "keeper", "gift": "potion:1+heal:6",
		"text": "\"You're still alive,\" the Keeper says, surprised. \"Good. It likes the stubborn ones less.\"\n\nWarmth spreads through you, and a vial. (+1 potion, +6 HP)"},
	8: {"art": "keeper", "gift": "potion:2+atk:2",
		"text": "\"This is as far as I go,\" the Keeper says. \"What's below never had a name, and I won't give it one.\"\n\nIt presses its spare lantern into your hands — and is gone. (+2 potions, +2 ATK)"},
}
const DEATH_TEXT := "The dark takes you the way it takes everyone — gently, then all at once.\n\nYour lantern gutters out. Somewhere above, a bell rings once, and stops."
const WIN_TEXT := "It lets go.\n\nYou climb with the last of your strength, up through the teeth-door, up through the chapels, up into grey morning light.\n\nVesper is still silent. But the whispering has stopped.\n\nYou walk out of the village and do not look back."

# endings: %d = gold, %s = boss name
const END_DAYBREAK := [
	{"art": "escape", "text": "It lets go.\n\nYou climb with the last of your strength — up through the teeth-door, up through the chapels, up into grey morning light."},
	{"art": "intro1", "text": "Vesper is still silent. But the whispering has stopped.\n\nYou walk out of the village and do not look back."},
	{"art": "title", "text": "DAYBREAK — escaped.\n\nGold carried out: %d\n\nThe dark will wait for the next delver."},
]
const END_STAY := [
	{"art": "boss", "text": "You kneel.\n\nThe dark rushes forward — not unkindly. It has been so lonely, wearing all those faces."},
	{"art": "death", "text": "The teeth-door closes behind you.\n\nAbove, the bells of Vesper ring once — and then never again.\n\nSTAY — you are home now."},
]
const END_LANTERN := [
	{"art": "keeper", "text": "The blue lantern flares. The Keeper steps out of the dark between heartbeats.\n\n\"You kept moving,\" it says. \"Few do. Come — there is another way up.\""},
	{"art": "escape", "text": "It takes your hand — cold, steady — and walks you up through a dark you never saw. No teeth. No singing.\n\nJust the blue light, going up."},
	{"art": "title", "text": "THE BLUE LANTERN — escaped.\n\nYour pockets are empty. Your lantern burns blue now.\n\nThe gold stayed below. So did the whispering."},
]
const END_GILDED := [
	{"art": "escape", "text": "It lets go — or it lets you think it did.\n\nYou climb out heavy with gold, %d coins that whisper when the room is quiet."},
	{"art": "intro1", "text": "Vesper is still silent. At night, your gold sings the hymn from downstairs.\n\nYou tell yourself it's just the wind."},
	{"art": "title", "text": "GILDED — escaped, rich, and never quite warm again.\n\nGold carried out: %d"},
]
const END_CLAIMED := [
	{"art": "boss", "text": "%s does not let go.\n\nIt keeps what it catches."},
	{"art": "death", "text": "The dark takes you the way it takes everyone — gently, then all at once.\n\nCLAIMED — the %s wears your face now."},
]
const END_TAKEN := [
	{"art": "death", "text": "The dark takes you the way it takes everyone — gently, then all at once.\n\nYour lantern gutters out. Somewhere above, a bell rings once, and stops.\n\nYou reached floor %d."},
	{"art": "title", "text": "Somewhere above, another lantern is lit.\n\nAnother delver lifts the chapel stones.\n\nTAKEN — the dark is patient."},
]
const GLOAM_OFFER := "The dark coils around you, almost gentle.\n\n\"KNEEL,\" it says, in your voice, \"AND STAY. IT'S WARM DOWN HERE.\"\n\nYour blade is in your hand. Your knees are already bending."
