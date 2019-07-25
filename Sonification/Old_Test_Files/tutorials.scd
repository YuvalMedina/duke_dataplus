s.boot;

x = {SinOsc.ar}.play;

x.free;

{SinOsc.ar(550, 0, 0.125, 0)}.play;

(
z = {
	arg freq=440, amp=1;
	var sig;
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\freq, 330);
z.set(\amp, 0.3);
z.set(\freq, 600, \amp, 0.4);
z.free;

(
z = {
	var freq, amp, sig;
	freq = LFNoise0.kr(8).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.free;


(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)
z.set(\noiseHz, 5);
z.free;

//now we make a Synth function that works same as z:
(
SynthDef.new(\sineTest, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sineTest);
x.free;
x = Synth.new(\sineTest, [\noiseHz, 32]);
x.set(\noiseHz, 12);
x.free;

//'round' rounds to the nearest multiple of a number, so this function generates random overtones of a fundamental! LFPulse will alternate between 1,2 (after adding 1) so will jump octaves as well
//from tutorial: "I'll use LFPulse again to control the amplitude and transform what would otherwise be a steady tone into regular pulses of sound. I'll specify a duty cycle that's close to zero, so that the pulses are fairly short. I'll set the phase of the 2nd amplitude control to 0.5 so that the two pulse waves are out of phase with one another. This way, the sound will alternate between the left and right speakers. And, I'll also multiply by 0.75 just to take down the volume a bit."
//In fact, let's use another argument for the amplitude pulse frequency. (ampHz)
//I'll add one last argument for the width of the pulse wave output, and fill in the parentheses at the bottom.
//Last, I'll add some reverb using FreeVerb to make it sound nice.
(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, sig1, sig2, freq1, freq2;
	amp1 = LFPulse.kr(ampHz,0,0.12)*0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12)*0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8)+1;
	freq2 = freq2 * LFPulse.kr(6)+1;
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

x = Synth.new(\pulseTest);
x.set(\width, 0.05);
x.set(\width, 0.5);
x.set(\fund, 50);
x.set(\fund, 60);
x.set(\fund, 70);
x.set(\fund, 80);
x.set(\fund, 160);
x.set(\fund, 30);
x.set(\maxPartial, 8);
x.set(\maxPartial, 20);
x.set(\maxPartial, 10);
x.set(\maxPartial, 30);
x.set(\maxPartial, 7);
x.set(\fund, 100);
x.set(\ampHz, 2);
x.set(\ampHz, 1);
x.set(\ampHz, 0.25);

x.free;

x = Synth.new(\pulseTest, [\ampHz, 3.3, \fund, 48, \maxPartial, 4, \width, 0.15]);
x.free;




x = {PinkNoise.ar * 0.5}.play;
x.free;
//envelopes control how a sound is shaped – mostly control amplitude but can easily control any other parameter. Useful for fade-outs/ins
//Let's start by looking at Line, which is the simplest of these envelopes.
Line.kr();

(
x = {
	var sig, env;
	env = Line.kr(1,0,1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play;
)

x.free;
s.freeAll;

//XLine is exponential – if we give it an ending point of 0 it will fail to produce sound...
(
{
	var sig, env;
	env = XLine.kr(1,0.0000001,1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play;
)

//Suppose our XLines had different durations and both had doneAction:2. In this case, whichever finishes first will free the Synth
(
{
	var sig, env, freq;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)


Env.new.plot;

(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play;
)

//Triangle envelopes are all well and good, but let's provide our own arguments for Env.new. We'll start by changing the levels array. The envelope will start at zero, rise to 1, fall to 0.2, and then fall all the way back to zero from 0.2. Since there are now four level points, I'll need three durations in the second array. I'll use 0.5, 1, and 2 seconds. I'll leave the curve argument alone for now and plot the Env, so that we can see that we have four level values, with linear interpolation, with durations equal to 0.5, 1, and 2.
Env.new([0,1,0.1,0.01],[0.5,1,2], \exp).plot;
//But a more flexible option is to use a third array of numbers to specify segment curvatures. Positive values make the segment change slowly at first, then quickly, while negative values make the segment change quickly at first, then level off. The size of this array should be equal to the size of the second array, since we need one curvature value for each breakpoint segment.
Env.new([0,1,0.1,0], [0.5,1,2], [\sine,\sine,0]).plot;

(
x = {
	arg gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), gate);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

x.set(\gate, 1);
x.set(\gate, 0);
x.set(\gate, 1);
x.free;

//but there's a special gate argument to automatically retrigger:
(
x = {
	arg t_gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), t_gate);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

x.set(\t_gate, 1);
x.free;

//adsr envelope: attack-decay-sustain-release
//Notice that it makes less sense to use a t-underscore argument for a gate when dealing with a sustainable envelope. If we were to use a trigger argument, then as soon as the envelope is triggered, t_gate will almost immediately return to zero, which will trigger the release phase of the adsr envelope.
(
x = {
	arg gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500,1000)) * env;
}.play;
)

x.set(\gate, 0);
x.free;

(
x = {
	arg gate=0;
	var sig, env, freq;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	sig = VarSaw.ar(SinOsc.ar(freq).range(300,500)) * env;
}.play
)
x.set(\gate, 1);
x.set(\gate, 0);


//multichannel:
x = {[SinOsc.ar(300), SinOsc.ar(600)]}.play;
x.free;
x = {SinOsc.ar([300, 500])}.play;
x.free;

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7,1]).range(0,1);
	sig = SinOsc.ar([300,500]);
	sig = sig * amp;
}.play;
)

//mix takes a lot of signals into one channel, and we're scaling by 1/4th to avoid audio clipping
(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	//sig = [Mix(sig), Mix(sig)] * 0.25;
	//also can use function dup!
	//sig = Mix(sig).dup(2) * 0.25;
	//shorthand for dup is the exclamation mark
	sig = Mix(sig)!2 * 0.25;
}.play;
)

x.free;

//Splay is a nicer version of mix for splitting audion down into multiple channels (like 2)
(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
}.play;
)

