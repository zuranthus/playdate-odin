//
//  pdext_sound.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

AUDIO_FRAMES_PER_CYCLE :: 512

SoundFormat :: enum u32 {
	_8bitMono    = 0,
	_8bitStereo  = 1,
	_16bitMono   = 2,
	_16bitStereo = 3,
	ADPCMMono    = 4,
	ADPCMStereo  = 5,
}

MIDINote :: f32

NOTE_C4 :: 60

SoundSource     :: struct {}
sndCallbackProc :: proc "c" (_c: ^SoundSource, userdata: rawptr)

// SoundSource is the parent class for FilePlayer, SamplePlayer, PDSynth, and DelayLineTap. You can safely cast those objects to a SoundSource* and use these functions:
sound_source :: struct {
	setVolume:         proc "c" (_c: ^SoundSource, lvol: f32, rvol: f32),
	getVolume:         proc "c" (_c: ^SoundSource, outl: ^f32, outr: ^f32),
	isPlaying:         proc "c" (_c: ^SoundSource) -> i32,
	setFinishCallback: proc "c" (_c: ^SoundSource, callback: sndCallbackProc, userdata: rawptr),
}

FilePlayer :: struct {} // extends SoundSource

sound_fileplayer :: struct {
	newPlayer:          proc "c" () -> ^FilePlayer,
	freePlayer:         proc "c" (player: ^FilePlayer),
	loadIntoPlayer:     proc "c" (player: ^FilePlayer, path: cstring) -> i32,
	setBufferLength:    proc "c" (player: ^FilePlayer, bufferLen: f32),
	play:               proc "c" (player: ^FilePlayer, repeat: i32) -> i32,
	isPlaying:          proc "c" (player: ^FilePlayer) -> i32,
	pause:              proc "c" (player: ^FilePlayer),
	stop:               proc "c" (player: ^FilePlayer),
	setVolume:          proc "c" (player: ^FilePlayer, left: f32, right: f32),
	getVolume:          proc "c" (player: ^FilePlayer, left: ^f32, right: ^f32),
	getLength:          proc "c" (player: ^FilePlayer) -> f32,
	setOffset:          proc "c" (player: ^FilePlayer, offset: f32),
	setRate:            proc "c" (player: ^FilePlayer, rate: f32),
	setLoopRange:       proc "c" (player: ^FilePlayer, start: f32, end: f32),
	didUnderrun:        proc "c" (player: ^FilePlayer) -> i32,
	setFinishCallback:  proc "c" (player: ^FilePlayer, callback: sndCallbackProc, userdata: rawptr),
	setLoopCallback:    proc "c" (player: ^FilePlayer, callback: sndCallbackProc, userdata: rawptr),
	getOffset:          proc "c" (player: ^FilePlayer) -> f32,
	getRate:            proc "c" (player: ^FilePlayer) -> f32,
	setStopOnUnderrun:  proc "c" (player: ^FilePlayer, flag: i32),
	fadeVolume:         proc "c" (player: ^FilePlayer, left: f32, right: f32, len: i32, finishCallback: sndCallbackProc, userdata: rawptr),
	setMP3StreamSource: proc "c" (player: ^FilePlayer, dataSource: proc "c" (data: ^i32, bytes: i32, userdata: rawptr) -> i32, userdata: rawptr, bufferLen: f32),
}

AudioSample  :: struct {}
SamplePlayer :: struct {}

sound_sample :: struct {
	newSampleBuffer:   proc "c" (byteCount: i32) -> ^AudioSample,
	loadIntoSample:    proc "c" (sample: ^AudioSample, path: cstring) -> i32,
	load:              proc "c" (path: cstring) -> ^AudioSample,
	newSampleFromData: proc "c" (data: ^i32, format: SoundFormat, sampleRate: i32, byteCount: i32, shouldFreeData: i32) -> ^AudioSample,
	getData:           proc "c" (sample: ^AudioSample, data: ^^i32, format: ^SoundFormat, sampleRate: ^i32, bytelength: ^i32),
	freeSample:        proc "c" (sample: ^AudioSample),
	getLength:         proc "c" (sample: ^AudioSample) -> f32,

	// 2.4
	decompress: proc "c" (sample: ^AudioSample) -> i32,
}

