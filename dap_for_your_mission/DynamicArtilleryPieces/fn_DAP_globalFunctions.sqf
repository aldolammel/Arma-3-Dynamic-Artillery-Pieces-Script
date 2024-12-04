// DAP: Dynamic Artillery Pieces v1.5
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
	// This function (a simpler version from my 'Vehicles Overhauling' script) checks the mag capacity and how much ammo still remains within.
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
	// When the armed-vehicle has NO ammo-capacity (0% ammunition in its attributes) it will force the vehicle to rearm:
	} else { _isRearmNeeded = true };
	// Return:
	_isRearmNeeded;
};


THY_fnc_VO_restore_ammo_capacity = {
	// This function (simpler version from my 'Vehicles Overhauling' script) restores the piece ammo capacity. Sometimes (mostly w/ mods) for any reason,
	// pieces start w/ no mags, and this (DAP_artill_preventStartNoMags = true) will restore the original mags.
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


THY_fnc_DAP_pieces_scanner = {
	// This function searches and appends in a list all pieces (objects) confirmed as real. The searching take place once right at the mission begins through fn_DAP_management.sqf file.
	// Return: _confirmedPieces: array

	params ["_prefix", "_spacer"];
	private ["_confirmedPieces", "_sidesOn", "_isValid", "_piece", "_ctrBLU", "_ctrOPF", "_ctrIND", "_nameStructure", "_piecesBLU", "_piecesOPF", "_piecesIND", "_possiblePieces"];

	// Initial values:
	_confirmedPieces = [];
	_sidesOn         = [];
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
	if DAP_BLU_isOn then { _sidesOn pushBack BLUFOR };
	if DAP_OPF_isOn then { _sidesOn pushBack OPFOR };
	if DAP_IND_isOn then { _sidesOn pushBack INDEPENDENT };
	// Selecting the relevant markers:
	// Critical: careful because 'vehicles' command brings lot of trash along: https://community.bistudio.com/wiki/vehicles
	_possiblePieces = vehicles select { !isNull (gunner _x) && side (leader _x) in _sidesOn && (toUpper (str _x) find (_prefix + _spacer)) isNotEqualTo -1 };
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
		if DAP_artill_preventDynamicSim then { group _piece enableDynamicSimulation false };  // CRUCIAL for long distances!
		if DAP_artill_preventStartNoMags then { [_piece] call THY_fnc_VO_restore_ammo_capacity };
		if DAP_artill_preventUnlocked then { _piece setVehicleLock "LOCKEDPLAYER" };
		// Adding extra configs:
		if DAP_artill_preventMoving then { (driver _piece) disableAI "MOVE" };

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
				_ctrOPF = _ctrOPF + 1;
				group _piece setGroupIdGlobal [DAP_OPF_name + "-" + str _ctrOPF];
				_piecesOPF pushBack _piece;
			};
			case INDEPENDENT: { 
				_ctrIND = _ctrIND + 1;
				group _piece setGroupIdGlobal [DAP_IND_name + "-" + str _ctrIND];
				_piecesIND pushBack _piece;
			};
		};
	} forEach _possiblePieces;
	// Destroying unnecessary things:
	_possiblePieces = nil;
	// Updating the general list to return:
	// Important: I'm using this structure, imagining in future the pieces from side can be stored by class or something else. So first index always BLU, and so on.
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
	private ["_targetMkrsBLU", "_targetMkrsOPF", "_targetMkrsIND", "_confirmedMkrs", "_isValid", "_mkr", "_isValidShape", "_tag", "_sector", "_isNum", "_nameStructure", /* "_callsign", */ "_possibleMkrs"];

	// Initial values:
	_targetMkrsBLU = [];
	_targetMkrsOPF = [];
	_targetMkrsIND = [];
	_confirmedMkrs = [[_targetMkrsBLU], [_targetMkrsOPF], [_targetMkrsIND]];
	_isValid       = false;
	_mkr           = "";
	_isValidShape  = false;
	_tag           = "";
	_sector        = "";
	_isNum         = false;
	_nameStructure = [];
	//_callsign      = "Fire Support";
	// Step 1/2 > Creating a list with only markers with right prefix:
	// Selecting the relevant markers:
	_possibleMkrs = allMapMarkers select { toUpper _x find (_prefix + _spacer) isNotEqualTo -1 };
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
				if !DAP_BLU_isOn then { deleteMarker _mkr; continue };
				_targetMkrsBLU pushBack _mkr;
				//if ( DAP_BLU_name isNotEqualTo "" ) then { _callsign = DAP_BLU_name } else { _callsign = _tag + " " + _callsign };
				// Why simplest? when u got too much mkrs, u need to know what the mkr really do, needing to add 'Artillery' but w/ _callsign it was huge on screen.
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
			case "OPF": {
				if !DAP_OPF_isOn then { deleteMarker _mkr; continue };
				_targetMkrsOPF pushBack _mkr;
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
			case "IND": {
				if !DAP_IND_isOn then { deleteMarker _mkr; continue };
				_targetMkrsIND pushBack _mkr;
				_mkr setMarkerText format ["  %1 Artillery target-%2", _tag, _sector];
			};
		};
	} forEach _possibleMkrs;
	// Destroying unnecessary things:
	_possibleMkrs = nil;
	// Debug message:
	if DAP_debug_isOn then { systemChat format ["%1 Artillery target-markers found: %2 from DAP.", DAP_txtDebugHeader, count (_targetMkrsBLU + _targetMkrsOPF + _targetMkrsIND)] };
	// Updating the general list to return:
	// Important: I'm using this structure, imagining in future the markers from side can be stored by class or something else. So first index always BLU, and so on.
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
			DAP_OPF_isOn = false;
			publicVariable "DAP_OPF_isOn";
			systemChat format ["%1 TARGET MARKERS > NO OPF TARGET MARKER FOUND. Check the documentation or turn 'DAP_OPF_isOn' to 'false' in 'fn_DAP_management.sqf' file! For now, DAP turned off Fire-missions capacity for OPF!",
			DAP_txtWarnHeader];
		};
	};
	if DAP_IND_isOn then {
		if ( count (_confirmedMkrs # 2) isEqualTo 0 ) then {
			DAP_IND_isOn = false;
			publicVariable "DAP_IND_isOn";
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

	// Initial values:
	_isInvalid = false;
	_classname = "";
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

	// Initial values:
	_isInvalid = false;
	// Declarations:
	_targetMkrs   = _targetsInfo # 0;
	_sectorLetter = _targetsInfo # 1;
	//_isReal     = _fireSetup # 0;  // Not used here yet.
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


THY_fnc_DAP_all_group_vehicles = {
	// This function retuns all pieces (vehicles/static turrets) alive with crew from a specific group.
	// Returns _array: of objects.

	params ["_group"];
	private ["_array"];

	// Initial values:
	_array = [];
	// Collecting:
	{ _array pushBackUnique (vehicle _x) } forEach ( (units _group) select { alive _x && !isNull (objectParent _x) } );
	// Return:
	_array;
};


THY_fnc_DAP_rearming_pieces = {
	// This function rearms one or more artillery-pieces from the same group, but only after a cooldown.
	// Returns nothing.

	params ["_side", "_fmTeam", "_fmCode", "_teamCooldown"];
	private ["_piecesNeedRearm", "_ctr", "_time", "_loopFrequency", "_fmGroupPieces"];

	// Initial values:
	_piecesNeedRearm = [];
	_ctr             = 0;
	// Declarations:
	_time            = time;
	_loopFrequency   = ( _teamCooldown / 3 ); if ( _loopFrequency < 15 ) then { _loopFrequency = 15 };
	// Check all pieces available in fire-mission-group:
	_fmGroupPieces   = [_fmTeam] call THY_fnc_DAP_all_group_vehicles;
	// Not forced rearm:
	if !DAP_artill_forcedRearm then {
		// Store each piece that needs to rearm:
		{
			if ( [_x] call THY_fnc_VO_is_rearm_needed ) then { 
				_piecesNeedRearm pushBack _x;
				// Adding to the list of pieces with no ammo:
				["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list;
			};
		} forEach _fmGroupPieces;
	// Forced rearm:
	} else {
		_piecesNeedRearm = _fmGroupPieces;
		{ ["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list } forEach _fmGroupPieces;
	};

	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnAmmo ) then {
		["%1 REARMING > %2-FIRE-MISSION > %3 piece(s) from %4 need to rearm: %4 | Cooldown starting now...",
		DAP_txtDebugHeader, _fmCode, count _piecesNeedRearm, _fmTeam, _piecesNeedRearm] call BIS_fnc_error; sleep 3;
	};

	// STEP 1/2 (COOLDOWN)
	// Wait until the rearm cooldown is completed:
	waitUntil {
		{  // forEachReversed _piecesNeedRearm:
			// SFX, men at work:
			_ctr = _ctr + 1;
			if ( _ctr isEqualTo 4 ) then { playSound3D ["a3\sounds_f\sfx\ui\vehicles\vehicle_rearm.wss", _x]; _ctr = 0;
			} else { playSound3D ["a3\sounds_f\characters\cutscenes\concrete_acts_walkingchecking.wss", _x] };
			// If any piece isn't operational:
			if ( !alive _x || count (crew _x) isEqualTo 0 ) then {
				["REMOVE", _side, _x] call THY_fnc_DAP_out_of_ammo_list;
				_piecesNeedRearm deleteAt _forEachIndex;
			};
			// SFX breath:
			sleep 0.5;
		} forEachReversed _piecesNeedRearm;
		// Loop frequency:
		sleep _loopFrequency;
		// Stop waiting if:
		time > (_time + _teamCooldown);
	};

	// STEP 2/2 (REARM)
	{
		// Play SFX:
		playSound3D ["a3\sounds_f\sfx\ui\vehicles\vehicle_rearm.wss", _x];
		// Rearm:
		_x setVehicleAmmo 1;
		// Remove this piece from this global list:
		["REMOVE", _side, _x] call THY_fnc_DAP_out_of_ammo_list;
		// And remove from the local list too:
		_piecesNeedRearm deleteAt _forEachIndex;
		// SFX breath:
		sleep 1;
	} forEachReversed _piecesNeedRearm;

	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnAmmo ) then {
		["%1 REARMING > %2-FIRE-MISSION > %3!",
		DAP_txtDebugHeader,
		_fmCode,
		if ( count _piecesNeedRearm isEqualTo 0 ) then {
			format ["All %1 pieces are ready", _fmTeam];
		} else {
			format ["%1 still has %2 piece(s) that not rearmed", _fmTeam, count _piecesNeedRearm];
		}] call BIS_fnc_error; sleep 3;
	};
	// Return:
	true;
};


THY_fnc_DAP_out_of_ammo_list = {
	// This function adds or removes artillery-pieces with no ammo in a list to further actions.
	// Returns nothing.

	params ["_action", "_side", "_piece", ["_pieceLeader", objNull]];
	//private [""];

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
	if ( DAP_debug_isOn && DAP_debug_isOnAmmo && !DAP_artill_forcedRearm &&_action isEqualTo "ADD" ) then {  // DAP_artill_forcedRearm true makes all pieces be here!
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


THY_fnc_DAP_assembling_firemission_team = {
	// This function assemblies the most prepare artillery-pieces for a specific fire-mission, based on the fire-mission requirements listed in fn_DAP_fireMissions.sqf file.
	// Returns _return: array with two others in: _libraryMags and _chosenOnes. Return empty if no team members available.

	params ["_fmMkrPos", "_side", "_tag", "_fmCode", "_numRequested", "_caliber", "_magType", "_isReporting"];
	private ["_return", "_libraryCaliber", "_libraryMags", "_freePieces", "_preCandidates", "_chosenOnes", "_candidates", "_candApprovedMags", "_finalists", "_bestOverall", "_groupKnownIds", "_groupLeader"];

	// Initial values:
	_return           = [[/* _libraryMags */],[/* _chosenOnes */]];
	_libraryCaliber   = [];
	_libraryMags      = [];
	_freePieces       = [];
	_preCandidates    = [];
	_chosenOnes       = [];
	_candidates       = [];
	_candApprovedMags = [];
	_finalists        = [];
	_bestOverall      = [];
	_groupKnownIds    = [];
	_groupLeader      = grpNull;

	// CHECKING THE ASSEMBLY QUEUE:
	waitUntil { sleep 10; ["IS_STATUS_FREE", _side] call THY_fnc_DAP_firemission_schedule };
	["ASSEMBLY_BUSY", _side] call THY_fnc_DAP_firemission_schedule;

	// (SETP 1/8) SELECTING CALIBER LIBRARY
	// Based on the request, selecting only the specific caliber section from the Artillery-pieces library:
	switch _caliber do {
		case "LIGHT":      { _libraryCaliber = DAP_piecesCaliber_light };
		case "MEDIUM":     { _libraryCaliber = DAP_piecesCaliber_medium };
		case "HEAVY":      { _libraryCaliber = DAP_piecesCaliber_heavy };
		case "SUPERHEAVY": { _libraryCaliber = DAP_piecesCaliber_superHeavy };
		case "COMBINED":   { _libraryCaliber = DAP_piecesCaliber_light + DAP_piecesCaliber_medium + DAP_piecesCaliber_heavy + DAP_piecesCaliber_superHeavy };
		default {
			// Warning message:
			systemChat format ["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > At least one %2 fire-mission is using an invalid CALIBER. Check the 'fn_DAP_management.sqf' file. This fire-mission was aborted.", 
			DAP_txtWarnHeader, _tag, _fmCode]; sleep 5;
			// Return:
			breakTo "earlyreturn";
		};
	};

	// (SETP 2/8) SELECTING MAG LIBRARY
	// Based on the request, selecting only the specific ammo type section from the Magazines library:
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
			systemChat format ["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > At least one %2 fire-mission is using an invalid AMMUNITION. Check the 'fn_DAP_management.sqf' file. This fire-mission was aborted.", 
			DAP_txtWarnHeader, _tag, _fmCode]; sleep 5;
			// Return:
			breakTo "earlyreturn";
		};
	};

	// (STEP 3/8) REMOVING PIECES LOSSES
	// Overriding the side pieces list for only those still in-game:
	switch _tag do {
		case "BLU": {
			// Basic valuation and update of side pieces available (only irreversible details):
			DAP_piecesBLU = DAP_piecesBLU select { alive _x && alive (gunner _x) };  // DONT!!!! Dont include ammunition checks here coz you are excluding the possibility to rearm later!
			// Broadcasting the public update:
			publicVariable "DAP_piecesBLU";
			// Preparing to the next step:
			_freePieces = DAP_piecesBLU;
			// Debug > Assembly starts (keeps it only for DAP_debug_isOn)
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > %4 artillery-piece(s) to valuation...",
				DAP_txtDebugHeader, _tag, _fmCode, count DAP_piecesBLU] call BIS_fnc_error; sleep 3;
			};
		};
		case "OPF": {
			DAP_piecesOPF = DAP_piecesOPF select { alive _x && alive (gunner _x) };
			publicVariable "DAP_piecesOPF";
			_freePieces = DAP_piecesOPF;
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > %4 artillery-piece(s) to valuation...",
				DAP_txtDebugHeader, _tag, _fmCode, count DAP_piecesOPF] call BIS_fnc_error; sleep 3;
			};
		};
		case "IND": {
			DAP_piecesIND = DAP_piecesIND select { alive _x && alive (gunner _x) };
			publicVariable "DAP_piecesIND";
			_freePieces = DAP_piecesIND;
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > %4 artillery-piece(s) to valuation...",
				DAP_txtDebugHeader, _tag, _fmCode, count DAP_piecesIND] call BIS_fnc_error; sleep 3;
			};
		};
	};
	// Escape:
	if ( count _freePieces isEqualTo 0 ) exitWith {
		// If has alive piece but they are busy with fire-mission:
		if _isReporting then {
			if ( !(["HAS_NO_FM_ONGOING", _side] call THY_fnc_DAP_firemission_schedule) ) then {
				[_side, "BASE"] commandChat format [
					"Our artillery is busy with another fire-mission ongoing! %1 is being cancelled. Sorry for that. Over.",
					_fmCode];  // WIP: could be amazing with include it in a wait queue!
			// All artillery-pieces were neutralized:
			} else {
				[_side, "BASE"] commandChat format [
					"We lost all our artillery on the field. You're by your own. %1 is being cancelled. Over.",
					_fmCode];
			};
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > No artillery available (maybe they're busy or were neutralized).",
			DAP_txtDebugHeader, _tag, _fmCode] call BIS_fnc_error; sleep 5;
		};
	};

	// (STEP 4/8) FILTERING BY NOT-REARM-NEEDED
	// Important: (WIP) I'm working on a simple re-supply system for artillery, regardless magic of ammunition shows up into the each artillery-piece! More details in future...
	// It's possible a piece is completely or almost out of ammo:
	if !DAP_artill_forcedRearm then {
		{ 
			// Rearm is needed:
			if ( [_x] call THY_fnc_VO_is_rearm_needed ) then {
				// Saving current pieces that need to rearm:
				["ADD", _side, _x] call THY_fnc_DAP_out_of_ammo_list;
			// Rearm is NOT needed:
			} else { _preCandidates pushBack _x };
		} forEach _freePieces;
	// Everyone are full:
	} else {
		// WIP: DAP_artill_preventStartNoMags "FALSE" need to be considered after be completelly functional!
		// WIP: DAP_artill_isInfiniteAmmo too!!!
		_preCandidates = _freePieces;
	};
	// Escape > If no side pieces available:
	if ( count _preCandidates isEqualTo 0 ) exitWith {
		// Side command message:
		if _isReporting then {
			if ( !(["HAS_NO_FM_ONGOING", _side] call THY_fnc_DAP_firemission_schedule) ) then {
				[_side, "BASE"] commandChat format ["Actually our artillery is focused on other fire-missions now... You're on your own! %1 is cancelled! Over.", _fmCode];  // WIP: make a new check when pieces are free again!
			} else {
				[_side, "BASE"] commandChat format ["We have NO EVEN ONE artillery-piece with ammo available for now! Logistic is needed! %1 is cancelled! Over.", _fmCode];
			};
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnAmmo ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > No piece with ammo available!",
			DAP_txtDebugHeader, _tag, _fmCode] call BIS_fnc_error; sleep 5;
		};
		// Return:
		_return;
	};

	// (STEP 5/8) FILTERING BY CALIBER
	// Filtering the current side-pieces by those that are the requested caliber and have some ammunition:
	// Checking the caliber:
	{ if ( typeOf _x in _libraryCaliber ) then { _candidates pushBack _x } } forEach _preCandidates;
	// Debug message:
	if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {[
		"%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > From %4 on the field, %5 have the requested caliber (%6).",
		DAP_txtDebugHeader,
		_tag,
		_fmCode, 
		count _preCandidates,
		count _candidates,
		_caliber
		] call BIS_fnc_error; sleep 5;
	};
	// Escape > If no side candidate-pieces available:
	if ( count _candidates isEqualTo 0 ) exitWith {
		// Side command message:
		if _isReporting then { 
			[_side, "BASE"] commandChat format [
				"Unfortunately our artillery DON'T fit the BASIC requirements for the %1-fire-mission that was supposed to take place now. It's cancelled! Over.",
				_fmCode
			];
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > No artillery fits the fire-mission BASIC requirements: %4 requested piece(s) | Caliber = %5 | Ammo-type = %6.",
			DAP_txtDebugHeader, _tag, _fmCode, _numRequested, _caliber, _magType] call BIS_fnc_error; sleep 5;
		};
		// Return:
		_return;
	};

	// (STEP 6/8) FILTERING BY AMMO-TYPE
	// Filtering those right-caliber-pieces by those that also have the requested ammo-type:
	{  // forEach _candidates:
		// Compars and stores only approved mags (if the _candidates got):
		_candApprovedMags = _libraryMags arrayIntersect (getArtilleryAmmo [_x]);
		// One or more ammo options:
		if ( count _candApprovedMags > 0 ) then {
			// Debug message:
			if ( DAP_debug_isOn && ( DAP_debug_isOnTeamCheck || DAP_debug_isOnAmmo ) ) then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > '%4' approved mag types: %5 = %6.",
				DAP_txtDebugHeader, _tag, _fmCode, _x, count _candApprovedMags, _candApprovedMags] call BIS_fnc_error; sleep 5;
			};
			// Once the candidate has at least one option of the requested ammo-type, it's a finalist:
			// Important: organizing the structure for the next step as well!
			_finalists append [[nil, _x, (_candApprovedMags # 0)]];  // [ [distant to the target (later), object, first approved magazine option] ]
		};
	} forEach _candidates;
	// Escape > If no side finalist-pieces available:
	if ( count _finalists isEqualTo 0 ) exitWith {
		// Side command message:
		if _isReporting then { 
			[_side, "BASE"] commandChat format [
				"Although our artillery has %1 the AMMO-TYPE requested (%2) that the fire-mission demands. %3 is being cancelled, over.",
				if ( count _candidates > 7 ) then {"MANY pieces with the right caliber, they DON'T HAVE"} else {
					if ( count _candidates > 1 ) then {"a FEW pieces with the right caliber, they DON'T HAVE"} else {"ONLY ONE piece with the right caliber, it DOESN'T HAVE"};
				},
				_magType,
				_fmCode
			];
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Requirements: %4 requested piece(s) | Caliber = %5 | Ammo-type = %6.",
			DAP_txtDebugHeader, _tag, _fmCode, _numRequested, _caliber, _magType] call BIS_fnc_error; sleep 5;
		};
		// Return:
		_return;
	};
	
	// (STEP 7/8) FILTERING BY RANGE
	// Filtering those right-caliber-and-ammo-type-pieces by those that also have range to the target:
	_bestOverall = _finalists select { _fmMkrPos inRangeOfArtillery [[_x # 1], (_x # 2)] };  // [ [obj], magazine ]
	// Escape > no _finalists, abort:
	if ( count _bestOverall isEqualto 0 ) exitWith {
		// Side command message:
		if _isReporting then {
			[_side, "BASE"] commandChat format [
				"Even with %1 RANGE for the %2-fire-mission that was supposed to take place now, over.",
				if ( count _finalists > 1 ) then {"SOME PIECES of the requested caliber and ammo-type, they DON'T HAVE"} else {"A PIECE of the requested caliber and ammo-type, it HAS NO"},
				_fmCode
			];
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Requirements: %4 requested piece(s) | Caliber = %5 | Ammo-type = %6.",
			DAP_txtDebugHeader, _tag, _fmCode, _numRequested, _caliber, _magType] call BIS_fnc_error; sleep 5;
		};
		// Return:
		_return;
	};
	// The piece search found the requested amount or more:
	// Important: let's figure out which piece is the closest to the target and difine it (index 0) as fire-mission-team-leader. Also, if more than requested number, let's dispose of the excess pieces.
	if ( count _bestOverall >= _numRequested ) then {
		// Update _chosenOnes structure:
			// 1st element: distance between piece and target (float number),
			// 2nd element: piece (object),
			// REMOVED v1.5! -- 3rd element: ammo (string) -- REMOVED v1.5!
			// E.g. [23423e.05+3, dap_1]
		_chosenOnes = _bestOverall apply {
			[
				// Distance:
				// Important, if specific caliber, always it considers the real distance, otherwise it creates a fake dist (0-500) to randomize piece choices during "sort" and avoid sort select only those side-by-side.
				if ( _caliber isNotEqualTo "COMBINED") then { _fmMkrPos distanceSqr (_x # 1) } else { round (random 501) },
				// Piece:
				_x # 1
			];
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Before reordering (sort): %4",
			DAP_txtDebugHeader, _tag, _fmCode, _chosenOnes] call BIS_fnc_error; sleep 3;
		};
		// Sort the _chosenOnes where the first element is the closest one from the target (and DAP will deal with it as the fire-mission leader later):
		_chosenOnes sort true;
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > After reordering (sort): %4",
			DAP_txtDebugHeader, _tag, _fmCode, _chosenOnes] call BIS_fnc_error; sleep 3;
		};
		// Resize the _chosenOnes only for what was requested, if appliable:
		if ( count _chosenOnes > _numRequested ) then { 
			_chosenOnes resize _numRequested;
			// Debug:
			if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Resized: %4 = %5",
				DAP_txtDebugHeader, _tag, _fmCode, count _chosenOnes, _chosenOnes] call BIS_fnc_error; sleep 5;
			};
		};
	// _chosenOnes has not enough number of pieces requested, take all we got:
	} else {
		// Prepare to return:
		_chosenOnes = _bestOverall;
		// Side command message:
		if _isReporting then {
			[_side, "BASE"] commandChat format [
				"We'll %1, but the %2-fire-mission will take place now!",
				if (!(_magType in ["FLARE","SMOKE"])) then {"hammer the position with LESS power as planned"} else {if (_magType isEqualTo "SMOKE") then {"NOT blind the position as planned"} else {"NOT paint the sky as planned"}},
				_fmCode
			];
			sleep 3;
		};
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Requirements: %4 requested piece(s) | Gonna use %5 with: Caliber = %6 | Ammo-type = %7",
			DAP_txtDebugHeader, _tag, _fmCode, _numRequested, count _chosenOnes, _caliber, _magType] call BIS_fnc_error; sleep 5;
		};
	};
	// Clean after all:
	_chosenOnes = _chosenOnes apply { _x # 1 };  // from [[Any, dap_1, "99rnd_HE"], ...] to [dap_1, ...]

	// (STEP 8/8) FORMALIZING THE TEMPORARY GROUP
	// Important: the piece-leader will be the _chosenOnes index '0'. It because, in a regular condition, the leader is the closest piece from the target ("better visual, intel", simulating).
	// Known group id's ready to be stored:
	switch _side do {
		case BLUFOR:      { _groupKnownIds = (DAP_groupIdsForDisbanded # 0) };
		case OPFOR:       { _groupKnownIds = (DAP_groupIdsForDisbanded # 1) };
		case INDEPENDENT: { _groupKnownIds = (DAP_groupIdsForDisbanded # 2) };
	};
	{  // Take all pieces and their crew and put in the group at index 0:
		// Save the original group name to restore later after the fire-mission:
		_groupKnownIds pushBack groupId (group (leader _x));
		// If the main group into the team:
		if ( _forEachIndex isEqualTo 0 ) then {
			_groupLeader = group (leader _x);
			_groupLeader setGroupIdGlobal [_fmCode + "-TEAM"];
		// If other groups of this team:
		} else {
			// Add the those crew in leader's group:
			crew _x joinSilent _groupLeader;
		};
	} forEach _chosenOnes;
	switch _side do {
		case BLUFOR: {
			// Removing group pieces temporarily from side pieces list:
			DAP_piecesBLU = DAP_piecesBLU - ([_groupLeader] call THY_fnc_DAP_all_group_vehicles);
			// Broadcasting the public update:
			publicVariable "DAP_piecesBLU";
			// Preparing public updates:
			DAP_groupIdsForDisbanded = [_groupKnownIds, DAP_groupIdsForDisbanded # 1, DAP_groupIdsForDisbanded # 2];
		};
		case OPFOR: {
			DAP_piecesOPF = DAP_piecesOPF - ([_groupLeader] call THY_fnc_DAP_all_group_vehicles);
			publicVariable "DAP_piecesOPF";
			DAP_groupIdsForDisbanded = [DAP_groupIdsForDisbanded # 0, _groupKnownIds, DAP_groupIdsForDisbanded # 2];
		};
		case INDEPENDENT: {
			DAP_piecesIND = DAP_piecesIND - ([_groupLeader] call THY_fnc_DAP_all_group_vehicles);
			publicVariable "DAP_piecesIND";
			DAP_groupIdsForDisbanded = [DAP_groupIdsForDisbanded # 0, DAP_groupIdsForDisbanded # 1, _groupKnownIds];
		};
	};
	// Broadcasting the public update:
	publicVariable "DAP_groupIdsForDisbanded";
	// Preparing to return:
	_return = [_libraryMags, _chosenOnes];
	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
		["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > _groupKnownIds saved to re-use later (%4): %5",
		DAP_txtDebugHeader, _tag, _fmCode, count _groupKnownIds, _groupKnownIds] call BIS_fnc_error; sleep 5;
	};
	// Debug > Assembly complete (keeps it only for DAP_debug_isOn)
	if DAP_debug_isOn then {
		["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 > Successfully done! | From %4 okay, gonna use the requested: %5 | Temporary group: %6 (%7 members in %5 pieces).",
			DAP_txtDebugHeader,
			_tag,
			_fmCode,
			count _bestOverall,
			count _chosenOnes,
			groupId _groupLeader,
			count (units _groupLeader)
		] call BIS_fnc_error;
		sleep 5;
	};
	// Return:
	scopeName "earlyreturn";
	// RELEASE OTHER SIDE ASSEMBLIES:
	["ASSEMBLY_FREE", _side] call THY_fnc_DAP_firemission_schedule;
	_return;
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
	if ( isNil { typeName _chosen isEqualTo "ARRAY" } ) then { _chosen = "CITY" + str (round (random 501)) };
	// Error handling > If editor customized the codes:
	_chosen = toUpper _chosen;
	// Return:
	_chosen;
};


THY_fnc_DAP_firemission_schedule = {
	// This function take a note of all fire-missions ongoing from a side.
	// Returns _isTrue (bool) that can be use for different _action options.

	params ["_action", "_side", ["_fmCode", ""], ["_fmTeam", grpNull]];
	private ["_isTrue"];
	/*
		SCHEDULING STRUCTURE:
		DAP_fmScheduled = [
			[0 = blu:
				[0 = fm n1:
					_fmCode,
					_fmTeam (added right after team creation)
				],
				[1 = fm n2:
					_fmCode,
					_fmTeam (added right after team creation)
				],
				[2 = fm n3:
					_fmCode,
					_fmTeam (added right after team creation)
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
	_isTrue = true;
	// Actions:
	switch _action do {
		// It notes each fire-mission called through fn_DAP_fireMissions.sqf file:
		case "CREATE": {
			switch _side do {
				case BLUFOR:      { (DAP_fmScheduled # 0) pushBack [_fmCode, _fmTeam]; publicVariable "DAP_fmScheduled" };  // [_fmCode, _fmTeam (comes later)].
				case OPFOR:       { (DAP_fmScheduled # 1) pushBack [_fmCode, _fmTeam]; publicVariable "DAP_fmScheduled" };
				case INDEPENDENT: { (DAP_fmScheduled # 2) pushBack [_fmCode, _fmTeam]; publicVariable "DAP_fmScheduled" };
			};
		};
		// It deletes a specific fire-mission note:
		case "DELETE": {
			switch _side do {
				case BLUFOR:      { (DAP_fmScheduled # 0) deleteAt ( (DAP_fmScheduled # 0) find [_fmCode, _fmTeam] ); publicVariable "DAP_fmScheduled" };
				case OPFOR:       { (DAP_fmScheduled # 1) deleteAt ( (DAP_fmScheduled # 1) find [_fmCode, _fmTeam] ); publicVariable "DAP_fmScheduled" };
				case INDEPENDENT: { (DAP_fmScheduled # 2) deleteAt ( (DAP_fmScheduled # 2) find [_fmCode, _fmTeam] ); publicVariable "DAP_fmScheduled" };
			};
		};
		// Checks if there's at least one side fire-mission ongoing:
		case "HAS_NO_FM_ONGOING": {
			// if just one fire-mission has the group element different than grpNull, it means there's at least one fire-mission ongoing:
			switch _side do {
				case BLUFOR:      { { if ( (_x # 1) isNotEqualTo grpNull ) exitWith { _isTrue = false } } forEach (DAP_fmScheduled # 0) };
				case OPFOR:       { { if ( (_x # 1) isNotEqualTo grpNull ) exitWith { _isTrue = false } } forEach (DAP_fmScheduled # 1) };
				case INDEPENDENT: { { if ( (_x # 1) isNotEqualTo grpNull ) exitWith { _isTrue = false } } forEach (DAP_fmScheduled # 2) };
			};
		};
		// Responsable to block more than one assembly request at the same time by side:
		case "ASSEMBLY_BUSY": {
			switch _side do {
				case BLUFOR:      { DAP_assemblyFree = [false, DAP_assemblyFree # 1, DAP_assemblyFree # 2]; publicVariable "DAP_assemblyFree" };
				case OPFOR:       { DAP_assemblyFree = [DAP_assemblyFree # 0, false, DAP_assemblyFree # 2]; publicVariable "DAP_assemblyFree" };
				case INDEPENDENT: { DAP_assemblyFree = [DAP_assemblyFree # 0, DAP_assemblyFree # 1, false]; publicVariable "DAP_assemblyFree" };
			};
		};
		// Responsable to release another assembly request from the side queue:
		case "ASSEMBLY_FREE": {
			switch _side do {
				case BLUFOR:      { DAP_assemblyFree = [true, DAP_assemblyFree # 1, DAP_assemblyFree # 2]; publicVariable "DAP_assemblyFree" };
				case OPFOR:       { DAP_assemblyFree = [DAP_assemblyFree # 0, true, DAP_assemblyFree # 2]; publicVariable "DAP_assemblyFree" };
				case INDEPENDENT: { DAP_assemblyFree = [DAP_assemblyFree # 0, DAP_assemblyFree # 1, true]; publicVariable "DAP_assemblyFree" };
			};
		};
		// Checks if a new assembly request can get started:
		case "IS_STATUS_FREE": {
			switch _side do {
				case BLUFOR:      { _isTrue = (DAP_assemblyFree # 0) };
				case OPFOR:       { _isTrue = (DAP_assemblyFree # 1) };
				case INDEPENDENT: { _isTrue = (DAP_assemblyFree # 2) };
			};
		};
	};
	// Return:
	_isTrue;
};


THY_fnc_DAP_firing = {
	// This function makes the specific fire-mission-team shelling down a specific target position once before return to THY_fnc_DAP_fire_management.
	// Returns true after all alive team member shoot: bool.

	params ["_tag", "_fmTeam", "_fmCode", "_fmUnitLeader", "_fmPieceLeader", "_fmMkrPos", "_rounds", "_magType", "_libraryMags", "_isReporting"];
	private ["_isNotShooting", "_piece", "_mag", "_piecesShootBefore", "_wasReported", "_countTeamSize" /*, "_wp" */];

	// Initial values:
	_isNotShooting     = nil;
	_piece             = objNull;
	_mag               = "";
	_piecesShootBefore = [];
	_wasReported       = false;
	// Declarations:
	_countTeamSize = count ([_fmTeam] call THY_fnc_DAP_all_group_vehicles);
	//_wp = [_fmTeam, currentWaypoint _fmTeam];
	//_wp setWaypointDescription localize "STR_A3_CfgWaypoints_Artillery";

	// Wait until no more artillery-pieces are shooting:
	waituntil {
		// Each new loop, assuming no one is shooting:
		_isNotShooting = true;
		// Check each unit in charge of artillery:
		{  // forEach _fmTeam member:
			_piece = vehicle _x;
			// Escape > Skip those units that is not in charge in their pieces or they're neutralized:
			if (_x isNotEqualTo (effectiveCommander _piece) || !alive _x || !alive _piece ) then { continue };
			// If piece doesn't fire yet:
			if !(_piece in _piecesShootBefore) then {
				// Selecting the first approved option available in piece arsenal:
				_mag = (_libraryMags arrayIntersect (getArtilleryAmmo [_piece])) # 0;
				// If leader:
				if ( _x isEqualTo _fmUnitLeader ) then {
					// Side command message:
					if _isReporting then {
						// Team-leader says once per cycle:
						_fmUnitLeader commandChat format [
							"%1-fire-mission ON THE WAY! Prepare %2 in %3 secs.",
							_fmCode,
							if ( _magType isNotEqualTo "FLARE" ) then {"to impact"} else {"to light up"},
							round (_fmPieceLeader getArtilleryETA [_fmMkrPos, _mag])  // ETA (Estimated Time of Arrival)
						];
					// Debug:
					} else {
						if DAP_debug_isOn then {
							["%1 %2 %3-fire-mission on the way! Impact in %4 secs.",
							DAP_txtDebugHeader, _tag, _fmCode, round (_fmPieceLeader getArtilleryETA [_fmMkrPos, _mag])
							] call BIS_fnc_error; sleep 1;
						};
					};
				// If not-leader member:
				} else {
					// Humanizing/desynchronizing the firing from multiple pieces:
					sleep selectRandom [0.1, 0.26, 0.41, 0.63, 0.83];
				};
				// Fire:
				_piece doArtilleryFire [_fmMkrPos, _mag, _rounds];
				// Flag it already shoot:
				_piecesShootBefore pushBack _piece;
			// if already shoot:
			} else {
				// Team-Leader:
				if ( _x isEqualTo _fmUnitLeader ) then {
					// If getting losses:
					if ( (_countTeamSize > count ([_fmTeam] call THY_fnc_DAP_all_group_vehicles)) && !_wasReported ) then {
						// Flag to report just once per cycle:
						_wasReported = true;
						// Side command chat:
						if _isReporting then {
							_fmUnitLeader commandChat "Our team's taking heavy casualties at our own position!!!";
						} else {
							// Debug:
							if DAP_debug_isOn then { systemChat format [
								"%1 %2 %3 taking heavy casualties in their position.", 
								DAP_txtDebugHeader, _tag, _fmCode];
							};
						};
					};
				// Not leader:
				} else {
					// Prevent other commanders keep shooting at target if fire-mission is aborted:
					// Important: they keeps engaging with coax (if available) local threats (perfect)!
					if ( !alive _fmUnitLeader || !alive _fmPieceLeader ) then { doStop _x };
				};
			};
			// If no more _fmTeam members are shooting, flag it:
			if ( currentCommand _piece isEqualTo "FIRE AT POSITION" ) then { _isNotShooting = false };
		} foreach units _fmTeam;
		// Debug:
		if DAP_debug_isOn then {
			["%1 %2 FIRE-MISSION SHOOTING PHASE > %3 > %4 > _isNotShooting = %5 | From %6 pieces, %7 already shoot: %8",
			DAP_txtDebugHeader, _tag, _fmCode, _fmTeam, _isNotShooting, _countTeamSize, count _piecesShootBefore, _piecesShootBefore] call BIS_fnc_error;
		};
		// Next check:
		sleep 10;
		// Stop waiting if: cycle completed or the leadership is neutralized.
		!alive _fmUnitLeader || !alive _fmPieceLeader || _isNotShooting;
	};  // waitUntil ends.

	// Return:
	true;
};


THY_fnc_DAP_virtual_firing = {
	// This function makes a virtual fire-mission shelling down a specific target position once before return to THY_fnc_DAP_virtual_fire_management.
	// Returns true after all virtual artillery-pieces shoot: bool.

	params ["_side", "_tag", "_numRequested", "_fmCode", "_fmMkrPos", "_rounds", "_magType", "_virtualMag", "_isReporting"];
	private ["_delayMax"];

	// Initial values:
		// reserved space.
	// Declarations:
	_delayMax = 5;
	// Side command message:
	if _isReporting then {
		// Once per cycle:
		[_side, "BASE"] commandChat format [
			"%1-fire-mission ON THE WAY! Prepare %2 in %3 secs.",
			_fmCode,
			if ( _magType isNotEqualTo "FLARE" ) then {"to impact"} else {"to light up"},
			DAP_fmVirtualETA  // Fake ETA (Estimated Time of Arrival)
		];
	// Debug:
	} else {
		if DAP_debug_isOn then {
			["%1 %2 %3-fire-mission on the way! Impact in %4 secs.",
			DAP_txtDebugHeader, _tag, _fmCode, DAP_fmVirtualETA
			] call BIS_fnc_error; sleep 1;
		};
	};

	// Simulating the shells travilling 'til the target:
	sleep DAP_fmVirtualETA;

	// HIGH EXPLOSIVE AMMO-TYPE:
	if ( _magType isEqualTo "HE" ) then {
		// Simulating multiple artillery-pieces (if appliable):
		for "_i" from 1 to _numRequested do {
			// Humanizing/desynchronizing the firing from multiple pieces:
			sleep selectRandom [0.1, 0.26, 0.41, 0.63, 0.83];
			// [fire-mission-pos, ammo, radius, rounds, delay [min,max], conditionEnd, safezone, initial alt of projectil, fall speed, sounds]
			// https://community.bistudio.com/wiki/BIS_fnc_fireSupportVirtual
			[_fmMkrPos, _virtualMag, 100, _rounds, [3, _delayMax], { false }, 0, 400, 250, ["shell1", "shell2"]] spawn BIS_fnc_fireSupportVirtual;
		};
	// CLUSTER AMMO-TYPE:
	} else {
		for "_i" from 1 to _numRequested do {
			sleep selectRandom [0.1, 0.26, 0.41, 0.63, 0.83];
			// [fire-mission-pos, ammo, radius, rounds, delay [min,max], conditionEnd, safezone, initial alt of projectil, fall speed, sounds]
			// https://community.bistudio.com/wiki/BIS_fnc_fireSupportCluster
			[_fmMkrPos, _virtualMag, 100, [_rounds, 20], [3, _delayMax], {/* nothing here */}, 0, 100, 100, ["shell1", "shell2"]] spawn BIS_fnc_fireSupportCluster;
		};
	};
	// Breath before to return:
	// Calc: time of each round firing + number of pieces * the average that small sleep for each one!
	sleep ((_delayMax * _rounds) + (_numRequested * 0.41));
	// Return:
	true;
};


THY_fnc_DAP_fire_management = {
	// This function controls the fire-mission firing (THY_fnc_DAP_firing), rearming and its possible repetition cycles.
	// Returns nothing.

	params ["_side", "_tag", "_fmTeam", "_fmCode", "_cycles", "_fmMkrPos", "_rounds", "_magType", "_libraryMags", "_teamCooldown", "_isReporting"];
	private ["_fmUnitLeader", "_fmPieceLeader"];

	// Initial values:
		// reserved space.
	// Declarations:
	_fmUnitLeader  = leader _fmTeam;        // Important: it shouldn't be updated to keep the DAP logic!
	_fmPieceLeader = vehicle _fmUnitLeader;  // Important: it shouldn't be updated to keep the DAP logic!

	// Fire if any cycles are left and team-leader is enough ok:
	while { _cycles > 0 && alive _fmUnitLeader && alive _fmPieceLeader } do {
		// Fire:
		waitUntil { 
			// Next check:
			sleep 10;
			// Stop the waiting if: firing returns true or the leadership is neutralized.
			!alive _fmUnitLeader || !alive _fmPieceLeader || [_tag, _fmTeam, _fmCode, _fmUnitLeader, _fmPieceLeader, _fmMkrPos, _rounds, _magType, _libraryMags, _isReporting] call THY_fnc_DAP_firing;
		};
		// Leadership still operational:
		if ( alive _fmUnitLeader && alive _fmPieceLeader ) then {
			// Control:
			_cycles = _cycles - 1;
			// Side command message > if there's at least one more repetition cycle:
			if ( _isReporting && _cycles > 0) then { _fmUnitLeader commandChat format ["Standby for the next rounds cycle in %1 seconds, sir.", _teamCooldown] };
		// Lost the leadership:
		} else {
			// Side command message:
			if _isReporting then {
				[_side, "BASE"] commandChat format ["Leaders, we LOST SIGNAL with %1. The %2-fire-mission is being ABORTED, over.", _fmTeam, _fmCode];
			};
		};
		// No cycle is leaft:
		if ( _cycles isEqualTo 0 ) then { 
			// Side command message:
			if _isReporting then {
				_fmUnitLeader commandChat format ["Sir, %1-fire-mission is successfully COMPLETE! Standby and over.", _fmCode];
			} else {
				// Debug:
				if DAP_debug_isOn then { systemChat format ["%1 %2 > %3-fire-mission successfully completed!", DAP_txtDebugHeader, _tag, _fmCode]; sleep 2 };
			};
		};
		// Rearm and cooldown:
		// Important: if fire-mission lose its leadership and has team members yet, those pieces will face the rearm normally to be ready to the next team-assembly if needed!
		[_side, _fmTeam, _fmCode, _teamCooldown] call THY_fnc_DAP_rearming_pieces;
		// Side command message if next cycle:
		if ( (_cycles > 0) && _isReporting && alive _fmUnitLeader && alive _fmPieceLeader ) then {
			_fmUnitLeader commandChat format ["%1-fire-mission-team locked and loaded. Firing again!", _fmCode];
		};
	};  // While loop ends.

	// Deleting the fire-mission:
	["DELETE", _side, _fmCode, _fmTeam] call THY_fnc_DAP_firemission_schedule;
	// Return:
	true;
};


THY_fnc_DAP_virtual_fire_management = {
	// This function controls the virtual fire-mission firing (THY_fnc_DAP_virtual_firing) and its possible repetition cycles.
	// Returns nothing.

	params ["_side", "_tag", "_numRequested", "_fmCode", "_cycles", "_fmMkrPos", "_rounds", "_magType", "_isReporting"];
	private ["_virtualMag"];

	// Initial values:
	_virtualMag = "";
	// Declarations:
		// reserved space.

	// HIGH EXPLOSIVE AMMO:
	if ( _magType isEqualTo "HE" ) then {
		switch _caliber do {
			// https://community.bistudio.com/wiki/Arma_3:_CfgMagazines
			case "LIGHT":      { _virtualMag = "Sh_82mm_AMOS" };
			case "MEDIUM":     { _virtualMag = "Sh_155mm_AMOS" };
			case "HEAVY":      { _virtualMag = "Sh_155mm_AMOS" };  // WIP no heavy ammo found yet :(
			case "SUPERHEAVY": { _virtualMag = "Sh_155mm_AMOS" };  // WIP The "R_230mm_HE" doesn't work well. Is "planing" and not "falling". 
			case "COMBINED":   { _virtualMag = "Sh_155mm_AMOS" };  // WIP
		};
	// CLUSTER AMMO:
	} else {
		switch _caliber do {
			case "LIGHT":      { _virtualMag = "G_40mm_HEDP" };
			case "MEDIUM":     { _virtualMag = "G_40mm_HEDP" };  // WIP: ammo_ShipCannon_120mm_HE_cluster my gosh, ammo is "planing" and super cost to CPU;
			case "HEAVY":      { _virtualMag = "G_40mm_HEDP" };  // WIP: Cluster_155mm_AMOS same problem.... ammo is "planing" and super cost to CPU;
			case "SUPERHEAVY": { _virtualMag = "G_40mm_HEDP" };  // WIP: R_230mm_Cluster same problem.... ammo is "planing" and super cost to CPU; 
			case "COMBINED":   { _virtualMag = "G_40mm_HEDP" };  // WIP
		};
	};
	
	// Fire if any cycles are left:
	while { _cycles > 0 } do {
		// Fire:
		waitUntil { 
			// Next check:
			sleep 10;
			// Stop the waiting if: firing returns true.
			[_side, _tag, _numRequested, _fmCode, _fmMkrPos, _rounds, _magType, _virtualMag, _isReporting] call THY_fnc_DAP_virtual_firing;
		};
		// Control:
		_cycles = _cycles - 1;
		// If more cycles to execute:
		if ( _cycles > 0 ) then {
			// Side command message:
			if _isReporting then {
				[_side, "BASE"] commandChat format [
					"%1-TEAM standby for the next rounds cycle in %2 seconds.",
					_fmCode, DAP_fmVirtualETA]; sleep 2;
			// Debug:
			} else {
				if DAP_debug_isOn then {
					["%1 %2 > %3-fire-mission standby for the new cycle in %4 seconds.",
					DAP_txtDebugHeader, _tag, _fmCode, DAP_fmVirtualETA] call BIS_fnc_error; sleep 2;
				};
			};
			// Simulation of rearming and cooldown of artillery-pieces involved:
			sleep DAP_fmVirtualETA;
			// Side command message:
			if _isReporting then {
				[_side, "BASE"] commandChat format [
					"%1-fire-mission-team locked and loaded. Firing again!",
					_fmCode];
			// Debug:
			} else {
				if DAP_debug_isOn then {
					["%1 %2 > %3-fire-mission new cycle starts: firing again!",
					DAP_txtDebugHeader, _tag, _fmCode, DAP_fmVirtualETA] call BIS_fnc_error;
				};
			};
		// No cycle is left:
		} else {
			// Side command message:
			if _isReporting then {
				[_side, "BASE"] commandChat format [
					"%1-fire-mission is successfully COMPLETE! Standby and over.",
					_fmCode]; sleep 2;
			// Debug:
			} else {
				if DAP_debug_isOn then {
					["%1 %2 > %3-fire-mission successfully completed!",
					DAP_txtDebugHeader, _tag, _fmCode] call BIS_fnc_error; sleep 2;
				};
			};
		};
	};  // While loop ends.

	// Deleting the fire-mission:
	["DELETE", _side, _fmCode, grpNull] call THY_fnc_DAP_firemission_schedule;
	// Return:
	true;
};


THY_fnc_DAP_firemission = {
	// This function (new thread) is the entire life-cicle of each not-triggered fire-mission. It waits to be triggered and then creates a temporary fire-mission-team using only the resources available at that moment, executing the firing, its cycles and rearm the pieces if available for, then, disband the fire-mission-team and compliting this function, closing the thread.
	// Returns nothing.

	params ["_side", "_tag", "_fmCode", "_fmTargetMkrs", "_fireSetup", "_fireTriggers"];
	private ["_isReleased", "_timeLoop", "_time", "_wait", "_ctr", "_isReporting", "_teamCooldown", "_assemblyInfo", "_libraryMags", "_chosenOnes", "_fmTeam", "_fmTeamDebug", "_fmGroupPieces", "_groupKnownIds", "_groupDisbanded", "_isReal", "_numRequested", "_caliber", "_magType", "_rounds", "_cycles", "_txt1", "_fmMkrPos"];

	// Escape:
		// reserved space.
	// Initial values:
	_isReleased     = False;
	_timeLoop       = 0;
	_time           = time;
	_wait           = 10;  // CAUTION: this number is used to calcs the TIMER too.
	_ctr            = _time;
	_isReporting    = false;
	_teamCooldown   = 0;
	_assemblyInfo   = [];
	_libraryMags    = [];
	_chosenOnes     = [];
	_fmTeam         = grpNull;
	_fmTeamDebug    = "";  // Debug purposes only.	
	_fmGroupPieces  = [];
	_groupKnownIds  = [];
	_groupDisbanded = grpNull;
	// Declarations:
	_isReal       = _fireSetup # 0;
	_numRequested = _fireSetup # 1;
	_caliber      = _fireSetup # 2;
	_magType      = _fireSetup # 3;
	_rounds       = _fireSetup # 4;
	_cycles       = _fireSetup # 5;

	// Debug texts:
	_txt1 = format ["fire-mission '%1' was released", _fmCode];

	// FIRE-MISSION WAITING TO BE TRIGGERED
	// Fire-mission trigger conditions > Stay checking until the fire-mission is released:
	while { !_isReleased } do {
		_timeLoop = time;
		// Delay for each loop check:
		waitUntil { sleep _wait; time >= _timeLoop + _wait };
		{  // forEach _fireTriggers:

			// RELEASED BY TIMER:
			// If fire-mission is triggered by timer, check if it's a number:
			if ( typeName _x isEqualTo "SCALAR" ) then {
				// Counter increase:
				_ctr = _ctr + _wait;
				// Timer checker:
				if ( _ctr >= _time + ((abs _x) * 60) ) exitWith {
					// Function completed:
					_isReleased = true;
					// Debug message:
					if DAP_debug_isOn then {
						systemChat format ["%1 %2 %3 by TIMER (it was %4 minutes).", DAP_txtDebugHeader, _tag, _txt1, _x];
						// Reading breather:
						sleep 3;
					};
				};
			// otherwise:
			} else {

				// RELEASED BY TRIGGER:
				// If fire-mission is triggered by an Eden-trigger, check if it's a real trigger:
				if ( _x isKindOf "EmptyDetector" ) then { 
					// If it's activated:
					if ( triggerActivated _x ) exitWith { 
						// Function completed:
						_isReleased = true; 
						// Debug message:
						if DAP_debug_isOn then {
							systemChat format ["%1 %2 %3 by TRIGGER (%4).", DAP_txtDebugHeader, _tag, _txt1, _x];
							// Reading breather:
							sleep 3;
						};
					};
				// Otherwise:
				} else {

					// RELEASED BY TARGET KILL/DESTROYED:
					// If the fire-mission is triggered by target elimination:
					if ( !alive _x ) exitWith {
						// Function completed:
						_isReleased = true;
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
 
	// TARGET SELECTION:
	// Select a fire-mission marker and take its position:
	// CRUCIAL: it's important the target-marker-selection to be here after the trigger checking 'cause it gives to the editor the chances to delete the marker 
	// for any mission logic reason before the fire-mission be triggered.
	_fmMkrPos = markerPos (selectRandom _fmTargetMkrs);  // returns a AGL pos, so [x, y, 0], z is always 0

	// CALIBER SETUP:
	switch _caliber do {
		case "LIGHT":      { _isReporting = DAP_fmCaliber_shouldReportLight;    _teamCooldown = DAP_fmCaliber_timeRearmLight };
		case "MEDIUM":     { _isReporting = DAP_fmCaliber_shouldReportMedium;   _teamCooldown = DAP_fmCaliber_timeRearmMedium };
		case "HEAVY":      { _isReporting = DAP_fmCaliber_shouldReportHeavy;    _teamCooldown = DAP_fmCaliber_timeRearmHeavy };
		case "SUPERHEAVY": { _isReporting = DAP_fmCaliber_shouldReportSuperH;   _teamCooldown = DAP_fmCaliber_timeRearmSuperH };
		case "COMBINED":   { _isReporting = DAP_fmCaliber_shouldReportCombined; _teamCooldown = selectRandom [DAP_fmCaliber_timeRearmMedium, DAP_fmCaliber_timeRearmHeavy] };
	};
	// Side command message:
	if _isReporting then { [_side, "BASE"] commandChat format ["Leaders, %1-fire-mission is being evaluated... We confirm it soon...", _fmCode] };

	// FIRE-MISSION:
	// If the piece is real (so, it has asset in-game involved):
	if _isReal then {
		// Assembling the fire-mission team:
		_assemblyInfo = [_fmMkrPos, _side, _tag, _fmCode, _numRequested, _caliber, _magType, _isReporting] call THY_fnc_DAP_assembling_firemission_team;
		_libraryMags  = _assemblyInfo # 0;
		_chosenOnes   = _assemblyInfo # 1;
		// Escape > No team available:
		if ( count _chosenOnes isEqualTo 0 ) then { breakTo "earlyreturn" };
		// Declaring the team (Arma format = group):
		_fmTeam      = group (_chosenOnes # 0);  // Output e.g.: B BLU FIRE SUPPORT-2
		_fmTeamDebug = str _fmTeam; // Debug purposes.
		// Including the fire-mission-team (only objects/pieces) into the specific fire-mission-data in DAP_fmScheduled control:
		switch _tag do {
			case "BLU": { (DAP_fmScheduled # 0) set [ (DAP_fmScheduled # 0) find [_fmCode, grpNull], [_fmCode, _fmTeam] ] };  //  set [idx, data]
			case "OPF": { (DAP_fmScheduled # 1) set [ (DAP_fmScheduled # 1) find [_fmCode, grpNull], [_fmCode, _fmTeam] ] };
			case "IND": { (DAP_fmScheduled # 2) set [ (DAP_fmScheduled # 2) find [_fmCode, grpNull], [_fmCode, _fmTeam] ] };
		};

		// FIRE-MISSION ONGOING:
		[_side, _tag, _fmTeam, _fmCode, _cycles, _fmMkrPos, _rounds, _magType, _libraryMags, _teamCooldown, _isReporting] call THY_fnc_DAP_fire_management;

		// DISBANDMENT OF THE TEMPORARY GROUP:
		_fmGroupPieces = [_fmTeam] call THY_fnc_DAP_all_group_vehicles;
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 DISBANDING %2 ARTILLERY TEAM > %4-fire-mission-team '%3' disbanding...",
			DAP_txtDebugHeader, _tag, _fmTeam, _fmCode] call BIS_fnc_error; sleep 3;
		};
		// Known group id's ready to be restored:
		switch _side do {
			case BLUFOR:{ 
				// Adding back group pieces temporarily removed from side pieces list:
				DAP_piecesBLU = DAP_piecesBLU + _fmGroupPieces;
				// Broadcasting the public update:
				publicVariable "DAP_piecesBLU";
				_groupKnownIds = (DAP_groupIdsForDisbanded # 0);
			};
			case OPFOR: {
				DAP_piecesOPF = DAP_piecesOPF + _fmGroupPieces;
				publicVariable "DAP_piecesOPF";
				_groupKnownIds = (DAP_groupIdsForDisbanded # 1);
			};
			case INDEPENDENT: {
				DAP_piecesIND = DAP_piecesIND + _fmGroupPieces;
				publicVariable "DAP_piecesIND";
				_groupKnownIds = (DAP_groupIdsForDisbanded # 2);
			};
		};
		{  // forEach _fmGroupPieces:
			// Creating a new group:
			_groupDisbanded = createGroup [_side, true];  // [side, deleteWhenEmpty]
			// Transfering the crew from the _fmTeam to the new group:
			crew _x joinSilent _groupDisbanded;
			// Renaming the new group with a known group name available:
			_groupDisbanded setGroupIdGlobal [_groupKnownIds # 0];
			// Delete that known group name from the available known group names:
			_groupKnownIds deleteAt 0;
		} forEach _fmGroupPieces;
		// Preparing the public update:
		switch _side do {
			case BLUFOR:      { DAP_groupIdsForDisbanded = [_groupKnownIds, DAP_groupIdsForDisbanded # 1, DAP_groupIdsForDisbanded # 2]};
			case OPFOR:       { DAP_groupIdsForDisbanded = [DAP_groupIdsForDisbanded # 0, _groupKnownIds, DAP_groupIdsForDisbanded # 2] };
			case INDEPENDENT: { DAP_groupIdsForDisbanded = [DAP_groupIdsForDisbanded # 0, DAP_groupIdsForDisbanded # 1, _groupKnownIds] };
		};
		// Broadcasting the public update:
		publicVariable "DAP_groupIdsForDisbanded";
		// Debug:
		if ( DAP_debug_isOn && DAP_debug_isOnTeamCheck ) then {
			["%1 DISBANDING %2 ARTILLERY TEAM > %3 DISBANDMENT complete | _groupKnownIds still stored (%4): %5",
			DAP_txtDebugHeader, _tag, _fmTeamDebug, count _groupKnownIds, _groupKnownIds] call BIS_fnc_error;
			sleep 10;
		};
		
	// If the fire-mission-artillery-pieces are not real, not involving in-game), do it:
	} else {
		// Escape:
		if !(_magType in ["HE", "CLUSTER"]) exitWith {
			systemChat format ["%1 VIRTUAL FIRE-MISSION > One or more %2 fire-mission are requesting for other ammo-type. Currently, virtual fire-mission only support _ammo_HE and _ammo_CLUSTER. This fire-mission won't be created.", DAP_txtWarnHeader, _tag];
		};
		
		// VIRTUAL FIRE-MISSION ONGOING:
		[_side, _tag, _numRequested, _fmCode, _cycles, _fmMkrPos, _rounds, _magType, _isReporting] call THY_fnc_DAP_virtual_fire_management;


	};
	// Return / Current thread ends:
	scopeName "earlyreturn";
	true;
};


THY_fnc_DAP_add_firemission = {
	// This function start the schadule of a fire-mission.
	// Returns nothing.
	
	params ["_side", ["_targetsInfo", [[], ""]], ["_fireSetup", [true, 1, "MEDIUM", "HE", 5, 1]], ["_fireTriggers", 1]];
	private ["_tag", "_fmTargetMkrs", "_fmTargetMkrsSector", "_fmCode"];
	
	// Initial values:
		// Reserved space.
	// Errors handling:
		// They are in THY_fnc_DAP_firemission_validation!
	// Declarations - part 1/2:
	_tag = [_side] call THY_fnc_DAP_convertion_side_to_tag;
	// Escape - part 1/2:
	if ( [_tag, _targetsInfo, _fireSetup, _fireTriggers] call THY_fnc_DAP_firemission_validation ) exitWith {};
	// Declarations - part 2/2:
	_fmTargetMkrs       = _targetsInfo # 0;
	_fmTargetMkrsSector = toUpper (_targetsInfo # 1);
	_fmCode             = [_tag] call THY_fnc_DAP_firemission_code;
	// Save fire-mission data for further actions:
	["CREATE", _side, _fmCode] call THY_fnc_DAP_firemission_schedule;  // dont use _tag.
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

	// FIRE-MISSION ITSELF:
	// It starts the fire-mission trigger checking (it's opening a new thread!):
	[_side, _tag, _fmCode, _fmTargetMkrs, _fireSetup, _fireTriggers] spawn THY_fnc_DAP_firemission;
	// CPU breather before check the next fire-mission or end the firemissions.sqf:
	sleep DAP_fireMissionBreath;
	// Return / Current thread ends:
	true;
};


THY_fnc_DAP_debug = {
	// This function shows some numbers to the mission editor when debugging.
	// Returns nothing.

	//params ["", ""];
	//private ["", ""];
	
	// Hint UI info:
	hintSilent format [
		"\n--- DAP DEBUG MONITOR ---" +
		"\nDebug for ammo: %1" +
		"\nDebug for team: %2" +
		"\n---" +
		"\nInfinite ammo: %3" +
		"\nForced rearm: %4" +
		"\nPrevent moving: %5" +
		"\n---" +
		"\nPLANNED FIRE-MISSIONS (all): %6" +
		"%7" +
		"%8" +
		"%9" +
		"%10" +
		"%11" +
		"%12" +
		"%13" +
		"\n\n",
		if DAP_debug_isOnAmmo then {"ON"} else {"OFF"},
		if DAP_debug_isOnTeamCheck then {"ON"} else {"OFF"},
		if DAP_artill_isInfiniteAmmo then {"ON"} else {"OFF"},
		if DAP_artill_forcedRearm then {"ON"} else {"OFF"},
		if DAP_artill_preventMoving then {"ON"} else {"OFF"},
		((if DAP_BLU_isOn then {count (DAP_fmScheduled # 0)} else {0}) + (if DAP_OPF_isOn then {count (DAP_fmScheduled # 1)} else {0}) + (if DAP_IND_isOn then {count (DAP_fmScheduled # 2)} else {0})),
		if DAP_BLU_isOn then {
			format ["\nby BLU:\n%1", (DAP_fmScheduled # 0) joinString "\n"]
		} else {""},
		if DAP_OPF_isOn then {
			format ["\nby OPF:\n%1", (DAP_fmScheduled # 1) joinString "\n"]
		} else {""},
		if DAP_IND_isOn then {
			format ["\nby IND:\n%1", (DAP_fmScheduled # 2) joinString "\n"]
		} else {""},
		if DAP_BLU_isOn then {
			"\n ---" +
			//"\nBLU Fire-missions: XX (WIP)" +
			format ["\nBLU Pieces standby: %1 %2", count DAP_piecesBLU, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 0)]}]
			//"\nBLU Virtual: XX (WIP)"
		} else {""},
		if DAP_OPF_isOn then {
			"\n ---" +
			//"\nOPF Fire-missions: XX (WIP)" +
			format ["\nOPF Pieces standby: %1 %2", count DAP_piecesOPF, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 1)]}]
			//"\nOPF Virtual: XX (WIP)"
		} else {""},
		if DAP_IND_isOn then {
			"\n ---" +
			//"\nIND Fire-missions: XX (WIP)" +
			format ["\nIND Pieces standby: %1 %2", count DAP_piecesIND, if DAP_artill_isInfiniteAmmo then {""} else {format ["(Need rearm: %1)", count (DAP_piecesNeedRearm # 2)]}]
			//"\nIND Virtual: XX (WIP)"
		} else {""},
		if DAP_debug_isOnAmmo then {
			format [
				"\n---" +
				"%1" +
				"%2" +
				"%3",
				if DAP_BLU_isOn then {
					if ( count DAP_piecesBLU > 0 ) then {
						format ["\nEXAMPLE OF BLU PIECE AVAILABLE:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n", 
							DAP_piecesBLU # 0, 
							typeOf (DAP_piecesBLU # 0), 
							toLower (groupId (group (DAP_piecesBLU # 0))),
							getArtilleryAmmo [DAP_piecesBLU # 0]
						]
					} else {"\nEXAMPLE OF BLU PIECE AVAILABLE:\nNeutralized or in-service!"};
				} else {""},
				if DAP_OPF_isOn then {
					if ( count DAP_piecesOPF > 0 ) then {
						format ["\nEXAMPLE OF OPF PIECE AVAILABLE:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n", 
							DAP_piecesOPF # 0, 
							typeOf (DAP_piecesOPF # 0), 
							toLower (groupId (group (DAP_piecesOPF # 0))),
							getArtilleryAmmo [DAP_piecesOPF # 0]
						]
					} else {"\nEXAMPLE OF OPF PIECE AVAILABLE:\nNeutralized or in-service!"};
				} else {""},
				if DAP_IND_isOn then {
					if ( count DAP_piecesIND > 0 ) then {
						format ["\nEXAMPLE OF IND PIECE AVAILABLE:\nVariable-name: %1\nPiece: %2\nGroup: %3\nMagazine types available:\n%4\n", 
							DAP_piecesIND # 0, 
							typeOf (DAP_piecesIND # 0), 
							toLower (groupId (group (DAP_piecesIND # 0))),
							getArtilleryAmmo [DAP_piecesIND # 0]
						]
					} else {"\nEXAMPLE OF IND PIECE AVAILABLE:\nNeutralized or in-service!"};
				} else {""}
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