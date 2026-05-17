package main

import pd "../playdate"
import "core:math/rand"

WIDTH, HEIGHT :: 400, 240
SIZE :: 40
SPEED :: 5

x, y: f32
dx, dy: i32 = 1, 1

onInit :: proc() {
	x = rand.float32() * (WIDTH - SIZE)
	y = rand.float32() * (HEIGHT - SIZE)
	pd.graphics_fill_rect(0, 0, WIDTH, HEIGHT, 0)
}

onUpdate :: proc() -> i32 {
	drawSquare(0)

	x += f32(dx * SPEED)
	y += f32(dy * SPEED)
	if x < 0 {
		dx = 1
		x = -x
	} else if x > WIDTH - SIZE {
		dx = -1
		x = 2 * (WIDTH - SIZE) - x
	}
	if y < 0 {
		dy = 1
		y = -y
	} else if y > HEIGHT - SIZE {
		dy = -1
		y = 2 * (HEIGHT - SIZE) - y
	}

	drawSquare(1)

	pd.system_draw_fps(0, 0)
	return 1
}

drawSquare :: proc(color: int) {
	pd.graphics_fill_rect(i32(x), i32(y), SIZE, SIZE, uintptr(color))
}