sound_sampleplayer :: struct {
	newPlayer:         proc "c" () -> ^SamplePlayer,
	freePlayer:        proc "c" (player: ^SamplePlayer),
	setSample:         proc "c" (player: ^SamplePlayer, sample: ^AudioSample),
	play:              proc "c" (player: ^SamplePlayer, repeat: i32, rate: f32) -> i32,
	isPlaying:         proc "c" (player: ^SamplePlayer) -> i32,
	stop:              proc "c" (player: ^SamplePlayer),
	setVolume:         proc "c" (player: ^SamplePlayer, left: f32, right: f32),
	getVolume:         proc "c" (player: ^SamplePlayer, left: ^f32, right: ^f32),
	getLength:         proc "c" (player: ^SamplePlayer) -> f32,
	setOffset:         proc "c" (player: ^SamplePlayer, offset: f32),
	setRate:           proc "c" (player: ^SamplePlayer, rate: f32),
	setPlayRange:      proc "c" (player: ^SamplePlayer, start: i32, end: i32),
	setFinishCallback: proc "c" (player: ^SamplePlayer, callback: sndCallbackProc, userdata: rawptr),
	setLoopCallback:   proc "c" (player: ^SamplePlayer, callback: sndCallbackProc, userdata: rawptr),
	getOffset:         proc "c" (player: ^SamplePlayer) -> f32,
	getRate:           proc "c" (player: ^SamplePlayer) -> f32,
	setPaused:         proc "c" (player: ^SamplePlayer, flag: i32),
} // SamplePlayer extends SoundSource

PDSynthSignalValue :: struct {}
PDSynthSignal      :: struct {}
signalStepFunc     :: proc "c" (userdata: rawptr, ioframes: ^i32, ifval: ^f32) -> f32
signalNoteOnFunc   :: proc "c" (userdata: rawptr, note: MIDINote, vel: f32, len: f32) // len = -1 for indefinite
signalNoteOffFunc  :: proc "c" (userdata: rawptr, stopped: i32, offset: i32)          // stopped = 0 on note release, = 1 when note actually stops playing; offset is # of frames into the current cycle
signalDeallocFunc  :: proc "c" (userdata: rawptr)

sound_signal :: struct {
	newSignal:      proc "c" (step: signalStepFunc, noteOn: signalNoteOnFunc, noteOff: signalNoteOffFunc, dealloc: signalDeallocFunc, userdata: rawptr) -> ^PDSynthSignal,
	freeSignal:     proc "c" (signal: ^PDSynthSignal),
	getValue:       proc "c" (signal: ^PDSynthSignal) -> f32,
	setValueScale:  proc "c" (signal: ^PDSynthSignal, scale: f32),
	setValueOffset: proc "c" (signal: ^PDSynthSignal, offset: f32),

	// 2.6
	newSignalForValue: proc "c" (value: ^PDSynthSignalValue) -> ^PDSynthSignal,
}

LFOType :: enum u32 {
	Square        = 0,
	Triangle      = 1,
	Sine          = 2,
	SampleAndHold = 3,
	SawtoothUp    = 4,
	SawtoothDown  = 5,
	Arpeggiator   = 6,
	Function      = 7,
}

PDSynthLFO :: struct {} // inherits from SynthSignal

sound_lfo :: struct {
	newLFO:          proc "c" (type: LFOType) -> ^PDSynthLFO,
	freeLFO:         proc "c" (lfo: ^PDSynthLFO),
	setType:         proc "c" (lfo: ^PDSynthLFO, type: LFOType),
	setRate:         proc "c" (lfo: ^PDSynthLFO, rate: f32),
	setPhase:        proc "c" (lfo: ^PDSynthLFO, phase: f32),
	setCenter:       proc "c" (lfo: ^PDSynthLFO, center: f32),
	setDepth:        proc "c" (lfo: ^PDSynthLFO, depth: f32),
	setArpeggiation: proc "c" (lfo: ^PDSynthLFO, nSteps: i32, steps: ^f32),
	setFunction:     proc "c" (lfo: ^PDSynthLFO, lfoFunc: proc "c" (lfo: ^PDSynthLFO, userdata: rawptr) -> f32, userdata: rawptr, interpolate: i32),
	setDelay:        proc "c" (lfo: ^PDSynthLFO, holdoff: f32, ramptime: f32),
	setRetrigger:    proc "c" (lfo: ^PDSynthLFO, flag: i32),
	getValue:        proc "c" (lfo: ^PDSynthLFO) -> f32,

	// 1.10
	setGlobal: proc "c" (lfo: ^PDSynthLFO, global: i32),

	// 2.2
	setStartPhase: proc "c" (lfo: ^PDSynthLFO, phase: f32),
}

