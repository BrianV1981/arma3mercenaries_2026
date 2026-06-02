// \arma3mercenaries\interrogations\civs\CfgTaskDescriptionsInterrogations.hpp

// In description.ext (or CfgTaskDescriptions.hpp included by description.ext)
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
        destination = "none"; // We'll set destinations dynamically
        textArguments[] = {};
        condition = "true"; // Task is always potentially available
        onCondition = "";
        onCreated = "";
        onAssigned = "";
        onSucceeded = "<t color='#00FF00'>Success!</t> Processing complete. Intel (and payment) extracted.";
        onFailed = "<t color='#FF0000'>Failed</t>."; // Optional failure condition needed
        onCanceled = ""; // Optional cancel condition needed
    };
};

// Make sure CfgTaskDescriptions.hpp is included if you use it:
// #include "CfgTaskDescriptions.hpp"