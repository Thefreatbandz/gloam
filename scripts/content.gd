extends RefCounted
# GLOAM — all writing, monsters, rooms. Horror rogue RPG.

const INTRO := [
	{"art": "title_hero", "text": "GLOAM.\n\nA horror rogue RPG.\n\nNine floors down. One way out.\n\nTap to begin your descent."},
	{"art": "war", "text": "The Ashen War took seven years from you.\n\nSeven years of gray snow that wasn't snow. Of mud that swallowed good men whole. Of orders you still hear at night, in a captain's voice, telling you to hold a line that no longer exists.\n\nYour armor — good Vesper steel, blessed by the chapel — came home dented, cracked, and dark with other men's blood. You stopped trying to clean it somewhere in year four. The stains had earned their place, same as you.\n\nYou told yourself, every winter: survive it, and go home. Just go home."},
	{"art": "homecoming", "text": "You limped into Vesper at dusk with your shield on your back and a medal in your pocket you never wanted.\n\nNo one met you at the road. No smoke from any chimney. No dogs barking.\n\nThe village was silent — had been, three nights now. Your armored boots were the only sound on the dirt, and even that felt like trespassing.\n\nWar taught you what silence means. Silence means everyone already knows something you don't."},
	{"art": "mira_room", "text": "Her room was exactly as she'd left it. Bed unslept. Carving knife on the pillow — the one you made her, the summer before you marched.\n\nHer blue scarf: gone from its hook.\n\nSix days gone. Six days, and no one in Vesper would meet your eyes when you asked where. Old Marta just crossed herself and shut her door. The blacksmith's boy whispered one word — 'chapel' — and ran.\n\nYou stood in that little empty room in your broken armor, and you understood: your sister went down into the dark alone, and the whole village let her."},
	{"art": "intro1", "text": "Three nights ago, the bells of Vesper stopped ringing.\n\nNo screams. No smoke. Just silence — and then the whispering from below the chapel floor. The priest is gone. The pews are overturned. And under the altar stones, behind the place where the bells' ropes hang slack and still, there is a stair.\n\nIt was not built by any mason of Vesper. The stones are older than the village. Older, the old ones say, than the war. Older than the kingdom.\n\nSix days ago, a twelve-year-old girl with a blue scarf pried those stones up with her little knife and climbed down alone.\n\nShe never came up."},
	{"art": "intro2", "text": "You pried up the chapel stones with gauntleted hands that have held a shield wall for seven years.\n\nThe stair goes down beyond your lantern light. Cold air breathes up out of it — old air, tasting of stone and deep water and something sweet underneath, like rot, like honey.\n\nYou checked your armor by feel: breastplate cracked at the left shoulder, vambrace dented, sword — your war sword, notched and true — at your hip. Not enough. Never enough. But it's what you have.\n\nYour lantern is lit. Your blade is sharp."},
	{"art": "vow", "text": "You are Corvin of Vesper. Knight. Brother.\n\nYou knelt in the chapel dirt and made a vow to whatever still listens: you will walk down into that dark, and you will not come up without her.\n\nNot for glory. Not for the village that let her go.\n\nFor Mira.\n\nGo find her."},
]

