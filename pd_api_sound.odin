//
//  pdext_sound.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_sound_h :: 

AUDIO_FRAMES_PER_CYCLE :: 512

SoundFormat :: enum u32 {
	_8bitMono,
	_8bitStereo,
	_16bitMono,
	_16bitStereo,
	ADPCMMono,
	ADPCMStereo,
}

MIDINote :: f32

NOTE_C4 :: 60

SoundSource :: struct {}

sndCallbackProc :: proc "c" (^SoundSource, rawptr)

// SoundSource is the parent class for FilePlayer, SamplePlayer, PDSynth, and DelayLineTap. You can safely cast those objects to a SoundSource* and use these functions:
sound_source :: struct {
	setVolume:         proc "c" (^SoundSource, f32, f32),
	getVolume:         proc "c" (^SoundSource, ^f32, ^f32),
	isPlaying:         proc "c" (^SoundSource) -> i32,
	setFinishCallback: proc "c" (^SoundSource, sndCallbackProc, rawptr),
}

FilePlayer :: struct {} // extends SoundSource

sound_fileplayer :: struct {
	newPlayer:          proc "c" () -> ^FilePlayer,
	freePlayer:         proc "c" (^FilePlayer),
	loadIntoPlayer:     proc "c" (^FilePlayer, cstring) -> i32,
	setBufferLength:    proc "c" (^FilePlayer, f32),
	play:               proc "c" (^FilePlayer, i32) -> i32,
	isPlaying:          proc "c" (^FilePlayer) -> i32,
	pause:              proc "c" (^FilePlayer),
	stop:               proc "c" (^FilePlayer),
	setVolume:          proc "c" (^FilePlayer, f32, f32),
	getVolume:          proc "c" (^FilePlayer, ^f32, ^f32),
	getLength:          proc "c" (^FilePlayer) -> f32,
	setOffset:          proc "c" (^FilePlayer, f32),
	setRate:            proc "c" (^FilePlayer, f32),
	setLoopRange:       proc "c" (^FilePlayer, f32, f32),
	didUnderrun:        proc "c" (^FilePlayer) -> i32,
	setFinishCallback:  proc "c" (^FilePlayer, sndCallbackProc, rawptr),
	setLoopCallback:    proc "c" (^FilePlayer, sndCallbackProc, rawptr),
	getOffset:          proc "c" (^FilePlayer) -> f32,
	getRate:            proc "c" (^FilePlayer) -> f32,
	setStopOnUnderrun:  proc "c" (^FilePlayer, i32),
	fadeVolume:         proc "c" (^FilePlayer, f32, f32, i32, sndCallbackProc, rawptr),
	setMP3StreamSource: proc "c" (^FilePlayer, proc "c" (^i32, i32, rawptr) -> i32, rawptr, f32),
}

AudioSample :: struct {}

SamplePlayer :: struct {}

sound_sample :: struct {
	newSampleBuffer:   proc "c" (i32) -> ^AudioSample,
	loadIntoSample:    proc "c" (^AudioSample, cstring) -> i32,
	load:              proc "c" (cstring) -> ^AudioSample,
	newSampleFromData: proc "c" (^i32, SoundFormat, i32, i32, i32) -> ^AudioSample,
	getData:           proc "c" (^AudioSample, ^^i32, ^SoundFormat, ^i32, ^i32),
	freeSample:        proc "c" (^AudioSample),
	getLength:         proc "c" (^AudioSample) -> f32,

	// 2.4
	decompress: proc "c" (^AudioSample) -> i32,
}

sound_sampleplayer :: struct {
	newPlayer:         proc "c" () -> ^SamplePlayer,
	freePlayer:        proc "c" (^SamplePlayer),
	setSample:         proc "c" (^SamplePlayer, ^AudioSample),
	play:              proc "c" (^SamplePlayer, i32, f32) -> i32,
	isPlaying:         proc "c" (^SamplePlayer) -> i32,
	stop:              proc "c" (^SamplePlayer),
	setVolume:         proc "c" (^SamplePlayer, f32, f32),
	getVolume:         proc "c" (^SamplePlayer, ^f32, ^f32),
	getLength:         proc "c" (^SamplePlayer) -> f32,
	setOffset:         proc "c" (^SamplePlayer, f32),
	setRate:           proc "c" (^SamplePlayer, f32),
	setPlayRange:      proc "c" (^SamplePlayer, i32, i32),
	setFinishCallback: proc "c" (^SamplePlayer, sndCallbackProc, rawptr),
	setLoopCallback:   proc "c" (^SamplePlayer, sndCallbackProc, rawptr),
	getOffset:         proc "c" (^SamplePlayer) -> f32,
	getRate:           proc "c" (^SamplePlayer) -> f32,
	setPaused:         proc "c" (^SamplePlayer, i32),
}

