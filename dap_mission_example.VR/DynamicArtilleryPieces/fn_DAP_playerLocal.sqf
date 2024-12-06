// DAP: Dynamic Artillery Pieces v1.5.2
// File: your_mission\DynamicArtilleryPieces\fn_DAP_playerLocal.sqf
// Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf
// by thy (@aldolammel)


// DAP CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
if ( !hasInterface || !DAP_isOn || !DAP_fmVisible_isOnMap ) exitWith {};

params ["_player"];
private ["_impactsForSide", "_mkr", "_onMap", "_impactMrk", "_color", "_impactInfoOnMap", "_side"];

waitUntil { sleep 1; !isNull _player };

// Escape > Only group leaders can get in:
if ( _player isNotEqualTo leader (group _player) ) exitWith {};

// Initial values:
_impactsForSide  = [];
_mkr             = "";
_onMap           = [];
_impactMrk       = "";
_color           = "";
_impactInfoOnMap = [];
// Declarations:
_side = side _player;
// First side actions:
switch _side do {
    case BLUFOR:      { if !DAP_BLU_isOn then { breakTo "earlyreturn" }; _color = "ColorWEST" };
    case OPFOR:       { if !DAP_OPF_isOn then { breakTo "earlyreturn" }; _color = "colorOPFOR" };
    case INDEPENDENT: { if !DAP_IND_isOn then { breakTo "earlyreturn" }; _color = "colorIndependent" };
    default           { breakTo "earlyreturn" };
};
// Checking impact markers loop:
while { DAP_isOn } do {
    // Refresh side markers ongoing from DAP server:
    switch _side do {
        case BLUFOR:      { _impactsForSide = DAP_impactMrksForPlayers # 0 };
        case OPFOR:       { _impactsForSide = DAP_impactMrksForPlayers # 1 };
        case INDEPENDENT: { _impactsForSide = DAP_impactMrksForPlayers # 2 };
    };
    {  // forEach _impactsForSide = [marker, position]
        _mkr = _x # 0;
        // If impact marker not mapped yet:
        if !(_mkr in _onMap) then {
            // Register the marker:
            _onMap pushBack _mkr;
            // Create the marker:
            _impactMrk = createMarkerLocal _x;  // [marker, position]
            _impactMrk setMarkerTypeLocal "hd_destroy";
            _impactMrk setMarkerColorLocal _color;
            _impactMrk setMarkerTextLocal ("   " + _mkr + "-TARGET");
            _impactMrk setMarkerDirLocal (random 180);
            _impactMrk setMarkerAlphaLocal DAP_fmVisible_alpha;
        };
    } forEach _impactsForSide;
    // Loop breath:
    sleep 15;
    // Refresh side markers ongoing from DAP server:
    switch _side do {
        case BLUFOR:      { _impactsForSide = DAP_impactMrksForPlayers # 0 };
        case OPFOR:       { _impactsForSide = DAP_impactMrksForPlayers # 1 };
        case INDEPENDENT: { _impactsForSide = DAP_impactMrksForPlayers # 2 };
    };
    {  // forEachReversed _onMap:
        _mkr = _x;
        // if mapped marker is NOT in _impactsForSide anymore:
        if ( _impactsForSide findIf { (_x # 0) isEqualTo _mkr } isEqualTo -1 ) then {
            // Delete marker:
            deleteMarkerLocal _mkr;
            // Remove from _onMap too:
            _onMap deleteAt _forEachIndex;
        };
    } forEachReversed _onMap;
    // Loop breath:
    sleep 15;
};  // While-loop ends.
// Return:
scopeName "earlyreturn";
true;