const WEAPONS := [
	{"id": "rusty", "name": "Rusty Blade", "atk": 0, "desc": "Your old blade. It has never once let you down, which is to say: it has never once been enough."},
	{"id": "soldier", "name": "Soldier's Sword", "atk": 2, "desc": "Your war blade, lost on the road home. The edge remembers the Ashen War. So do you."},
	{"id": "axe", "name": "Executioner's Axe", "atk": 4, "desc": "Heavy as a verdict. It drinks deep and asks nothing."},
	{"id": "gloambrand", "name": "Gloambrand", "atk": 6, "desc": "Forged from the dark itself. It hums your name when you sleep — which is never, down here."},
	{"id": "bellhammer", "name": "Bellhammer", "atk": 7, "effect": "stun", "desc": "A cracked chapel bell on a haft. When it rings, the dark flinches — 25% chance to stun foes before they strike."},
	{"id": "miraknife", "name": "Mira's Knife", "atk": 5, "effect": "heal_kill", "desc": "Her little carving knife, found in the chapel dirt. It remembers who you're fighting for — heals 3 HP on every kill."},
	{"id": "wardenteeth", "name": "Warden's Teeth", "atk": 8, "effect": "heavy_crit", "desc": "A flail strung with the Warden's own teeth. Heavy blows crave throats — 30% chance to crit for double damage."},
	{"id": "choirwire", "name": "Choirwire", "atk": 7, "effect": "first_blood", "desc": "A garrote of choir strings, still humming. The first strike of every fight sings — +6 damage on your opening blow."},
	{"id": "oathkeeper", "name": "Oathkeeper", "atk": 9, "effect": "vow", "desc": "Your knight's sword, broken at the Ashen War and reforged in the dark. When you bleed, it remembers your vow — +5 ATK below half HP."},
]

const ARMORS := [
	{"id": "rags", "name": "Torn Rags", "def": 0, "desc": "What you marched home in."},
	{"id": "leather", "name": "Leather Jerkin", "def": 1, "desc": "Scuffed, patched, smells of rain. Blocks 1 damage."},
	{"id": "chain", "name": "Chainmail", "def": 2, "desc": "Some dead soldier's second skin. Blocks 2 damage."},
	{"id": "gloamplate", "name": "Gloamplate", "def": 3, "desc": "Black plates that drink the lantern light. Blocks 3 damage."},
]

const CHARMS := [
	{"id": "none", "name": "No charm", "desc": ""},
	{"id": "ember", "name": "Ember Charm", "desc": "A coal that never cools. Burns enemies for 3 at the start of every fight."},
	{"id": "ward", "name": "Ward Charm", "desc": "A saint's finger-bone. Blocks the first hit of every fight."},
	{"id": "leech", "name": "Leech Charm", "desc": "A fat black leech in a locket. Heals you 2 whenever you kill."},
	{"id": "moth", "name": "Lantern Moth", "desc": "It eats darkness and shits gold. +50% gold from fights."},
]

const DEAD_NOTES := [
	"If you read this, don't go deeper. The bells were a warning. I didn't listen either.",
	"Tell my wife the cellar hid the money. Tell my son I was brave. One of those is true.",
	"I counted the doors. There are more doors than yesterday. Don't trust the count.",
	"The Keeper lies. The lantern isn't blue, it's just cold. Cold looks blue down here.",
	"Mira — if that's really your name, little one — I left you half my bread by the third stair. Run.",
	"I stopped being hungry on day nine. That's when I got scared.",
]

const CARVINGS := [
	"DAY 12 — THE WALLS BREATHE. DON'T SLEEP FACING THEM.",
	"Forgive me. I ate the dog first. Then I ate the silence.",
	"If the bells ring, it's already too late. Plug your ears and run UP.",
	"She walks here. The little one with the blue scarf. She hums.",
	"I was a king's man. Now I'm a wall's man. The wall pays better.",
	"Don't drink the water that sings. Don't follow the water that doesn't.",
]

const MIRA_TRACES := {
	2: {"title": "Mira's Scarf", "text": "A woolen scarf, blue as a summer sky, tied to a stone.\n\nMira's. She hated the dark.\n\nShe came down anyway."},
	5: {"title": "Mira's Carving", "text": "Knife-cuts in the wall, small and careful:\n\n'MIRA WAS HERE. DON'T FOLLOW.'\n\nThe cuts are old. The dust over them is not."},
	8: {"title": "Mira's Lantern", "text": "A lantern, cold and dark, set carefully on a ledge —\n\nas if she'd be back for it any moment.\n\nShe won't."},
}

