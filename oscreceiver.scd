//receiving from iPython

s.boot;
NetAddr.langPort.postln;

(
SynthDef( \sin,	{ | amp = 0.01, freq = 291, trig = 1 |
	var env, sig;
	env = EnvGen.kr( Env.asr( 0.5, 0.9, 0.5 ), trig, doneAction: 0 );
	sig = SinOsc.ar( LFPulse.kr([freq, freq], 0.0, 40, 300), 0.0, amp ) * env;
	Out.ar( [ 0 ], sig * 0.6);
}).add;

h = Synth( \mysound, [ \amp, 0.0001 , \freq, 0.0] );

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
	sig = SinOsc.ar( [ freq, freq ], 0.0, amp) * env;
	Out.ar( [ out ], sig * 0.6);
}).add;
)


