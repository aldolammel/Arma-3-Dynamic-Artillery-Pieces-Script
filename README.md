# Arma-3-Dynamic-Artillery-Pieces-Script v1.5
>*Dependencies: none.*

DAP is an Arma 3 script that allows the Mission Editor (you) to create real (or virtual) artillery/mortar fire missions faster and smarter for one or multiple sides, using Eden marker’s positions and an external fire missions list where you plan the caliber, ammo type, rounds, cycle of repetition and more.

<img src="dap_mission_example.VR/images/thumb.jpg" />

Creation concept: make use of artillery pieces practical and fast for multiplayer or single-player missions.

## HOW TO INSTALL / DOCUMENTATION

Video demo: soon.

Video tutorials: soon, but subscribe to my channel now, https://youtube.com/@thy1984

Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf

__

## SCRIPT DETAILS

**What you set for each fire mission with DAP:**
- Real or virtual fire mission;  (Virtual is WIP)
- The side that owns the fire mission;
- Potential target sectors (Eden markers);
- How much weaponry you want in the fire mission;
- What caliber these weaponry will be (Light, Medium, Heavy, Super Heavy);
- Ammunition type (HE, Cluster, Smoke, Flare etc);
- Control the volume of rounds;
- How many cycle repetitions;
- Triggers that will trigger the fire mission (trigger activation, timer, kill/destruction).

**What you set globally with DAP:**
- Custom callsign for artillery side;
- Which pieces can use CommandChat to report (On/Off)
- Infinite ammunition (On/Off);
- Fire mission areas visible on the player map (On/Off)  (WIP)
- Custom cooldown between cycles of fire mission repetition;
- Pre-defined whitelist of weaponry working (Arma, DLCs, RHS, CUP, etc);
- Pre-defined whitelist of ammunition working (Arma, DLCs, RHS, CUP, etc);
- Pre-defined blacklist of currently bugged vehicles;
- Pre-defined blacklist of currently bugged ammunition;
- Debug mode;
- etc...

**Automatically DAP library supports content from:**
- Arma 3;
- Expansion Apex;
- DLC Tanks;
- DLC Contact;
- CDLC Western Sahara;
- CDLC Reaction Forces;
- CDLC Expeditionary Forces;
- CDLC Global Mobilization;
- Mod RHS;
- Mod CUP.
 
**How DAP works internally:** (for advanced editors valuation)
There's a workflow in the first pages of the documentation. Check it out!

__

## IDEA AND FIX?

Discussion and known issues: https://forums.bohemia.net/forums/topic/290962-release-dynamic-artillery-pieces-dap/

__

## CHANGELOG

**Soon 2024 | v1.5**

- Added native support to artillery-pieces from CDLC Expeditionary Forces;
- Added automatic schedule management that allows multiples fire-missions at the same time;
- Added rearming management by caliber (with 3D sound effects);
- Added option to lock all artillery-pieces for players;
- Added option to prevent pieces starting with no magazines/low ammo;
- Added option to prevent pieces self-propelled to move from their original positions;
- Improved the fire-mission feedback messages;
- Improved, each fire-mission was given a codename (customizable) to help identify what the feedback is about;
- Improved, each artillery-piece automatically renamed to the custom side name;
- Improved, the caliber 'ANY' was renamed to 'COMBINED' for better understanding and use;
- Improved, performance;
- Fixed the debug target-markers-counter that was considering DAP markers from disabled sides as well;
- Fixed the debug artillery-pieces-counter that was considering DAP vehicles from disabled sides as well;
- Removed rhs_9k79, rhs_9k79_K, and rhs_9k79_B from the DAP Library. They're bugged;
- Documentation updated;

**Nov, 25th 2024 | v1.0**
- Hello, world.