const SEAL_TEXTS := [
	"Stone grinds on stone behind you. A door you never saw slides shut — dust sighs from its seams. There is no going back.",
	"A roar fills the passage. Rocks crash down where you just stood, sealing it in dust and dark. Forward is the only way now.",
	"The entrance shudders — then collapses in a avalanche of stone. Your lantern gutters in the dust. The dark has made its decision: forward.",
	"Iron shutters slam down behind you with a final, church-bell clang. Somewhere, deep in the walls, something turns a key.",
	"The floor tilts. The ceiling drops. By the time the dust clears, the way back is a wall of rubble. The Gloam does not believe in retreat.",
]

const BARKS := [
	["Fresh meat walks in.", "The dark sent you? How kind.", "Another lantern. Another moth.",
	 "Come closer. We don't bite much.", "Your heart is so loud, little knight."],
	["Your bones will sing with us.", "We remember being you.", "Kneel now. Save us the trouble.",
	 "The war made you hard. We'll make you soft.", "That armor won't save you. Nothing down here saves."],
	["IT WEARS YOUR SHAPE ALREADY.", "The deep is hungry, little lantern.", "Come. Be unmade.",
	 "WE TASTED YOUR SISTER'S COURAGE. IT WAS SWEET.", "Kneel, knight. The dark outranks you."],
]

const CORVIN_KILL := [
	"For Mira.", "Stay down.", "Seven years of war. You were nothing.",
	"That's one.", "For Vesper.", "The dark takes. I take back.",
]

const CORVIN_HURT := [
	"Ghh — not yet. Not yet.", "I've had worse. Had worse...", "Mira — hold on —",
	"Armor held. Barely.", "You hit like the Ashen War. I've survived that.",
]

const CORVIN_LOW := [
	"Not here. Not like this.", "I promised her. I PROMISED.",
	"One more. Just one more room.", "If I fall, she stays down here forever.",
]

const MONSTERS := [
	# tier 0 — floors 1-3
	{"name": "Gutter Wretch", "hp": 19, "atk": 5, "gold": [8, 14], "art": "beast", "tint": [0.65, 0.95, 0.65],
		"desc": "It was a person, once. Now it drags itself along the gutter-stones, begging with a mouth full of black teeth."},
	{"name": "Pale Crawler", "hp": 16, "atk": 6, "gold": [8, 14], "art": "mon_pale", "tint": [0.75, 0.85, 1.05],
		"desc": "It moves wrong — joints bending the other way. It has been waiting in the dark a long, long time."},
	{"name": "Bell Ringer", "hp": 22, "atk": 4, "gold": [10, 16], "art": "beast", "tint": [1.05, 0.9, 0.65],
		"desc": "It carries a cracked chapel bell and rings it as it comes. The sound makes your teeth ache."},
	# tier 1 — floors 4-6
	{"name": "Flayed Choir", "hp": 35, "atk": 7, "gold": [15, 24], "art": "beast", "tint": [1.05, 0.65, 0.65],
		"desc": "Three voices, one body, no skin. It sings the hymn they sang upstairs, before the silence."},
	{"name": "Marrow Hound", "hp": 32, "atk": 8, "gold": [15, 24], "art": "mon_marrow", "tint": [0.95, 0.9, 0.7],
		"desc": "It smells the marrow in your bones. It is patient. It does not need to hurry."},
	{"name": "Weeping Knight", "hp": 40, "atk": 6, "gold": [18, 28], "art": "mon_weeping", "tint": [0.7, 0.8, 0.95],
		"desc": "Armor rusted shut around something that still breathes. It weeps as it raises its sword. It cannot stop."},
	# tier 2 — floors 7-9
	{"name": "Gristle Titan", "hp": 54, "atk": 11, "gold": [25, 38], "art": "beast", "tint": [0.9, 0.7, 0.95],
		"desc": "The ceiling is too low for it, so it crawls. The stones crack under its knuckles."},
	{"name": "The Unraveled", "hp": 49, "atk": 12, "gold": [25, 38], "art": "mon_unraveled", "tint": [0.8, 0.78, 0.78],
		"desc": "It is coming apart and it wants you to hold it together. Its hands are so cold."},
	{"name": "Choir Master", "hp": 59, "atk": 10, "gold": [28, 42], "art": "mon_master", "tint": [0.8, 0.65, 1.05],
		"desc": "It conducts with a spine for a baton. The song it is building needs one more voice. Yours."},
	{"name": "The Unnamed", "hp": 70, "atk": 12, "gold": [32, 48], "art": "mon_unnamed",
		"desc": "It has no face because it gave its name away, and something else is wearing it now. It wants yours too."},
]

