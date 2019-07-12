//receiving from iPython

s.boot;
NetAddr.langPort.postln;

(
SynthDef( \sin,	{ | amp = 0.01, freq = 291, trig = 1 |
	var env, sig;
	env = EnvGen.kr( Env.asr( 0.5, 0.9, 0.5 ), trig, doneAction: 0 );
	sig = SinOsc.ar( [ freq, freq ], 0.0, amp ) * env;
	Out.ar( [ 0 ], sig * 0.6);
}).add;

//reader for gpp, sinoscillators
h = Synth( \mysound, [ \amp, 0.01 , \freq, 300.0] );

x = OSCFunc( { | msg, time, addr, port |
	var pyFreq;

	pyFreq = msg[1].asFloat;
	( "freq is " + pyFreq ).postln;
	h.set( \freq, pyFreq );
}, '/print' );
)

s.record;
s.stopRecording;
s.freeAll;

(
SynthDef.new(\mysound, { | out=0, amp = 0.01, freq = 500, trig = 1 |
	var sig, env;
	env = EnvGen.kr( Env.asr( 0.5, 0.9, 0.5 ), trig, doneAction: 0 );
	sig = SinOsc.ar( [ freq, freq ],  0.0, amp ) * env;
	Out.ar( [ out ], sig * 0.6);
}).add;
)

(
SynthDef.new(\turbidity, { | out=0, vol = 0.01, trig = 1 |
	var sig, amp;
	amp = [SinOsc.kr(0.5, 0.2, 0.15, 0.85), SinOsc.kr(0.6, 0.9, 0.15, 0.85) ];
	sig = PinkNoise.ar(1!2) * amp;
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig * vol);
}).add;
)

(
//reader for turbidity, pinknoises
h = Synth( \turbidity, [ \vol, 0] );

x = OSCFunc( { | msg, time, addr, port |
	var pyVol;

	pyVol = msg[1].asFloat;
	( "vol is " + pyVol ).postln;
	h.set( \vol, pyVol );
}, '/print' );
)