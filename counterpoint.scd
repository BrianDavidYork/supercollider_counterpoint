s.boot;
s.quit;

(
// ----- SCALE ------
~scale = Scale.major;

// ----- REPETITIONS ------
~repetitions = 1;

// ----- MELODY 1 ------

// melody must start and end on tonic
~melodyPitches = [0, 1, 2, 4, 5, 3, 4, 3, 1, 0];
~melodyDurations = Array.fill(~melodyPitches.size, 1); // first species generator

~melody = Pbind(
	\scale, ~scale,
	\degree, Pseq(~melodyPitches, ~repetitions),
	\dur, Pseq(~melodyDurations, ~repetitions)
);

// ----- MELODY 2 -----
~firstPitch = {
	var tonic = ~melodyPitches[0];
	// first/last note should be 5th, 8th, or 10th
	var choices = [tonic+4, tonic+7, tonic+9];
	choices.choose;
};

~lastPitch = {
	arg previousCounterMelodyTone;

	var tonic = ~melodyPitches[0];
	// first/last note should be 5th, 8th, 10th, 12th, or  15th
	var choices = [tonic+4, tonic+7, tonic+9, tonic+11, tonic+14];
	var distances = Array.new(maxSize: choices.size);

	// should move to the CLOSEST of the available choices
	choices.do({ arg item; distances.add((previousCounterMelodyTone - item).abs) });
	distances.postln;
    // get index of the closest one or two values
	// if one, return based on index
	// if two, randomly choose based on index

	choices.choose;
};

~removeDimFifths = {
	// Because we don't include 4ths as possible harmonies, we only need to check for dim 5ths
	arg melodyNote, possibleHarmonyNotes;
	var tritoneRatio = 1.414;
	var melodyToneFreq = ~scale.degreeToFreq(melodyNote, 60.midicps, 1).round(0.001);
	var fifthToneFreq = ~scale.degreeToFreq(possibleHarmonyNotes[1], 60.midicps, 1).round(0.001);
	var intervalRatio = (fifthToneFreq / melodyToneFreq).round(0.001);
	if (intervalRatio == tritoneRatio, {
		possibleHarmonyNotes.removeAt(5);
		possibleHarmonyNotes.removeAt(1);
		possibleHarmonyNotes;
	}, {
		possibleHarmonyNotes;
	});
};

~getStepwiseConsonances = {
	arg consonances, previousCounterMelodyTone;

	var stepwiseConsonances = Array.new(maxSize: 2);
	var minusNdx = consonances.indexOfEqual((previousCounterMelodyTone - 1));
	var plusNdx = consonances.indexOfEqual((previousCounterMelodyTone + 1));

	if (minusNdx == nil, {}, { stepwiseConsonances.add(consonances[minusNdx]) });
	if (plusNdx == nil, {}, { stepwiseConsonances.add(consonances[plusNdx]) });

	stepwiseConsonances;
};

~getLeapConsonances = {
	arg consonances, previousCounterMelodyTone;

	var leapConsonances = consonances;
	var minusNdx = leapConsonances.indexOfEqual((previousCounterMelodyTone - 1));
	var plusNdx = leapConsonances.indexOfEqual((previousCounterMelodyTone + 1));

	if (minusNdx == nil, {}, { leapConsonances.remove(leapConsonances[minusNdx]) });
	if (plusNdx == nil, {}, { leapConsonances.remove(leapConsonances[plusNdx]) });

	leapConsonances;
};

~intermediaryPitch = {
	arg melodyTone, melodyToneNdx;

	var previousCounterMelodyTone = ~counterMelodyPitches[(melodyToneNdx - 1)];
	var consonantIntervals = [2, 4, 5, 7, 9, 11, 12, 14]; // third through two octaves (unison, third, fifth, sixth)
	var consonances = Array.new(maxSize: consonantIntervals.size);
	var motionType = ["step", "oblique", "leap"].wchoose([0.6, 0.15, 0.25]);

	consonantIntervals.do({ arg item; consonances.add(melodyTone + item) });
	consonances = ~removeDimFifths.value(melodyTone, consonances);

	switch (motionType,
		"step", {
			var stepwiseConsonances = ~getStepwiseConsonances.value(consonances, previousCounterMelodyTone);

			if (stepwiseConsonances.size == 0, {
				// call one of the other motion type methods
				consonances = [consonances[consonances.indexOfEqual(previousCounterMelodyTone)]];
			}, {
				consonances = stepwiseConsonances;
			});
		},
		"oblique", {
			var obliqueIndex = consonances.indexOfEqual(previousCounterMelodyTone);

			if (obliqueIndex == nil, {
				// call one of the other motion type methods
				consonances = ~getLeapConsonances.value(consonances, previousCounterMelodyTone);
			}, {
				consonances = [consonances[obliqueIndex]];
			});
		},
		"leap", {
			var leapConsonances = ~getLeapConsonances.value(consonances, previousCounterMelodyTone);

			if (leapConsonances.size == 0, {}, {
				consonances = leapConsonances;
			});
		},
	);

	// if parllel, restrict consecutive 5ths and 8ths
	// make this a separate function that removies offending tones from the intermeidate array
	// call this function in stepwise and leap, before the if-block

	consonances.choose;
};

~getcounterMelodyNote = {
	arg melodyTone, melodyToneNdx;
	// first note
	if (melodyToneNdx == 0, { ~firstPitch.value }, {
		// last note
		// NEED TO PASS IN THE PREVIOUS COUNTERMELPITCH NOT MELPItCH
		if (melodyToneNdx == (~melodyPitches.size - 1), { ~lastPitch.value(~counterMelodyPitches[~melodyPitches.size - 2]) }, {
			// intermediary notes
			~intermediaryPitch.value(melodyTone, melodyToneNdx)
		})
	});
};

~counterMelodyPitches = Array.new(maxSize: ~melodyPitches.size);
~melodyPitches.do({ arg item, i; ~counterMelodyPitches.add(~getcounterMelodyNote.value(item, i)) });

~melodyPitches.postln;
~counterMelodyPitches.postln;

~counterMelodyDurations = Array.fill(~counterMelodyPitches.size, 1); // first species generator

~counterMelody = Pbind(
	\scale, ~scale,
	\degree, Pseq(~counterMelodyPitches, ~repetitions),
	\dur, Pseq(~counterMelodyDurations, ~repetitions)
);

~melody.play;
~counterMelody.play;
)



// TODO:
// 1) leap
// 2) last note
// 3) no parallel motion with 5ths or 8ths
// 4) make motion logic recusrive so it keeps picking until valid array is returned


// MVP:
// - first species, two voices
// - only generate melody


// STRUCTURE:
// - A counterpoint class that can be initialized
// - methods that allow you to set musical constraints.
// - methods that let you turn on and off additional rules
// - a play method
// - the play method will execute a large, high level flow for constructing the melodies.  Based on the methods called
//   altering the constants and the rules (which set internal properties) the flow will include or exclude certain calls.


// GOALS:
// - Rules Options:
    // - if leap, acceptable leap size
	// - if stepwise, prevent too many consecutive stepwise
    // - if previous was a leap, use probability chooser to move contrary stepwise
	// - if previous oblique, prevent two oblique in a row
    // - 4th are consonant
    // - no tritones
    // - which intervals are consonant
    // - account for harmonc and melodic minor
    // - restrict prallel 5th
    // - restrict paralle 8ths
// - Musical Options:
    // - scale
    // - instrument
    // - melody
    // - counterpoint voices (harmony or bass or both)
    // - counterpoint species
    // - range of voice
    // - repetition pattern -- infinite, cf, then cp...
    // - speed

