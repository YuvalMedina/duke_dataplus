var path, wavname, regionID, siteID, variable, line, list;

s.boot;

path = thisProcess.nowExecutingPath.dirname;
("File exists?:" + File.exists(path +/+ "flagged_sites.csv")).postln;

f = File(path +/+ "flagged_sites.csv", "r"); c = CSVFileReader(f); c.next.postln; c.next.postln;

regionID = "NC";
siteID = "Eno";
variable = "DOmgL";

//wavname = regionID ++ "_" ++ siteID ++ "_" ++ variable ++ ".wav";
//(path +/+ wavname).postln;
//w = SoundFile.openWrite(path +/+ wavname, "WAV", "float");

//b = Buffer.alloc(s, 44100, 1);

"got here1".postln;

(
line = c.next;
list = List.new;
while({line = c.next; line != nil}, if(line.at(0).compare(regionID) == 0 && line.at(1).compare(siteID) == 0 && line.at(3).compare(variable) == 0, {list.add(line.at(4).asFloat); line.at(4).asFloat.postln;} ));

"got here2".postln;

//w.writeData(list);

"got here3".postln;

//w.cue(b, true, true);
)

(
{
   // sets up the frequencies of both channels
   var frequencyL = SinOsc.kr( freq:10, mul:200, add:400 ); // oscillating
   var frequencyR = SinOsc.kr( freq:1, mul:50, add:150 ); // oscillating
   var frequencyL_drone = SinOsc.kr( freq:0.03, mul:20, add:100 ); // drone
   var frequencyR_drone = SinOsc.kr( freq:0.01, mul:20, add:210 ); // drone

   // changes the volume of the oscillating part in the left channel
   var volumeL = SinOsc.kr( freq:0.5, mul:0.02, add:0.03 );

   // left channel
   var left = [ SinOsc.ar( freq:frequencyL, mul:volumeL ), // this is the oscillating part
                SinOsc.ar( freq:[frequencyL_drone,2*frequencyL_drone], mul:0.02 ), // the rest make up the drone
                SinOsc.ar( freq:[3*frequencyL_drone,4*frequencyL_drone], mul:0.005 ),
                SinOsc.ar( freq:[5*frequencyL_drone,6*frequencyL_drone], mul:0.001 ) ];

   // right channel
   var right = [ SinOsc.ar( freq:frequencyR, mul:0.1 ), // this is the oscillating part
                 SinOsc.ar( freq:[frequencyR_drone,2*frequencyR_drone], mul:0.02 ), // the rest make up the drone
                 SinOsc.ar( freq:4*frequencyR_drone, mul:0.005 ),
                 SinOsc.ar( freq:[7*frequencyR_drone,8*frequencyR_drone], mul:0.01 ) ]; // high frequencies!

   [ left, right ];
}.play


)

File.delete(path + wavname);