const BOSSES := [
	{"name": "WARDEN OF TEETH", "hp": 81, "atk": 9, "gold": 60, "art": "boss",
		"text": "The stair ends at a door made of teeth. It opens like a mouth.\n\nThe Warden unfolds from the dark — tall as the room, grinning with a hundred borrowed smiles.\n\n\"ANOTHER ONE,\" it says, with everyone's voice at once. \"COME. BE COUNTED.\""},
	{"name": "THE STARVED SAINT", "hp": 119, "atk": 13, "gold": 100, "art": "boss",
		"text": "The chapel below the chapel. Candles that burn black.\n\nThe Saint hangs above the altar, thin as a prayer, eyes like embers.\n\n\"I fasted,\" she whispers, \"so that I would never hunger again. Look how well it worked.\""},
	{"name": "GLOAM ITSELF", "hp": 169, "atk": 16, "gold": 200, "art": "boss",
		"text": "There is no floor nine. There is only the dark, and the dark has a face now.\n\nIt wears the village. It wears the chapel. It is wearing your shape, poorly.\n\n\"STAY,\" it says, in your voice. \"IT'S WARM DOWN HERE.\""},
]

const ROOMS := [
	# --- treasure ---
	{"art": "treasure", "kind": "treasure",
		"text": "A chest, banded in iron, half-buried in dust. The lock is already broken — someone left in a hurry. — someone was here before you, and they left in a hurry. Their bootprints lead away from the chest, not toward it. Whatever they found, it wasn't worth staying for.",
		"sting": "The gold is cold. Everything down here is cold — except the things that are watching.",
		"choices": [
			{"label": "Take the gold", "do": "gold:22"},
			{"label": "Leave it", "do": "nothing"},
		]},
	{"art": "corridor", "kind": "treasure",
		"text": "A dead delver slumps against the wall, pack still on. His lantern went out a long time ago. His coin purse didn't.g time ago. His journal's last page reads: 'Day 9. The whispering knows my name now. Going deeper anyway.' His sword is still sharp. He'd want you to take it.",
		"sting": "You take his purse. You leave his name. The dark keeps the rest.",
		"choices": [
			{"label": "Search the pack", "do": "pack"},
			{"label": "Say a prayer, move on", "do": "heal:4"},
		]},
	{"art": "room_armory", "kind": "treasure",
		"text": "An armory niche, miraculously untouched. A whetstone sits on the rack, still oiled.ed, as if someone was just using it. But the dust on the floor is undisturbed — no footprints. Whatever maintains this place doesn't walk.",
		"sting": "The whetstone sings against your blade. Somewhere, something answers.",
		"choices": [
			{"label": "Sharpen your blade (+1 ATK)", "do": "atk:1"},
			{"label": "Pry loose the fittings (gold)", "do": "gold:18"},
		]},
	# --- traps ---
	{"art": "trap", "kind": "trap",
		"text": "The floor clicks under your boot. Ahead, the tiles are wrong — too clean, too even. — too clean, too even, like teeth. Your war instincts count the seams. Pressure plates, probably. Or worse. Step light, knight.",
		"sting": "You don't look down. Looking down is how it starts.",
		"choices": [
			{"label": "Rush across", "do": "dmg:6"},
			{"label": "Pick your way through (slow, safe)", "do": "nothing"},
		]},
	{"art": "trap", "kind": "trap",
		"text": "Green vapor curls from a cracked pipe. It smells sweet, like rot and honey. The same sweetness from the chapel stair. You wrap your scarf — Mira's blue scarf, the one you carry now — over your nose and mouth. Breathe shallow. Keep moving.",
		"sting": "Sweet. Like rot and honey. Like the chapel incense, before.",
		"choices": [
			{"label": "Hold breath, push through", "do": "dmg:4"},
			{"label": "Wait for it to thin", "do": "nothing"},
		]},
	# --- shrine ---
	{"art": "shrine", "kind": "shrine",
		"text": "A shrine to something with too many names. The candles are still lit. Someone tends this place.nds them. Down here. In the dark. You leave an offering anyway — a copper coin, a whispered name. Some doors you don't want closed behind you.",
		"sting": "The candles lean toward you as you pass. Hungry, or hopeful. You can't tell.",
		"choices": [
			{"label": "Pray (heal 10)", "do": "heal:10"},
			{"label": "Offer 20 gold (full heal, +4 max HP)", "do": "offer:20"},
			{"label": "Leave", "do": "nothing"},
		]},
	{"art": "shrine", "kind": "shrine",
		"text": "A fountain of black water. It doesn't reflect your face — it reflects a face you almost remember. — it reflects a face you almost recognize. Younger. Unscarred. It mouths something at you: 'turn back.' You drink anyway. Knights don't turn back.",
		"sting": "Your almost-face ripples. It looks happier than you.",
		"choices": [
			{"label": "Drink (heal 8)", "do": "heal:8"},
			{"label": "Fill a vial (+1 potion)", "do": "potion:1"},
			{"label": "Leave", "do": "nothing"},
		]},
	# --- events ---
	{"art": "room_whisper", "kind": "event",
		"text": "The walls are whispering. If you press your ear to the stone, you can almost make out words.e out the words. Almost. That's the trap — the almost. You pull away before it finishes the sentence. Some things you don't want to understand.",
		"sting": "The walls know your name now. They practice it when you leave.",
		"choices": [
			{"label": "Listen", "do": "whispers"},
			{"label": "Keep walking", "do": "nothing"},
		]},
	{"art": "trap", "kind": "event",
		"text": "A rusted cage hangs from the ceiling. Inside, a prisoner — alive, somehow. \"Free me,\" he rasps, \"and I'll make it worth your while.\" — alive, somehow. 'Don't,' they croak. 'It's not locked to keep me in.' The cage door swings open at your touch. Empty. It was never about the cage.",
		"sting": "The cage sways empty behind you. You don't turn around.",
		"choices": [
			{"label": "Break the lock", "do": "cage"},
			{"label": "Leave him", "do": "nothing"},
		]},
	{"art": "shrine", "kind": "event",
		"text": "A tall mirror, filmed with dust. Your reflection is already looking at you before you arrive.e you look at it. It smiles with your mouth. You smash it with your pommel before it can speak. The shards whisper as they fall.",
		"sting": "Your reflection stays a moment too long after you look away.",
		"choices": [
			{"label": "Gaze into it (+2 ATK, -6 HP)", "do": "mirror"},
			{"label": "Smash it", "do": "gold:10"},
			{"label": "Walk away", "do": "nothing"},
		]},
	{"art": "room_gambler", "kind": "event",
		"text": "A shade in a gambler's coat shuffles bone dice. \"Double or nothing, delver. Feeling blessed?\" 'Play me,' it says. 'Winner takes a memory.' You think of Mira's laugh, and you keep your memories exactly where they are. Some games you walk away from.",
		"sting": "The dice keep rolling after you leave. You can hear them. Don't go back.",
		"choices": [
			{"label": "Bet 15 gold", "do": "gamble:15"},
			{"label": "Refuse", "do": "nothing"},
		]},
	{"art": "lost_soul", "kind": "lost",
		"text": "A villager — from Vesper, by the cut of their coat — clutching a dying lantern.\n\n'Please. I can't find the way up. I can't find the way anywhere.'",
		"sting": "Their lantern follows you with its dying eye until the dark takes it.",
		"choices": [
			{"label": "Guide them to the stairs", "do": "soul_guide"},
			{"label": "Rob them (30 gold)", "do": "soul_rob"},
			{"label": "Leave them", "do": "soul_leave"},
		]},
	{"art": "trapped", "kind": "trapped",
		"text": "A fallen beam. A hand reaching out from under it, still moving.\n\n'Help — please — I can hear it coming back —'",
		"sting": "The beam settles behind you with a sound like a sigh.",
		"choices": [
			{"label": "Free them", "do": "trap_free"},
			{"label": "Leave them", "do": "trap_leave"},
		]},
	{"art": "dead_note", "kind": "dead",
		"text": "A skeleton in rotted clothes, slumped against the wall. A folded note is clutched in its hand.\n\nSomeone's whole life, down to one page.",
		"sting": "You fold the note into your pack. The dark is full of last words.",
		"choices": [
			{"label": "Read the note", "do": "dead_read"},
			{"label": "Take their supplies", "do": "dead_loot"},
			{"label": "Say a prayer", "do": "dead_pray"},
		]},
	{"art": "carving", "kind": "carving",
		"text": "The wall is covered in scratches — tally marks, warnings, names worn smooth by desperate fingers.\n\nSomeone was here. Someone is always here.",
		"sting": "You add nothing. Some walls are already full.",
		"choices": [
			{"label": "Read the scratches", "do": "carve_read"},
			{"label": "Move on", "do": "nothing"},
		]},
]