PDSynthSignalValue :: struct {}

PDSynthSignal :: struct {}

signalStepFunc :: proc "c" (rawptr, ^i32, ^f32) -> f32

signalNoteOnFunc :: proc "c" (rawptr, MIDINote, f32, f32) // len = -1 for indefinite

signalNoteOffFunc :: proc "c" (rawptr, i32, i32) // stopped = 0 on note release, = 1 when note actually stops playing; offset is # of frames into the current cycle

signalDeallocFunc :: proc "c" (rawptr)

sound_signal :: struct {
	newSignal:      proc "c" (signalStepFunc, signalNoteOnFunc, signalNoteOffFunc, signalDeallocFunc, rawptr) -> ^PDSynthSignal,
	freeSignal:     proc "c" (^PDSynthSignal),
	getValue:       proc "c" (^PDSynthSignal) -> f32,
	setValueScale:  proc "c" (^PDSynthSignal, f32),
	setValueOffset: proc "c" (^PDSynthSignal, f32),

	// 2.6
	newSignalForValue: proc "c" (^PDSynthSignalValue) -> ^PDSynthSignal,
}

LFOType :: enum u32 {
	Square,
	Triangle,
	Sine,
	SampleAndHold,
	SawtoothUp,
	SawtoothDown,
	Arpeggiator,
	Function,
}

PDSynthLFO :: struct {} // inherits from SynthSignal

sound_lfo :: struct {
	newLFO:          proc "c" (LFOType) -> ^PDSynthLFO,
	freeLFO:         proc "c" (^PDSynthLFO),
	setType:         proc "c" (^PDSynthLFO, LFOType),
	setRate:         proc "c" (^PDSynthLFO, f32),
	setPhase:        proc "c" (^PDSynthLFO, f32),
	setCenter:       proc "c" (^PDSynthLFO, f32),
	setDepth:        proc "c" (^PDSynthLFO, f32),
	setArpeggiation: proc "c" (^PDSynthLFO, i32, ^f32),
	setFunction:     proc "c" (^PDSynthLFO, proc "c" (^PDSynthLFO, rawptr) -> f32, rawptr, i32),
	setDelay:        proc "c" (^PDSynthLFO, f32, f32),
	setRetrigger:    proc "c" (^PDSynthLFO, i32),
	getValue:        proc "c" (^PDSynthLFO) -> f32,

	// 1.10
	setGlobal: proc "c" (^PDSynthLFO, i32),

	// 2.2
	setStartPhase: proc "c" (^PDSynthLFO, f32),
}

PDSynthEnvelope :: struct {}

sound_envelope :: struct {
	newEnvelope:            proc "c" (f32, f32, f32, f32) -> ^PDSynthEnvelope,
	freeEnvelope:           proc "c" (^PDSynthEnvelope),
	setAttack:              proc "c" (^PDSynthEnvelope, f32),
	setDecay:               proc "c" (^PDSynthEnvelope, f32),
	setSustain:             proc "c" (^PDSynthEnvelope, f32),
	setRelease:             proc "c" (^PDSynthEnvelope, f32),
	setLegato:              proc "c" (^PDSynthEnvelope, i32),
	setRetrigger:           proc "c" (^PDSynthEnvelope, i32),
	getValue:               proc "c" (^PDSynthEnvelope) -> f32,

	// 1.13
	setCurvature: proc "c" (^PDSynthEnvelope, f32),
	setVelocitySensitivity: proc "c" (^PDSynthEnvelope, f32),
	setRateScaling:         proc "c" (^PDSynthEnvelope, f32, MIDINote, MIDINote),
}

