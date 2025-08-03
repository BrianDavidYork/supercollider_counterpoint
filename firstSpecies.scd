~firstTone = {
	var tonic = ~melodyTones[0];
	var choices = [tonic+4, tonic+7, tonic+9];

	choices.choose;
};

~lastTone = {
	arg previousMelodyTone, previousCounterMelodyTone, melodyTone;

	var tonic = ~melodyTones[0];
	// last tone should be 5th, 8th, 10th, 12th, or 15th
	var choices = [tonic+4, tonic+7, tonic+9, tonic+11, tonic+14];
	var finalChoices = Array.new(maxSize: 5);
	var distances = Dictionary.new(n: choices.size);

	choices = ~removeParallel5thsAnd8ths.value(previousMelodyTone, previousCounterMelodyTone, melodyTone, choices);

	// CHOOSE A CLOSE FINAL TONE
	/*choices.do({ arg item; distances.put(item, (previousCounterMelodyTone - item).abs) });
	choices.postln;
	distances.keysValuesDo({ arg key, value; if ((value < 5),
		{ finalChoices.add(key); },
		{})
	});

	finalChoices.choose;*/
	choices.choose;
};

~removeTritones = {
	// Because we don't include 4ths as possible harmonies, we only need to check for dim 5ths
	arg melodyTone, possibleHarmonyTones;

	var tritoneRatio = 1.414;
	var melodyToneFreq = ~scale.degreeToFreq(melodyTone, 60.midicps, 1).round(0.001);
	var fifthToneFreq = ~scale.degreeToFreq(possibleHarmonyTones[1], 60.midicps, 1).round(0.001);
	var intervalRatio = (fifthToneFreq / melodyToneFreq).round(0.001);

	if (
		intervalRatio == tritoneRatio,
		{
			possibleHarmonyTones.removeAt(5);
			possibleHarmonyTones.removeAt(1);
	    },
		{}
	);

	possibleHarmonyTones;
};

~removeParallel5thsAnd8ths = {
	arg previousMelodyTone, previousCounterMelodyTone, melodyTone, harmonyChoices;

	var previousHarmony = (previousCounterMelodyTone - previousMelodyTone);

	// parallel 5ths
	if ((previousHarmony == 4) || (previousHarmony == 11), {
		harmonyChoices = harmonyChoices.reject({
			arg item;
			(item - melodyTone == 4) ||
			(item - melodyTone == 11)
		});
	}, {});

	// parallel 8ths
    if ((previousHarmony == 7) || (previousHarmony == 14), {
		harmonyChoices = harmonyChoices.reject({
			arg item;
			(item - melodyTone == 7) ||
			(item - melodyTone == 14)
		});
	}, {});

	harmonyChoices;
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

~getObliqueConsonance = {
	arg consonances, previousCounterMelodyTone;

	var obliqueIndex = consonances.indexOfEqual(previousCounterMelodyTone);

	obliqueIndex;
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

~getConsonances = {
	arg consonances, motionType, previousCounterMelodyTone;

	switch (motionType,
		"step", {
			var stepwiseConsonances = ~getStepwiseConsonances.value(consonances, previousCounterMelodyTone);

			if (stepwiseConsonances.size == 0, {
				// use oblique instead
				~getConsonances.value(consonances, "oblique", previousCounterMelodyTone);
			}, {
				stepwiseConsonances;
			});
		},
		"oblique", {
			var obliqueIndex = ~getObliqueConsonance.value(consonances, previousCounterMelodyTone);

			if (obliqueIndex == nil, {
				// use leap instead
				~getConsonances.value(consonances, "leap", previousCounterMelodyTone);
			}, {
				[consonances[obliqueIndex]];
			});
		},
		"leap", {
			var leapConsonances = ~getLeapConsonances.value(consonances, previousCounterMelodyTone);

			if (leapConsonances.size == 0, {
				// use step instead
				~getConsonances.value(consonances, "step", previousCounterMelodyTone);
			}, {
				leapConsonances;
			});
		},
	);
};

~intermediaryTone = {
	arg melodyTone, melodyToneNdx;

	var previousMelodyTone = ~melodyTones[(melodyToneNdx - 1)];
	var previousCounterMelodyTone = ~counterMelodyTones[(melodyToneNdx - 1)];
	var consonantIntervals = [2, 4, 5, 7, 9, 11, 12, 14]; // third through two octaves (unison, third, fifth, sixth)
	var consonances = Array.new(maxSize: consonantIntervals.size);
	var motionType = ["step", "oblique", "leap"].wchoose([0.6, 0.15, 0.25]);

	consonantIntervals.do({ arg item, i; consonances.add(melodyTone + item) });
	consonances = ~removeTritones.value(melodyTone, consonances);
	consonances = ~removeParallel5thsAnd8ths.value(previousMelodyTone, previousCounterMelodyTone, melodyTone, consonances);
	consonances = ~getConsonances.value(consonances, motionType, previousCounterMelodyTone);

	consonances.choose;
};

~getcounterMelodyTone = {
	arg melodyTone, melodyToneNdx, strongBeat;

	// if species == 1, continue as written
	// if species == 2, we need to know if we are on strong or weak beat
	//                  also, tracking par. 5ths and 8ths needs counterMelTone Ndx - 1, 2, or 4.

	// need prev. counterMelodyTone and prev. counterMelodyStrongBeatTone ??

	var previousMelodyTone = ~melodyTones[melodyToneNdx - 1];
	var previousCounterMelodyTone = ~counterMelodyTones[melodyToneNdx - 1];

	switch(melodyToneNdx)
	{0} { ~firstTone.value }
	{(~melodyTones.size - 1)} {~lastTone.value(previousMelodyTone, previousCounterMelodyTone, melodyTone)}
	{~intermediaryTone.value(melodyTone, melodyToneNdx)}
};