PDSynthEnvelope :: struct {} // inherits from SynthSignal

sound_envelope :: struct {
	newEnvelope:  proc "c" (attack: f32, decay: f32, sustain: f32, release: f32) -> ^PDSynthEnvelope,
	freeEnvelope: proc "c" (env: ^PDSynthEnvelope),
	setAttack:    proc "c" (env: ^PDSynthEnvelope, attack: f32),
	setDecay:     proc "c" (env: ^PDSynthEnvelope, decay: f32),
	setSustain:   proc "c" (env: ^PDSynthEnvelope, sustain: f32),
	setRelease:   proc "c" (env: ^PDSynthEnvelope, release: f32),
	setLegato:    proc "c" (env: ^PDSynthEnvelope, flag: i32),
	setRetrigger: proc "c" (lfo: ^PDSynthEnvelope, flag: i32),
	getValue:     proc "c" (env: ^PDSynthEnvelope) -> f32,

	// 1.13
	setCurvature:           proc "c" (env: ^PDSynthEnvelope, amount: f32),
	setVelocitySensitivity: proc "c" (env: ^PDSynthEnvelope, velsens: f32),
	setRateScaling:         proc "c" (env: ^PDSynthEnvelope, scaling: f32, start: MIDINote, end: MIDINote),
}