const STAIR_TEXT := "A stair spirals down into deeper dark. The air gets colder. The whispering gets clearer."
const FLOOR_NAMES := ["", "The Throat", "The Gullet", "The Warden's Door", "The Hollow Choir", "The Drowned Chapel", "The Saint's Door", "The Marrow Deep", "The Unraveling", "ITSELF"]

# cutscene panels: {"art":..., "text":...}
const BOSS_CUTSCENES := [
	[
		{"art": "boss1_origin", "text": "Before the dark, he was the Warden. For forty years he counted every prisoner, every morning, by name.\n\nWhen the Gloam swallowed the prison, it kept him — because someone has to count.\n\nNow he counts teeth. He has been short for a very, very long time."},
		{"art": "boss1_approach", "text": "The corridor narrows. The walls here aren't stone — they're teeth, set in humming rows.\n\nAhead, a door grins at you."},
		{"art": "boss", "text": "The stair ends at a door made of teeth. It opens like a mouth.\n\nThe Warden unfolds from the dark — tall as the room, grinning with a hundred borrowed smiles.\n\n\"ANOTHER ONE,\" it says, with everyone's voice at once. \"COME. BE COUNTED.\""},
		{"art": "boss", "text": "\"COME. BE COUNTED.\"\n\nThe Warden lunges — teeth first."},
	],
	[
		{"art": "shrine", "text": "She was Sister Anselm. She fasted forty days to purify her soul, and on the fortieth day she died kneeling.\n\nThe Gloam answered her prayer the way it answers everything: literally.\n\nShe will never hunger again. She is hunger now."},
		{"art": "shrine", "text": "You smell wax and stagnant water.\n\nA drowned chapel opens before you — rows of black candles burning without melting. Something thin hangs above the altar.\n\nIt is breathing."},
		{"art": "boss", "text": "The chapel below the chapel. Candles that burn black.\n\nThe Saint hangs above the altar, thin as a prayer, eyes like embers.\n\n\"I fasted,\" she whispers, \"so that I would never hunger again. Look how well it worked.\""},
		{"art": "boss", "text": "\"Look how well it worked.\"\n\nThe Saint opens her eyes. Every candle goes out at once."},
	],
	[
		{"art": "boss3_origin", "text": "Before Vesper, before the chapel, there was the dark under the hill.\n\nThe Ashen War fed it — seven years of dead. Corvin's war. Every delver who never came back fed it.\n\nIt learned faces from the corpses. Now it wears them, trying to remember what it felt like to be held."},
		{"art": "corridor", "text": "The last corridor. Your lantern light doesn't reach the walls anymore — or there are no walls.\n\nThe dark presses close. Curious.\n\nIt is trying on your shape."},
		{"art": "boss", "text": "There is no floor nine. There is only the dark, and the dark has a face now.\n\nIt wears the village. It wears the chapel. It is wearing your shape, poorly.\n\n\"STAY,\" it says, in your voice. \"IT'S WARM DOWN HERE.\""},
		{"art": "boss", "text": "\"IT'S WARM DOWN HERE.\"\n\nThe dark rushes forward — wearing your face."},
	],
]

