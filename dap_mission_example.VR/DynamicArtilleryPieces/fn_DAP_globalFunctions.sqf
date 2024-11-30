// DAP: Dynamic Artillery Pieces v1.1
// File: your_mission\DynamicArtilleryPieces\fnc_DAP_globalFunctions.sqf
// Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf
// by thy (@aldolammel)


// DAP CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
if !DAP_isOn exitWith {};


// STRUCTURE OF A FUNCTION BY THY:
/* THY_fnc_DAP_name_of_the_function = {
	// This function <doc string>.
	// Returns nothing <or varname + type>

	params ["", "", "", ""];
	private ["", "", ""];

	// Escape:
		// reserved space.
	// Initial values:
		// reserved space.
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.

	// Main functionality:
	// code

	// Return:
	true;
}; */


THY_fnc_DAP_name_splitter = {
	// This function splits the variable-name (marker or object) to check if the name has the basic structure for further validations.
	// Important: i'm checking what the editor is using as DAP_spacer in management file and there I'm setting a limit to use just _ or -.
	// Returns _nameStructure: array

	params ["_what", "_name", "_prefix"];
	private ["_nameStructure", "_minSectionAmount", "_spacer", "_a", "_b"];

	// Initial values:
	_nameStructure    = [];
	_minSectionAmount = 2;
	_spacer           = "";
	// Errors handling:
		// reserved space.
	// Escape:
		// reserved space.
	switch _what do {
		// Artillery Piece
		case 1: {
			// FUNDAMENT for this weird pieces-varname check: unlike markers that DAP has a restricted naming rules, for pieces, I'm assuming some cases the Editor
			// can be running another script where vehicles (for example) could be using restricted naming rules where all DAP will consider whether the vehicle has,
			// at least, 'DAP' in some moment of the varname.
			_name = str _name;
			_a = count (_name splitString "_");
			_b = count (_name splitString "-");
			// The name structure has at least X sections:
			if ( _a >= _minSectionAmount || _b >= _minSectionAmount ) then {
				// If A section's amount is not equal to B section amount:
				if ( _a isNotEqualTo _b ) then {
					if ( _a > _b ) then { _spacer = "_" } else { _spacer = "-" };
					// spliting the object name to check its structure:
					_nameStructure = _name splitString _spacer;  // for pieces of artillery, e.g. ["DAP", ...] or [..., "DAP"] or [..., "DAP", ...]
				// Otherwise, A and B has the same section amount:
				} else {
					// Warning message:
					systemChat format ["%1 ARTILLERY-PIECES '%2' > This name's structure IS NOT correct! Decide if you'll use '_' or '-' as spacer in piece variable-names. You can use like '%3%4...' or '...%4%3%4...' or '...%4%3'. This piece has been ignored.",
					DAP_txtWarnHeader, _name, _prefix, DAP_spacer];
					// Update to return as failed:
					_nameStructure = [];
				};
			};
		};
		// Marker
		case 2: {
			// spliting the marker name to check its structure:
			_nameStructure = _name splitString DAP_spacer;  // e.g. ["DAP","OPF","C","1"]
			// if the _spacer is NOT been used correctly:
			if ( count _nameStructure isNotEqualTo 4 ) then {
				// Warning message:
				systemChat format ["%1 TARGET MARKER '%2' > This marker name's structure look's NOT correct! DAP target markers must have their structure names like '%3%4BLU%4sectorletter%4anynumber' for example. The marker has been ignored.",
				DAP_txtWarnHeader, _name, _prefix, DAP_spacer];
				// Update to return as failed:
				_nameStructure = [];
			};
		};
	};
	// Return:
	_nameStructure;
};


THY_fnc_DAP_is_position_valid = {
	// This function checks if the thing (marker or piece) exists and if it's inside map borders.
	// Return _isValid: bool.

	params ["_what", "_thing"];
	private ["_isValid", "_pos", "_posA", "_posB"];

	// Initial values:
	_isValid = false;
	_pos     = [];
	// Errors handling:
		// reserved space.
	// Escape:
		// reserved space.
	// Declarations:
	switch _what do {
		case 1: { if ( !isNull _thing ) then { _pos = getPosATL _thing } };  // Piece
		case 2: { if ( (getMarkerColor _thing) isNotEqualTo "" ) then { _pos = markerPos _thing } };  // Marker
	};
	_posA = _pos # 0;
	_posB = _pos # 1;
	// Check if the marker is out of the map edges:
	if ( _posA >= 0 && _posB >= 0 && _posA <= worldSize && _posB <= worldSize ) then {
		// Update to return:
		_isValid = true;
	// Otherwise, if not on map area:
	} else {
		// Warning message:
		systemChat format ["%1 WORLD POSITION '%2' > This marker or piece has an invalid position and it'll be ignored until its position is within the map borders.",
		DAP_txtWarnHeader, toUpper _thing];
	};
	// Return:
	_isValid;
};


THY_fnc_DAP_marker_shape = {
	// This function checks the marker shape.
	// Returns _isValidShape: bool.

	params ["_mkr"];
	private ["_isValidShape", "_mkrType"];

	// Initial values:
	_isValidShape = false;
	// Declarations:
	_mkrType = getMarkerType _mkr;
	// Main functionality:
	if ( _mkrType isEqualTo DAP_fmVisible_type ) then { _isValidShape = true } else {
		// Warning message:
		systemChat format ["%1 TARGET MARKER > The %2 '%3' marker DOESN'T HAVE the correct shape. For any target-marker, use '%4' marker! This marker was ignored.",
		DAP_txtWarnHeader, _mkrType, _mkr, DAP_fmVisible_type];
	};
	// Return:
	_isValidShape;
};


THY_fnc_DAP_marker_name_section_owner = {
	// This function checks only the third section (mandatory) of the marker's name, validating who is the marker's owner.
	// Returns _mkrTag: when valid, owner tag as string. When invalid, an empty string ("").

	params ["_nameStructure", "_mkr", "_prefix", "_spacer"];
	private ["_mkrTag", "_tagsAvailable", "_mkrTagToCheck"];

	// Initial values:
	_mkrTag = "";
	// Escape:
		// reserved space.
	// Declarations:
	_tagsAvailable  = ["BLU", "OPF", "IND"];
	_mkrTagToCheck  = _nameStructure # 1;  // e.g: it'll take 'blu' from 'dap_blu_a_1'
	// If owner is present:
	if ( _mkrTagToCheck in _tagsAvailable ) then {
		// Updating to return:
		_mkrTag = _mkrTagToCheck;
	// Otherwise, if not:
	} else {
		systemChat format ["%1 TARGET MARKER '%2' > The SIDE TAG looks missing. DAP target-markers must have their structure names like '%3%4BLU%4sectorletter%4anynumber' or '%3%4OPF%4sectorletter%4anynumber' for example. This marker has been ignored!",
		DAP_txtWarnHeader, _mkr, _prefix, _spacer];
	};
	// Return:
	_mkrTag;
};


THY_fnc_DAP_marker_name_section_sector = {
	// This function checks only the sector section (mandatory) of the marker's name, validating if the sector-letter is valid. Structure with sector e.g: dap_blu_A_1
	// Returns _mkrSector: it's a letter and return as string. If missing, empty string ("") is returned.

	params ["_nameStructure", "_mkr"];
	private ["_mkrSector", "_sectorsAvailable", "_mkrSectorToCheck"];

	// Initial values:
	_mkrSector = "";
	// Escape > if _nameStructure has no five sections, abort:
	//if ( count _nameStructure isNotEqualTo 5 ) exitWith { _mkrSector /* Returning */ };
	// Declarations:
	_sectorsAvailable = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
	_mkrSectorToCheck = _nameStructure # 2;  // e.g: dap_blu_A_1
	// Debug texts:
		// reserved space.
	// Errors handling:
		// reserved space.
	// If the sector is valid:
	if ( _mkrSectorToCheck in _sectorsAvailable ) then {
		// Updating to return:
		_mkrSector = _mkrSectorToCheck;
	// If NOT valid, warning message:
	} else {
		systemChat format ["%1 TARGET MARKER '%2' > SECTOR LETTER looks wrong. There's NO '%3' option available. Meanwhile this marker is ignored, here's the options: %4. Fix it on Eden. This marker was ignored!",
		DAP_txtWarnHeader, _mkr, _mkrSectorToCheck, _sectorsAvailable];
	}; 
	// Return:
	_mkrSector;
};


