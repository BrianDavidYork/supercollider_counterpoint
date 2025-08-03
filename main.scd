s.boot;
s.quit;

"./firstSpecies.scd".load;
"/Users/brianyork/repos/supercollider_counterpoint/melodyGenerator.scd".load;

(
// ----- SCALE ------
~scale = Scale.major;

// ----- REPETITIONS ------
~repetitions = 1;

// ----- SPECIES ------
// 1, 2, 3, 4, f
~species = 1;

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

// DO I NEED TO DEFINE THE TYPES OF MOTION AND THEN CONSTRUCT BLOCKS BASED ON THAT?

// this on;y works for species 1 and 2
~counterMelodyTones = Array.new(maxSize: ~melodyTones.size \* ~species);
// species 1, 2, 3 change number iterations per melodyNote
// for loop inside .do -- if i = 0, strong beat, else weak beat.
~melodyTones.do({
arg item, i;
// only works for species 1 and 2
~species.do({ arg j; ~counterMelodyTones.add(~getcounterMelodyTone.value(item, i, (j == 0))) });
});
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

// Load and call the melody generator function
"/Users/brianyork/repos/supercollider_counterpoint/melodyGenerator.scd".load;
~generateAndPlayMelody.value(1);
)