x = {PinkNoise.ar(0.5)!2}.play;
//important nuance – below we PinkNoise receives two arguments and generates different noise for each. Above, an exact copy of the same PinkNoise object is given to each channel.
x = {PinkNoise.ar(0.5!2)}.play;
x.free;

//important, don't invoke multichannel expansion on the Out object, it won't behave as expected. Instead, just Splay the signal/invoke mult. exp. on the object and give it to Out
(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

rrand(50,1200)!4; //this creates an exact copy
{rrand(50,1200)}!4; //here we duplicated the function, and different instance of function random behave in different ways!

//with the curly brackets the expansion below works perfectly – without them the random will be exact copies of each other...
(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr({exprand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({exprand(50,1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)
//^^But, using the language operator exprand, even with curly braces, isn't the best option for SynthDefs. Using lowercase exprand in a SynthDef chooses random values when the SynthDef is compiled, and these random values remain fixed, for every instance of Synth that's created. So here, even though I'm creating several Synths, you can hear that the randomly chosen values are the same each time.

x = Synth.new(\multi);
x.free;

//The best option is to use the UGen ExpRand, with capital E capital R. While lowercase exprand picks values when the SynthDef is compiled, uppercase ExpRand chooses random values when the Synth is created
(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

s.freeAll;


//iteration:
(
[6, 4, 0.5, 10, 7].do{
	arg item, count;
	[count, item.squared].postln;
}
)
(
x = Array.newClear(5);

[6, 4, 0.5, 10, 7].do{
	arg item, count;
	x[count] = item.squared;
};
)

(
z = [6, 4, 0.5, 10, 7].collect{
	arg item;
	item.squared;
};
)
//or:
z = [6, 4, 0.5, 10, 7].collect(_.squared);

[0,1,2,3,4].do{arg item; item.postln};
//same as:
5.do{arg item; item.postln};

(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99,1.02)}!2,
			0,
			0.05
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

//Right off the bat, this sounds a lot more interesting than the single VarSaw. But as you might have heard, there's a huge pop at the beginning of this sound. And it's pretty ugly. and that's because these VarSaws all have the same initial phase offset, zero. So if we randomize the phase as well, we can smooth out the sound a bit.
(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(40 * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, 0.05);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

//And, you know, while we're at it, we could randomize the duty cycle as well.
(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum, env;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	sum = 0;
	10.do{
		temp = VarSaw.ar(freq * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, {ExpRand(0.005, 0.05)}!2);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

//If you prefer, you can deal in midi note numbers, using the method 'midicps'
Synth.new(\iter, [\freq, 66.midicps]);
Synth.new(\iter, [\freq, 73.midicps]);
Synth.new(\iter, [\freq, 80.midicps]);
Synth.new(\iter, [\freq, 75.midicps]);

//can use iteration to create multiple synths!
(
[53,59,63,68].do{
	arg midinote;
	Synth.new(\iter, [\freq, midinote.midicps]);
};
)

//Here, is another example. Unlike the previous SynthDef, this time I'll actually incorporate the iteration count into the audio manipulation. So I'll define an argument within the iteration block, call it 'count'. Notice that I don't actually need a second argument for the iteration count, because when using integer dot do, the items in the collection and the iteration count are actually the same stream of numbers, so using two arguments is redundant. I'll create an overtone of a fundamental pitch by multiplying the frequency by the iteration count. I have to add one because the iteration count starts at zero, and we don't want an oscillator with a frequency of 0Hz. The rest of this example is no different from the previous example.
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count+1));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);
x.free;

//What we hear is a stack of 10 partials with a fundamental of 200Hz. Now, granted, there's already a UGen that does this, called blip.
x = {Blip.ar(200, 10, 0.5)}.play;
x.free;

//we can also make each overtone meander slightly with LFNoise1, let's also invoke multichannel expansion:
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count+1) * LFNoise1.kr({Rand(0.05,0.2)}!2).range(0.98,1.02));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);
x.set(\freq, 50);
x.free;

s.boot;
s.plotTree;
s.meter;

s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 2;
s.reboot;
s.meter;

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out,sig);
}).add;
)

