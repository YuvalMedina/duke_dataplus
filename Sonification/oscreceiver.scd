//receiving from python-osc
var path, wavname, site, region, variable, start, stop, setvar;

s.boot;
NetAddr.langPort.postln;
path = thisProcess.nowExecutingPath.dirname;




SynthDef.new(\gppsound, { | out=0, amp = 0.01, freq = 500, trig = 1 |
	var sig, env;
	env = EnvGen.kr( Env.asr( 0.5, 0.9, 0.5 ), trig, doneAction: 0 );
	sig = SinOsc.ar( [ freq, freq ],  0.0, amp ) * env;
	Out.ar( [ out ], sig * 0.6);
}).add;

SynthDef.new(\discharge, { | out=0, vol = 0.01, trig = 1 |
	var sig, amp;
	amp = [SinOsc.kr(0.5, 0.2, 0.15, 0.85), SinOsc.kr(0.6, 0.9, 0.15, 0.85) ] * vol;
	amp = CombC.ar(amp, 0.2, 0.2, 1.0, 1.0);
	sig = PinkNoise.ar(1!2) * amp;
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig);
}).add;

x = SynthDef(\thunder,{ arg out = 0, bufnum=b.bufnum;
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)) * env;
	Out.ar( out, sig)
}).add;

SynthDef(\dissolved_oxygen, { arg out=0, vol=0.01, freq=0.0, trig=1;
	var sig, mod=5;
	sig = Pan2.ar(LFTri.ar(freq + (freq * SinOsc.ar(mod,0,0.02))));
	Out.ar(0, sig * vol);
}).add;




x = OSCFunc( { | msg, time, addr, port |
	site = msg[1].asFloat;
	( "site is " + site ).postln;
}, '/site' );

y = OSCFunc( { | msg, time, addr, port |
	region = msg[1].asFloat;
	( "region is " + region ).postln;
}, '/region' );

setvar = OSCFunc( { | msg, time, addr, port |
	variable = msg[1].asFloat;
	( "recording " + variable ).postln;
}, '/variable' );

start = OSCFunc( { | msg, time, addr, port |
	s.record;
	x = case
	{ variable == 'GPP' }   { h = Synth( \gppsound, [ \amp, 0.1 , \freq, 0.0] ); }
	{ variable == 'DO_mgL' } { h = Synth( \dissolved_oxygen, [ \freq, 0] ); }
	{ variable == 'Discharge_m3s' } { h = Synth( \discharge, [ \vol, 0] ); };
}, '/start' );

stop = OSCFunc( { | msg, time, addr, port |
	s.stopRecording;
	s.freeAll;
}, '/stop' );




//reader for gpp, sinoscillators
x = OSCFunc( { | msg, time, addr, port |
	var pyFreq;

	pyFreq = msg[1].asFloat;
	( "freq is " + pyFreq ).postln;
	h.set( \freq, pyFreq );
}, '/gpp' );

//reader for discharge -- pinknoises
x = OSCFunc( { | msg, time, addr, port |
	var pyVol;

	pyVol = msg[1].asFloat;
	( "vol is " + pyVol ).postln;
	h.set( \vol, pyVol );
}, '/discharge' );

//reader for discharge -- thunder
y = OSCFunc( { | msg, time, addr, port |
	var trigger;

	trigger = msg[1].asFloat;
	if (trigger == 1, {b = Buffer.read(s, "/Users/yuvalmedina/Downloads/verysharp_thunder.aif");
		g = Synth(\thunder, [\bufnum, b.bufnum] );});
}, '/thunder' );

//reader for dissolved oxygen
x = OSCFunc( { | msg, time, addr, port |
	var pyFreq;

	pyFreq = msg[1].asFloat;
	( "std dev is " + pyFreq ).postln;
	h.set( \freq, pyFreq * 2000 + 1000 );
}, '/DO' );