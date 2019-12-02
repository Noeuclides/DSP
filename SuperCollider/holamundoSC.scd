"Hola Mundo".class.postln

1.class

1.0.class

"a".class

a = "hola mundo"
// métodos

a.postln

a.reverse
a.rotate(n: 4)

b = "Qué Onda?"
(
a.postln;

b.postln;
)

// variables globales a - z o ~name
~rosita = 8

a = 8

(
var x = 4.postln;
(x + a).postln;

(x + (x*a));

)

[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].rand

y = 10.collect{|i| i*100};

y = 10.collect{|i| (i+1)*100};


10.do {|i| "lanzamiento % = %".format(i, 0.5.coin).postln};

10.do {|i| rrand(23, 33).postln};


//síntesis

s.boot
s.quit

1 ! 4
a = {SinOsc.ar(XLine.kr(600, 50, 15), 0, mul: 0.5)};

a.play;
a.scope;

// usar MouseX
{SinOsc.ar(MouseX.kr(100, 1000))}.play;

//AM
~am = {SinOsc.ar( freq: 440, phase: 0, mul: SinOsc.kr(0.1, 0, 0.5, 0.5) * 0.5)}.plot;
~am = {SinOsc.ar( freq: 440, phase: 0, mul: SinOsc.kr(100).range(0, 1) * 0.5)}.play;

//Ring mod
~rm = {(SinOsc.ar(440) * SinOsc.ar(120)) ! 4};
~rm.scope;

// síntesis aditiva
(
{
	var n = 8;
	var intervalo = 100;
	var amplitud = 1/n; //escalar la amplitud de cada oscilador, en caso contrario la señal se distorsiona
	var frecs = n.collect{|i| (i+1)*intervalo}.postln;
	var oscs = frecs.collect{|i| SinOsc.ar(i)*amplitud};
	oscs.sum ! 2;
}.play

)


// Substractiva
{LPF.ar(WhiteNoise.ar(1), MouseX.kr(80, 10000)) * 0.25}.play


(
{
	var modFrec = VarSaw.ar(0.15).rand(200, 15000); // onda triangular en el rango 20-15000
	var modBand = SinOsc.ar(30).range(0.1, 2);
	var filtro = Resonz.ar(WhiteNoise.ar(1), modFrec, modBand);
	var amp = 0.8;
	filtro*amp ! 2;
}.play
)

(
{
	var ruido = WhiteNoise.ar(1);
	var freq = [300, 500 ,800, 1600];
	var amps = [0.5, 0.75, 0.8, 1];
	var tres = [1, 1, 1, 1];
	var resonador = DynKlang.ar(`[freq, amps, tres], ruido * 0.25);
	resonador * 0.1 ;
}.play(rrand(0, 1), rrand(0, 1));
)
rrand(0, 1);
(
{
	var ruido = WhiteNoise.ar(1);
	var frecs = [300, 500, 800, 1600];
	var amps = [1, 1, 1, 1];
	var resonanciasT = [1, 1, 1, 1];
	var resonador = DynKlank.ar(`[frecs, amps, resonanciasT], ruido * 0.25);
	resonador * 0.015;
}.play(rrand(0, 1), rrand(0,1));
)

// Envelopers

Env.perc(attackTime: 1, releaseTime: 1,level: 1,curve: -4).plot;
Env.perc(attackTime: 1, releaseTime: 1,level: 1,curve: 4).plot;

{SinOsc.ar(880, 1,1)*EnvGen.kr(Env([0, 0.7, 0.25], [0.25, 1]), doneAction:2) * 0.25}.play

(
{
	var freqEnv = Env([600, 1000, 50], [0.25, 0.1], \lin);
	var ampEnv = Env([0, 1, 1, 0], [0.01, 0.25, 0.1], \lin);
	var genFreq = EnvGen.kr(freqEnv, doneAction: 2);
	var genAmp = EnvGen.kr(ampEnv, doneAction: 2);
	var sin = SinOsc.ar(genFreq, mul: genAmp);
	sin * 0.5 ! 2;
}.play
)



// Synthdef

(
SynthDef(\simple, { | freq = 440, amp = 0.25, rel = 1 |
	var sig = SinOsc.ar(freq) * EnvGen.kr(Env.perc(releaseTime: rel), doneAction: 2);
	Out.ar([0,1], sig * amp);
}).add;
)

(
if(0.5.coin) {
	Synth(\simple);
}{
	Synth(\simple, [\freq, 840]);
}
)

(
var valor = [0, 1, 2].choose;
switch(valor.postln)
{0} {Synth(\simple)}
{1} {Synth(\simple, [\freq, 670])}
{2} {Synth(\simple, [\freq, [880*1.75, 880*1.25, 880*2.25].wchoose([2, 1, 2].normalizeSum), \amp, 0.1])};
)

Env.adsr(0.1, 0.3, 0.8, 1).plot;



// MIDI

(
SynthDef(\algo, {| freq = 100, filtro = 450, amp = 0.25 |
	var osc = VarSaw.ar(freq);
	Out.ar(0, BPF.ar(osc ! 2, filtro) * amp);
}).add;
)

x = Synth(\algo);
x.set(\freq, 220);


MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.cc(\micontrol, {| val, cc, canal|
	cc.postln;
	switch(cc)
	{1} {x.set(\freq, val.linlin(0, 127, 100, 1000));}
	{2} {x.set(\filtro, val.linlin(0, 127, 300, 1600));}
	{3} {x.set(\amp, val.linlin(0, 127, 0, 1));}
	{4} {"knob4 val %".format(val).postln;}

}
);
)


UGens

a = { LFPulse.ar(XLine.kr(1000,15000,5),0,1,0.1) }.scope(1, zoom: 4);



// 4. LIVE CODING CON SC PARTE I


// Opción 1. Jit Lib (Just in Time Library) escrita por Julian Rohruber.



p = ProxySpace.push; // Crear un espacio proxy, que permite evaluar todo el tiempo una función, asignarle una función y enviarlo al servidor.



().play // sonido por defecto en SC




// Variables globales ~ (o de la a.. z). otras van con ~


{SinOsc.ar([440, 220, 880], 0, 1)}.play

~andromeda = {SinOsc.ar(440, 0, 1) * 0.5}
~andromeda.play
// ~andromeda.play(0, 2) // (bus, número de canales)
~andromeda.stop
~andromeda.clear //quita del servidor


//GUIs
s.makeWindow // crea GUI para el servidor
s.scope() //podemos ver la forma de onda con scope
s.meter //muestra un metro gráfico de amplitud y canales


//  varios osciladores que podemos usar con SC (Saw, Pulse, VarSaw, WhiteNoise, PinkNoise, GrayNoise)

~rafa = {Saw.ar()}
~rafa.play
~rafa.stop

~laura = {PinkNoise.ar()};
~laura.play;
~laura.stop;

~sebas= { Pulse.ar };
~sebas.play;
~sebas.stop;

~andromeda.play;~rafa.play;~laura.play; ~sebas.play;

~andromeda.stop;~rafa.stop;~laura.stop; ~sebas.stop;


//comencemos a introducir valores para los parámetros para cada tipo de onda. No olvides ir a la ayuda del Help browser.


~andromeda = { SinOsc.ar(400, mul: 0.7 )  }; ~andromeda.play

//cambia los valores, ejecuta nuevamente y sabrás qué esta ocurrindo


//Ahora vamos a ponernos más musicales, con sólo esto.
p.fadeTime =5; // Hace que desde el Espacio Proxy, todo lo que se ejecute tenga un tiempo de fade out y otro de fade in --> crossfade.

~rm.fadeTime = 5
~rm.play
~rm.stop(10)

~am.play
~am.stop(20)


~andromeda = { SinOsc.ar([200, 800].rand)  };
~andromeda.play;
~andromeda.stop(10)//[] permite hacer arrays (contenedor de varios objetos, cada uno con su índice, y pueden ser de diferentes clases, p.e. [integral, float, string]), y el método .rand nos devuelve valores aleatorios de los valores dentro del array.
//Si queremos Multichannel Expansion -->
// s.options.numOutputBusChannels = 8;  //ejemplo para octofonía
// s.boot;
// command + m --> mixer
// {Out.ar(bus: , channelsArray:)} // --> sobreescribir orden de buses de salida de un array en una función.
//! --> número de repeticiones que devuelve un array del tamaño asignado. Funciona sobre números, strings y señales.
// 1 ! 2
// "hola mundo" ! 4
// {SinOsc.ar(440) ! 2 * 0.25}.play

~andromeda.play
~andromeda.stop(10) // el tiempo que tarda en silenciar el sonido

~dientigre= {VarSaw.ar([[160, 321, 483].rand + [320, 644, 968].rand].choose)}; //choose escoge elementos dentro del array.
~dientigre.play
~dientigre.vol = 0.4 //controlamos el volumen
~dientigre.fadeTime = 5 // fadeTime también nos permite el crossfade a nivel individual por cada sonido.
~dientigre.stop(5)

             // CONGRATS! CON ESTO YA TE PUEDES MONTAR UNA PERFORMANCE DE LIVE CODING BIEN EXPERIMENTAL!


{WhiteNoise.ar()}.scope

Dust

/// Síntesis substractiva con filtros resonantes


(
{
    var ruido = WhiteNoise.ar(1.0.rand(0.1));
    var frecs = [300, 500, 800, 1600, 10000].rand;
    var amps = [0.5, 0.75, 0.8, 1.0, 0.5].rand;
    var tRes = [1, 1, 1, 1, 1];
    var resonador = DynKlank.ar(`[frecs, amps, tRes], ruido * 0.5) ! 2;
    resonador * 0.015;


}.play;
)


//reemplazar con Impulse, Dust, PinkNoise, etc

(
{
    var impulso = Dust.ar(8.0.rand, 0.4.rand);
    var frecs = [300, 500, 800, 1600, 10000].rand;
    var amps = [0.5, 0.75, 0.8, 1.0, 0.5].rand;
    var tRes = [1.0, 1.0, 1.0, 1.0, 1.0].rand;
    var resonador = DynKlank.ar(`[frecs, amps, tRes], impulso);
    resonador ! 2;

}.play;
)
