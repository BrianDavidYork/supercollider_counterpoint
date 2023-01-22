# supercollider_counterpoint ReadMe

## This project is a WIP

// TODO:  
// - tests    
// - second species  
// - third species   
// - fourth species  
// - florid  
// - bass line for each species  
// - use class format  



// STRUCTURE:    
// - A counterpoint class that can be initialized  
// - methods that allow you to set musical constraints   
// - methods that let you turn on and off additional rules  
// - a play method  
// - the play method will execute a large, high level flow for constructing the melodies.  Based on the methods called altering the constants and the rules (which set internal properties) the flow will include or exclude certain calls


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