THY_fnc_DAP_marker_name_section_number = {
	// This function checks the last section (mandatory) of the marker's name, validating if the section is numeric;
	// Returns _isNum: bool.

	params ["_nameStructure", "_mkr", "_prefix", "_spacer"];
	private ["_isNum", "_itShouldBeNum"];

	// Initial values:
	_isNum = false;
	// Errors handling:
		// reserved space.
	// Declarations:
		// reserved space.
	// Escape > If name's structure has less than X sections:
		// reserved space.
	// Now, let's check if the number section is in fact a number:
	// Result will be a number extracted from string OR ZERO if inside the string has no numbers:
	_itShouldBeNum = parseNumber (_nameStructure # 3);  // e.g. dap_blu_a_1
	// If is number (and the result is not a zero), it's true:
	if ( _itShouldBeNum isNotEqualTo 0 ) then {
		_isNum = true;
	// If is NOT a number (will be zero):
	} else {
		// Warning message:
		systemChat format ["%1 TARGET MARKER '%2' > It has no a valid name. DAP markers must have their structure names like '%3%4BLU%4sectorletter%4anynumber' or '%3%4IND%4sectorletter%4anynumber' for example.",
		DAP_txtWarnHeader, _mkr, _prefix, _spacer];
	};
	// Return:
	_isNum;
};


THY_fnc_VO_is_rearm_needed = {
	// This function (a simpler version from my script 'Vehicles Overhauling') checks the mag capacity and how much ammo still remains within.
	// Returns _isRearmNeeded bool.
	
	params ["_piece"];
	private ["_isRearmNeeded", "_pieceMagsStr", "_pieceMagDetail", "_ammoName", "_ammoInMag", "_capacityMag"];

	// Initial values:
	_isRearmNeeded = false;
	// Declarations: 
	_pieceMagsStr = magazinesDetail _piece;  // "120mm (2/20)[id/cr:10000011/0]".
	// Main function:
	if ( count _pieceMagsStr > 0 ) then {
		{  // foreEach _pieceMagsStr:
			_pieceMagDetail = _x splitString "([]/:)";  // ["120mm", "2", "20", "id", "cr", "10000011", "0"]
			_ammoName       = _pieceMagDetail # 0;      // "120mm"
			reverse _pieceMagDetail;                    // ["0", "10000011", "cr", "id", "20", "2", "120mm"] coz the current ammo and ammo capacity don't change their index when reversed.
			_ammoInMag      = parseNumber (_pieceMagDetail # 5);  // string "2" convert to number 2.
			_capacityMag    = parseNumber (_pieceMagDetail # 4);  // string "20" convert to number 20.
			// Checking if rearm is needed:
			if ( _ammoInMag < (_capacityMag / 4) ) exitWith {
				if ( DAP_debug_isOn && DAP_debug_isOnAmmo ) then {
					systemChat format ["%1 %2 Magazine [%3]: %4 ammo of %5 capacity. Rearm is needed!", DAP_txtDebugHeader, _piece, _ammoName, _ammoInMag, _capacityMag]; sleep 0.5;
				};
				_isRearmNeeded = true;
			};
		} forEach _pieceMagsStr;

	} else {
		// When the armed-vehicle has NO ammo-capacity (0% ammunition in its attributes) it will force the vehicle to rearm:
		_isRearmNeeded = true;
	};
	// Return:
	_isRearmNeeded;
};


THY_fnc_VO_restore_ammo_capacity = {
	// This function (simpler version from my 'Vehicles Overhauling' script) restores the piece ammo capacity. Sometimes (mostly w/ mods) for any reason,
	// pieces start w/ no mags, and this (DAP_preventStartLowAmmo = true) will restore the original mags.
	// Returns nothing.

	params ["_piece"];
	private ["_pieceMags", "_magsRemoved", "_mag"];

	// Initial values:
	_pieceMags   = [];
	_magsRemoved = [];
	_mag         = "";
	// Mapping all piece original mags capacity:
	_pieceMags = magazinesAllTurrets _piece;  // list of all magazines (include the empty ones) and their additional data.
	// Removing the compromised mags:
	{ _mag = _x # 0; _piece removeMagazineTurret [_mag, [0]]; _magsRemoved pushBack _mag } forEach _pieceMags;
	// Adding new mags with full capacity restored:
	{ _piece addMagazineTurret [_x, [0]] } forEach _magsRemoved;
	// Rearm all mags available:
	_piece setVehicleAmmo 1;
	// Return:
	true;
};


THY_fnc_DAP_rearming = {
	// This function rearm the artillery-piece after a cooldown defined by caliber.
	// Returns nothing.

	params ["_side", "_piece", "_teamCooldown", "_shouldReport"];
	private ["_time", "_loopFrequency"];

	// Initial values:
		// reserved space.
	// Declarations:
	_time = time;
	// Has unlimited ammo:
	if DAP_artill_isInfiniteAmmo then {
		// Minimal cooldown time defined by editor:
		_teamCooldown = DAP_fmCaliber_timeRearmLight;
	// Has limited ammo:
	} else {
		// Escape > Rearming is not needed:
		if !([_piece] call THY_fnc_VO_is_rearm_needed) then { breakTo "earlyreturn" };
		// Adding to the list of pieces with no ammo:
		["ADD", _side, _piece] call THY_fnc_DAP_out_of_ammo_list;
	};
	// Check minimal looping frequency:
	_loopFrequency = ( _teamCooldown / 3 ); if ( _loopFrequency < 12 ) then { _loopFrequency = 12 };
	// Wait until the rearm cooldown is completed:
	waitUntil {
		// Loop frequency:
		sleep _loopFrequency;
		// SFX:
		playSound3D ["a3\sounds_f\characters\cutscenes\concrete_acts_walkingchecking.wss", _piece];
		// Stop waiting if:
		time > (_time + _teamCooldown) || !alive _piece || count (crew _piece) isEqualTo 0;
	};
	// Piece still running and there's some crew alive:
	if ( alive _piece && count (crew _piece) > 0 ) then {
		// If piece is NOT mortar light and medium, play SFX:
		if ( !(typeOf _piece in [(DAP_knownPieces_mortar # 0) # 1, (DAP_knownPieces_mortar # 1) # 1]) ) then {
			playSound3D ["a3\sounds_f\sfx\ui\vehicles\vehicle_rearm.wss", _piece];
		};
		// REARM:
		// (If a fucking client-player in the vehicle hehe) in case the piece is created-by (or transfered-to) another machine and not the server:
		//[_piece, 1] remoteExec ["setVehicleAmmo", _piece];
		// But let's take the performance way here:
		_piece setVehicleAmmo 1;
	// Otherwise:
	} else {
		if ( _shouldReport || DAP_debug_isOn ) then {
			// Side command message:
			[_side, "BASE"] commandChat format ["Squad leaders, we lost signal with %1, over.", groupId (group _piece) ];
			// Debug:
			if DAP_debug_isOn then {systemChat format ["%1 AMMO LOGISTIC > %2 was neutralized during rearming cooldown.", DAP_txtDebug, groupId (group _piece)]};
			sleep 3;
		};
	};
	// Infinite mode always ignores this list (adding and removing):
	// Removing to the list of pieces with no ammo:
	if !DAP_artill_isInfiniteAmmo then { ["REMOVE", _side, _piece] call THY_fnc_DAP_out_of_ammo_list };
	
	// Return:
	scopeName "earlyreturn";
	true;
};


THY_fnc_DAP_out_of_ammo_list = {
	// This function adds or removes artillery-pieces with no ammo in a list to further actions.
	// Returns nothing.

	params ["_action", "_side", "_piece", ["_pieceLeader", objNull]];
	//private [""];

	// Escape:
		// reserved space.
	// Initial values:
		// reserved space.
	// Declarations:
		// reserved space.
	// Main functionality:
	switch _side do {
		case BLUFOR: {
			switch _action do {
				case "ADD":    { (DAP_piecesNeedRearm # 0) pushBackUnique _piece };
				case "REMOVE": { (DAP_piecesNeedRearm # 0) deleteAt ((DAP_piecesNeedRearm # 0) find _piece) };
			};
		};
		case OPFOR: {
			switch _action do {
				case "ADD":    { (DAP_piecesNeedRearm # 1) pushBackUnique _piece };
				case "REMOVE": { (DAP_piecesNeedRearm # 1) deleteAt ((DAP_piecesNeedRearm # 1) find _piece) };
			};
		};
		case INDEPENDENT: {
			switch _action do {
				case "ADD":    { (DAP_piecesNeedRearm # 2) pushBackUnique _piece };
				case "REMOVE": { (DAP_piecesNeedRearm # 2) deleteAt ((DAP_piecesNeedRearm # 2) find _piece) };
			};
		};
	};
	// Broadcasting the public update:
	publicVariable "DAP_piecesNeedRearm";
	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnAmmo && _action isEqualTo "ADD" ) then {
		systemChat format [
			"%1 AMMO LOGISTIC > '%2' out of ammo%3", 
			DAP_txtDebugHeader, 
			_piece, 
			if ( !isNull _pieceLeader ) then {format [" (from fire-mission %1-TEAM)", groupId (group _pieceLeader)]} else {"!"}
		]; sleep 1;
	};
	// Return:
	true;
};


THY_fnc_DAP_pieces_scanner = {
	// This function searches and appends in a list all pieces (objects) confirmed as real. The searching take place once right at the mission begins through fn_DAP_management.sqf file.
	// Return: _confirmedPieces: array

	params ["_prefix", "_spacer"];
	private ["_confirmedPieces", "_isValid", "_piece", "_ctrBLU", "_ctrOPF", "_ctrIND", "_nameStructure", "_piecesBLU", "_piecesOPF", "_piecesIND", "_possiblePieces"];

	// Escape:
		// reserved space.
	// Initial values:
	_confirmedPieces = [];
	_isValid         = false;
	_piece           = objNull;
	_ctrBLU          = 0;
	_ctrOPF          = 0;
	_ctrIND          = 0;
	_nameStructure   = [];
	_piecesBLU       = [];
	_piecesOPF       = [];
	_piecesIND       = [];
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.
	// Selecting the relevant markers:
	// Critical: careful because 'vehicles' command brings lot of trash along: https://community.bistudio.com/wiki/vehicles
	_possiblePieces = vehicles select { !isNull (gunner _x) && toUpper (str _x) find (_prefix + _spacer) isNotEqualTo -1 };
	// Debug message:
	if DAP_debug_isOn then { systemChat format ["%1 Artillery-pieces found: %2 from DAP.", DAP_txtDebugHeader, count _possiblePieces] };
	// Escape > If no _possiblePieces found:
	if ( count _possiblePieces isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 ARTILLERY-PIECES > This mission still HAS NO ARTILLERY-PIECES (Howitzers or MRL's or Mortars) to be used for. DAP pieces must have their structure names like '%2%3anynumber'. Reminder: no need to add a side-tag in the piece variable-name as seen in markers!",
		DAP_txtWarnHeader, _prefix, _spacer];
		// Returning:
		_confirmedPieces;
	};
	// Validating each piece position:
	{  // forEach _possiblePieces:
		_isValid = [1, _x] call THY_fnc_DAP_is_position_valid;
		// If something wrong, remove the object (vehicle) from the list and from the map:
		if !_isValid then {
			deleteVehicle _x;
			_possiblePieces deleteAt (_possiblePieces find _x);
		};
	} forEach _possiblePieces;
	// Escape > All _possiblePieces deleted during position check:
	if ( count _possiblePieces isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 ARTILLERY-PIECES > Looks like all artillery-pieces available were out of the map borders and were deleted.",
		DAP_txtWarnHeader];
		// Returning:
		_confirmedPieces;
	};

	// Step 2/2 > Ignoring from the first pieces list that doesn't fit the name's structure rules, and creating new lists:
	{  // forEach _possiblePieces:
		_piece = _x;
		// Escape > if weaponey side is civilian, skip to the next _piece:
		if ( side _piece isEqualTo CIVILIAN ) then { systemChat format ["%1 ARTILLERY-PIECES '%2' > You cannot use Civilian with DAP! Piece ignored!", DAP_txtWarnHeader, _piece]; continue };
		// check if the _piece name has _spacer character enough in its string composition:
		_nameStructure = [1, _piece, _prefix] call THY_fnc_DAP_name_splitter;
		// Escape > if invalid structure, skip to the next _piece:
		if ( count _nameStructure < 2 ) then { continue };
		// Fixing possible editor's mistakes:
		if DAP_preventDynamicSim then { group _piece enableDynamicSimulation false };  // CRUCIAL for long distances!
		if DAP_preventStartLowAmmo then { [_piece] call THY_fnc_VO_restore_ammo_capacity };
		if DAP_preventUnlocked then { _piece setVehicleLock "LOCKEDPLAYER" };
		// Adding extra configs:
		if DAP_preventMoving then { (driver _piece) disableAI "MOVE" };
		// WIP THERMAL SIGNATURE: if DAP_artill_isForcedThermalSignat then { [_piece, [1,0,1]] remoteExec ["setVehicleTiPars"] };  // [engine, wheels, weapon] / 1=hot / 0.5=warm / 0=cool
		
		// If all validations alright:
		switch (side (gunner _piece)) do {
			case BLUFOR: {
				// Defining the group name:
				_ctrBLU = _ctrBLU + 1;
				group _piece setGroupIdGlobal [DAP_BLU_name + "-" + str _ctrBLU];
				// Officially part of the support team:
				_piecesBLU pushBack _piece;
			};
			case OPFOR: { 
				// Defining the group name:
				_ctrOPF = _ctrOPF + 1;
				group _piece setGroupIdGlobal [DAP_OPF_name + "-" + str _ctrOPF];
				// Officially part of the support team:
				_piecesOPF pushBack _piece;
			};
			case INDEPENDENT: { 
				// Defining the group name:
				_ctrIND = _ctrIND + 1;
				group _piece setGroupIdGlobal [DAP_IND_name + "-" + str _ctrIND];
				// Officially part of the support team:
				_piecesIND pushBack _piece;
			};
		};  // switch ends.
	} forEach _possiblePieces;
	// Destroying unnecessary things:
	_possiblePieces = nil;
	// Updating the general list to return:
	_confirmedPieces = [
		[_piecesBLU],
		[_piecesOPF],
		[_piecesIND]
	];
	// Return:
	_confirmedPieces;
};


THY_fnc_DAP_marker_scanner = {
	// This function searches and appends in a list all markers confirmed as real. The searching take place once right at the mission begins through fn_DAP_management.sqf file.
	// Return: _confirmedMkrs: array

	params ["_prefix", "_spacer"];
	private ["_targetMkrsBLU", "_targetMkrsOPF", "_targetMkrsIND", "_confirmedMkrs", "_isValid", "_mkr", "_isValidShape", "_tag", "_sector", "_isNum", "_nameStructure", "_callsign", "_possibleMkrs"];

	// Initial values:
	_targetMkrsBLU     = [];
	_targetMkrsOPF     = [];
	_targetMkrsIND     = [];
	_confirmedMkrs     = [[_targetMkrsBLU], [_targetMkrsOPF], [_targetMkrsIND]];
	_isValid          = false;
	_mkr              = "";
	_isValidShape     = false;
	_tag              = "";
	_sector           = "";
	_isNum            = false;
	_nameStructure    = [];
	_callsign         = "Fire Support";
	// Errors handling:
		// reserved space.
	// Escape:
		// reserved space.
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.
	// Step 1/2 > Creating a list with only markers with right prefix:
	// Selecting the relevant markers:
	_possibleMkrs = allMapMarkers select { toUpper _x find (_prefix + _spacer) isNotEqualTo -1 };
	// Debug message:
	if DAP_debug_isOn then { systemChat format ["%1 Artillery target-markers found: %2 from DAP.", DAP_txtDebugHeader, count _possibleMkrs] };
	// Escape > If no _possibleMkrs found:
	if ( count _possibleMkrs isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 This mission still HAS NO possible DAP MARKERS to be loaded. DAP markers must have their structure names like '%2%3BLU%3sectorLetter%3anynumber' or '%2%3OPF%3A%3anynumber' or '%2%3IND%3E%3anynumber' for example.",
		DAP_txtWarnHeader, _prefix, _spacer];
		// Returning:
		_confirmedMkrs;
	};
	// Validating each marker position:
	{  // forEach _possibleMkrs:
		_isValid = [2, _x] call THY_fnc_DAP_is_position_valid;
		// If something wrong, remove the marker from the list and from the map:
		if !_isValid then {
			deleteMarker _x;
			_possibleMkrs deleteAt (_possibleMkrs find _x);
		};
	} forEach _possibleMkrs;

	// Step 2/2 > Ignoring from the first list those markers that don't fit the name's structure rules, and creating new lists:
	{  // forEach _possibleMkrs:
		_mkr = toUpper _x;
		// check if the marker name has DAP_spacer character enough in its string composition:
		_nameStructure = [2, _mkr, _prefix] call THY_fnc_DAP_name_splitter;
		// Escape > if invalid structure, skip to the next marker:
		if ( count _nameStructure isEqualTo 0 ) then { continue };
		// Check the type of marker:
		_isValidShape = [_mkr] call THY_fnc_DAP_marker_shape;
		// Escape > if _isValidShape returns false, skip to the next marker:
		if !_isValidShape then { continue };
		// Check if there is a valid owner tag:
		_tag = [_nameStructure, _mkr, _prefix, _spacer] call THY_fnc_DAP_marker_name_section_owner;
		// Escape > if invalid _tag, skip to the next marker:
		if ( _tag isEqualTo "" ) then { continue };
		// Check if there is a valid sector letter:
		_sector = [_nameStructure, _mkr] call THY_fnc_DAP_marker_name_section_sector;
		// Escape > if invalid _sector, skip to the next marker:
		if ( _sector isEqualTo "" ) then { continue };
		// Check if the last section of the area marker name is numeric:
		_isNum = [_nameStructure, _mkr, _prefix, _spacer] call THY_fnc_DAP_marker_name_section_number;
		// Escape > if not a _isNum, skip to the next marker:
		if !_isNum then { continue };
		// If all validations alright:
		switch _tag do {
			case "BLU": { 
				_targetMkrsBLU pushBack _mkr;
				//if ( DAP_BLU_name isNotEqualTo "" ) then { _callsign = DAP_BLU_name } else { _callsign = _tag + " " + _callsign };
				// Why simplest? when u got too much mkrs, u need to know what the mkr really do, needing to add 'Artillery' but w/ _callsign it was huge on screen.
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
			case "OPF": { 
				_targetMkrsOPF pushBack _mkr;
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
			case "IND": { 
				_targetMkrsIND pushBack _mkr;
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
		};
	} forEach _possibleMkrs;
	// Destroying unnecessary things:
	_possibleMkrs = nil;
	// Updating the general list to return:
	_confirmedMkrs = [
		[_targetMkrsBLU],
		[_targetMkrsOPF],
		[_targetMkrsIND]
	];
	//systemChat str _confirmedMkrs;                                     // [*]             sides markers (array)
	//systemChat str _confirmedMkrs # 0;                                 // [[*]]           blufor markers only (array)
	//systemChat str (_confirmedMkrs # 0) # 0;                           // [[[*]]]         first blufor marker itself! (string)
	//private _toPrintOnChat = (_confirmedMkrs # 0) # 0;
	//systemChat _toPrintOnChat;
	//systemChat str markerPos _toPrintOnChat;
	//sleep 5;

	// By actived side, check if there is, at least, one fire marker available:
	if DAP_BLU_isOn then {
		if ( count (_confirmedMkrs # 0) isEqualTo 0 ) then {
			// Turn the side off:
			DAP_BLU_isOn = false;
			// Update the Public variable:
			publicVariable "DAP_BLU_isOn";
			// Warning message:
			systemChat format ["%1 TARGET MARKERS > NO BLU TARGET MARKER FOUND. Check the documentation or turn 'DAP_BLU_isOn' to 'false' in 'fn_DAP_management.sqf' file! For now, DAP turned off Fire-missions capacity for BLU!",
			DAP_txtWarnHeader];
		};
	};
	if DAP_OPF_isOn then {
		if ( count (_confirmedMkrs # 1) isEqualTo 0 ) then {
			// Turn the side off:
			DAP_OPF_isOn = false;
			// Update the Public variable:
			publicVariable "DAP_OPF_isOn";
			// Warning message:
			systemChat format ["%1 TARGET MARKERS > NO OPF TARGET MARKER FOUND. Check the documentation or turn 'DAP_OPF_isOn' to 'false' in 'fn_DAP_management.sqf' file! For now, DAP turned off Fire-missions capacity for OPF!",
			DAP_txtWarnHeader];
		};
	};
	if DAP_IND_isOn then {
		if ( count (_confirmedMkrs # 2) isEqualTo 0 ) then {
			// Turn the side off:
			DAP_IND_isOn = false;
			// Update the Public variable:
			publicVariable "DAP_IND_isOn";
			// Warning message:
			systemChat format ["%1 TARGET MARKERS > NO IND TARGET MARKER FOUND. Check the documentation or turn 'DAP_IND_isOn' to 'false' in 'fn_DAP_management.sqf' file! For now, DAP turned off Fire-missions capacity for IND!",
			DAP_txtWarnHeader];
		};
	};
	// Return:
	_confirmedMkrs;
};


THY_fnc_DAP_initial_validation = {
	// Still in fn_DAP_management.sqf reading, this function checks if the classnames registered for weanponry and magazines are valid.
	// Critical: don't use 'BIS_fnc_error' and 'sleep' here because we need the messages on the screen before the game starts!
	// Return _isInvalid: bool.

	// Params info: keep using local vars, not Public, in this case 'cause it happens before braodcast them in management!
	params ["_knownPiecesAll", "_knownMagsAll", "_piecesForbidden", "_magsForbidden", "_txtWarnHeader"];
	private ["_isInvalid", "_classname", "_txt1", "_txt2"];

	// Escape:
		// reserved space.
	// Initial values:
	_isInvalid = false;
	_classname = "";
	// Declarations:
		// reserved space.
	// Debug texts:
	_txt1 = "Check the 'fn_DAP_management.sqf' file";
	_txt2 = "The script stopped automatically";
	
	// CHECKING PIECE SECTION:
	{
		// Escape > If not string, abort:
		_classname = _x;
		if ( typeName _classname isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES REGISTER > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''B_G_Pickup_mrl_rf''. %3. %4!",
			 _txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES REGISTER > Never set an empty string ('' '') as artillery piece classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If a classname is forbidden, abort:
		_classname = _x;
		// Critical info: keep using 'findIf' with '==' and never 'in' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( _piecesForbidden findIf { _x == _classname } isNotEqualTo -1 ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES REGISTER > '%2' is a known problematic artillery piece, or it's inconsistent with DAP purposes. %3. %4!",
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If a classname shows up more than once, abort:
		_classname = _x;
		// Critical info: keep using '==' and never 'isEqualTo' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( ({_classname == _x} count _knownPiecesAll) > 1 ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES REGISTER > '%2' is duplicated as registered artillery piece. A piece CANNOT be registered more than once. %3. %4!", 
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If not string, abort:
		if ( typeName _x isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES FORBIDDEN > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''B_G_Pickup_mrl_rf''. %3. %4!", 
			_txtWarnHeader, _x, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _piecesForbidden;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY-PIECES FORBIDDEN > Never set an empty string ('' '') as artillery piece classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _piecesForbidden;

	// CHECKING MAGAZINES SECTION:
	{
		// Escape > If not string, abort:
		_classname = _x;
		if ( typeName _classname isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 MAGAZINE REGISTER > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''32Rnd_155mm_Mo_shells''. %3. %4!",
			 _txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE REGISTER > Never set an empty string ('' '') as magazine classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If a classname is forbidden, abort:
		_classname = _x;
		// Critical info: keep using 'findIf' with '==' and never 'in' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( _piecesForbidden findIf { _x == _classname } isNotEqualTo -1 ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE REGISTER > '%2' is a known problematic magazine, or it's inconsistent with DAP purposes. %3. %4!",
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If a classname shows up more than once, abort:
		_classname = _x;
		// Critical info: keep using '==' and never 'isEqualTo' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( ({_classname == _x} count _knownMagsAll) > 1 ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE REGISTER > '%2' is duplicated as registered magazine. A magazine CANNOT be registered more than once. %3. %4!", 
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If not string, abort:
		if ( typeName _x isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 MAGAZINE FORBIDDEN > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''32Rnd_155mm_Mo_shells''. %3. %4!", 
			_txtWarnHeader, _x, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _magsForbidden;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE FORBIDDEN > Never set an empty string ('' '') as magazine classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _magsForbidden;
	
	/*
	// Escape > xxxxxxxxxxxxxx, abort: without looping and in main scope of fnc (using exitWith);
	if ( xxxxxxxxxxxxxxxxxxx ) exitWith {
		// Warning message:
		["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
		systemChat format ["%1 XXXXXX > xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
		_txtWarnHeader];
		// Return _isInvalid:
		true;
	};
	// Escape > xxxxxxxxxxxxxx, abort: without looping but NOT in the main sscope of fnc (using breakTo);
	if ( xxxxxxxxxxxxxxxxxxx ) then {
		// Warning message:
		["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
		systemChat format ["%1 XXXXXX > xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
		_txtWarnHeader];
		// Prepare to return:
		_isInvalid = true; breakTo "earlyreturn";
	};
	// Escape > xxxxxxxxxxxxxx, abort: all situations where you have a looping;
	{
		if ( xxxxxxxxxxxxxxxxxxx ) then {
			// Warning message:
			["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
			systemChat format ["%1 XXXXXX > xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
			_txtWarnHeader];
			// Prepare to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _xxxxxxxxx;
	*/

	// Return:
	scopeName "earlyreturn";
	_isInvalid;
};


THY_fnc_DAP_convertion_side_to_tag = {
	// This function converts the side name to the owner tag for further validations.
	// Returns _tag: string of side abbreviation.

	params ["_side"];
	private ["_tag"];

	// Initial values:
	_tag = "";
	// Errors handling:
		// reserved space.
	// Escape:
		// reserved space.
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.
	// Main validation:
	switch _side do {
		case BLUFOR:      { _tag = "BLU" };
		case OPFOR:       { _tag = "OPF" };
		case INDEPENDENT: { _tag = "IND" };
		case CIVILIAN: {
			systemChat format ["%1 You CANNOT use CIVILIAN with DAP. Fix it, using BLUFOR, OPFOR, or INDEPENDENT in the rows of 'fn_DAP_firemissions.sqf' file.",
			DAP_txtWarnHeader]; sleep 5;
			// Prepare to return:
			_tag = "";
		};
		default { /* Debug message is not needed here coz the error handling is make in THY_fnc_DAP_add_firemission function */ };
	};
	// Return:
	_tag;
};


THY_fnc_DAP_firemission_validation = {
	// This function validate most part of the parameters of THY_fnc_DAP_add_firemission, controlling the integraty of the fire-mission setup defined by the editor.
	// Returns _isInvalid: bool.

	params ["_tag", "_targetsInfo", "_fireSetup", "_fireTriggers"];
	private ["_isInvalid", "_targetMkrs", "_sectorLetter", "_isReal", "_piecesAmount", "_caliber", "_magType", "_rounds", "_cycles", "_txt1", "_txt2", "_txt3", "_txt4", "_txt5"];

	// Escape:
		// reserved space.
	// Initial values:
	_isInvalid = false;
	// Declarations:
	_targetMkrs   = _targetsInfo # 0;
	_sectorLetter = _targetsInfo # 1;
	_isReal       = _fireSetup # 0;
	_piecesAmount = _fireSetup # 1;
	_caliber      = _fireSetup # 2;
	_magType      = _fireSetup # 3;
	_rounds       = _fireSetup # 4;
	_cycles       = _fireSetup # 5;
	// Debug texts:
	_txt1 = "Check the 'fn_DAP_firemissions.sqf' file";
	_txt2 = format ["This %1 fire-mission WON'T be created", _tag];
	_txt3 = format ["Fix it using trigger-id: [trg%1name%1var]; or delay-timer (in min): [30]; or object-variable-name: [obj%1name%1var]; or those 3 along: [trg%1name%1var, 30, obj%1mame%1var]", DAP_spacer];
	_txt4 = "To setup a not-virtual-firing, it's needed 5 data: 1) Number of pieces involved; 2) Caliber to use; 3) Ammo type to use; 4) Rounds per piece in cycle; and 5) How much cycles. E.g. [3, _power_MEDIUM, _use_HE, 5, 1]";
	_txt5 = "To use a virtual-firing, add 'false,' (no quotes) as first column (before number of pieces column)";
	// Escape > If some issue with the side declaration, abort:
	if ( _tag isEqualTo "" ) exitWith {
		// Warning message:
		systemChat format ["%1 SIDE > One or more %2 fire-mission rows have a issue with the side they belong to. %3. %4!", 
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	// Escape > If _targetsInfo is not array, abort:
	if ( typeName _targetsInfo isNotEqualTo "ARRAY" ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > One or more %2 fire-mission rows have no '[ ]' in target-markers column, e.g: [%3%4%2%4someNumber]. %5. %6!", 
		DAP_txtWarnHeader, _tag, DAP_prefix, DAP_spacer, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If non-existent target-markers, abort:
	if ( isNil { typeName _targetMkrs isEqualTo "ARRAY" } || count _targetsInfo isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > One or more %2 fire-mission rows got an invalid target-markers column, may be has its '[ ]' empty. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if first element of _targetsInfo is a string and not an array instead, abort:
	if ( typeName (_targetsInfo # 0) isEqualTo "STRING" ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > Looks you didn't type the %2 target-markers in its column, only the sector. Use that into '[ ]' like this for example: [DAP_targetMrks%2, ''A'']. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > first element is not array, abort:
	if ( typeName _targetMkrs isNotEqualTo "ARRAY" ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > Looks you declared the %2 target-markers without 'DAP_targetMrks%2' in its column in, at least, one of your fire-missiom rows. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If no target-markers, abort:
	if ( count _targetMkrs isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > There IS NO %2 MARKER to create a %2 fire-mission. Check if (e.g.) 'DAP_targetMrks%2' is spelled correctly and make sure there's at least 1 %2 target-marker placed on Eden. %3!", 
		DAP_txtWarnHeader, _tag, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > test if the first marker is a string, if not, abort:
	if ( typeName (_targetMkrs # 0) isNotEqualTo "STRING" ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > You have no %2 target-markers valid. Make sure you're using the structure like this: [DAP_targetMrks%2, ''A''] or [DAP_targetMrks%2, ''B''] and so on. %3!",
		DAP_txtWarnHeader, _tag, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If the side tag is not found in the first target-marker, abort to avoid a fire-mission over a target from another side:
	if ( (((_targetMkrs # 0) splitString DAP_spacer) # 1) isNotEqualTo _tag ) exitWith {  // e.g. ['DAP','BLU','A','1']
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > NOT ALLOWED to execute a %2 fire-mission with target-markers of another side. Make sure all %2 fire-mission rows have the target-markers assigned to %2. %3. %4!", 
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;  // splitString results e.g: ["DAP","BLU","A","1"]
		// Return _isInvalid:
		true;
	};
	// Escape > If target-sector is not a string, abort:
	if ( isNil { typeName _sectorLetter isEqualTo "STRING" } ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > Target-markers SECTOR must be a letter between DOUBLE-QUOTES, e.g: [DAP_targetMrks%2, ''A'']. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If the target sector letter has more than one character, abort:
	if ( _sectorLetter isNotEqualTo "" && count _sectorLetter isNotEqualTo 1 ) exitWith {
		// Warning message:
		systemChat format ["%1 TARGET MARKERS > At least one %2 fire-mission has an invalid target-markers-SECTOR. Sectorization accepts only ONE LETTER, like this: [DAP_targetMrks%2, ''F'']. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	// Escape > _fireSetup needs at least X elements and not more than Y. If less or more, abort:
	if ( count _fireSetup < 5 || count _fireSetup > 6 ) exitWith {  // It's because _isReal (for non-virtual-fire-mission) can be omited.
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. %3!",
		DAP_txtWarnHeader, _txt4, _txt5]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if the number of pieces requested is not a number or if it's breaking the amount limits, abort:
	if ( typeName _piecesAmount isNotEqualTo "SCALAR" || _piecesAmount < 1 || _piecesAmount > 10 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. Number of pieces limit: min=1, max=10. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if the caliber power is not a string, abort:
	if ( typeName _caliber isNotEqualTo "STRING" ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if the magazine type is not a string, abort:
	if ( typeName _magType isNotEqualTo "STRING" ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if the number of rounds requested is not a number or if it's breaking the amount limits, abort:
	if ( typeName _rounds isNotEqualTo "SCALAR" || _rounds < 1 || _rounds > 50 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. Number of rounds limit: min=1, max=50. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > if the number of cycles to repeat the fire-mission requested is not a number or if it's breaking the amount limits, abort:
	if ( typeName _cycles isNotEqualTo "SCALAR" || _cycles < 1 || _cycles > 50 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. Cycle of times limit: min=1, max=50. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	// Escape > If _fireTriggers is not array, abort:
	if ( typeName _fireTriggers isNotEqualTo "ARRAY" ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE-MISSION TRIGGER > One or more %2 fire-mission rows have no '[ ]' in fire-triggers column. %3. %4. %5!",
		DAP_txtWarnHeader, _tag, _txt3, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If _fireTriggers is empty, abort:
	if ( count _fireTriggers isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE-MISSION TRIGGER > At least one %2 fire-mission row has no any type of trigger defined. %3. %4. %5!",
		DAP_txtWarnHeader, _tag, _txt3, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If _fireTriggers excepted the trigger elements limit, abort:
	if ( count _fireTriggers > 3 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE-MISSION TRIGGER > At least one %2 fire-mission row has more than the limit (3) of triggers acceptable for fire-mission. %3. %4!",
		DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > If some _fireTriggers is in a wrong format, abort:
	{
		if ( !(typeName _x in ["OBJECT", "SCALAR"]) ) then { 
			// Warning message:
			systemChat format ["%1 FIRE-MISSION TRIGGER > %2 > Make sure you're using a timer or a trigger name without quotes. %3. %4. %5!",
			DAP_txtWarnHeader, _tag, _txt3, _txt1, _txt2]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _fireTriggers;
	// Escape > If _fireTriggers timer is zero, abort:
	{
		if ( typeName _x isEqualTo "SCALAR" ) then {
			// Disclaimer: why separing conditions (above and below)? Because this approach avoid an error if the _x is not number and hit the 'isEqualTo 0'!
			if ( _x isEqualTo 0 ) then {
				// Warning message:
				systemChat format ["%1 FIRE-MISSION TRIGGER > %2 > Please, don't use '0' (zero) as a value for timer-trigger. If you have NO intension to use the timer, remove any number from the trigger column in this %2 fire-mission. %3!",
				DAP_txtWarnHeader, _tag, _txt2]; sleep 5;
				// Prepare to return:
				_isInvalid = true; breakTo "earlyreturn";
			};
		};
	} forEach _fireTriggers;
	// Escape > If _fireTriggers content doesn't exist in-game, abort:
	{
		if ( isNil "_x" ) then {
			// Warning message:
			systemChat format ["%1 FIRE-MISSION TRIGGER > At least one %2 fire-mission row has a trigger method invalid. Make sure you SPELLED the trigger and/or the target name CORRECTLY. %3. %4!",
			DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _fireTriggers;
	// Escape > If _fireTriggers there is more than 1 timer, abort:
	{
		if ( { typeName _x isEqualTo "SCALAR" } count _fireTriggers > 1 ) then {
			// Warning message:
			systemChat format ["%1 FIRE-MISSION TRIGGER > At least one %2 fire-mission row has more than one timer as trigger method. You can use 3 different trigger methods, or 3 of the same method, excluding Timer for logic reasons. %3. %4!",
			DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _fireTriggers;
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	/*
	// Escape > xxxxxxxxxxxxxx, abort: without looping and in main scope of fnc (using exitWith);
	if ( xxxxxxxxxxxxxxxxxxx ) exitWith {
		// Warning message:
		systemChat format ["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
		DAP_txtWarnHeader, _tag]; sleep 5;
		// Return _isInvalid:
		true;
	};
	// Escape > xxxxxxxxxxxxxx, abort: without looping but NOT in the main sscope of fnc (using breakTo);
	if ( xxxxxxxxxxxxxxxxxxx ) then {
		// Warning message:
		systemChat format ["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
		DAP_txtWarnHeader, _tag]; sleep 5;
		// Prepare to return:
		_isInvalid = true; breakTo "earlyreturn";
	};
	// Escape > xxxxxxxxxxxxxx, abort: all situations where you have a looping;
	{
		if ( xxxxxxxxxxxxxxxxxxx ) then {
			// Warning message:
			systemChat format ["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
			DAP_txtWarnHeader, _tag]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "earlyreturn";
		};
	} forEach _xxxxxxxxx;
	*/

	// Return:
	scopeName "earlyreturn";
	_isInvalid;
};


THY_fnc_DAP_assembling_firemission_team = {
	// This function assembly the most prepare artillery-pieces for a specific fire-mission, based on the fire-mission requirements listed in fn_DAP_fireMissions.sqf file.
	// Returns _fmGroupInfo: array. Return empty if nothing available.

	params ["_fmMkrPos", "_side", "_tag", "_fmCode", "_numRequested", "_caliber", "_magType", "_shouldReport"];
	private ["_libraryCaliber", "_libraryMags", "_preCandidates", "_fmGroupInfo", "_candidates", "_candApprovedMags", "_ammo", "_finalists", "_bestOverall", "_pieceCrewmen"];

	// Escape:
		// reserved space.
	// Initial values:
	_libraryCaliber   = [];
	_libraryMags      = [];
	_preCandidates    = [];
	_fmGroupInfo       = [];
	_candidates       = [];
	_candApprovedMags = [];
	_ammo             = "";
	_finalists        = [];
	_bestOverall      = [];
	_pieceCrewmen     = [];
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.
	// (SETP 1/X) Based on the request, selecting only the specific caliber section from the Artillery-pieces library:
	switch _caliber do {
		case "LIGHT":      { _libraryCaliber = DAP_piecesCaliber_light };
		case "MEDIUM":     { _libraryCaliber = DAP_piecesCaliber_medium };
		case "HEAVY":      { _libraryCaliber = DAP_piecesCaliber_heavy };
		case "SUPERHEAVY": { _libraryCaliber = DAP_piecesCaliber_superHeavy };
		case "COMBINED":   { _libraryCaliber = DAP_piecesCaliber_light + DAP_piecesCaliber_medium + DAP_piecesCaliber_heavy + DAP_piecesCaliber_superHeavy };
		default {
			// Warning message:
			systemChat format ["%1 ASSEMBLING %2 ARTILLERY TEAM > At least one %2 fire-mission is using an invalid CALIBER. Check the 'fn_DAP_management.sqf' file. This fire-mission was aborted.", 
			DAP_txtWarnHeader, _tag]; sleep 5;
			// Return:
			breakTo "earlyreturn";
		};
	};

	// (SETP 2/X) Based on the request, selecting only the specific ammo type section from the Magazines library:
	switch _magType do {
		case "HE":              { _libraryMags = DAP_mags_he };
		case "CLUSTER":         { _libraryMags = DAP_mags_cluster };
		case "CLUSTER_MINE_AP": { _libraryMags = DAP_mags_cluster_mine_ap };
		case "CLUSTER_MINE_AT": { _libraryMags = DAP_mags_cluster_mine_at };
		case "GUIDED":          { _libraryMags = DAP_mags_guided };
		case "GUIDED_LASER":    { _libraryMags = DAP_mags_guided_laser };
		case "SMOKE":           { _libraryMags = DAP_mags_smoke };
		case "FLARE":           { _libraryMags = DAP_mags_flare };
		default {
			// Warning message:
			systemChat format ["%1 ASSEMBLING %2 ARTILLERY TEAM > At least one %2 fire-mission is using an invalid AMMUNITION. Check the 'fn_DAP_management.sqf' file. This fire-mission was aborted.", 
			DAP_txtWarnHeader, _tag]; sleep 5;
			// Return:
			breakTo "earlyreturn";
		};
	};
	
	// (STEP 3/X) Filtering the current side-pieces by those that are the requested caliber and have some ammunition:
	switch _tag do {
		case "BLU": {
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesBLU] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available (only irreversible details):
			DAP_piecesBLU = DAP_piecesBLU select { alive _x && alive (gunner _x) };  // DONT!!!! Dont include ammunition checks here coz you are excluding the possibility to rearm later!
			// Broadcasting the public update:
			publicVariable "DAP_piecesBLU";
			// Saving current pieces that need to rearm to be operational/selectable again:
			if !DAP_artill_isInfiniteAmmo then {
				{ if ([_x] call THY_fnc_VO_is_rearm_needed) then { ["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list } } forEach DAP_piecesBLU;
			};
			// Check the current ammunition status: 
			_preCandidates = DAP_piecesBLU select { !([_x] call THY_fnc_VO_is_rearm_needed) };
		};
		case "OPF": { 
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesOPF] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available (only irreversible details):
			DAP_piecesOPF = DAP_piecesOPF select { alive _x && alive (gunner _x) };  // DONT!!!! Dont include ammunition checks here coz you are excluding the possibility to rearm later!
			// Broadcasting the public update:
			publicVariable "DAP_piecesOPF";
			// Saving current pieces that need to rearm to be operational/selectable again:
			if !DAP_artill_isInfiniteAmmo then {
				{ if ([_x] call THY_fnc_VO_is_rearm_needed) then { ["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list } } forEach DAP_piecesOPF;
			};
			// Check the current ammunition status: 
			_preCandidates = DAP_piecesOPF select { !([_x] call THY_fnc_VO_is_rearm_needed) };
		};
		case "IND": {
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesIND] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available (only irreversible details):
			DAP_piecesIND = DAP_piecesIND select { alive _x && alive (gunner _x) };  // DONT!!!! Dont include ammunition checks here coz you are excluding the possibility to rearm later!
			// Broadcasting the public update:
			publicVariable "DAP_piecesIND";
			// Saving current pieces that need to rearm to be operational/selectable again:
			if !DAP_artill_isInfiniteAmmo then {
				{ if ([_x] call THY_fnc_VO_is_rearm_needed) then { ["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list } } forEach DAP_piecesIND;
			};
			// Check the current ammunition status: 
			_preCandidates = DAP_piecesIND select { !([_x] call THY_fnc_VO_is_rearm_needed) };
		};
	};  // switch _tag ends.
	// Escape > If no side pieces available:
	if ( count _preCandidates isEqualTo 0 ) exitWith {
		// Side command message:
		if _shouldReport then { 
			[_side, "BASE"] commandChat "Squad leaders, we HAVE NO EVEN ONE artillery-piece available for now! You're on your own... Over.";
			sleep 3;
		};
		// Return:
		_fmGroupInfo;
	};
	// Checking the caliber:
	{ if ( typeOf _x in _libraryCaliber ) then { _candidates pushBack _x } } forEach _preCandidates;
	// Escape > If no side pieces available:
	if ( count _candidates isEqualTo 0 ) exitWith { _fmGroupInfo /* Return */ };
	// Debug message:
	if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {[
		"%1 ASSEMBLING %2 ARTILLERY TEAM > From %3 in the field, %4 have the requested caliber (%5).",
		DAP_txtDebugHeader,
		_tag,
		count _preCandidates,
		count _candidates,
		_caliber
		] call BIS_fnc_error; sleep 3;
	};
	// Escape > If no side candidate-pieces available:
	if ( count _candidates isEqualTo 0 ) exitWith {
		// Side command message:
		if _shouldReport then { 
			[_side, "BASE"] commandChat "Squad leaders, unfortunately our artillery DON'T fit the BASIC requirements for the planned fire-mission that was supposed to take place now, over.";
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo-type = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_fmGroupInfo;
	};

	// (STEP 4/X) Filtering those right-caliber-pieces by those that also have the requested ammo-type:
	{  // forEach _candidates:
		// Compars and stores only approved mags (if the _candidates got):
		_candApprovedMags = _libraryMags arrayIntersect (getArtilleryAmmo [_x]);
		// One or more ammo options:
		if ( count _candApprovedMags > 0 ) then {
			// Debug message:
			if ( DAP_debug_isOn && ( DAP_debug_isOnTeamCheck || DAP_debug_isOnAmmo ) && count _candApprovedMags > 1 ) then { 
				["%1 ASSEMBLING %2 ARTILLERY TEAM > '%3' approved mag types: %4 = %5. DAP will select randomly one of them.", DAP_txtDebugHeader, _tag, _x, count _candApprovedMags, _candApprovedMags] call BIS_fnc_error; sleep 3;
			};
			// Selecting the ammo:
			_ammo = selectRandom _candApprovedMags;
			// Building the array to receive all data needed for _fmGroupInfo:
			_finalists append [[nil, _x, _ammo]];
		};
	} forEach _candidates;
	// Escape > If no side finalist-pieces available:
	if ( count _finalists isEqualTo 0 ) exitWith {
		// Side command message:
		if _shouldReport then { 
			[_side, "BASE"] commandChat format [
				"Squad leaders, although our artillery has %1 the AMMO-TYPE requested (%2) for the planned fire-mission that was supposed to take place now, over.",
				if ( count _candidates > 8 ) then {"MANY pieces with the right caliber, they DON'T HAVE"} else {
					if ( count _candidates > 1 ) then {"a FEW pieces with the right caliber, they DON'T HAVE"} else {"ONLY ONE piece with the right caliber, it DOESN'T HAVE"};
				},
				_magType
			];
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo-type = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_fmGroupInfo;
	};
	
	// (STEP 5/X) Filtering those right-caliber-and-ammo-type-pieces by those that also have range to the target:
	_bestOverall = _finalists select { _fmMkrPos inRangeOfArtillery [[_x # 1], _x # 2] };  // _x # 0 = reserved space / _x # 1 = obj  /  _x # 2 = _ammo.
	// Escape > no _finalists, abort:
	if ( count _bestOverall isEqualto 0 ) exitWith {
		// Side command message:
		if _shouldReport then {
			[_side, "BASE"] commandChat format [
				"Squad leaders, even with %1 RANGE for the planned fire-mission that was supposed to take place now, over.",
				if ( count _finalists > 1 ) then {"SOME PIECES of the requested caliber and ammo-type, they DON'T HAVE"} else {"A PIECE of the requested caliber and ammo-type, it HAS NO"}
			];
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo-type = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_fmGroupInfo;
	};
	// _bestOverall needs define its leader/closest from the target:
	if ( count _bestOverall >= 2 ) then {
		// Build and array (_fmGroupInfo) with another array in:
			// 1st element: distance between piece and the target-marker,
			// 2nd element: piece (object) itself,
			// 3rd element: selected ammo.
			// E.g. [23423e.05+3, dap_1, "12Rnd_HE_example"]
		_fmGroupInfo = _bestOverall apply {
			[
				// Distance:
				// Important, if specific caliber, always consider the real distance, otherwise it creates a fake distance (0-500) to randomize the piece choices during the "sort" and avoid the sort select only one caliber type.
				if ( _caliber isNotEqualTo "COMBINED") then { _fmMkrPos distanceSqr (_x # 1) } else { round (random 501) },
				// Piece:
				_x # 1,
				// Ammo:
				_x # 2
			];
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then { ["%1 Team check before reordering (sort): %2", DAP_txtDebugHeader, _fmGroupInfo] call BIS_fnc_error; sleep 5 };
		// Sort the _fmGroupInfo where the first element is the closest one from the target (and DAP will deal with it as the fire-mission leader later):
		_fmGroupInfo sort true;
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then { ["%1 Team check after reordering (sort): %2", DAP_txtDebugHeader, _fmGroupInfo] call BIS_fnc_error; sleep 5 };
		// Resize the _fmGroupInfo only for what was requested, if appliable:
		if ( count _fmGroupInfo > _numRequested ) then { 
			_fmGroupInfo resize _numRequested;
			// Debug:
			if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then { ["%1 Team resized: %2", DAP_txtDebugHeader, _fmGroupInfo] call BIS_fnc_error; sleep 5 };
		};
		
		// WIP: Booking the piece busy with a fire-mission!
		// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	// _fmGroupInfo has not enough number of pieces requested, take all those we got:
	} else {
		// Prepare to return:
		_fmGroupInfo = _bestOverall;
		// Side command message:
		if _shouldReport then {
			[_side, "BASE"] commandChat format ["Squad leaders, we'll %1, but the fire-mission will take place now!",
			if (!(_magType in ["FLARE","SMOKE"])) then {"hammer the position with LESS power as planned"} else {if (_magType isEqualTo "SMOKE") then {"NOT blind the position as planned"} else {"NOT paint the sky as planned"}}];
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Gonna use %4 with: Caliber = %5 | Ammo-type = %6",
				DAP_txtDebugHeader, _tag, _numRequested, count _fmGroupInfo, _caliber, _magType] call BIS_fnc_error; 
			};
			sleep 3;
		};
	};

	// FORMALIZING THE TEMPORARY GROUP
	// Important: the piece-leader will be the _fmGroupInfo index '0'. It because, in a regular condition, the leader is the closest piece from the target ("better visual, intel", simulating hehe).
	for "_i" from 1 to (count _fmGroupInfo) do {
		// [array of units from other groups] join (group of the first piece):
		(crew ((_fmGroupInfo # _i) # 1)) join group ((_fmGroupInfo # 0) # 1);
	};
	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
		["%1 ASSEMBLING %2 ARTILLERY TEAM > Successfully done! | From %3 ok, gonna use the requested: %4 | Temporary group: %5 (%6 members in %4 pieces) | for %7-FIRE-MISSION.",
			DAP_txtDebugHeader,
			_tag,
			count _bestOverall,
			count _fmGroupInfo,
			groupId (group ((_fmGroupInfo # 0) # 1)),
			count (units (group ((_fmGroupInfo # 0) # 1))),
			_fmCode
		] call BIS_fnc_error;
		sleep 5;
	};

	// Return:
	scopeName "earlyreturn";
	_fmGroupInfo;
};


THY_fnc_DAP_firemission_code = {
	// This function gives a unique codename for each side fire-mission scheduled. The codename is needed for futher actions.
	// Returns _fmCode: string.

	params ["_tag"];
	private ["_chosen"];

	// Escape:
		// reserved space.
	// Initial values:
	_chosen = "";
	// Selecting the name and remove it from the side code list:
	switch _tag do {
		case "BLU": { _chosen = selectRandom (DAP_firemissions_codenames # 0); if (!isNil { _chosen isNotEqualTo "" }) then {(DAP_firemissions_codenames # 0) deleteAt ((DAP_firemissions_codenames # 0) find _chosen)} };
		case "OPF": { _chosen = selectRandom (DAP_firemissions_codenames # 1); if (!isNil { _chosen isNotEqualTo "" }) then {(DAP_firemissions_codenames # 1) deleteAt ((DAP_firemissions_codenames # 1) find _chosen)} };
		case "IND": { _chosen = selectRandom (DAP_firemissions_codenames # 2); if (!isNil { _chosen isNotEqualTo "" }) then {(DAP_firemissions_codenames # 2) deleteAt ((DAP_firemissions_codenames # 2) find _chosen)} };
	};
	// Broadcasting the public update:
	publicVariable "DAP_firemissions_codenames";
	// Error handling > If no more codename available:
	if ( isNil { typeName _chosen isEqualTo "ARRAY" } ) then { _chosen = "FM" + str (round (random 501)) };
	// Error handling > If editor customized the codes:
	_chosen = toUpper _chosen;
	// Return:
	_chosen;
};


THY_fnc_DAP_firemission_schedule = {
	// This function is the CRUD for fire-mission control, needed for better sync of the events.
	// Returns _isHoldingFire.

	params ["_action", "_side", "_fmCode", ["_isHoldingFire", true]];
	//private [""];
	/*
		Scheduling structure:
		
		DAP_fmScheduled = [
			[0 = blu:
				[0 = fm:
					_fmCode,
					_isHoldingFire,
					_fmGroup (added right after team creation)
				],
				[1 = fm:
					_fmCode,
					_isHoldingFire,
					_fmGroup (added right after team creation)
				],
				[2 = fm:
					_fmCode,
					_isHoldingFire,
					_fmGroup (added right after team creation)
				],
				...
			],
			[1 = opf:
				...
			],
			[2 = ind:
				...
			]
		]
	*/

	// Initial values:
		// reserved space.
	// Escape:
		// reserved space.
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.

	// Main functionality:
	switch _action do {
		case "CREATE": {
			switch _side do {
				case BLUFOR:      { (DAP_fmScheduled # 0) pushBack [_fmCode, _isHoldingFire] };  // [fire-mission-codename, team-must-hold-fire] and later it receives a third element (_fmGroup).
				case OPFOR:       { (DAP_fmScheduled # 1) pushBack [_fmCode, _isHoldingFire] };
				case INDEPENDENT: { (DAP_fmScheduled # 2) pushBack [_fmCode, _isHoldingFire] };
			};
			// Broadcasting the public update:
			publicVariable "DAP_fmScheduled";
		};
		case "READ": {
			switch _side do {
				case BLUFOR:      { _isHoldingFire = ((DAP_fmScheduled # 0) select ((DAP_fmScheduled # 0) find _fmCode)) # 1 };
				case OPFOR:       { _isHoldingFire = ((DAP_fmScheduled # 1) select ((DAP_fmScheduled # 1) find _fmCode)) # 1 };
				case INDEPENDENT: { _isHoldingFire = ((DAP_fmScheduled # 2) select ((DAP_fmScheduled # 2) find _fmCode)) # 1 };
			};
		};
		case "UPDATE": {
			switch _side do {
				case BLUFOR:     { (DAP_fmScheduled # 0) set [ (DAP_fmScheduled # 0) find _fmCode, [_fmCode, _isHoldingFire, ((DAP_fmScheduled # 0) select ((DAP_fmScheduled # 0) find _fmCode)) # 2] ]};  // array set [idx, data]
				case OPFOR:      { (DAP_fmScheduled # 1) set [ (DAP_fmScheduled # 1) find _fmCode, [_fmCode, _isHoldingFire, ((DAP_fmScheduled # 1) select ((DAP_fmScheduled # 1) find _fmCode)) # 2] ]};
				case INDEPENDENT:{ (DAP_fmScheduled # 2) set [ (DAP_fmScheduled # 2) find _fmCode, [_fmCode, _isHoldingFire, ((DAP_fmScheduled # 2) select ((DAP_fmScheduled # 2) find _fmCode)) # 2] ]};
			};
			// Broadcasting the public update:
			publicVariable "DAP_fmScheduled";
		};
		case "DELETE": {
			switch _side do {
				case BLUFOR:      { (DAP_fmScheduled # 0) deleteAt ( (DAP_fmScheduled # 0) find _fmCode ) };
				case OPFOR:       { (DAP_fmScheduled # 1) deleteAt ( (DAP_fmScheduled # 1) find _fmCode ) };
				case INDEPENDENT: { (DAP_fmScheduled # 2) deleteAt ( (DAP_fmScheduled # 2) find _fmCode ) };
			};
			// Broadcasting the public update:
			publicVariable "DAP_fmScheduled";
		};
	};
	// Return:
	_isHoldingFire;
};


THY_fnc_DAP_is_member_firing = {
	// This function checks if someone from a custom group is shooting, no matter what amount of members is shooting, it will returns if at least one is firing.
	// Returns _isFiring: bool.

	params ["_side", "_fmCode", "_piece", "_pieceLeader"];
	private ["_isFiring", "_fmGroup"];

	// Escape > if not leader checking, abort:
	if ( _piece isNotEqualTo _pieceLeader) exitWith { false };
	// Initial values:
	_isFiring = false;
	_fmGroup  = grpNull;
	// Declarations:
	switch _side do {
		case BLUFOR:      { _fmGroup = ((DAP_fmScheduled # 0) select ((DAP_fmScheduled # 0) find _fmCode)) # 2 }; 
		case OPFOR:       { _fmGroup = ((DAP_fmScheduled # 1) select ((DAP_fmScheduled # 1) find _fmCode)) # 2 };
		case INDEPENDENT: { _fmGroup = ((DAP_fmScheduled # 2) select ((DAP_fmScheduled # 2) find _fmCode)) # 2 };
	};

	{ _x addEventHandler ["Fired", { /* params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"]; */ _isFiring = true }]; systemChat str _isFiring } forEach (units _fmGroup);
	
	
	
	systemChat format ["_isFiring=%1", _isFiring];


	// Return:
	_isFiring;
};


THY_fnc_DAP_firing = {
	// This function just control the firing of the fire-mission. Once it's finished, this thread/spawn is done.
	// Returns nothing.

	params ["_side", "_fmGroup", "_fmCode", "_cycles", "_fmMkrPos", "_magType", "_ammo", "_rounds", "_teamCooldown", "_shouldReport"];
	private ["_cyclesRequested", "_fmGroupPieces"];

	// Initial values:
	_cyclesRequested = _cycles;
	_fmGroupPieces   = [];
	// Declarations:
		// reserved space.
	// Humanizing/desynchronizing the firing from multiple sources:
	//sleep selectRandom [0.26, 0.41, 0.63, 0.83, 1.09, 1.27, 1.49, 1.63, 1.96];
	// Firing if has cycle, the piece is alive, the gunner is alive, and there's ammunition in main gun:
	while { _cycles > 0 } do {  // WIP is needed this rearm check? think!
		

		waitUntil { sleep 10; [_fmGroup, _fmMkrPos, objNull, 40, ""] call BIS_fnc_wpArtillery };


		// Control:
		_cycles = _cycles - 1;
		
		// If there's at least one more repetition cycle:
		if ( _shouldReport && _cycles > 0 ) then {
			// Side command message:
			leader _fmGroup commandChat format ["Stand by for the next rounds cycle in %1 seconds, sir.", _teamCooldown];
		};

		// Check the current pieces alive in the group:
		_fmGroupPieces = [_fmGroup, false] call BIS_fnc_groupVehicles;  // https://community.bistudio.com/wiki/BIS_fnc_groupVehicles
		// Rearm and cooldown:
		{ [_side, _x, _teamCooldown, _shouldReport] call THY_fnc_DAP_rearming } forEach _fmGroupPieces;
	
	};  // While loop ends.

	// Side command message:
	if _shouldReport then {
		// If the fire-mission leader:
		if ( _piece isEqualTo _pieceLeader ) then {
			// breath before to talk:
			sleep 5;
			// If piece and its crew is fine enough:
			if ( alive _pieceLeader && count (crew _pieceLeader) > 0 ) then {
				if ( _cycles isEqualTo 0 ) then {
					// Side command message:
					_pieceLeader commandChat format ["Fire-mission from %1-TEAM was successfully completed, sir. Over.", groupId (group _pieceLeader)];
				} else {
					// Side command message:
					_pieceLeader commandChat format ["Fire-mission from %1-TEAM COULDN'T execute all planned cycles, sir! Over.", groupId (group _pieceLeader)];
				};
			// Fire-mission leader is neutralized:
			} else {
				// Side command message:
				[_side, "BASE"] commandChat format ["Squad leaders, we just lost signal with the fire-mission-leader '%1'. Probably their fire-mission's gone. Over.", groupId (group _pieceLeader)];
				sleep 2;
			};
		// If not the fire-mission leader:
		} else {
			// If a fire-mission member (not leader) is neutralized:
			if ( !alive _piece || !alive (gunner _piece) ) then {
				// Side command message:
				_pieceLeader commandChat "A member of my fire-mission-team was lost, sir...";
				sleep 2;
			};
		};
	};
	//
	scopeName "earlyreturn";
	// WIP: it could prints out error for alive members during validation in the while-looping:
	// Avoid other members to activate deletion when they down:
	if ( !alive _pieceLeader || !alive (gunner _pieceLeader) ) then {
		// Deleting the fire-mission:
		["DELETE", _side, _fmCode] call THY_fnc_DAP_firemission_schedule;
	};
	// Return:
	true;
};


THY_fnc_DAP_trigger = {
	// This function (new thread) waits the right moment to pull the trigger of the artillery piece. It runs separately of THY_fnc_DAP_add_firemission that's finished once this fnc is called.
	// Returns nothing.

	params ["_side", "_tag", "_callsign", "_fmCode", "_fmTargetMkrs", "_fireSetup", "_fireTriggers"];
	private ["_wasReleased", "_timeLoop", "_time", "_ctr", "_wait", "_shouldReport", "_fmGroupInfo", "_fmGroup", "_pieceLeader", "_ammo", "_piece", "_gunner", "_isReal", "_numRequested", "_caliber", "_magType", "_rounds", "_cycles", "_txt1", "_fmMkrPos"];

	// Escape:
		// reserved space.
	// Initial values:
	_wasReleased  = False;
	_timeLoop     = 0;
	_time         = time;
	_ctr          = _time;
	_wait         = 10;  // CAUTION: this number is used to calcs the TIMER too.
	_shouldReport = false;
	_fmGroupInfo  = [];
	_fmGroup      = grpNull;
	_pieceLeader  = objNull;
	_ammo         = "";
	_piece        = objNull;
	_gunner       = objNull;
	_teamCooldown = 0;
	
	// Declarations:
	_isReal       = _fireSetup # 0;
	_numRequested = _fireSetup # 1;
	_caliber      = _fireSetup # 2;
	_magType      = _fireSetup # 3;
	_rounds       = _fireSetup # 4;
	_cycles       = _fireSetup # 5;

	// Debug texts:
	_txt1 = format ["fire-mission '%1' was released", _fmCode];
	// Fire-mission trigger conditions > Stay checking until the fire-mission is released:
	while { !_wasReleased } do {
		_timeLoop = time;
		// Delay for each loop check:
		waitUntil { sleep _wait; time >= _timeLoop + _wait };
		{  // forEach _fireTriggers:
			// TRIGGERED BY TIMER:
			// If fire-mission is triggered by timer, check if it's a number:
			if ( typeName _x isEqualTo "SCALAR" ) then {
				// Counter increase:
				_ctr = _ctr + _wait;
				// Timer checker:
				if ( _ctr >= _time + ((abs _x) * 60) ) exitWith {
					// Function completed:
					_wasReleased = true;
					// Debug message:
					if DAP_debug_isOn then {
						systemChat format ["%1 %2 %3 by TIMER (it was %4 minutes).", DAP_txtDebugHeader, _tag, _txt1, _x];
						// Reading breather:
						sleep 3;
					};
				};
			// otherwise:
			} else {
				// TRIGGERED BY ITSELF:
				// If fire-mission is triggered by an Eden-trigger, check if it's a real trigger:
				if ( _x isKindOf "EmptyDetector" ) then { 
					// If it's activated:
					if ( triggerActivated _x ) exitWith { 
						// Function completed:
						_wasReleased = true; 
						// Debug message:
						if DAP_debug_isOn then {
							systemChat format ["%1 %2 %3 by TRIGGER (%4).", DAP_txtDebugHeader, _tag, _txt1, _x];
							// Reading breather:
							sleep 3;
						};
					};
				// Otherwise:
				} else {
					// TRIGGERED BY TARGET:
					// If the fire-mission is triggered by target elimination:
					if ( !alive _x ) exitWith {
						// Function completed:
						_wasReleased = true;
						// Debug message:
						if DAP_debug_isOn then {
							systemChat format ["%1 %2 %3 by TARGET (%4).", DAP_txtDebugHeader, _tag, _txt1, _x];
							// Reading breather:
							sleep 3;
						};
					};
				};
			};
		} forEach _fireTriggers;
	};  // while loop ends;
	
	// MARKER SELECTION:
	// Select a fire-mission marker and take its position:
	// CRUCIAL: it's important the target-marker-selection to be here after the trigger checking 'cause it gives to the editor the chances to delete the marker 
	// for any mission logic reason before the fire-mission be triggered.
	_fmMkrPos = markerPos (selectRandom _fmTargetMkrs);  // returns a AGL pos, so [x, y, 0], z is always 0

	// CALIBER SETUP:
	switch _caliber do {
		case "LIGHT":      { _shouldReport = DAP_fmCaliber_shouldReportLight;    _teamCooldown = DAP_fmCaliber_timeRearmLight };
		case "MEDIUM":     { _shouldReport = DAP_fmCaliber_shouldReportMedium;   _teamCooldown = DAP_fmCaliber_timeRearmMedium };
		case "HEAVY":      { _shouldReport = DAP_fmCaliber_shouldReportHeavy;    _teamCooldown = DAP_fmCaliber_timeRearmHeavy };
		case "SUPERHEAVY": { _shouldReport = DAP_fmCaliber_shouldReportSuperH;   _teamCooldown = DAP_fmCaliber_timeRearmSuperH };
		case "COMBINED":   { _shouldReport = DAP_fmCaliber_shouldReportCombined; _teamCooldown = selectRandom [DAP_fmCaliber_timeRearmMedium, DAP_fmCaliber_timeRearmHeavy] };
	};
	// FIRE-MISSION:
	// If the piece is real (so, it has asset in-game involved):
	if _isReal then {
		// Assembling the fire-mission team:
		_fmGroupInfo = [_fmMkrPos, _side, _tag, _fmCode, _numRequested, _caliber, _magType, _shouldReport] call THY_fnc_DAP_assembling_firemission_team;
		// Escape > No team available:
		if ( count _fmGroupInfo isEqualTo 0 ) then { breakTo "earlyreturn" };
		
		// Extracting only the objects (team members/pieces) for further checks:
		//{ _fmTeam pushBack (_x # 1) } forEach _fmGroupInfo;
	
		// Declaring the group:
		_fmGroup = group ((_fmGroupInfo # 0) # 1);  // Output e.g.: B BLU FIRE SUPPORT-2

		// Including the fire-mission-team (only objects/pieces) into the specific fire-mission-data in DAP_fmScheduled control:
		switch _tag do {
			case "BLU": { (DAP_fmScheduled # 0) set [ (DAP_fmScheduled # 0) find _fmCode, [_fmCode, false, _fmGroup] ] };  // set [idx, data]
			case "OPF": { (DAP_fmScheduled # 1) set [ (DAP_fmScheduled # 1) find _fmCode, [_fmCode, false, _fmGroup] ] };
			case "IND": { (DAP_fmScheduled # 2) set [ (DAP_fmScheduled # 2) find _fmCode, [_fmCode, false, _fmGroup] ] };
		};


		// Fire (opening a new thread but here for each fire-mission-team-member [member and leader are, each one, a piece and its crewmen]):
		[_side, _fmGroup, _fmCode, _cycles, _fmMkrPos, _magType, _ammo, _rounds, _teamCooldown, _shouldReport] spawn THY_fnc_DAP_firing;




		/* {	// forEach _fmGroupInfo piece:
			_piece  = _x # 1;  // Important: _fmGroupInfo arrives here with arrays inside, each one with 3 elements, e.g [[2.94454e+07, dap_1, "Sh_155mm_AMOS"],...].
			_gunner = gunner _piece;  // Dont worry, THY_fnc_DAP_pieces_scanner make sure all pieces here got a gunner.
			// A bunch of conditions about piece and its crew's state:
			if ( alive _piece &&
				alive _gunner &&
				!(incapacitatedState _gunner in ["UNCONSCIOUS", "MOVING"]) &&
				canFire _piece &&
				alive _pieceLeader &&
				canFire _pieceLeader ) then {
					// Ammunition to be used:
					_ammo = _x # 2;
					// Fire (opening a new thread but here for each fire-mission-team-member [member and leader are, each one, a piece and its crewmen]):
					[_side, _fmCode, _pieceLeader, _cycles, _piece, _fmMkrPos, _magType, _ammo, _rounds, _teamCooldown, _shouldReport] spawn THY_fnc_DAP_firing;
			// The piece looks out of service:
			} else {
				// Side command message:
				if ( _shouldReport || DAP_debug_isOn ) then {
					if ( _piece isEqualTo _pieceLeader ) then {
						[_side, "BASE"] commandChat format ["Squad leaders, the LEADER of the %1-FIRE-MISSION is NOT responding. %1 has been cancelled, over!", _fmCode, _pieceLeader];
					} else {
						[_side, "BASE"] commandChat format ["Squad leaders, a member of %1-FIRE-MISSION is NOT responding, over!", _fmCode];
						if DAP_debug_isOn then { systemChat format ["%1 Member NOT responding = %2", DAP_txtDebugHeader, _piece]};
					};
					sleep 3;
				};
			};
		} forEach _fmGroupInfo; */


	// If the fire-mission-artillery-pieces are not real, not involving in-game), do it:
	} else {
		// WIP!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// Ammunition to be used:
		_ammo = "Sh_155mm_AMOS";  // https://community.bistudio.com/wiki/Arma_3:_CfgMagazines
		// Message to the leardership of ally sides:
		systemChat format ["%1 Fire-mission on the way!", _callsign];
		// Simulation the rounds travel to the target position:
		sleep DAP_fmVirtualETA;
		// [fire-mission-pos, ammo, radius, rounds, delay, conditionEnd, safezone, initial alt of projectil, fall speed, sounds] 
		[_fmMkrPos, _ammo, 100, 10, 5] spawn BIS_fnc_fireSupportVirtual;  // https://community.bistudio.com/wiki/BIS_fnc_fireSupportVirtual
		//[_target, _ammo, _accuracy, _rounds, _roundReloadDelay] spawn BIS_fnc_fireSupportCluster;  // https://community.bistudio.com/wiki/BIS_fnc_fireSupportCluster
	};
	// Return:
	scopeName "earlyreturn";
	true;
};


THY_fnc_DAP_add_firemission = {
	// This function start the schadule of a fire-mission.
	// Returns nothing.
	
	params ["_side", ["_targetsInfo", [[], ""]], ["_fireSetup", [true, 1, "MEDIUM", "HE", 5, 1]], ["_fireTriggers", 1]];
	private ["_callsign", "_tag", "_fmTargetMkrs", "_fmTargetMkrsSector"];
	
	// Initial values:
	_callsign = "";
	// Errors handling:
		// reserved space.
	// Declarations - part 1/2:
	// Important: dont declare _targetsInfo or _destsInfo selections before the Escapes coz during Escape tests easily the declarations will print out errors that will stop the creation of other groups.
	_tag = [_side] call THY_fnc_DAP_convertion_side_to_tag;  // if something wrong with _side, it will return empty.
	// Debug texts:
		// reserved space.
	// Escape - part 1/2:
	if ( [_tag, _targetsInfo, _fireSetup, _fireTriggers] call THY_fnc_DAP_firemission_validation ) exitWith {};
	// Declarations - part 2/2:
	_fmTargetMkrs       = _targetsInfo # 0;
	_fmTargetMkrsSector = toUpper (_targetsInfo # 1);
	_fmCode             = [_tag] call THY_fnc_DAP_firemission_code;
	switch _tag do {
		case "BLU": { _callsign = DAP_BLU_name };
		case "OPF": { _callsign = DAP_OPF_name };
		case "IND": { _callsign = DAP_IND_name };
	};
	// Save fire-mission data for further actions:
	["CREATE", _side, _fmCode, false] call THY_fnc_DAP_firemission_schedule;  // dont use _tag.
	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnSectors ) then {
		// Message:
		systemChat format ["%1 %2 FIRE-MISSION SCHEDULE > '%3' targets: %4 | Markers:\n%5.",
		DAP_txtDebugHeader, 
		_tag, 
		_fmCode,
		_fmTargetMkrsSector, 
		_fmTargetMkrs];
		// Breather:
		sleep 5;
	};
	// Selecting only those with right sector-letter:
	_fmTargetMkrs = +(_fmTargetMkrs select { _x find (DAP_spacer + _fmTargetMkrsSector + DAP_spacer) isNotEqualTo -1 });

	// TRIGGERS SECTION:
	// It starts the fire-mission trigger checking (it's opening a new thread!):
	[_side, _tag, _callsign, _fmCode, _fmTargetMkrs, _fireSetup, _fireTriggers] spawn THY_fnc_DAP_trigger;
	// CPU breather before check the next fire-mission or end the firemissions.sqf:
	sleep DAP_fireMissionBreath;
	// Return:
	true;
};


THY_fnc_DAP_debug = {
	// This function shows some numbers to the mission editor when debugging.
	// Returns nothing.

	//params ["", ""];
	//private ["", ""];
	
	// Initial values:
		// reserved space.
	// Errors handling > Wait global variables be broadcasted:
	if DAP_debug_isOnAmmo then {
		// If Blufor is in mission and has at least one piece, show the compatible magazines of the first asset only:
		if ( DAP_BLU_isOn && count DAP_piecesBLU > 0 ) then {waitUntil { sleep 1; !isNull (DAP_piecesBLU # 0) }};
		// If Opfor is in mission and has at least one piece, show the compatible magazines of the first asset only:
		if ( DAP_OPF_isOn && count DAP_piecesOPF > 0 ) then {waitUntil { sleep 1; !isNull (DAP_piecesOPF # 0) }};
		// If Independent is in mission and has at least one piece, show the compatible magazines of the first asset only:
		if ( DAP_IND_isOn && count DAP_piecesIND > 0 ) then {waitUntil { sleep 1; !isNull (DAP_piecesIND # 0) }};
	};
	// Escape:
		// reserved space.
	// Debug texts:
		// reserved space.
	// Declarations:
		// reserved space.
	// Hint info:
	hintSilent format [
		"\n--- DAP DEBUG MONITOR ---" +
		"\nInfinite ammo: %1" + 
		"\nPLANNED FIRE-MISSIONS (all): %2" +
		"%3" +
		"%4" +
		"%5" +
		"%6" +
		"%7" +
		"%8" +
		"%9" +
		"\n\n",
		if DAP_artill_isInfiniteAmmo then {"ON"} else {"OFF"},
		((if DAP_BLU_isOn then {count (DAP_fmScheduled # 0)} else {0}) + (if DAP_OPF_isOn then {count (DAP_fmScheduled # 1)} else {0}) + (if DAP_IND_isOn then {count (DAP_fmScheduled # 2)} else {0})),
		if DAP_BLU_isOn then {
			"\nby BLU:\n" + 
			str (DAP_fmScheduled # 0) +
			"\n"
		} else {""},
		if DAP_OPF_isOn then {
			"\nby OPF:\n" + 
			str (DAP_fmScheduled # 1) +
			"\n"
		} else {""},
		if DAP_IND_isOn then {
			"\nby IND:\n" + 
			str (DAP_fmScheduled # 2) +
			"\n"
		} else {""},
		if DAP_BLU_isOn then {
			"\n ---" +
			//"\nBLU Fire-missions: XX (WIP)" +
			format ["\nBLU Pieces: %1 %2", count DAP_piecesBLU, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 0)]}]
			//"\nBLU Virtual: XX (WIP)"
		} else {""},
		if DAP_OPF_isOn then {
			"\n ---" +
			//"\nOPF Fire-missions: XX (WIP)" +
			format ["\nOPF Pieces: %1 %2", count DAP_piecesOPF, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 1)]}]
			//"\nOPF Virtual: XX (WIP)"
		} else {""},
		if DAP_IND_isOn then {
			"\n ---" +
			//"\nIND Fire-missions: XX (WIP)" +
			format ["\nIND Pieces: %1 %2", count DAP_piecesIND, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 2)]}]
			//"\nIND Virtual: XX (WIP)"
		} else {""},
		if DAP_debug_isOnAmmo then {
			format [
				"\n---" +
				"\nAMMO MAGAZINES:" +
				"%1" +
				"%2" +
				"%3",
				if DAP_BLU_isOn then {format [
					"\n1st BLU PIECE FOUND:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n", 
					DAP_piecesBLU # 0, 
					typeOf (DAP_piecesBLU # 0), 
					toLower (groupId (group (DAP_piecesBLU # 0))),
					getArtilleryAmmo [DAP_piecesBLU # 0]
				]} else {""},
				if DAP_OPF_isOn then {format [
					"\n1st OPF PIECE FOUND:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n",
					DAP_piecesOPF # 0, 
					typeOf (DAP_piecesOPF # 0), 
					toLower (groupId (group (DAP_piecesOPF # 0))),
					getArtilleryAmmo [DAP_piecesOPF # 0]
				]} else {""},
				if DAP_IND_isOn then {format [
					"\n1st IND PIECE FOUND:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n",
					DAP_piecesIND # 0,
					typeOf (DAP_piecesIND # 0),
					toLower (groupId (group (DAP_piecesIND # 0))),
					getArtilleryAmmo [DAP_piecesIND # 0]
				]} else {""}
			];
		} else {""}
	];
	// CPU breather:
	sleep 10;
	// Return:
	true;
};
// Return:
true;