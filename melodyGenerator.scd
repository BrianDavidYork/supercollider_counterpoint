// Melody Generator Function
// Generates a melody in minor key, logs it, and plays it

~generateAndPlayMelody = {
arg repetitions = 1, // number of times to repeat the melody
scale = Scale.minor, // scale to use (default minor)
root = 60; // root note in MIDI (default middle C)

        var melodyTones, melodyDurations, melody,
        repeatCount, noteRepeatCounts, highestNote,
        octaveUp, octaveDown, validOctaveLeaps, length, highestNoteUsed;

        // Set random melody length between 6 and 14 notes
        length = 6 + (9.rand);

    // Initialize tracking variables
    repeatCount = 0;
    noteRepeatCounts = Dictionary.new;
    highestNote = 0;
    highestNoteUsed = false;

    // Generate random melody tones within the scale
    // Start on tonic, generate middle notes, end with cadence
    melodyTones = Array.new(length);
    melodyTones.add(0); // Start on tonic
    noteRepeatCounts.put(0, 1); // Track tonic usage

    // Generate middle notes with weighted motion and constraints (reserving 3 notes for cadence)
    "Generating middle notes...".postln;

    (length - 4).do({
        arg i;
        var note, previousNote, stepwiseChoice, leapChoice, canRepeat, randomValue;

        previousNote = melodyTones[i];
        "Previous note:".postln;
        previousNote.postln;
        "Melody tones so far:".postln;
        melodyTones.postln;

        // Check if we can repeat this note
        canRepeat = (noteRepeatCounts.at(previousNote) == nil) || (noteRepeatCounts.at(previousNote) < 2);

        // 70% stepwise, 22% leap, 8% repeat previous note (if allowed)
        randomValue = 1.0.rand;

        if (randomValue < 0.7, {
            // 70% stepwise motion (1 or -1)
            stepwiseChoice = [];
            if (previousNote > 0, {
                stepwiseChoice = stepwiseChoice.add(previousNote - 1)
            });
            if (previousNote < 10, {
                stepwiseChoice = stepwiseChoice.add(previousNote + 1)
            });

            // Filter out notes that have been repeated too much or are the highest note (if already used)
            stepwiseChoice = stepwiseChoice.reject({
                arg x;
                var count = noteRepeatCounts.at(x);
                (if (count == nil, { false }, { count >= 2 })) ||
                ((x == highestNote) && highestNoteUsed)
            });

            // If no stepwise options available, use leap
            if (stepwiseChoice.size == 0, {
                leapChoice = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reject({
                    arg x;
                    var count = noteRepeatCounts.at(x);
                    (x == previousNote) ||
                    (if (count == nil, { false }, { count >= 2 })) ||
                    ((x - previousNote).abs + 1 > 5) ||
                    ((x == 1 && previousNote == 5) || (x == 5 && previousNote == 1)) || // tritone 2-6 (0-indexed: 1-5)
                    ((x == highestNote) && highestNoteUsed)
                });
                note = leapChoice.choose;
            }, {
                note = stepwiseChoice.choose;
            });
        }, {
            if (randomValue < 0.92, {
                // 22% larger leaps - choose from non-adjacent scale degrees (max fifth)
                leapChoice = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reject({
                    arg x;
                    var count = noteRepeatCounts.at(x);
                    (x == previousNote) ||
                    (x == (previousNote + 1)) ||
                    (x == (previousNote - 1)) ||
                    (if (count == nil, { false }, { count >= 2 })) ||
                    ((x - previousNote).abs + 1 > 5) ||
                    ((x == 1 && previousNote == 5) || (x == 5 && previousNote == 1)) || // tritone 2-6 (0-indexed: 1-5)
                    ((x == highestNote) && highestNoteUsed)
                });

                // If no leap options available, use stepwise
                if (leapChoice.size == 0, {
                    stepwiseChoice = [];
                    if (previousNote > 0, {
                        stepwiseChoice = stepwiseChoice.add(previousNote - 1)
                    });
                    if (previousNote < 10, {
                        stepwiseChoice = stepwiseChoice.add(previousNote + 1)
                    });
                    stepwiseChoice = stepwiseChoice.reject({
                        arg x;
                        var count = noteRepeatCounts.at(x);
                        (if (count == nil, { false }, { count >= 2 })) ||
                        ((x == highestNote) && highestNoteUsed)
                    });
                    note = stepwiseChoice.choose;
                }, {
                    note = leapChoice.choose;
                });
            }, {
                // 8% repeat the previous note (only if allowed and under repeat limit)
                if (canRepeat && (repeatCount < 2), {
                    "Note repeat chosen!".postln;

                    // 50% chance to leap by octave, 50% chance to repeat
                    if (0.5.coin, {
                        "Attempting octave leap...".postln;
                        octaveUp = previousNote + 7;
                        octaveDown = previousNote - 7;
                        validOctaveLeaps = [];

                                                                        // Check if octave up is valid (within range and not repeated too much)
                        if (octaveUp <= 10, {
                            var upCount = noteRepeatCounts.at(octaveUp);
                            if (upCount == nil, {
                                if ((octaveUp != highestNote) || (highestNoteUsed == false), {
                                    validOctaveLeaps = validOctaveLeaps.add(octaveUp);
                                });
                            }, {
                                if (upCount < 2, {
                                    if ((octaveUp != highestNote) || (highestNoteUsed == false), {
                                        validOctaveLeaps = validOctaveLeaps.add(octaveUp);
                                    });
                                });
                            });
                        });

                        // Check if octave down is valid (within range and not repeated too much)
                        if (octaveDown >= 0, {
                            var downCount = noteRepeatCounts.at(octaveDown);
                            if (downCount == nil, {
                                if ((octaveDown != highestNote) || (highestNoteUsed == false), {
                                    validOctaveLeaps = validOctaveLeaps.add(octaveDown);
                                });
                            }, {
                                if (downCount < 2, {
                                    if ((octaveDown != highestNote) || (highestNoteUsed == false), {
                                        validOctaveLeaps = validOctaveLeaps.add(octaveDown);
                                    });
                                });
                            });
                        });

                        // If valid octave leaps exist, choose one
                        if (validOctaveLeaps.size > 0, {
                            "Octave leap successful!".postln;
                            note = validOctaveLeaps.choose;
                        }, {
                            // If no valid octave leaps, just repeat the note
                            "No valid octave leaps, repeating note".postln;
                            note = previousNote;
                        });
                    }, {
                        // 50% chance to just repeat the note
                        note = previousNote;
                    });
                    repeatCount = repeatCount + 1;
                }, {
                    // Fall back to stepwise motion
                    stepwiseChoice = [];
                    if (previousNote > 0, {
                        stepwiseChoice = stepwiseChoice.add(previousNote - 1)
                    });
                    if (previousNote < 10, {
                        stepwiseChoice = stepwiseChoice.add(previousNote + 1)
                    });
                    stepwiseChoice = stepwiseChoice.reject({
                        arg x;
                        var count = noteRepeatCounts.at(x);
                        (if (count == nil, { false }, { count >= 2 })) ||
                        ((x == highestNote) && highestNoteUsed)
                    });
                    if (stepwiseChoice.size == 0, {
                        leapChoice = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reject({
                            arg x;
                            var count = noteRepeatCounts.at(x);
                            (x == previousNote) ||
                            (if (count == nil, { false }, { count >= 2 })) ||
                            ((x - previousNote).abs + 1 > 5) ||
                            ((x == 1 && previousNote == 5) || (x == 5 && previousNote == 1)) || // tritone 2-6 (0-indexed: 1-5)
                            ((x == highestNote) && highestNoteUsed)
                        });
                        note = leapChoice.choose;
                    }, {
                        note = stepwiseChoice.choose;
                    });
                });
            });
        });

        // Track note usage and find highest note
        if (noteRepeatCounts.at(note) == nil, {
            noteRepeatCounts.put(note, 1);
        }, {
            noteRepeatCounts.put(note, noteRepeatCounts.at(note) + 1);
        });

        if (note > highestNote, {
            highestNote = note;
        });

        // Mark if this note is the highest note (so it can only be used once)
        if (note == highestNote, {
            highestNoteUsed = true;
        });

        "Chosen note:".postln;
        note.postln;
        "Leap size (inclusive):".postln;
        ((note - previousNote).abs + 1).postln;

        melodyTones.add(note);
    });

    // Ensure we have one highest note by modifying the melody generation approach
    // Instead of inserting, we'll just note if we need a high note for future reference
    if (highestNote < 8, {
        "Note: Melody needs a high note (current highest:".postln;
        highestNote.postln;
        ")".postln;
    }, {});

    // Determine cadence based on whether melody reached the octave
    if (melodyTones.maxItem >= 8, {
        // If melody reached octave, use 10, 9, 8 cadence (ending on octave)
        "Adding high cadence: 10, 9, 8".postln;
        melodyTones.add(9);
        melodyTones.add(8);
        melodyTones.add(7);
    }, {
        // Otherwise use standard 3, 2, 1 cadence (ending on tonic)
        "Adding standard cadence: 3, 2, 1".postln;
        melodyTones.add(2);
        melodyTones.add(1);
        melodyTones.add(0);
    });

    // Create durations (all quarter notes for simplicity)
    melodyDurations = Array.fill(melodyTones.size, 1);

    // Create the melody pattern
    melody = Pbind(
        \scale, scale,
        \degree, Pseq(melodyTones, repetitions),
        \dur, Pseq(melodyDurations, repetitions),
        \amp, 0.3,
        \pan, 0
    );

    // Log the generated melody
    "Generated Melody:".postln;
    "Scale:".postln;
    scale.postln;
    "Melody tones (scale degrees, 1-indexed):".postln;
    melodyTones.do({
        arg note;
        (note + 1).post;
        " ".post;
    });
    "".postln;
    "Raw melody tones (0-indexed):".postln;
    melodyTones.postln;
    "Durations:".postln;
    melodyDurations.postln;
    "Root note (MIDI):".postln;
    root.postln;
    "Highest note:".postln;
    melodyTones.maxItem.postln;
    "Repeat count:".postln;
    repeatCount.postln;
    "".postln;

    // Play the melody
    melody.play;

    // Return the melody pattern for further use
    melody;

};

// Example usage:
// ~generateAndPlayMelody.value(8, 2); // 8-note melody repeated twice
// ~generateAndPlayMelody.value(12, 1, Scale.major, 64); // 12-note melody in E major
