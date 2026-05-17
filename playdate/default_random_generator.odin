package playdate

import "base:intrinsics"
import "base:runtime"

// xoshiro128++ — 32-bit-native PRNG by Blackman & Vigna (https://prng.di.unimi.it/).
// Chosen over Odin's stdlib PCG64 / xoshiro256 because it uses only 32-bit ops,
// which avoids 64-bit emulation cost on the Playdate's 32-bit Cortex-M7.
// Time-seeded convenience: seeds the default state from pd.system.getCurrentTimeMilliseconds().
@(require_results)
default_random_generator :: proc "contextless" (pd: ^API) -> runtime.Random_Generator {
	return random_generator(pd.system.getCurrentTimeMilliseconds())
}

// Explicitly-seeded constructor. Use this for deterministic randomness (replays,
// tests, seeded procgen). Any u32 seed is valid, including 0.
@(require_results)
random_generator :: proc "contextless" (seed: u32) -> runtime.Random_Generator {
	seed_xoshiro128(&_default_state, seed)
	return runtime.Random_Generator{procedure = random_generator_proc, data = &_default_state}
}

@(private = "file")
Xoshiro128_State :: struct {
	s: [4]u32,
}

@(private = "file")
_default_state: Xoshiro128_State

// Produces one 32-bit output and advances state. The algorithm requires that
// `state.s` is not all-zero — use `seed_xoshiro128` to initialize.
@(private = "file")
xoshiro128_next :: proc "contextless" (state: ^Xoshiro128_State) -> u32 {
	s := &state.s
	result := rotl(s[0] + s[3], 7) + s[0]
	t := s[1] << 9
	s[2] ~= s[0]
	s[3] ~= s[1]
	s[1] ~= s[2]
	s[0] ~= s[3]
	s[2] ~= t
	s[3] = rotl(s[3], 11)
	return result
}

// Initializes state from any u32 seed (including 0) via SplitMix32. xoshiro128++
// requires non-all-zero state; SplitMix32 output is never zero (its `+golden`
// step plus bit-mixing makes 0 unreachable for any input), so the requirement
// is satisfied automatically.
@(private = "file")
seed_xoshiro128 :: proc "contextless" (state: ^Xoshiro128_State, seed: u32) {
	z := seed
	for i in 0 ..< 4 {
		z = splitmix32(z)
		state.s[i] = z
	}
}

@(private = "file")
splitmix32 :: proc "contextless" (input: u32) -> u32 {
	z := input + 0x9E3779B9
	z = (z ~ (z >> 16)) * 0x85EBCA6B
	z = (z ~ (z >> 13)) * 0xC2B2AE35
	z = z ~ (z >> 16)
	return z
}

@(private = "file")
rotl :: proc "contextless" (x: u32, k: u32) -> u32 {
	return (x << k) | (x >> (32 - k))
}

@(private = "file")
random_generator_proc :: proc(data: rawptr, mode: runtime.Random_Generator_Mode, p: []byte) {
	state := cast(^Xoshiro128_State)data
	switch mode {
	case .Read:
		remaining := p
		for len(remaining) > 0 {
			v := xoshiro128_next(state)
			n := min(len(remaining), 4)
			for i in 0 ..< n {
				remaining[i] = u8(v >> (8 * u32(i)))
			}
			remaining = remaining[n:]
		}
	case .Reset:
		// Accept a single u32 seed if provided; otherwise ignore. (rand.reset(u64)
		// passes 8 LE bytes; we take the low 4.) `raw_data(p)` has no alignment
		// guarantee, so use unaligned_load rather than a reinterpret cast.
		if len(p) >= size_of(u32) {
			seed := intrinsics.unaligned_load((^u32)(raw_data(p)))
			seed_xoshiro128(state, seed)
		}
	case .Query_Info:
		if len(p) >= size_of(runtime.Random_Generator_Query_Info) {
			info := cast(^runtime.Random_Generator_Query_Info)raw_data(p)
			info^ += {.Uniform, .Resettable}
		}
	}
}
