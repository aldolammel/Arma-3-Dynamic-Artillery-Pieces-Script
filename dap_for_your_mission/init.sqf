// ATTENCION: if you already have a init.sqf file in your mission, just include the lines below in that file. 



// DAP: DYNAMIC ARTILLERY PIECES v1.5.5> HIDE THE SCRIPT MARKERS:
// Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf
if (!DAP_isOn || !DAP_debug_isOn) then {if !isMultiplayer then {uiSleep 1};{private _mkr = toUpper _x; private _mkrChecking = _mkr splitString DAP_spacer; if (_mkrChecking find DAP_prefix isNotEqualTo -1) then {_x setMarkerAlpha 0}} forEach allMapMarkers};