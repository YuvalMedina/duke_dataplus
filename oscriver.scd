
//my Synth!

~sourceGrp = Group.new;
~backgroundGrp = Group.after(~sourceGrp);

(
SynthDef.new(\streambackground, {
	arg vol=0.5, out=0;
	var totalfreq, temp, ampL, ampR, adjvol;
	adjvol = vol;
	temp = PinkNoise.ar(adjvol);
	ampL = SinOsc.kr(0.7, 0.2, 0.1, 0.9);
	ampR = SinOsc.kr(0.6, 0.9, 0.1, 0.9);
	totalfreq = temp * [ampL, ampR];
	totalfreq = FreeVerb.ar(totalfreq, 0.4, 0.5, 0.2);
	Out.ar(out, totalfreq * 0.06 * adjvol);
}).add;
)


[midi.midicps, (midi+3).midicps, (midi+5).midicps, (midi+7).midicps, (midi+9).midicps].do{
	arg freq;

};

(
SynthDef.new(\harp, {
	arg vol=0.3, midi=60, out=0, gate=1.0;
	var freq=midi.midicps, sig, sum, temp, amp, env;
	sum = 0;
	[midi.midicps, (midi+3).midicps, (midi+5).midicps, (midi+7).midicps, (midi+9).midicps].do{
		arg freq;
		temp = SinOsc.ar(freq!2, 0.5!2, 1!2);
		sum = sum + temp;
	};
	env = EnvGen.kr(Env.adsr(0.6,5.0,3.0,1.0), gate, doneAction:2);
	sig = FreeVerb.ar(sum / 64, 0.3, 0.6, 0.5) * env;
	Out.ar(out, sig * vol);
}).add;
)

Synth.new(\harp, [\vol, 0.3], ~backgroundGrp);
Synth.new(\streambackground, [\vol, 1.0], ~backgroundGrp);

s.freeAll;

~backgroundGrp.freeAll;

x = Synth(\streambackground);
x.set(\vol, 1.0);
x.free;
s.freeAll;

(
SynthDef.new(\underwaternoises, {
	arg vol=0.5;
	