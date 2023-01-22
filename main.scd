s.boot;
s.quit;

"./firstSpecies.scd".load;

(
// ----- SCALE ------
~scale = Scale.major;

// ----- REPETITIONS ------
~repetitions = 1;

// ----- MELODY 1 ------

// melody must start and end on tonic
~melodyTones = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 8, 3, 5, 2, 1, 0];
~melodyDurations = Array.fill(~melodyTones.size, 1);

~melody = Pbind(
	\scale, ~scale,
	\degree, Pseq(~melodyTones, ~repetitions),
	\dur, Pseq(~melodyDurations, ~repetitions)
);

// ----- MELODY 2 ------

~counterMelodyTones = Array.new(maxSize: ~melodyTones.size);
~melodyTones.do({ arg item, i;  ~counterMelodyTones.add(~getcounterMelodyTone.value(item, i)) });
~counterMelodyDurations = Array.fill(~counterMelodyTones.size, 1);

~counterMelody = Pbind(
	\scale, ~scale,
	\degree, Pseq(~counterMelodyTones, ~repetitions),
	\dur, Pseq(~counterMelodyDurations, ~repetitions)
);

// ----- LOG & PLAY ------

~melodyTones.postln;
~counterMelodyTones.postln;

~melody.play;
~counterMelody.play;
)