const TIER_CUTSCENES := {
	1: [{"art": "floor1", "text": "FLOOR ONE — THE THROAT\n\nThe stair lets you out into a tunnel that breathes. In. Out. In. Out.\n\nDon't think about it."}, {"art": "floor1", "text": "Your armor scrapes the narrowing walls. The Throat swallows lanterns whole — yours gutters, then burns on, defiant."}, {"art": "floor1", "text": "They say the Throat was a mine, once. The miners dug too deep, too fast — chasing a vein of something that glowed. The company sealed the shafts. The company is gone now. The shafts are not."}],
	2: [{"art": "floor2", "text": "FLOOR TWO — THE GULLET\n\nWater drips from somewhere overhead. The dark down here is thicker — it sticks to your lantern light and won't let go."}, {"art": "floor2", "text": "Something small scuttles just beyond the light. You raise your sword. Nothing there. The Gullet likes its jokes."}, {"art": "floor2", "text": "The Gullet drowned in the year of the black rain. Thirty souls, the chapel records say — though the records stop mid-sentence, as if the writer was interrupted. You can guess by what."}],
	3: [{"art": "floor3", "text": "FLOOR THREE — THE WARDEN'S DOOR\n\nTeeth in the walls now. The humming is louder. Something big waits at the end of this floor — you can feel it in your molars."}, {"art": "floor3", "text": "Your war instincts scream: choke point ahead. You check your dented shield twice. Whatever the Warden is, it bleeds."}, {"art": "floor3", "text": "The Warden was a man, once. A jailer who loved his work too much. When the dark came up through the floor, he didn't run. He applied for the position. He's still on duty."}],
	4: [{"art": "deep4", "text": "FLOOR FOUR — THE HOLLOW CHOIR\n\nThe singing starts here. Not voices — the stones themselves, humming the hymn from the chapel upstairs.\n\nYour lantern burns lower, as if afraid."}, {"art": "deep4", "text": "The hymn gets under your armor, under your skin. You hum along before you catch yourself — and stop, cold."}, {"art": "deep4", "text": "The Hollow Choir sings the hymn from your childhood — every verse, in order, in your mother's voice. You never told anyone your mother sang it. The stones know anyway."}],
	5: [{"art": "floor5", "text": "FLOOR FIVE — THE DROWNED CHAPEL\n\nYour boots splash. The chapel down here drowned a long time ago.\n\nBut the candles never went out."}, {"art": "floor5", "text": "A drowned pew floats past, slow as a coffin. You think of Mira's little knife, and grip your sword tighter."}, {"art": "floor5", "text": "The Drowned Chapel held weddings, once. The candles never went out because the bride's family paid for eternal flame. The family is dust. The flame kept its contract."}],
	6: [{"art": "floor6", "text": "FLOOR SIX — THE SAINT'S DOOR\n\nStatues line the way, all weeping, all facing away.\n\nAt the end of this floor, she hangs and waits."}, {"art": "floor6", "text": "One statue's face is yours. You don't look twice. Knights learn when not to look."}, {"art": "floor6", "text": "The Saint was walled up alive for heresy — she claimed the dark below was holy. The weeping statues are the monks who sealed her in. They've been apologizing for three hundred years."}],
	7: [{"art": "trap", "text": "FLOOR SEVEN — THE MARROW DEEP\n\nThe dark stops pretending to be stone. Everything down here is sharp, or hungry, or both.\n\nThe whispering knows your name now."}, {"art": "trap", "text": "Your lantern light bends here, wrong. The Marrow Deep doesn't want to be seen clearly. You see it anyway."}, {"art": "trap", "text": "The Marrow Deep is where the Gloam keeps what it eats. The bones here are old — older than Vesper, older than the kingdom. Some of them are not human. Most of them are."}],
	8: [{"art": "corridor", "text": "FLOOR EIGHT — THE UNRAVELING\n\nThe walls are bone now, fused and yellowed. The whispering is clear enough to understand.\n\nYou wish it wasn't."}, {"art": "corridor", "text": "The bone walls pulse, faintly, like a heart. You put your gauntleted hand to them. Still warm. Still wrong."}, {"art": "corridor", "text": "The Unraveling is where the dark stops pretending to be stone and shows you what it really is: a wound. The whispering here isn't the Gloam talking. It's the world, bleeding."}],
	9: [{"art": "floor9", "text": "FLOOR NINE — ITSELF\n\nThere are no more stairs after this. No more doors.\n\nWhatever the Gloam is, it's done hiding. End it."}, {"art": "floor9", "text": "No more stairs. No more doors. Just you, your broken armor, and ITSELF. For Mira. End it."}, {"art": "floor9", "text": "ITSELF has been waiting since before the first bell rang in Vesper. It remembers when your ancestors were fish. It has been patient. It is done being patient."}],
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

# 12 collectible lore fragments: {id, title, text}
const WHISPERS := [
	{"id": "first_bell", "title": "The First Bell",
		"text": "Vesper was a silver-mining village, until the ninth shaft broke into a hollow that breathed.\n\nThe company sealed the shaft. The village kept the silver.\n\nThe hollow kept the village."},
	{"id": "the_throat", "title": "The Throat",
		"text": "The mine didn't dig down. It dug in — into the throat of something sleeping.\n\nEvery scream down here echoes twice: once off the stone, once off the teeth."},
	{"id": "bell_keeper", "title": "The Bell-Keeper",
		"text": "The chapel bell was rung every hour, to remind the dark it was being watched.\n\nWhen the dark took the keeper's hands, the bells stopped.\n\nHe still rings. He doesn't know what for."},
	{"id": "hollow_choir", "title": "The Hollow Choir",
		"text": "The stones sing because the dark memorized the hymn from the buried dead.\n\nIt sings to itself the way you hum while you work.\n\nYou are the work."},
	{"id": "the_warden", "title": "The Warden",
		"text": "The Warden counts teeth because every taken soul leaves one at the door.\n\nIt is not cruel. It is only thorough.\n\nBe counted."},
	{"id": "starved_saint", "title": "The Starved Saint",
		"text": "Saint Oda fasted for forty days to become too holy to be eaten.\n\nOn the forty-first day, hunger ate her first.\n\nShe has been fasting ever since."},
	{"id": "keeper1", "title": "The Keeper, I",
		"text": "The Keeper was the first delver, years before you.\n\nThey walked all nine floors, and stood where you will stand."},
	{"id": "keeper2", "title": "The Keeper, II",
		"text": "At the end, the Keeper refused to kneel — and refused to leave.\n\nThe dark could neither keep them nor release them.\n\nSo they tend the blue lanterns, in between."},
	{"id": "keeper3", "title": "The Keeper, III",
		"text": "The blue flame is the last hour of every bell ever rung in Vesper, saved and burning.\n\nAs long as one burns, the dark cannot learn your name."},
	{"id": "gambler", "title": "The Gambler's Debt",
		"text": "The shade bet his soul double-or-nothing on one last roll. He lost.\n\nHe's still rolling.\n\nHe'll stake yours too, if you let him."},
	{"id": "mirror", "title": "The Mirror",
		"text": "The dark wears your shape because it has no shape of its own.\n\nIt is learning 'person' the way a child learns a word —\n\nby repeating it wrong, at you."},
	{"id": "the_gloam", "title": "The Gloam",
		"text": "The Gloam isn't below the world.\n\nThe world is a scab over the Gloam —\n\nand Vesper picked at it until it bled."},
]