y = Synth.new(\reverb, [\in, 6]);
x = Synth.new(\blip, [\out, 6]);

x.set(\out, 25);
y.set(\in, 25);
x.free;
y.free;

~reverbBus = Bus.audio(s, 1);
~reverbBus.index;

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);

x.free;
y.free;

//Pan2 pans a monophonic signal across multichannel
(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise0.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\blip, [\out, 0]);
x.free;

~reverbBus2 = Bus.audio(s, 2);
y = Synth.new(\reverb, [\in, ~reverbBus2]);
x = Synth.new(\blip, [\out, ~reverbBus2]);
x.free;
y.free;

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);
x.free;
y.free;

//"if you have a synth on the server (i.e. an "effect") that depends on the output from another synth (the "source"), the effect must appear later in the chain of nodes on the server than the source." ::
x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2]);
s.freeAll;


x = Synth.new(\blip, [\out, 0]);
g = Group.new;
x.free;
g.free;

//I'm specifying the local server as a target, which means these Synths will end up in the default group of the local server. And now the order in which we create these nodes doesn't matter, because the effect Synth will always be added to the very end of the default group.
x = Synth.new(\blip, [\out, ~reverbBus2], s);
y = Synth.new(\reverb, [\in, ~reverbBus2], s, \addToTail);
x.free;
y.free;

//Here's another way to place these nodes in the correct order
x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2], x, \addAfter);
x.free;

x = Synth.before(y, \blip, [\out, ~reverbBus2]);
x.free;
y.free;

~sourceGrp = Group.new;
~fxGrp = Group.after(~sourceGrp);

x = Synth.new(\blip, [\out, ~reverbBus2], ~sourceGrp);
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGrp);
x.free;

(
SynthDef.new(\blip, {
	arg out, fund=330, dens=2, decay=0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;
)

8.do{Synth.new(\blip, [\out, ~reverbBus2, \fund, exprand(60,300).round(30)], ~sourceGrp)};

~sourceGrp.set(\decay, 0.05);
~sourceGrp.set(\dens, 12);
~sourceGrp.set(\dens, 0.25);
~sourceGrp.set(\decay, 1);

~sourceGrp.freeAll;
s.freeAll;
	