// SYNTHS
SoundWaveform :: enum u32 {
	Square,
	Triangle,
	Sine,
	Noise,
	Sawtooth,
	POPhase,
	PODigital,
	POVosim,
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
synthRenderFunc :: proc "c" (rawptr, ^i32, ^i32, i32, i32, i32) -> i32

// generator event callbacks
synthNoteOnFunc :: proc "c" (rawptr, MIDINote, f32, f32) // len == -1 if indefinite

synthReleaseFunc :: proc "c" (rawptr, i32)

synthSetParameterFunc :: proc "c" (rawptr, i32, f32) -> i32

synthDeallocFunc :: proc "c" (rawptr)

synthCopyUserdata :: proc "c" (rawptr) -> rawptr

PDSynth :: struct {}

sound_synth :: struct {
	newSynth:                proc "c" () -> ^PDSynth,
	freeSynth:               proc "c" (^PDSynth),
	setWaveform:             proc "c" (^PDSynth, SoundWaveform),
	setGenerator_deprecated: proc "c" (^PDSynth, i32, synthRenderFunc, synthNoteOnFunc, synthReleaseFunc, synthSetParameterFunc, synthDeallocFunc, rawptr),
	setSample:               proc "c" (^PDSynth, ^AudioSample, i32, i32),
	setAttackTime:           proc "c" (^PDSynth, f32),
	setDecayTime:            proc "c" (^PDSynth, f32),
	setSustainLevel:         proc "c" (^PDSynth, f32),
	setReleaseTime:          proc "c" (^PDSynth, f32),
	setTranspose:            proc "c" (^PDSynth, f32),
	setFrequencyModulator:   proc "c" (^PDSynth, ^PDSynthSignalValue),
	getFrequencyModulator:   proc "c" (^PDSynth) -> ^PDSynthSignalValue,
	setAmplitudeModulator:   proc "c" (^PDSynth, ^PDSynthSignalValue),
	getAmplitudeModulator:   proc "c" (^PDSynth) -> ^PDSynthSignalValue,
	getParameterCount:       proc "c" (^PDSynth) -> i32,
	setParameter:            proc "c" (^PDSynth, i32, f32) -> i32,
	setParameterModulator:   proc "c" (^PDSynth, i32, ^PDSynthSignalValue),
	getParameterModulator:   proc "c" (^PDSynth, i32) -> ^PDSynthSignalValue,
	playNote:                proc "c" (^PDSynth, f32, f32, f32, i32),      // len == -1 for indefinite
	playMIDINote:            proc "c" (^PDSynth, MIDINote, f32, f32, i32), // len == -1 for indefinite
	noteOff:                 proc "c" (^PDSynth, i32),                     // move to release part of envelope
	stop:                    proc "c" (^PDSynth),                          // stop immediately
	setVolume:               proc "c" (^PDSynth, f32, f32),
	getVolume:               proc "c" (^PDSynth, ^f32, ^f32),
	isPlaying:               proc "c" (^PDSynth) -> i32,
	getEnvelope:             proc "c" (^PDSynth) -> ^PDSynthEnvelope,      // synth keeps ownership--don't free this!

	// 2.2
	setWavetable: proc "c" (^PDSynth, ^AudioSample, i32, i32, i32) -> i32,

	// 2.4
	setGenerator: proc "c" (^PDSynth, i32, synthRenderFunc, synthNoteOnFunc, synthReleaseFunc, synthSetParameterFunc, synthDeallocFunc, synthCopyUserdata, rawptr),
	copy:                    proc "c" (^PDSynth) -> ^PDSynth,

	// 2.6
	clearEnvelope: proc "c" (^PDSynth),
}

ControlSignal :: struct {}

control_signal :: struct {
	newSignal:               proc "c" () -> ^ControlSignal,
	freeSignal:              proc "c" (^ControlSignal),
	clearEvents:             proc "c" (^ControlSignal),
	addEvent:                proc "c" (^ControlSignal, i32, f32, i32),
	removeEvent:             proc "c" (^ControlSignal, i32),
	getMIDIControllerNumber: proc "c" (^ControlSignal) -> i32,
}

// a PDSynthInstrument is a bank of voices for playing a sequence track
PDSynthInstrument :: struct {}

sound_instrument :: struct {
	newInstrument:     proc "c" () -> ^PDSynthInstrument,
	freeInstrument:    proc "c" (^PDSynthInstrument),
	addVoice:          proc "c" (^PDSynthInstrument, ^PDSynth, MIDINote, MIDINote, f32) -> i32,
	playNote:          proc "c" (^PDSynthInstrument, f32, f32, f32, i32) -> ^PDSynth,
	playMIDINote:      proc "c" (^PDSynthInstrument, MIDINote, f32, f32, i32) -> ^PDSynth,
	setPitchBend:      proc "c" (^PDSynthInstrument, f32),
	setPitchBendRange: proc "c" (^PDSynthInstrument, f32),
	setTranspose:      proc "c" (^PDSynthInstrument, f32),
	noteOff:           proc "c" (^PDSynthInstrument, MIDINote, i32),
	allNotesOff:       proc "c" (^PDSynthInstrument, i32),
	setVolume:         proc "c" (^PDSynthInstrument, f32, f32),
	getVolume:         proc "c" (^PDSynthInstrument, ^f32, ^f32),
	activeVoiceCount:  proc "c" (^PDSynthInstrument) -> i32,
}

SequenceTrack :: struct {}

sound_track :: struct {
	newTrack:              proc "c" () -> ^SequenceTrack,
	freeTrack:             proc "c" (^SequenceTrack),
	setInstrument:         proc "c" (^SequenceTrack, ^PDSynthInstrument),
	getInstrument:         proc "c" (^SequenceTrack) -> ^PDSynthInstrument,
	addNoteEvent:          proc "c" (^SequenceTrack, i32, i32, MIDINote, f32),
	removeNoteEvent:       proc "c" (^SequenceTrack, i32, MIDINote),
	clearNotes:            proc "c" (^SequenceTrack),
	getControlSignalCount: proc "c" (^SequenceTrack) -> i32,
	getControlSignal:      proc "c" (^SequenceTrack, i32) -> ^ControlSignal,
	clearControlEvents:    proc "c" (^SequenceTrack),
	getPolyphony:          proc "c" (^SequenceTrack) -> i32,
	activeVoiceCount:      proc "c" (^SequenceTrack) -> i32,
	setMuted:              proc "c" (^SequenceTrack, i32),
	uint32_t:              proc "c" (^i32) -> proc "c" (^SequenceTrack) -> i32, // in steps, includes full last note
	getIndexForStep:       proc "c" (^SequenceTrack, i32) -> i32,
	getNoteAtIndex:        proc "c" (^SequenceTrack, i32, ^i32, ^i32, ^MIDINote, ^f32) -> i32,

	// 1.10
	getSignalForController: proc "c" (^SequenceTrack, i32, i32) -> ^ControlSignal,
}

SoundSequence :: struct {}

SequenceFinishedCallback :: proc "c" (^SoundSequence, rawptr)

sound_sequence :: struct {
	newSequence:         proc "c" () -> ^SoundSequence,
	freeSequence:        proc "c" (^SoundSequence),
	loadMIDIFile:        proc "c" (^SoundSequence, cstring) -> i32,
	uint32_t:            proc "c" (^i32) -> proc "c" (^SoundSequence) -> i32,
	setTime:             proc "c" (^SoundSequence, i32),
	setLoops:            proc "c" (^SoundSequence, i32, i32, i32),
	getTempo_deprecated: proc "c" (^SoundSequence) -> i32,
	setTempo:            proc "c" (^SoundSequence, f32),
	getTrackCount:       proc "c" (^SoundSequence) -> i32,
	addTrack:            proc "c" (^SoundSequence) -> ^SequenceTrack,
	getTrackAtIndex:     proc "c" (^SoundSequence, u32) -> ^SequenceTrack,
	setTrackAtIndex:     proc "c" (^SoundSequence, ^SequenceTrack, u32),
	allNotesOff:         proc "c" (^SoundSequence),

	// 1.1
	isPlaying: proc "c" (^SoundSequence) -> i32,
	play:                proc "c" (^SoundSequence, SequenceFinishedCallback, rawptr),
	stop:                proc "c" (^SoundSequence),
	getCurrentStep:      proc "c" (^SoundSequence, ^i32) -> i32,
	setCurrentStep:      proc "c" (^SoundSequence, i32, i32, i32),

	// 2.5
	getTempo: proc "c" (^SoundSequence) -> f32,
}

TwoPoleFilter :: struct {}

TwoPoleFilterType :: enum u32 {
	LowPass,
	HighPass,
	BandPass,
	Notch,
	PEQ,
	LowShelf,
	HighShelf,
}

sound_effect_twopolefilter :: struct {
	newFilter:             proc "c" () -> ^TwoPoleFilter,
	freeFilter:            proc "c" (^TwoPoleFilter),
	setType:               proc "c" (^TwoPoleFilter, TwoPoleFilterType),
	setFrequency:          proc "c" (^TwoPoleFilter, f32),
	setFrequencyModulator: proc "c" (^TwoPoleFilter, ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (^TwoPoleFilter) -> ^PDSynthSignalValue,
	setGain:               proc "c" (^TwoPoleFilter, f32),
	setResonance:          proc "c" (^TwoPoleFilter, f32),
	setResonanceModulator: proc "c" (^TwoPoleFilter, ^PDSynthSignalValue),
	getResonanceModulator: proc "c" (^TwoPoleFilter) -> ^PDSynthSignalValue,
}

OnePoleFilter :: struct {}

sound_effect_onepolefilter :: struct {
	newFilter:             proc "c" () -> ^OnePoleFilter,
	freeFilter:            proc "c" (^OnePoleFilter),
	setParameter:          proc "c" (^OnePoleFilter, f32),
	setParameterModulator: proc "c" (^OnePoleFilter, ^PDSynthSignalValue),
	getParameterModulator: proc "c" (^OnePoleFilter) -> ^PDSynthSignalValue,
}

BitCrusher :: struct {}

sound_effect_bitcrusher :: struct {
	newBitCrusher:           proc "c" () -> ^BitCrusher,
	freeBitCrusher:          proc "c" (^BitCrusher),
	setAmount:               proc "c" (^BitCrusher, f32),
	setAmountModulator:      proc "c" (^BitCrusher, ^PDSynthSignalValue),
	getAmountModulator:      proc "c" (^BitCrusher) -> ^PDSynthSignalValue,
	setUndersampling:        proc "c" (^BitCrusher, f32),
	setUndersampleModulator: proc "c" (^BitCrusher, ^PDSynthSignalValue),
	getUndersampleModulator: proc "c" (^BitCrusher) -> ^PDSynthSignalValue,
}

RingModulator :: struct {}

sound_effect_ringmodulator :: struct {
	newRingmod:            proc "c" () -> ^RingModulator,
	freeRingmod:           proc "c" (^RingModulator),
	setFrequency:          proc "c" (^RingModulator, f32),
	setFrequencyModulator: proc "c" (^RingModulator, ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (^RingModulator) -> ^PDSynthSignalValue,
}

DelayLine :: struct {}

DelayLineTap :: struct {}

sound_effect_delayline :: struct {
	newDelayLine:          proc "c" (i32, i32) -> ^DelayLine,
	freeDelayLine:         proc "c" (^DelayLine),
	setLength:             proc "c" (^DelayLine, i32),
	setFeedback:           proc "c" (^DelayLine, f32),
	addTap:                proc "c" (^DelayLine, i32) -> ^DelayLineTap,

	// note that DelayLineTap is a SoundSource, not a SoundEffect
	freeTap: proc "c" (^DelayLineTap),
	setTapDelay:           proc "c" (^DelayLineTap, i32),
	setTapDelayModulator:  proc "c" (^DelayLineTap, ^PDSynthSignalValue),
	getTapDelayModulator:  proc "c" (^DelayLineTap) -> ^PDSynthSignalValue,
	setTapChannelsFlipped: proc "c" (^DelayLineTap, i32),
}

Overdrive :: struct {}

sound_effect_overdrive :: struct {
	newOverdrive:       proc "c" () -> ^Overdrive,
	freeOverdrive:      proc "c" (^Overdrive),
	setGain:            proc "c" (^Overdrive, f32),
	setLimit:           proc "c" (^Overdrive, f32),
	setLimitModulator:  proc "c" (^Overdrive, ^PDSynthSignalValue),
	getLimitModulator:  proc "c" (^Overdrive) -> ^PDSynthSignalValue,
	setOffset:          proc "c" (^Overdrive, f32),
	setOffsetModulator: proc "c" (^Overdrive, ^PDSynthSignalValue),
	getOffsetModulator: proc "c" (^Overdrive) -> ^PDSynthSignalValue,
}

SoundEffect :: struct {}

effectProc :: proc "c" (^SoundEffect, ^i32, ^i32, i32, i32) -> i32 // samples are in signed q8.24 format

sound_effect :: struct {
	newEffect:       proc "c" (effectProc, rawptr) -> ^SoundEffect,
	freeEffect:      proc "c" (^SoundEffect),
	setMix:          proc "c" (^SoundEffect, f32),
	setMixModulator: proc "c" (^SoundEffect, ^PDSynthSignalValue),
	getMixModulator: proc "c" (^SoundEffect) -> ^PDSynthSignalValue,
	setUserdata:     proc "c" (^SoundEffect, rawptr),
	getUserdata:     proc "c" (^SoundEffect) -> rawptr,
	twopolefilter:   ^sound_effect_twopolefilter,
	onepolefilter:   ^sound_effect_onepolefilter,
	bitcrusher:      ^sound_effect_bitcrusher,
	ringmodulator:   ^sound_effect_ringmodulator,
	delayline:       ^sound_effect_delayline,
	overdrive:       ^sound_effect_overdrive,
}

// A SoundChannel contains SoundSources and SoundEffects
SoundChannel :: struct {}

AudioSourceFunction :: proc "c" (rawptr, ^i32, ^i32, i32) -> i32 // len is # of samples in each buffer, function should return 1 if it produced output

sound_channel :: struct {
	newChannel:         proc "c" () -> ^SoundChannel,
	freeChannel:        proc "c" (^SoundChannel),
	addSource:          proc "c" (^SoundChannel, ^SoundSource) -> i32,
	removeSource:       proc "c" (^SoundChannel, ^SoundSource) -> i32,
	addCallbackSource:  proc "c" (^SoundChannel, AudioSourceFunction, rawptr, i32) -> ^SoundSource,
	addEffect:          proc "c" (^SoundChannel, ^SoundEffect) -> i32,
	removeEffect:       proc "c" (^SoundChannel, ^SoundEffect) -> i32,
	setVolume:          proc "c" (^SoundChannel, f32),
	getVolume:          proc "c" (^SoundChannel) -> f32,
	setVolumeModulator: proc "c" (^SoundChannel, ^PDSynthSignalValue),
	getVolumeModulator: proc "c" (^SoundChannel) -> ^PDSynthSignalValue,
	setPan:             proc "c" (^SoundChannel, f32),
	setPanModulator:    proc "c" (^SoundChannel, ^PDSynthSignalValue),
	getPanModulator:    proc "c" (^SoundChannel) -> ^PDSynthSignalValue,
	getDryLevelSignal:  proc "c" (^SoundChannel) -> ^PDSynthSignalValue,
	getWetLevelSignal:  proc "c" (^SoundChannel) -> ^PDSynthSignalValue,
}

RecordCallback :: proc "c" (rawptr, ^i32, i32) -> i32 // data is mono

MicSource :: enum u32 {
	Autodetect,
	Internal,
	Headset,
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
	uint32_t:          proc "c" (^i32) -> proc "c" () -> i32,
	addSource:         proc "c" (AudioSourceFunction, rawptr, i32) -> ^SoundSource,
	getDefaultChannel: proc "c" () -> ^SoundChannel,
	addChannel:        proc "c" (^SoundChannel) -> i32,
	removeChannel:     proc "c" (^SoundChannel) -> i32,
	setMicCallback:    proc "c" (RecordCallback, rawptr, MicSource) -> i32,
	getHeadphoneState: proc "c" (^i32, ^i32, proc "c" (i32, i32)),
	setOutputsActive:  proc "c" (i32, i32),

	// 1.5
	removeSource: proc "c" (^SoundSource) -> i32,

	// 1.12
	signal: ^sound_signal,

	// 2.2
	getError: proc "c" () -> cstring,
}