SoundWaveform :: enum u32 {
	Square    = 0,
	Triangle  = 1,
	Sine      = 2,
	Noise     = 3,
	Sawtooth  = 4,
	POPhase   = 5,
	PODigital = 6,
	POVosim   = 7,
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
synthRenderFunc :: proc "c" (userdata: rawptr, left: ^i32, right: ^i32, nsamples: i32, rate: i32, drate: i32) -> i32

// generator event callbacks
synthNoteOnFunc       :: proc "c" (userdata: rawptr, note: MIDINote, velocity: f32, len: f32) // len == -1 if indefinite
synthReleaseFunc      :: proc "c" (userdata: rawptr, stop: i32)
synthSetParameterFunc :: proc "c" (userdata: rawptr, parameter: i32, value: f32) -> i32
synthDeallocFunc      :: proc "c" (userdata: rawptr)
synthCopyUserdata     :: proc "c" (userdata: rawptr) -> rawptr
PDSynth               :: struct {}

sound_synth :: struct {
	newSynth:                proc "c" () -> ^PDSynth,
	freeSynth:               proc "c" (synth: ^PDSynth),
	setWaveform:             proc "c" (synth: ^PDSynth, wave: SoundWaveform),
	setGenerator_deprecated: proc "c" (synth: ^PDSynth, stereo: i32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, userdata: rawptr),
	setSample:               proc "c" (synth: ^PDSynth, sample: ^AudioSample, sustainStart: i32, sustainEnd: i32),
	setAttackTime:           proc "c" (synth: ^PDSynth, attack: f32),
	setDecayTime:            proc "c" (synth: ^PDSynth, decay: f32),
	setSustainLevel:         proc "c" (synth: ^PDSynth, sustain: f32),
	setReleaseTime:          proc "c" (synth: ^PDSynth, release: f32),
	setTranspose:            proc "c" (synth: ^PDSynth, halfSteps: f32),
	setFrequencyModulator:   proc "c" (synth: ^PDSynth, mod: ^PDSynthSignalValue),
	getFrequencyModulator:   proc "c" (synth: ^PDSynth) -> ^PDSynthSignalValue,
	setAmplitudeModulator:   proc "c" (synth: ^PDSynth, mod: ^PDSynthSignalValue),
	getAmplitudeModulator:   proc "c" (synth: ^PDSynth) -> ^PDSynthSignalValue,
	getParameterCount:       proc "c" (synth: ^PDSynth) -> i32,
	setParameter:            proc "c" (synth: ^PDSynth, parameter: i32, value: f32) -> i32,
	setParameterModulator:   proc "c" (synth: ^PDSynth, parameter: i32, mod: ^PDSynthSignalValue),
	getParameterModulator:   proc "c" (synth: ^PDSynth, parameter: i32) -> ^PDSynthSignalValue,
	playNote:                proc "c" (synth: ^PDSynth, freq: f32, vel: f32, len: f32, _when: i32),      // len == -1 for indefinite
	playMIDINote:            proc "c" (synth: ^PDSynth, note: MIDINote, vel: f32, len: f32, _when: i32), // len == -1 for indefinite
	noteOff:                 proc "c" (synth: ^PDSynth, _when: i32),                                     // move to release part of envelope
	stop:                    proc "c" (synth: ^PDSynth),                                                 // stop immediately
	setVolume:               proc "c" (synth: ^PDSynth, left: f32, right: f32),
	getVolume:               proc "c" (synth: ^PDSynth, left: ^f32, right: ^f32),
	isPlaying:               proc "c" (synth: ^PDSynth) -> i32,

	// 1.13
	getEnvelope: proc "c" (synth: ^PDSynth) -> ^PDSynthEnvelope, // synth keeps ownership--don't free this!

	// 2.2
	setWavetable: proc "c" (synth: ^PDSynth, sample: ^AudioSample, log2size: i32, columns: i32, rows: i32) -> i32,

	// 2.4
	setGenerator: proc "c" (synth: ^PDSynth, stereo: i32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, copyUserdata: synthCopyUserdata, userdata: rawptr),
	copy:         proc "c" (synth: ^PDSynth) -> ^PDSynth,

	// 2.6
	clearEnvelope: proc "c" (synth: ^PDSynth),
} // PDSynth extends SoundSource

ControlSignal :: struct {}

control_signal :: struct {
	newSignal:               proc "c" () -> ^ControlSignal,
	freeSignal:              proc "c" (signal: ^ControlSignal),
	clearEvents:             proc "c" (control: ^ControlSignal),
	addEvent:                proc "c" (control: ^ControlSignal, step: i32, value: f32, interpolate: i32),
	removeEvent:             proc "c" (control: ^ControlSignal, step: i32),
	getMIDIControllerNumber: proc "c" (control: ^ControlSignal) -> i32,
}

PDSynthInstrument :: struct {}

sound_instrument :: struct {
	newInstrument:     proc "c" () -> ^PDSynthInstrument,
	freeInstrument:    proc "c" (inst: ^PDSynthInstrument),
	addVoice:          proc "c" (inst: ^PDSynthInstrument, synth: ^PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: f32) -> i32,
	playNote:          proc "c" (inst: ^PDSynthInstrument, frequency: f32, vel: f32, len: f32, _when: i32) -> ^PDSynth,
	playMIDINote:      proc "c" (inst: ^PDSynthInstrument, note: MIDINote, vel: f32, len: f32, _when: i32) -> ^PDSynth,
	setPitchBend:      proc "c" (inst: ^PDSynthInstrument, bend: f32),
	setPitchBendRange: proc "c" (inst: ^PDSynthInstrument, halfSteps: f32),
	setTranspose:      proc "c" (inst: ^PDSynthInstrument, halfSteps: f32),
	noteOff:           proc "c" (inst: ^PDSynthInstrument, note: MIDINote, _when: i32),
	allNotesOff:       proc "c" (inst: ^PDSynthInstrument, _when: i32),
	setVolume:         proc "c" (inst: ^PDSynthInstrument, left: f32, right: f32),
	getVolume:         proc "c" (inst: ^PDSynthInstrument, left: ^f32, right: ^f32),
	activeVoiceCount:  proc "c" (inst: ^PDSynthInstrument) -> i32,
}

SequenceTrack :: struct {}

sound_track :: struct {
	newTrack:              proc "c" () -> ^SequenceTrack,
	freeTrack:             proc "c" (track: ^SequenceTrack),
	setInstrument:         proc "c" (track: ^SequenceTrack, inst: ^PDSynthInstrument),
	getInstrument:         proc "c" (track: ^SequenceTrack) -> ^PDSynthInstrument,
	addNoteEvent:          proc "c" (track: ^SequenceTrack, step: i32, len: i32, note: MIDINote, velocity: f32),
	removeNoteEvent:       proc "c" (track: ^SequenceTrack, step: i32, note: MIDINote),
	clearNotes:            proc "c" (track: ^SequenceTrack),
	getControlSignalCount: proc "c" (track: ^SequenceTrack) -> i32,
	getControlSignal:      proc "c" (track: ^SequenceTrack, idx: i32) -> ^ControlSignal,
	clearControlEvents:    proc "c" (track: ^SequenceTrack),
	getPolyphony:          proc "c" (track: ^SequenceTrack) -> i32,
	activeVoiceCount:      proc "c" (track: ^SequenceTrack) -> i32,
	setMuted:              proc "c" (track: ^SequenceTrack, mute: i32),

	// 1.1
	uint32_t:        proc "c" (track: ^SequenceTrack, getLength: ^i32) -> proc "c" (track: ^SequenceTrack) -> i32, // in steps, includes full last note
	getIndexForStep: proc "c" (track: ^SequenceTrack, step: i32) -> i32,
	getNoteAtIndex:  proc "c" (track: ^SequenceTrack, index: i32, outStep: ^i32, outLen: ^i32, outNote: ^MIDINote, outVelocity: ^f32) -> i32,

	// 1.10
	getSignalForController: proc "c" (track: ^SequenceTrack, controller: i32, create: i32) -> ^ControlSignal,
}

SoundSequence            :: struct {}
SequenceFinishedCallback :: proc "c" (seq: ^SoundSequence, userdata: rawptr)

sound_sequence :: struct {
	newSequence:         proc "c" () -> ^SoundSequence,
	freeSequence:        proc "c" (sequence: ^SoundSequence),
	loadMIDIFile:        proc "c" (seq: ^SoundSequence, path: cstring) -> i32,
	uint32_t:            proc "c" (seq: ^SoundSequence, getTime: ^i32) -> proc "c" (^SoundSequence) -> i32,
	setTime:             proc "c" (seq: ^SoundSequence, time: i32),
	setLoops:            proc "c" (seq: ^SoundSequence, loopstart: i32, loopend: i32, loops: i32),
	getTempo_deprecated: proc "c" (seq: ^SoundSequence) -> i32,
	setTempo:            proc "c" (seq: ^SoundSequence, stepsPerSecond: f32),
	getTrackCount:       proc "c" (seq: ^SoundSequence) -> i32,
	addTrack:            proc "c" (seq: ^SoundSequence) -> ^SequenceTrack,
	getTrackAtIndex:     proc "c" (seq: ^SoundSequence, track: u32) -> ^SequenceTrack,
	setTrackAtIndex:     proc "c" (seq: ^SoundSequence, track: ^SequenceTrack, idx: u32),
	allNotesOff:         proc "c" (seq: ^SoundSequence),

	// 1.1
	isPlaying:      proc "c" (seq: ^SoundSequence) -> i32,
	play:           proc "c" (seq: ^SoundSequence, finishCallback: SequenceFinishedCallback, userdata: rawptr),
	stop:           proc "c" (seq: ^SoundSequence),
	getCurrentStep: proc "c" (seq: ^SoundSequence, timeOffset: ^i32) -> i32,
	setCurrentStep: proc "c" (seq: ^SoundSequence, step: i32, timeOffset: i32, playNotes: i32),

	// 2.5
	getTempo: proc "c" (seq: ^SoundSequence) -> f32,
}

TwoPoleFilter :: struct {}

TwoPoleFilterType :: enum u32 {
	LowPass   = 0,
	HighPass  = 1,
	BandPass  = 2,
	Notch     = 3,
	PEQ       = 4,
	LowShelf  = 5,
	HighShelf = 6,
}

sound_effect_twopolefilter :: struct {
	newFilter:             proc "c" () -> ^TwoPoleFilter,
	freeFilter:            proc "c" (filter: ^TwoPoleFilter),
	setType:               proc "c" (filter: ^TwoPoleFilter, type: TwoPoleFilterType),
	setFrequency:          proc "c" (filter: ^TwoPoleFilter, frequency: f32),
	setFrequencyModulator: proc "c" (filter: ^TwoPoleFilter, signal: ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (filter: ^TwoPoleFilter) -> ^PDSynthSignalValue,
	setGain:               proc "c" (filter: ^TwoPoleFilter, gain: f32),
	setResonance:          proc "c" (filter: ^TwoPoleFilter, resonance: f32),
	setResonanceModulator: proc "c" (filter: ^TwoPoleFilter, signal: ^PDSynthSignalValue),
	getResonanceModulator: proc "c" (filter: ^TwoPoleFilter) -> ^PDSynthSignalValue,
}

OnePoleFilter :: struct {}

sound_effect_onepolefilter :: struct {
	newFilter:             proc "c" () -> ^OnePoleFilter,
	freeFilter:            proc "c" (filter: ^OnePoleFilter),
	setParameter:          proc "c" (filter: ^OnePoleFilter, parameter: f32),
	setParameterModulator: proc "c" (filter: ^OnePoleFilter, signal: ^PDSynthSignalValue),
	getParameterModulator: proc "c" (filter: ^OnePoleFilter) -> ^PDSynthSignalValue,
}

BitCrusher :: struct {}

sound_effect_bitcrusher :: struct {
	newBitCrusher:           proc "c" () -> ^BitCrusher,
	freeBitCrusher:          proc "c" (filter: ^BitCrusher),
	setAmount:               proc "c" (filter: ^BitCrusher, amount: f32),
	setAmountModulator:      proc "c" (filter: ^BitCrusher, signal: ^PDSynthSignalValue),
	getAmountModulator:      proc "c" (filter: ^BitCrusher) -> ^PDSynthSignalValue,
	setUndersampling:        proc "c" (filter: ^BitCrusher, undersampling: f32),
	setUndersampleModulator: proc "c" (filter: ^BitCrusher, signal: ^PDSynthSignalValue),
	getUndersampleModulator: proc "c" (filter: ^BitCrusher) -> ^PDSynthSignalValue,
}

RingModulator :: struct {}

sound_effect_ringmodulator :: struct {
	newRingmod:            proc "c" () -> ^RingModulator,
	freeRingmod:           proc "c" (filter: ^RingModulator),
	setFrequency:          proc "c" (filter: ^RingModulator, frequency: f32),
	setFrequencyModulator: proc "c" (filter: ^RingModulator, signal: ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (filter: ^RingModulator) -> ^PDSynthSignalValue,
}

DelayLine    :: struct {}
DelayLineTap :: struct {}

sound_effect_delayline :: struct {
	newDelayLine:  proc "c" (length: i32, stereo: i32) -> ^DelayLine,
	freeDelayLine: proc "c" (filter: ^DelayLine),
	setLength:     proc "c" (d: ^DelayLine, frames: i32),
	setFeedback:   proc "c" (d: ^DelayLine, fb: f32),
	addTap:        proc "c" (d: ^DelayLine, delay: i32) -> ^DelayLineTap,

	// note that DelayLineTap is a SoundSource, not a SoundEffect
	freeTap:               proc "c" (tap: ^DelayLineTap),
	setTapDelay:           proc "c" (t: ^DelayLineTap, frames: i32),
	setTapDelayModulator:  proc "c" (t: ^DelayLineTap, mod: ^PDSynthSignalValue),
	getTapDelayModulator:  proc "c" (t: ^DelayLineTap) -> ^PDSynthSignalValue,
	setTapChannelsFlipped: proc "c" (t: ^DelayLineTap, flip: i32),
}

Overdrive :: struct {}

sound_effect_overdrive :: struct {
	newOverdrive:       proc "c" () -> ^Overdrive,
	freeOverdrive:      proc "c" (filter: ^Overdrive),
	setGain:            proc "c" (o: ^Overdrive, gain: f32),
	setLimit:           proc "c" (o: ^Overdrive, limit: f32),
	setLimitModulator:  proc "c" (o: ^Overdrive, mod: ^PDSynthSignalValue),
	getLimitModulator:  proc "c" (o: ^Overdrive) -> ^PDSynthSignalValue,
	setOffset:          proc "c" (o: ^Overdrive, offset: f32),
	setOffsetModulator: proc "c" (o: ^Overdrive, mod: ^PDSynthSignalValue),
	getOffsetModulator: proc "c" (o: ^Overdrive) -> ^PDSynthSignalValue,
}

SoundEffect :: struct {}
effectProc  :: proc "c" (e: ^SoundEffect, left: ^i32, right: ^i32, nsamples: i32, bufactive: i32) -> i32 // samples are in signed q8.24 format

sound_effect :: struct {
	newEffect:       proc "c" (_proc: effectProc, userdata: rawptr) -> ^SoundEffect,
	freeEffect:      proc "c" (effect: ^SoundEffect),
	setMix:          proc "c" (effect: ^SoundEffect, level: f32),
	setMixModulator: proc "c" (effect: ^SoundEffect, signal: ^PDSynthSignalValue),
	getMixModulator: proc "c" (effect: ^SoundEffect) -> ^PDSynthSignalValue,
	setUserdata:     proc "c" (effect: ^SoundEffect, userdata: rawptr),
	getUserdata:     proc "c" (effect: ^SoundEffect) -> rawptr,
	twopolefilter:   ^sound_effect_twopolefilter,
	onepolefilter:   ^sound_effect_onepolefilter,
	bitcrusher:      ^sound_effect_bitcrusher,
	ringmodulator:   ^sound_effect_ringmodulator,
	delayline:       ^sound_effect_delayline,
	overdrive:       ^sound_effect_overdrive,
}

SoundChannel        :: struct {}
AudioSourceFunction :: proc "c" (_context: rawptr, left: ^i32, right: ^i32, len: i32) -> i32 // len is # of samples in each buffer, function should return 1 if it produced output

sound_channel :: struct {
	newChannel:         proc "c" () -> ^SoundChannel,
	freeChannel:        proc "c" (channel: ^SoundChannel),
	addSource:          proc "c" (channel: ^SoundChannel, source: ^SoundSource) -> i32,
	removeSource:       proc "c" (channel: ^SoundChannel, source: ^SoundSource) -> i32,
	addCallbackSource:  proc "c" (channel: ^SoundChannel, callback: AudioSourceFunction, _context: rawptr, stereo: i32) -> ^SoundSource,
	addEffect:          proc "c" (channel: ^SoundChannel, effect: ^SoundEffect) -> i32,
	removeEffect:       proc "c" (channel: ^SoundChannel, effect: ^SoundEffect) -> i32,
	setVolume:          proc "c" (channel: ^SoundChannel, volume: f32),
	getVolume:          proc "c" (channel: ^SoundChannel) -> f32,
	setVolumeModulator: proc "c" (channel: ^SoundChannel, mod: ^PDSynthSignalValue),
	getVolumeModulator: proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	setPan:             proc "c" (channel: ^SoundChannel, pan: f32),
	setPanModulator:    proc "c" (channel: ^SoundChannel, mod: ^PDSynthSignalValue),
	getPanModulator:    proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	getDryLevelSignal:  proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	getWetLevelSignal:  proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
}

RecordCallback :: proc "c" (_context: rawptr, buffer: ^i32, length: i32) -> i32 // data is mono

MicSource :: enum u32 {
	Autodetect = 0,
	Internal   = 1,
	Headset    = 2,
}

sound :: struct {
	channel:           ^sound_channel,
	fileplayer:        ^sound_fileplayer,
	sample:            ^sound_sample,
	sampleplayer:      ^sound_sampleplayer,
	synth:             ^sound_synth,
	sequence:          ^sound_sequence,
	effect:            ^sound_effect,
	lfo:               ^sound_lfo,
	envelope:          ^sound_envelope,
	source:            ^sound_source,
	controlsignal:     ^control_signal,
	track:             ^sound_track,
	instrument:        ^sound_instrument,
	uint32_t:          proc "c" (getCurrentTime: ^i32) -> proc "c" () -> i32,
	addSource:         proc "c" (callback: AudioSourceFunction, _context: rawptr, stereo: i32) -> ^SoundSource,
	getDefaultChannel: proc "c" () -> ^SoundChannel,
	addChannel:        proc "c" (channel: ^SoundChannel) -> i32,
	removeChannel:     proc "c" (channel: ^SoundChannel) -> i32,
	setMicCallback:    proc "c" (callback: RecordCallback, _context: rawptr, source: MicSource) -> i32,
	getHeadphoneState: proc "c" (headphone: ^i32, headsetmic: ^i32, changeCallback: proc "c" (headphone: i32, mic: i32)),
	setOutputsActive:  proc "c" (headphone: i32, speaker: i32),

	// 1.5
	removeSource: proc "c" (source: ^SoundSource) -> i32,

	// 1.12
	signal: ^sound_signal,

	// 2.2
	getError: proc "c" () -> cstring,
}

