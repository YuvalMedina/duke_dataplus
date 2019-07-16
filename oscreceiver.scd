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
h = Synth( \gppsound, [ \amp, 0.1 , \freq, 0.0] );

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
SynthDef.new(\gppsound, { | out=0, amp = 0.01, freq = 500, trig = 1 |
	var sig, env;
	env = EnvGen.kr( Env.asr( 0.5, 0.9, 0.5 ), trig, doneAction: 0 );
	sig = SinOsc.ar( [ freq, freq ],  0.0, amp ) * env;
	Out.ar( [ out ], sig * 0.6);
}).add;
)

(
SynthDef.new(\discharge, { | out=0, vol = 0.01, trig = 1 |
	var sig, amp;
	amp = [SinOsc.kr(0.5, 0.2, 0.15, 0.85), SinOsc.kr(0.6, 0.9, 0.15, 0.85) ] * vol;
	amp = CombC.ar(amp, 0.2, 0.2, 1.0, 1.0);
	sig = PinkNoise.ar(1!2) * amp;
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig);
}).add;
)

(
//reader for discharge, pinknoises, then thunder

h = Synth( \discharge, [ \vol, 0] );

x = OSCFunc( { | msg, time, addr, port |
	var pyVol;

	pyVol = msg[1].asFloat;
	( "vol is " + pyVol ).postln;
	h.set( \vol, pyVol );
}, '/print' );

y = OSCFunc( { | msg, time, addr, port |
	var trigger;

	trigger = msg[1].asFloat;
	if (trigger == 1, {b = Buffer.read(s, "/Users/yuvalmedina/Downloads/verysharp_thunder.aif");
		g = Synth(\thunder, [\bufnum, b.bufnum] );});
}, '/thunder' );
)


// now play it
(
x = SynthDef(\thunder,{ arg out = 0, bufnum=b.bufnum;
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)) * env;
	Out.ar( out, sig)
}).add;
)
x.free; b.free;


(
SynthDef(\dissolved_oxygen, { arg out=0, vol=0.01, freq=0.0, trig=1;
	var sig, mod=5;
	sig = Pan2.ar(LFTri.ar(freq + (freq * SinOsc.ar(mod,0,0.02))));
	Out.ar(0, sig * vol);
}).add;
)

(
SynthDef(\dissolved_oxygen2, { arg out=0, vol=0.0, trig=1;
	var sig, env;
	sig = ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 14)
		* 400 + 500, 0.03, 0.003)}!2)
	+ ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
		* 800 + 1000, 0.03, 0.005)}!2)
	* vol;
	Out.ar(out, sig);
}).add;
)

(
//reader for dissolved oxygen 1

h = Synth( \dissolved_oxygen, [ \freq, 0] );

x = OSCFunc( { | msg, time, addr, port |
	var pyFreq;

	pyFreq = msg[1].asFloat;
	( "freq is " + pyFreq ).postln;
	h.set( \freq, pyFreq * 2000 + 1000 );
}, '/print' );

//reader for dissolved oxygen 2 – not recorded, not working yet
h = Synth( \dissolved_oxygen, [ \vol, 0] );

x = OSCFunc( { | msg, time, addr, port |
	var pyVol;

	pyVol = msg[1].asFloat;
	( "vol is " + pyVol ).postln;
	h.set( \vol, pyVol);
}, '/print' );
)
s.record;
s.stopRecording;
s.freeAll;