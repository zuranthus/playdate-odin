package main

import pd "../playdate"
import "core:math/rand"

WIDTH, HEIGHT :: 400, 240
SIZE :: 40
SPEED :: 5

wall_sound: ^pd.PD_Synth
corner_sound: ^pd.PD_Synth

x, y: f32
dx, dy: i32 = 1, 1

onInit :: proc() {
	x = rand.float32() * (WIDTH - SIZE)
	y = rand.float32() * (HEIGHT - SIZE)
	pd.graphics_fill_rect(0, 0, WIDTH, HEIGHT, 0)

	wall_sound = make_synth(pd.Sound_Waveform.Sine, 0.02, 0.05, 0.0, 0.0)
	corner_sound = make_synth(pd.Sound_Waveform.Sawtooth, 0.02, 0.05, 0.5, 0.2)
}

onUpdate :: proc() -> i32 {
	// Erase at the old position
	drawSquare(0)

	x += f32(dx * SPEED)
	y += f32(dy * SPEED)
	dir_changes := 0
	if x <= 0 {
		dx = 1
		x = -x
		dir_changes += 1
	} else if x >= WIDTH - SIZE {
		dx = -1
		x = 2 * (WIDTH - SIZE) - x
		dir_changes += 1
	}
	if y <= 0 {
		dy = 1
		y = -y
		dir_changes += 1
	} else if y >= HEIGHT - SIZE {
		dy = -1
		y = 2 * (HEIGHT - SIZE) - y
		dir_changes += 1
	}
	if dir_changes == 2 {
		// hit a corner!
		pd.sound_synth_play_midi_note(corner_sound, 86, 1.0, 0.1, 0.0)
	} else if dir_changes == 1 {
		// hit a wall
		pd.sound_synth_play_midi_note(wall_sound, 48, 1.0, 0.25, 0.0)
	}

	// Draw at the new position
	drawSquare(1)

	pd.system_draw_fps(0, 0)
	return 1
}

drawSquare :: proc(color: int) {
	pd.graphics_fill_rect(i32(x), i32(y), SIZE, SIZE, uintptr(color))
}

make_synth :: proc(waveform: pd.Sound_Waveform, attack, decay, sustain, release: f32) -> ^pd.PD_Synth {
	synth := pd.sound_synth_new_synth()
	pd.sound_synth_set_waveform(synth, waveform)
	pd.sound_synth_set_attack_time(synth, attack)
	pd.sound_synth_set_decay_time(synth, decay)
	pd.sound_synth_set_sustain_level(synth, sustain)
	pd.sound_synth_set_release_time(synth, release)
	return synth
}
