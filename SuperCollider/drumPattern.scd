Server.default = s = Server.internal;
s.boot;

/* ----------------------
   Synthetic bass drum
   ---------------------- */

(
~bass = {
	arg amp=1;
	{
		var amp_env, phase_env, phase, freq, dur;

		freq = 100;
		dur = 0.25;

		amp_env   = EnvGen.ar(Env.perc(1e-6,dur), doneAction:2);
		phase_env = EnvGen.ar(Env.perc(1e-6,0.125));

		phase = SinOsc.ar(20,0,pi) * phase_env;
		SinOsc.ar([freq,1.01*freq],phase) * amp_env * amp;
	}
}
)
~bass.value.play;



/* ----------------------
   Synthetic snare
   ---------------------- */

(
~snare = {
	arg amp=0.5;
	{
		var amp_env, cut_freq, dur;

		cut_freq = 300;
		dur = [0.5, 0.125, 0.25].choose;

		amp_env = EnvGen.ar(Env.perc(1e-6, dur), doneAction:2);
		LPF.ar( {WhiteNoise.ar(WhiteNoise.ar)}.dup * amp_env, cut_freq ) * amp;
	}
}
)
~snare.value.play;



/* ----------------------
   Synthetic hi-hat
   ---------------------- */


~hat = {
	arg amp=0.5;
	{
		var amp_env, cut_freq, dur;

		cut_freq = 6000;
		dur = [0.0625, 0.125, 0.25].choose;

		amp_env = EnvGen.ar(Env.perc(1e-7, dur), doneAction:2);
		HPF.ar( {WhiteNoise.ar}.dup * amp_env, cut_freq ) * amp / 4;
	}
}

~hat.value.play;


/* ------------------------
   Simple 8-step sequencer
   ------------------------ */

~player = {
	arg beat_list, synth;
	{
		arg i;
		var amp = beat_list.wrapAt(i);
		if( amp>0, { synth.value(amp).play } );
	}
}

~bd_player = ~player.value([1, 0, 0, 0], ~bass);
~sn_player = ~player.value([1, 0.1, 0.75, 1, 0.175], ~snare);
~hh_player = ~player.value([1, 1, 0, 1], ~hat);


(
c = TempoClock.new(1);
~swing = 0.8; // swing amount
~times = [1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing]; // add swing
{
	inf.do{
		arg i;
		~bd_player.value(i);
		~sn_player.value(i);
		~hh_player.value(i);

		~times.wrapAt(i).wait;
	};

}.fork(c);
)

c.tempo = 4;

~bd_player = ~player.value([0], ~bass);
~sn_player = ~player.value([0], ~snare);
~hh_player = ~player.value([0], ~hat);