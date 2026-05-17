package test

import playdate "../playdate"
import "core:math/rand"

RANDOM_GENERATOR_TESTS :: Test_Suite {
	"Random_Generator",
	{
		{"uint64_matches_reference_seed_42", test_uint64_matches_reference_seed_42},
		{"reset_equals_constructor_for_same_seed", test_reset_equals_constructor_for_same_seed},
		{"seed_zero_does_not_degenerate", test_seed_zero_does_not_degenerate},
		{"sequence_is_deterministic", test_sequence_is_deterministic},
	},
}

// Reference value computed via canonical C reference of splitmix32 (seed-derive)
// then xoshiro128++ twice, little-endian-concatenated to a u64. Pins the entire
// pipeline: seeder, algorithm, Read byte-marshaling.
@(private = "file")
REFERENCE_SEED_42_UINT64 :: u64(16171030750909909833)

@(private = "file")
test_uint64_matches_reference_seed_42 :: proc() -> bool {
	context.random_generator = playdate.random_generator(42)
	expect_eq(rand.uint64(), REFERENCE_SEED_42_UINT64) or_return
	return true
}

@(private = "file")
test_reset_equals_constructor_for_same_seed :: proc() -> bool {
	context.random_generator = playdate.random_generator(0)
	rand.reset(u64(42))
	expect_eq(rand.uint64(), REFERENCE_SEED_42_UINT64) or_return
	return true
}

@(private = "file")
test_seed_zero_does_not_degenerate :: proc() -> bool {
	// All-zero state would make xoshiro128++ emit 0 forever.
	context.random_generator = playdate.random_generator(0)
	expect(rand.uint32() != 0) or_return
	return true
}

@(private = "file")
test_sequence_is_deterministic :: proc() -> bool {
	context.random_generator = playdate.random_generator(42)
	first: [64]u64
	for &v in first {
		v = rand.uint64()
	}

	context.random_generator = playdate.random_generator(42)
	for expected in first {
		expect_eq(rand.uint64(), expected) or_return
	}
	return true
}
