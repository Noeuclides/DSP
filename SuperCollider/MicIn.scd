s.reboot;

s.meter;



(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
}.play;
)

x.free;

(
x = {
	var sig, rmod;
	sig = In.ar(2!2);
	rmod = sig * SinOsc.ar(5000);
	(sig + rmod) * 0.8;
	Out.ar (0,sig);
}.play;
)
(
SynthDef.new(\mic, {
	arg in= 0, out=0, deleytime= 12, mix =(-5),amp=0.5;
	var sig, delay;
	sig = SoundIn.ar(in!2)*amp;
	delay = DelayL.ar(sig,5, deleytime);
	sig = XFade2.ar(sig,delay,mix);
	Out.ar(out,sig);
}).add;
)
x = Synth (\mic);

x.free;

(
SynthDef.new(\mic, {|in= 0, out=0 , mix =(-0.5), decay = 3, amp=0.5|
	var sig, delay;
	sig = SoundIn.ar(in!2)*amp;
	delay = CombL.ar(sig,0.5,SinOsc.kr(0.3).exprange(0.1,0.4),decay);
	sig = XFade2.ar(sig,delay,mix);
	Out.ar(out,sig);
}).add;
)

x = Synth (\mic);

Ndef(\mic).gui


x.free;


(
Ndef(\mic, {|in= 0, out=0 , mix =(-0.5), decay = 10, amp=0.5, maxdelay=5|
	var sig, delay;
	sig = SoundIn.ar(in!2)*amp;
	delay = CombL.ar(sig,maxdelay,SinOsc.kr(0.8).exprange(0.1,0.4),decay);
	sig = XFade2.ar(sig,delay,mix);
	Out.ar(out,sig);
}).add;
)
Ndef(\mic).gui