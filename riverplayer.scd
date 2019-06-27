var path, file;

path = thisProcess.nowExecutingPath.dirname;
file = "NC_Eno_DO_mgL";

s.boot;


d = Buffer.read(s, path +/+ "wav_files" +/+ file ++ ".wav");

(path +/+ "wav_files" +/+ file ++ ".wav").postln;

~soundingGrp = Group.new;
~reverbGrp = Group.after(~soundingGrp);


(
SynthDef.new(\enoriver, {
	arg buffer, out;
	var in, chain, sig;
    in = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer), loop: 1);
    chain = FFT(LocalBuf(2048), in);
	chain = PV_MagBelow(chain, 0.5);
	sig = IFFT(chain);
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\enoriver, [\buffer, d, \out, 0]);
x.free;

s.record;
s.stopRecording;

(
SynthDef.new(\virtualStream, {
	arg buffer, out;
	var in, chain, sum;
	sum = 0;
    in = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer), loop: 1);
    chain = FFT(LocalBuf(2048), in);
	chain.pvcollect(20, {|mag, phase, index|
		var temp;
		temp = SinOsc.ar(index, 0, mag);
		sum = sum + temp;
	});
	Out.ar(out, sum * 0.01);
}).add;
)
​
x = Synth.new(\virtualStream, [\buffer, d, \out, 0], ~soundingGrp);
x.free;

(
SynthDef.new(\streamProcessor, {
	arg in, out=0, vol=0.3, midi=60;
	var sig, sum, temp, amp, env;
	sum = 0;
	[midi.midicps, (midi+3).midicps, (midi+5).midicps, (midi+7).midicps, (midi+9).midicps].do{
		arg freq;
		temp = SinOsc.ar(freq!2, 0.5!2, 1!2);
		sum = sum + temp;
	};
	sig = FreeVerb.ar(sum / 64, 0.3, 0.6, 0.5) * (in * in) * 0.4;
	Out.ar(out, sig * vol * 0.2);
}).add;
)

y = Synth.new(\streamProcessor, [\in, 25], ~soundingGrp);
s.record;
s.stopRecording;
y.free;

(
SynthDef.new(\pinknoises, {
	arg out=0, vol=0.5;
	var sig, ampL, ampR;
	ampL = SinOsc.kr(0.5, 0.2, 0.15, 0.85);
	ampR = SinOsc.kr(0.6, 0.9, 0.15, 0.85);
	sig = PinkNoise.ar(1!2);
	sig = sig * [ampL, ampR];
	sig = FreeVerb.ar(sig);
	Out.ar(out, sig);
}).add;
)

z = Synth.new(\pinknoises, [\vol, 0.5], ~soundingGrp);
s.record;
s.stopRecording;
z.free;

(
FFT{
	var in, chain;
	f = SoundFile.new;
	f.openRead(path +/+ "wav_files" +/+ file ++ ".wav");

	f.readData(chain);

)

s.freeAll;






var path, gppfile;

path = thisProcess.nowExecutingPath.dirname;
gppfile = "gpp_list";

s.boot;

d = Buffer.read(s, path +/+ "csv_files +/+