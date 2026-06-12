# A3M Black Market

## How to set up a Black Market Vendor in Eden Editor:

Because the A3M architecture uses Global ACE Actions, you **do not** need to execute any scripts on your objects to make them functional. The system automatically detects objects that are flagged as Black Markets and attaches the dual "Pay with Cash" and "Pay with Debit Card" ACE actions for you. This makes your objects 100% immune to JIP (Join-In-Progress) and Respawn bugs.

### Setup Instructions:
1. Place any object in the Eden Editor (e.g., an Arms Dealer NPC, an ammo crate, or a computer terminal).
2. Open the object's attributes (Double Click).
3. Paste the following line into the **Init** field:

```sqf
this setVariable ["A3M_isBlackMarket", true, true];
```

4. Click OK.

That's it! When a player approaches the object in-game, the Black Market interactions will automatically appear. The scripts will dynamically parse your `CfgGradBuymenu` to determine prices and available items.
