// \arma3mercenaries\interrogations\civs\CfgTaskDescriptionsInterrogations.hpp

// Call In description.ext 
// #include "arma3mercenaries\interrogations\civs\CfgTaskDescriptionsInterrogations.hpp"
class CfgTasks
{
class GatherCivs
{
    title = "Enhanced Interrogation";
    description[] = {
        "<t size='1.2'>Gather Civilians</t>",
        "Command wants intel, and they don't care how we get it.",
        "Grab any civilians you find and bring them to one of the designated 'processing' locations marked on your map.",
        "Once a civilian is near the location, use the action on the bodybag container to begin the interrogation.",
        "Successful interrogations yield cash rewards. High-value targets may provide critical intel, triggering further operations."
    };
    iconType = "default"; // Or "pickup", "move", etc.
    markerType = "hd_pickup"; // Optional marker type
    // destination = "none"; // Usually omit destination here, set by script
    // textArguments[] = {}; // Usually omit, handled by script if needed
    // condition = "true"; // Usually omit, handled by script
    // onCondition = ""; // Usually omit, handled by script
    // onCreated = ""; // Usually omit, handled by script
    // onAssigned = ""; // Usually omit, handled by script
    onSucceeded = "<t color='#00FF00'>Success!</t> Processing complete. Intel (and payment) extracted.";
    onFailed = "<t color='#FF0000'>Failed</t>."; // Keep if you might set failed state
    onCanceled = ""; // Keep if you might set cancelled state
};
};

