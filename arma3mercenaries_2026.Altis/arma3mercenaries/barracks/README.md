# A3M Virtual Barracks

## How to set up a Barracks object in Eden Editor:

Because the A3M architecture uses Global ACE Actions, you **do not** need to execute any scripts on your objects to make them functional. The system automatically detects objects that are flagged as Barracks and attaches the ACE action for you. This makes your objects 100% immune to JIP (Join-In-Progress) and Respawn bugs.

### Setup Instructions:
1. Place any object in the Eden Editor (e.g., a whiteboard, a laptop, an NPC, or a sign).
2. Open the object's attributes (Double Click).
3. Paste the following line into the **Init** field:

```sqf
this setVariable ["A3M_isBarracks", true, true];
```

4. Click OK.

That's it! When a player approaches the object in-game, the "Access Mercenary Barracks" ACE interaction will automatically appear.
