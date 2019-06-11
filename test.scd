(
{ SinOsc.ar( [[200, 200*2, 200*3, 200*4, 200*5, 200*6],
              [200, 200*2, 200*3, 200*4, 200*5, 200*6]],
             0,
             0.2 ); }.play;
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
                SinOsc.ar( freq:[5*frequencyL_drone,7*frequencyL_drone], mul:0.005 ),
                SinOsc.ar( freq:[13*frequencyL_drone,28*frequencyL_drone], mul:0.001 ) ];

   // right channel
   var right = [ SinOsc.ar( freq:frequencyR, mul:0.1 ), // this is the oscillating part
                 SinOsc.ar( freq:[frequencyR_drone,2*frequencyR_drone], mul:0.02 ), // the rest make up the drone
                 SinOsc.ar( freq:4*frequencyR_drone, mul:0.005 ),
                 SinOsc.ar( freq:[64*frequencyR_drone,128*frequencyR_drone], mul:0.01 ) ]; // high frequencies!

   [ left, right ];
}.play
)

(
{
	var 