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
					systemChat format ["%1 ARTILLERY PIECES '%2' > This name's structure IS NOT correct! Decide if you'll use '_' or '-' as spacer in piece variable-names. You can use like '%3%4...' or '...%4%3%4...' or '...%4%3'. This piece has been ignored.",
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


THY_fnc_DAP_pieces_scanner = {
	// This function searches and appends in a list all pieces (objects) confirmed as real. The searching take place once right at the mission begins through fn_DAP_management.sqf file.
	// Return: _confirmedPieces: array

	params ["_prefix", "_spacer"];
	private ["_confirmedPieces", "_isValid", "_obj", "_ctrBLU", "_ctrOPF", "_ctrIND", "_nameStructure", "_piecesBLU", "_piecesOPF", "_piecesIND", "_possiblePieces"];

	// Escape:
		// reserved space.
	// Initial values:
	_confirmedPieces = [];
	_isValid           = false;
	_obj               = objNull;
	_ctrBLU            = 0;
	_ctrOPF            = 0;
	_ctrIND            = 0;
	_nameStructure     = [];
	_piecesBLU       = [];
	_piecesOPF       = [];
	_piecesIND       = [];
	// Declarations:
		// reserved space.
	// Debug texts:
		// reserved space.
	// Selecting the relevant markers:
	// Critical: careful because 'vehicles' command brings lot of trash along: https://community.bistudio.com/wiki/vehicles
	_possiblePieces = vehicles select { count (crew _x) > 0 && toUpper (str _x) find (_prefix + _spacer) isNotEqualTo -1 };
	// Debug message:
	if DAP_debug_isOn then { systemChat format ["%1 Artillery-pieces found: %2 from DAP.", DAP_txtDebugHeader, count _possiblePieces] };
	// Escape > If no _possiblePieces found:
	if ( count _possiblePieces isEqualTo 0 ) exitWith {
		// Warning message:
		systemChat format ["%1 This mission still HAS NO ARTILLERY PIECES (Howitzers or MRL's or Mortars) to be used for. DAP pieces must have their structure names like '%2%3anynumber'. Reminder: no need to add a side in the piece variable-name as seen in markers!",
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

	// Step 2/2 > Ignoring from the first pieces list that doesn't fit the name's structure rules, and creating new lists:
	{  // forEach _possiblePieces:
		_obj = _x;
		// Escape > if weaponey side is civilian, skip to the next _obj:
		if ( side _obj isEqualTo CIVILIAN ) then { systemChat format ["%1 ARTILLERY PIECES '%2' > You cannot use Civilian with DAP! Piece ignored!", DAP_txtWarnHeader, _obj]; continue };
		// check if the _obj name has _spacer character enough in its string composition:
		_nameStructure = [1, _obj, _prefix] call THY_fnc_DAP_name_splitter;
		// Escape > if invalid structure, skip to the next _obj:
		if ( count _nameStructure < 2 ) then { continue };
		// Fixing possible editor's mistakes:
		if DAP_preventDynamicSim then { group _obj enableDynamicSimulation false };  // CRUCIAL for long distances!
		// Adding extra configs:
		if DAP_proventMoving then { (driver _obj) disableAI "MOVE" };
		// WIP THERMAL SIGNATURE: if DAP_artill_isForcedThermalSignat then { [_obj, [1,0,1]] remoteExec ["setVehicleTiPars"] };  // [engine, wheels, weapon] / 1=hot / 0.5=warm / 0=cool
		
		// If all validations alright:
		switch (side (gunner _obj)) do {
			case BLUFOR: {
				// Defining the group name:
				_ctrBLU = _ctrBLU + 1;
				group _obj setGroupIdGlobal [DAP_BLU_name + "-" + str _ctrBLU];
				// Officially part of the support team:
				_piecesBLU pushBack _obj;
			};
			case OPFOR: { 
				// Defining the group name:
				_ctrOPF = _ctrOPF + 1;
				group _obj setGroupIdGlobal [DAP_OPF_name + "-" + str _ctrOPF];
				// Officially part of the support team:
				_piecesOPF pushBack _obj;
			};
			case INDEPENDENT: { 
				// Defining the group name:
				_ctrIND = _ctrIND + 1;
				group _obj setGroupIdGlobal [DAP_IND_name + "-" + str _ctrIND];
				// Officially part of the support team:
				_piecesIND pushBack _obj;
			};
		};
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
			systemChat format ["%1 ARTILLERY PIECES REGISTER > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''B_G_Pickup_mrl_rf''. %3. %4!",
			 _txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY PIECES REGISTER > Never set an empty string ('' '') as artillery piece classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If a classname is forbidden, abort:
		_classname = _x;
		// Critical info: keep using 'findIf' with '==' and never 'in' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( _piecesForbidden findIf { _x == _classname } isNotEqualTo -1 ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY PIECES REGISTER > '%2' is a known problematic artillery piece, or it's inconsistent with DAP purposes. %3. %4!",
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If a classname shows up more than once, abort:
		_classname = _x;
		// Critical info: keep using '==' and never 'isEqualTo' here 'cause it demands case-insensitive once classnames are included by the editor (inconsistence/human typing)!
		if ( ({_classname == _x} count _knownPiecesAll) > 1 ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY PIECES REGISTER > '%2' is duplicated as registered artillery piece. A piece CANNOT be registered more than once. %3. %4!", 
			_txtWarnHeader, _classname, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownPiecesAll;
	{
		// Escape > If not string, abort:
		if ( typeName _x isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 ARTILLERY PIECES FORBIDDEN > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''B_G_Pickup_mrl_rf''. %3. %4!", 
			_txtWarnHeader, _x, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _piecesForbidden;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 ARTILLERY PIECES FORBIDDEN > Never set an empty string ('' '') as artillery piece classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
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
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE REGISTER > Never set an empty string ('' '') as magazine classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
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
			_isInvalid = true; breakTo "return";
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
			_isInvalid = true; breakTo "return";
		};
	} forEach _knownMagsAll;
	{
		// Escape > If not string, abort:
		if ( typeName _x isNotEqualTo "STRING") then {
			// Warning message:
			systemChat format ["%1 MAGAZINE FORBIDDEN > '%2' should be a string, so in other words, it should be a classname between double-quotes, e.g. ''32Rnd_155mm_Mo_shells''. %3. %4!", 
			_txtWarnHeader, _x, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _magsForbidden;
	{
		// Escape > If empty string, abort:
		if ( _x isEqualTo "" ) then {
			// Warning message:
			systemChat format ["%1 MAGAZINE FORBIDDEN > Never set an empty string ('' '') as magazine classname. %2. %3!", 
			_txtWarnHeader, _txt1, _txt2];
			// Preparing to return:
			_isInvalid = true; breakTo "return";
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
		_isInvalid = true; breakTo "return";
	};
	// Escape > xxxxxxxxxxxxxx, abort: all situations where you have a looping;
	{
		if ( xxxxxxxxxxxxxxxxxxx ) then {
			// Warning message:
			["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
			systemChat format ["%1 XXXXXX > xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
			_txtWarnHeader];
			// Prepare to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _xxxxxxxxx;
	*/

	// Return:
	scopeName "return";
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

	params ["_isVirtual" /* (WIP) */, "_tag", "_targetsInfo", "_fireSetup", "_fireTriggers"];
	private ["_isInvalid", "_targetMkrs", "_sectorLetter", "_piecesAmount", "_caliber", "_magType", "_rounds", "_cycles", "_txt1", "_txt2", "_txt3", "_txt4"];

	// Escape:
		// reserved space.
	// Initial values:
	_isInvalid = false;
	// Declarations:
	_targetMkrs     = _targetsInfo # 0;
	_sectorLetter   = _targetsInfo # 1;
	_piecesAmount = _fireSetup # 0;
	_caliber        = _fireSetup # 1;
	_magType        = _fireSetup # 2;
	_rounds         = _fireSetup # 3;
	_cycles         = _fireSetup # 4;
	// Debug texts:
	_txt1 = "Check the 'fn_DAP_firemissions.sqf' file";
	_txt2 = format ["This %1 fire-mission WON'T be created", _tag];
	_txt3 = format ["Fix it using trigger-id: [trg%1name%1var]; or delay-timer (in min): [30]; or object-variable-name: [obj%1name%1var]; or those 3 along: [trg%1name%1var, 30, obj%1mame%1var]", DAP_spacer];
	_txt4 = "To setup the firing, it's needed 5 data: 1) Number of pieces involved; 2) Caliber to use; 3) Ammo type to use; 4) Rounds per piece in cycle; and 5) How much cycles. E.g. [3, _power_MEDIUM, _use_HE, 5, 1]";
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

	// Escape > _fireSetup needs its X elements. If less or more, abort:
	if ( count _fireSetup isNotEqualTo 5 ) exitWith {
		// Warning message:
		systemChat format ["%1 FIRE SETUP > %2. %3!",
		DAP_txtWarnHeader, _txt4, _txt2]; sleep 5;
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
			_isInvalid = true; breakTo "return";
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
				_isInvalid = true; breakTo "return";
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
			_isInvalid = true; breakTo "return";
		};
	} forEach _fireTriggers;
	// Escape > If _fireTriggers there is more than 1 timer, abort:
	{
		if ( { typeName _x isEqualTo "SCALAR" } count _fireTriggers > 1 ) then {
			// Warning message:
			systemChat format ["%1 FIRE-MISSION TRIGGER > At least one %2 fire-mission row has more than one timer as trigger method. You can use 3 different trigger methods, or 3 of the same method, excluding Timer for logic reasons. %3. %4!",
			DAP_txtWarnHeader, _tag, _txt1, _txt2]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "return";
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
		_isInvalid = true; breakTo "return";
	};
	// Escape > xxxxxxxxxxxxxx, abort: all situations where you have a looping;
	{
		if ( xxxxxxxxxxxxxxxxxxx ) then {
			// Warning message:
			systemChat format ["%1 XXXXXXXXXX > xxxxxxxxxxxxxxxxxxxx.",
			DAP_txtWarnHeader, _tag]; sleep 5;
			// Prepare to return:
			_isInvalid = true; breakTo "return";
		};
	} forEach _xxxxxxxxx;
	*/

	// Return:
	scopeName "return";
	_isInvalid;
};


THY_fnc_DAP_building_firemission_team = {
	// This function build up a list of the best pieces for a specific fire-mission, based on the fire-mission requirements.
	// Returns _team: array. Return empty if nothing available.

	params ["_fmMkrPos", "_side", "_tag", "_numRequested", "_caliber", "_magType", "_shouldReport"];
	private ["_libraryCaliber", "_libraryMags", "_debugPurposes", "_team", "_candidates", "_candApprovedMags", "_ammo", "_finalists", "_bestOverall", "_txt1"];

	// Escape:
		// reserved space.
	// Initial values:
	_libraryCaliber   = [];
	_libraryMags      = [];
	_debugPurposes    = nil;
	_team             = [];
	_candidates       = [];
	_candApprovedMags = [];
	_ammo             = "";
	_finalists        = [];
	_bestOverall      = [];
	// Declarations:
		// reserved space.
	// Debug texts:
	_txt1 = "Sir, we've NO artillery pieces alive on the field! You're on your own, over.";
	// (SETP 1/X) Based on the request, selecting only the specific caliber section from the Artillery-pieces library:
	switch _caliber do {
		case "COMBINED":   { _libraryCaliber = DAP_piecesCaliber_light + DAP_piecesCaliber_medium + DAP_piecesCaliber_heavy + DAP_piecesCaliber_superHeavy };
		case "LIGHT":      { _libraryCaliber = DAP_piecesCaliber_light };
		case "MEDIUM":     { _libraryCaliber = DAP_piecesCaliber_medium };
		case "HEAVY":      { _libraryCaliber = DAP_piecesCaliber_heavy };
		case "SUPERHEAVY": { _libraryCaliber = DAP_piecesCaliber_superHeavy };
		default {
			// Warning message:
			systemChat format ["%1 ASSEMBLING %2 ARTILLERY TEAM > At least one %2 fire-mission is using an invalid CALIBER. Check the 'fn_DAP_management.sqf' file. This fire-mission was aborted.", 
			DAP_txtWarnHeader, _tag]; sleep 5;
			// Return:
			breakTo "return";
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
			breakTo "return";
		};
	};
	
	// (STEP 3/X) Filtering for current side pieces those have the requested caliber:
	switch _tag do {
		case "BLU": {
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesBLU] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available:
			DAP_piecesBLU = DAP_piecesBLU select { alive _x && alive (gunner _x) };
			// Broadcasting the update:
			publicVariable "DAP_piecesBLU";
			// Escape > If no side pieces available:
			if ( count DAP_piecesBLU isEqualTo 0 ) then {
				// Side command message:
				if _shouldReport then { 
					[_side, "BASE"] commandChat _txt1;
					sleep 3;
				};
				// Return:
				breakTo "return";
			};
			// Debug:
			if DAP_debug_isOn then { _debugPurposes = count DAP_piecesBLU };
			// Checking the caliber:
			{ if ( typeOf _x in _libraryCaliber ) then { _candidates pushBack _x } } forEach DAP_piecesBLU;
			// Escape > If no side pieces available:
			if ( count _candidates isEqualTo 0 ) exitWith {};
		};
		case "OPF": { 
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesOPF] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available:
			DAP_piecesOPF = DAP_piecesOPF select { alive _x && alive (gunner _x) };
			// Broadcasting the update:
			publicVariable "DAP_piecesOPF";
			// Escape > If no side pieces available:
			if ( count DAP_piecesOPF isEqualTo 0 ) then {
				// Side command message:
				if _shouldReport then { 
					[_side, "BASE"] commandChat _txt1;
					sleep 3;
				};
				// Return:
				breakTo "return";
			};
			// Debug:
			if DAP_debug_isOn then { _debugPurposes = count DAP_piecesOPF };
			// Checking the caliber:
			{ if ( typeOf _x in _libraryCaliber ) then { _candidates pushBack _x } } forEach DAP_piecesOPF;
			// Escape > If no side pieces available:
			if ( count _candidates isEqualTo 0 ) exitWith {};
		};
		case "IND": {
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > %3 artillery-piece(s) to valuation...", DAP_txtDebugHeader, _tag, count DAP_piecesIND] call BIS_fnc_error; sleep 3;
			};
			// Basic valuation and update of side pieces available:
			DAP_piecesIND = DAP_piecesIND select { alive _x && alive (gunner _x) };
			// Broadcasting the update:
			publicVariable "DAP_piecesIND";
			// Escape > If no side pieces available:
			if ( count DAP_piecesIND isEqualTo 0 ) then {
				// Side command message:
				if _shouldReport then { 
					[_side, "BASE"] commandChat _txt1;
					sleep 3;
				};
				// Return:
				breakTo "return";
			};
			// Debug:
			if DAP_debug_isOn then { _debugPurposes = count DAP_piecesIND };
			// Checking the caliber:
			{ if ( typeOf _x in _libraryCaliber ) then { _candidates pushBack _x } } forEach DAP_piecesIND;
			// Escape > If no side pieces available:
			if ( count _candidates isEqualTo 0 ) exitWith {};
		};
	};  // switch _tag ends.
	// Debug message:
	if DAP_debug_isOn then {[
		"%1 ASSEMBLING %2 ARTILLERY TEAM > From %3 in the field, %4 have the requested caliber (%5).",
		DAP_txtDebugHeader,
		_tag,
		_debugPurposes,
		count _candidates,
		_caliber
		] call BIS_fnc_error; sleep 3;
	};
	// Escape > If no side candidate-pieces available:
	if ( count _candidates isEqualTo 0 ) exitWith {
		// Side command message:
		if _shouldReport then { 
			[_side, "BASE"] commandChat "Sir, unfortunately our artillery DON'T fit the BASIC requirements for the planned fire-mission that was supposed to take place now, over.";
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_team;
	};

	// (STEP 4/X) Filtering for those right-caliber-pieces those have the requested ammo type:
	{  // forEach _candidates:
		// Compars and stores only approved mags (if the _candidates got):
		_candApprovedMags = _libraryMags arrayIntersect (getArtilleryAmmo [_x]);
		// One or more ammo options:
		if ( count _candApprovedMags > 0 ) then {
			// Debug message:
			if ( DAP_debug_isOn && count _candApprovedMags > 1 ) then { 
				["%1 ASSEMBLING %2 ARTILLERY TEAM > '%3' approved mag types: %4 = %5. DAP will select randomly one of them.", DAP_txtDebugHeader, _tag, _x, count _candApprovedMags, _candApprovedMags] call BIS_fnc_error; sleep 3;
			};
			// Selecting the ammo:
			_ammo = selectRandom _candApprovedMags;
			// Building the array to receive all data needed for _team:
			_finalists append [[nil, _x, _ammo]];
		};
	} forEach _candidates;
	// Escape > If no side finalist-pieces available:
	if ( count _finalists isEqualTo 0 ) exitWith {
		// Side command message:
		if _shouldReport then { 
			[_side, "BASE"] commandChat format [
				"Sir, although our artillery has %1 the AMMO-TYPE requested (%2) for the planned fire-mission that was supposed to take place now, over.",
				if ( count _candidates > 8 ) then {"MANY pieces with the right caliber, they DON'T HAVE"} else {
					if ( count _candidates > 1 ) then {"a FEW pieces with the right caliber, they DON'T HAVE"} else {"ONLY ONE piece with the right caliber, it DOESN'T HAVE"};
				},
				_magType
			];
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_team;
	};

	// (STEP 5/X) Selecting those right-caliber-and-ammo-type-pieces with range from the target:
	_bestOverall = _finalists select { _fmMkrPos inRangeOfArtillery [[_x # 1], _x # 2] };  // _x # 0 = reserved space / _x # 1 = obj  /  _x # 2 = _ammo.
	// Escape > no _finalists, abort:
	if ( count _bestOverall isEqualto 0 ) exitWith {
		// Side command message:
		if _shouldReport then {
			[_side, "BASE"] commandChat format [
				"Sir, even with %1 RANGE for the planned fire-mission that was supposed to take place now, over.",
				if ( count _finalists > 1 ) then {"SOME PIECES of the requested caliber and ammo-type, they DON'T HAVE"} else {"A PIECE of the requested caliber and ammo-type, it HAS NO"}
			];
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s) | Caliber = %4 | Ammo = %5.", DAP_txtDebugHeader, _tag, _numRequested, _caliber, _magType] call BIS_fnc_error;
			};
			sleep 3;
		};
		// Return:
		_team;
	};
	// _bestOverall needs define its leader/closest from the target:
	if ( count _bestOverall >= 2 ) then {
		// Build and array (_team) with another array in:
			// 1st element: distance between piece and the target-marker,
			// 2nd element: piece (object) itself,
			// 3rd element: selected ammo.
			// E.g. [23423e.05+3, dap_1, "12Rnd_HE_example"]
		_team = _bestOverall apply {
			[
				// Distance:
				// Important, if specific caliber, always consider the real distance, otherwise it creates a fake distance (0-500) to randomize the piece choices during the "sort" and avoid the sort select only one caliber type.
				if ( _caliber isNotEqualTo "COMBINED") then { _fmMkrPos distanceSqr (_x # 1) } else { random 501 },
				// Piece:
				_x # 1,
				// Ammo:
				_x # 2
			];
		};
		// Sort the _team where the first element is the closest one from the target (and DAP will deal with it as the fire-mission leader later):
		_team sort true;
		// Resize the _team only for what was requested, if appliable:
		if ( count _team > _numRequested ) then {_team resize _numRequested};

		// WIP: Booking the piece busy with a fire-mission!
		// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

		if DAP_debug_isOn then {
			["%1 ASSEMBLING %2 ARTILLERY TEAM > Successfully done! | Perfect for mission = %3 | Let's use the requested = %4.", DAP_txtDebugHeader, _tag, count _bestOverall, count _team] call BIS_fnc_error;
			sleep 3;
		};
	// _team has not enough number of pieces requested, take all those we got:
	} else {
		// Prepare to return:
		_team = _bestOverall;
		// Side command message:
		if _shouldReport then {
			[_side, "BASE"] commandChat format ["We will %1, but the fire-mission will take place now as planned, sir! Over.",
			if (!(_magType in ["FLARE","SMOKE"])) then {"hammer the position with LESS power as planned"} else {if (_magType isEqualTo "SMOKE") then {"NOT blind the position as planned"} else {"NOT paint the sky as planned"}}];
			// Debug message:
			if DAP_debug_isOn then {
				["%1 ASSEMBLING %2 ARTILLERY TEAM > Requirements: %3 requested piece(s), released %4 with: Caliber = %5 | Ammo-type = %6",
				DAP_txtDebugHeader, _tag, _numRequested, count _team, _caliber, _magType] call BIS_fnc_error; 
			};
			sleep 3;
		};
	};
	// Return:
	scopeName "return";
	_team;
};


THY_fnc_VO_isRearmNeeded = {
	// This function (from my script 'Vehicles Overhauling') checks the mag capacity and how much ammo still remains within.
	// Returns _isRearmNeeded bool.
	
	params ["_piece"];
	private ["_isRearmNeeded", /*"_gunnerWeapons", "_hasGunnerNoWeapon", "_notWeaponWords", "_turretPath",*/ "_pieceMagsStr", "_pieceMagDetail", "_ammoName", "_ammoInMag", "_capacityMag"];

	_isRearmNeeded        = false;
	//_gunnerWeapons        = _piece weaponsTurret [0];
	//_hasGunnerNoWeapon    = false;
	//_notWeaponWords       = ["horn", "flare"];  // add here the key-word that indicates "the ammo name" is NOT an ammo.
	
	// Extra debug for rearming:
	/* if DAP_debug_isOn then {
		_turretPath = [[-1], [0], [1], [0,0], [0,1], [1,0]];  // https://community.bistudio.com/wiki/Turret_Path
		{ systemChat format ["%1 Piece turret path %2 = %3", DAP_txtDebugHeader, _x, _piece weaponsTurret _x]; sleep 2 } forEach _turretPath;
	}; */
	
	// Check if the turrets are not just a horn or other stuff in _notWeaponWords:
	/* if ( count _gunnerWeapons <= 1 ) then {
		if ( count _gunnerWeapons isEqualTo 0 ) exitWith { _hasGunnerNoWeapon = true };
		{
			_hasGunnerNoWeapon = [_x, (_gunnerWeapons # 0), false] call BIS_fnc_inString;
			if _hasGunnerNoWeapon exitWith {};
		} forEach _notWeaponWords;
	}; 

	// Exit if the vehicle has NO weaponry for gunner:
	if _hasGunnerNoWeapon exitWith {
		if DAP_debug_isOn then { systemChat format ["%1 %2 has NO weaponry, then rearm IS NOT needed.", DAP_txtDebugHeader, _piece]; sleep 2 };
		_isRearmNeeded;
	};*/
	
	_pieceMagsStr = magazinesDetail _piece;  // "120mm (2/20)[id/cr:10000011/0]".

	if ( count _pieceMagsStr > 0 ) then {
		{
			_pieceMagDetail = _x splitString "([]/:)";  // ["120mm", "2", "20", "id", "cr", "10000011", "0"]
			_ammoName = _pieceMagDetail # 0;
			reverse _pieceMagDetail;  // ["0", "10000011", "cr", "id", "20", "2", "120mm"] coz the current ammo and ammo capacity don't change their index when reversed.
			//systemChat str _pieceMagDetail;  // Extra debug: checking the index of mag details.
			_ammoInMag = parseNumber (_pieceMagDetail # 5);  // string "2" convert to number 2.
			_capacityMag = parseNumber (_pieceMagDetail # 4);  // string "20" convert to number 20.
	
			// Checking if rearm is needed:
			if ( _ammoInMag < (_capacityMag / 4) ) exitWith {
				if DAP_debug_isOn then {
					systemChat format ["%1 %2 Magazine [%3]: %4 ammo of %5 capacity. Rearm is needed!", DAP_txtDebugHeader, _piece, _ammoName, _ammoInMag, _capacityMag]; sleep 0.5;
				};
				_isRearmNeeded = true;
			};
		} forEach _pieceMagsStr;

	} else {
		// When the armed-vehicle has NO ammo-capacity (0% ammunition in its attributes) it will force the vehicle to rearm:
		_isRearmNeeded = true;
	};
	_isRearmNeeded // Returning...
};


THY_fnc_DAP_firing = {
	// This function just control the firing of the fire-mission. Once it's finished, this thread/spawn is done.
	// Returns nothing.

	params ["_pieceLeader", "_side", "_cycles", "_piece", "_fmMkrPos", "_magType", "_ammo", "_rounds", "_teamCooldown", "_shouldReport"];
	//private [""];

	// Initial values:
		// reserved space.
	// Declarations:
		// reserved space.
	// Side command message:
	if ( _shouldReport && _piece isEqualTo _pieceLeader ) then {
		if ( alive _pieceLeader && alive (gunner _pieceLeader) ) then {
			_pieceLeader commandChat format [
				"Fire-mission on the way. Prepare %1 in %2 secs.",
				if ( _magType isNotEqualTo "FLARE" ) then {"to impact"} else {"to light up"},
				round (_pieceLeader getArtilleryETA [_fmMkrPos, _ammo]) + 2  // ETA (Estimated Time of Arrival) + next sleep time.
				// WIP the distance between fire position and the player leader: round (_fmMkrPos distance (getPos player))
			];
			// Breath before take some action:
			sleep 2;
		};
	};
	// Humanizing/desynchronizing the firing from multiple sources:
	sleep selectRandom [0.26, 0.41, 0.63, 0.83, 1.09, 1.27, 1.49, 1.63, 1.96];
	// Firing if has cycle, the piece is alive, the gunner is alive, and there's ammunition in main gun:
	while { _cycles > 0 && alive _piece && alive (gunner _piece) && !([_piece] call THY_fnc_VO_isRearmNeeded) } do {
		// Control:
		_cycles = _cycles - 1;
		// Additional and shortest humanizing/desynchronizing each new cycle:
		sleep selectRandom [0, 0.26, 0.47, 0.79, 1.03];
		// Fire:
		_piece doArtilleryFire [_fmMkrPos, _ammo, _rounds];
		// Wait the cycle be complete or the piece is neutralized or out of ammo:
		waitUntil { sleep 5; unitReady _piece || !alive _piece || !canFire _piece || [_piece] call THY_fnc_VO_isRearmNeeded };
		// Side command message:
		if ( _shouldReport && _piece isEqualTo _pieceLeader && alive _pieceLeader && alive (gunner _pieceLeader) && _cycles > 0 ) then {
			// Side command message:
			_pieceLeader commandChat format ["Stand by for the next rounds cycle in %1 seconds, sir.", round _teamCooldown];
		};
		// Cycle cooldown:
		sleep _teamCooldown;
		// Rearming automatically:
		if DAP_artill_isInfiniteAmmo then {
			// (If a fucking client-player in the vehicle hehe) in case the piece is created-by (or transfered-to) another machine and not the server:
			//[_piece, 1] remoteExec ["setVehicleAmmo", _piece];
			// But let's take the performance way here:
			_piece setVehicleAmmo 1;
		};
	};  // While loop ends.

	// Side command message:
	if _shouldReport then {
		// If the fire-mission leader:
		if ( _piece isEqualTo _pieceLeader ) then {
			// breath before to talk:
			sleep 5;
			// If piece and its crew is fine:
			if ( alive _pieceLeader && alive (gunner _pieceLeader) ) then {
				// Side command message:
				_pieceLeader commandChat "Fire-mission completed, sir.";
			// Fire-mission leader is neutralized:
			} else {
				// Side command message:
				[_side, "BASE"] commandChat format ["We lost signal with the fire-mission leader '%1', sir, over!", _piece];
				sleep 2;
			};
		// If not the fire-mission leader:
		} else {
			// If a fire-mission member (not leader) is neutralized:
			if ( !alive _piece || !alive (gunner _piece) ) then {
				// Side command message:
				_pieceLeader commandChat "A member of my fire-mission team was lost, sir, over!";
				sleep 2;
			};

		};
	};
	// Return:
	true;
};


THY_fnc_DAP_trigger = {
	// This function (new thread) waits the right moment to pull the trigger of the artillery piece. It runs separately of THY_fnc_DAP_add_firemission that's finished once this fnc is called.
	// Returns nothing.

	params ["_isVirtual", /* (WIP) */ "_side", "_tag", "_callsign", "_fmTargetMkrs", "_fireSetup", "_fireTriggers"];
	private ["_wasTriggered", "_timeLoop", "_time", "_ctr", "_wait", "_shouldReport", "_team", "_ammo", "_piece", "_gunner", "_numRequested", "_caliber", "_magType", "_rounds", "_cycles", "_txt1", "_fmMkrPos"];

	// Escape:
		// reserved space.
	// Initial values:
	_wasTriggered = False;
	_timeLoop     = 0;
	_time         = time;
	_ctr          = _time;
	_wait         = 10;  // CAUTION: this number is used to calcs the TIMER too.
	_shouldReport = false;
	_team         = [];
	_ammo         = "";
	_piece     = objNull;
	_gunner       = objNull;
	_teamCooldown = 1;
	
	// Declarations:
	_numRequested = _fireSetup # 0;
	_caliber      = _fireSetup # 1;
	_magType      = _fireSetup # 2;
	_rounds       = _fireSetup # 3;
	_cycles       = _fireSetup # 4;

	// Debug texts:
	_txt1 = "FIRE-MISSION was released";

	// Debug monitor > Adding one fire-mission to the queue:
	if DAP_debug_isOn then { DAP_fmQueueAmount = DAP_fmQueueAmount + 1; publicVariable "DAP_fmQueueAmount" };

	// Fire-mission trigger conditions > Stay checking until the fire-mission is released:
	while { !_wasTriggered } do {
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
					_wasTriggered = true;
					// Debug message:
					if DAP_debug_isOn then {
						systemChat format ["%1 A %2 %3 by TIMER (it was %4 minutes).", DAP_txtDebugHeader, _tag, _txt1, _x];
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
						_wasTriggered = true; 
						// Debug message:
						if DAP_debug_isOn then {
							systemChat format ["%1 A %2 %3 by TRIGGER (%4).", DAP_txtDebugHeader, _tag, _txt1, _x];
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
						_wasTriggered = true;
						// Debug message:
						if DAP_debug_isOn then {
							systemChat format ["%1 A %2 %3 by TARGET (%4).", DAP_txtDebugHeader, _tag, _txt1, _x];
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

	// COMMUNICATION SETUP:
	switch _caliber do {
		case "LIGHT":      { _shouldReport = DAP_fmCaliber_shouldReportLight };
		case "MEDIUM":     { _shouldReport = DAP_fmCaliber_shouldReportMedium };
		case "HEAVY":      { _shouldReport = DAP_fmCaliber_shouldReportHeavy };
		case "SUPERHEAVY": { _shouldReport = DAP_fmCaliber_shouldReportSuperH };
		case "COMBINED":   { _shouldReport = DAP_fmCaliber_shouldReportCombined };
	};
	
	// FIRE-MISSION:
	// If the piece is real (so, it has asset in-game involved):
	if !_isVirtual then {

		// Building the fire-mission team:
		_team = [_fmMkrPos, _side, _tag, _numRequested, _caliber, _magType, _shouldReport] call THY_fnc_DAP_building_firemission_team;
		// Escape > No team available:
		if ( count _team isEqualTo 0 ) then { breakTo "return" };
		
		if (_cycles > 0) then {
			// Defining randomly the cooldown for this specific team if it has cycles (variation of 20% less, 30% more):
			_teamCooldown = random [DAP_fmCycle_coolDown - (DAP_fmCycle_coolDown * 0.20), DAP_fmCycle_coolDown, DAP_fmCycle_coolDown + (DAP_fmCycle_coolDown * 0.30)];
		};

		{	// forEach _team:
			_piece = _x # 1;  // Important: _team arrives here with arrays inside, each one with 3 elements, e.g [[2.94454e+07, dap_1, "Sh_155mm_AMOS"],...].
			// If the piece is not destroyed, it still can fire, , keep going:
			if ( alive _piece && canFire _piece ) then {
				// Define the gunner if available:
				_gunner = gunner _piece;
				// If piece has a gunner, gunner is not a player, the gunner are minimally healthy, keep going:
				if ( alive _gunner && !isPlayer _gunner && !(incapacitatedState _gunner in ["UNCONSCIOUS", "MOVING"]) ) then {
					// Ammunition to be used:
					_ammo = _x # 2;
					// Fire:
					[(_team # 0) # 1, _side, _cycles, _piece, _fmMkrPos, _magType, _ammo, _rounds, _teamCooldown, _shouldReport] spawn THY_fnc_DAP_firing;
				
				} else {
					// Otherwise, no AI as gunner position:
					if ( _shouldReport && !isPlayer _gunner ) then {
						// Side command message:
						[_side, "BASE"] commandChat format ["'%1' is not responding, sir, over!", _piece];
						sleep 3;
					// Somehow, the gunner is a player:
					} else {
						// Side command message:
						if _shouldReport then {
							[_side, "BASE"] commandChat format ["Hehe, '%1' has a human player as gunner (%2), sir! Better to order them directly, over!", _piece, _gunner];
							sleep 3;
						};
					};
				};
			// The piece looks out of service:
			} else {
				// Side command message:
				if _shouldReport then {
					[_side, "BASE"] commandChat format ["'%1' is NOT responding, sir, over!", _piece];
					sleep 3;
				};
			};
		} forEach _team;

		// Debug monitor > Removing one fire-mission to the queue:
		if DAP_debug_isOn then { DAP_fmQueueAmount = DAP_fmQueueAmount - 1; publicVariable "DAP_fmQueueAmount" };

	// If the piece is virtual (there's no asset in-game involved):
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
	scopeName "return";
	true;
};


THY_fnc_DAP_add_firemission = {
	// This function start the schadule of a fire-mission.
	// Returns nothing.
	
	params ["_side", ["_targetsInfo", [[], ""]], ["_fireSetup", [1, "MEDIUM", "HE", 5, 1]], ["_fireTriggers", 1]];
	private ["_callsign", "_tag", "_targetMkrs", "_mkrsSectorLetter", "_fmTargetMkrs", "_fmTargetMkrsSector"];
	
	// Initial values:
	_callsign = "";
	// Errors habdling > _team: it's already done through the THY_fnc_DAP_teams!
	// Errors handling > If _targetsInfo is empty or has just one element, fix it including the sector empty:
	if ( count _targetsInfo < 2 ) then { _targetsInfo set [1, ""] };
	// Declarations - part 1/2:
	// Important: dont declare _targetsInfo or _destsInfo selections before the Escapes coz during Escape tests easily the declarations will print out errors that will stop the creation of other groups.
	_tag = [_side] call THY_fnc_DAP_convertion_side_to_tag;  // if something wrong with _side, it will return empty.
	// Debug texts:
		// reserved space.
	// Escape - part 1/2:
	if ( [false, _tag, _targetsInfo, _fireSetup, _fireTriggers] call THY_fnc_DAP_firemission_validation ) exitWith {};
	// Declarations - part 2/2:
	_targetMkrs       = _targetsInfo # 0;
	_mkrsSectorLetter = toUpper (_targetsInfo # 1);
	switch _tag do {
		case "BLU": { _callsign = DAP_BLU_name };
		case "OPF": { _callsign = DAP_OPF_name };
		case "IND": { _callsign = DAP_IND_name };
	};
	// Debug:
	if ( DAP_debug_isOn && DAP_debug_isOnSectors ) then {
		// Message:
		systemChat format ["%1 %2 FIRE-MISSION SCHEDULE > Sectorized targets: %3 | Markers:\n%4.",
		DAP_txtDebugHeader, 
		_tag, 
		_mkrsSectorLetter, 
		_targetMkrs];
		// Breather:
		sleep 5;
	};
	// Re-building _targetsInfo to be straight:
	_targetsInfo = [_targetMkrs, _mkrsSectorLetter];
	// Selecting only those with right sector-letter:
	_fmTargetMkrs       = _targetsInfo # 0;
	_fmTargetMkrsSector = _targetsInfo # 1;
	_fmTargetMkrs       = +(_fmTargetMkrs select { _x find (DAP_spacer + _fmTargetMkrsSector + DAP_spacer) isNotEqualTo -1 });

	// TRIGGERS SECTION:
	// Pull the trigger once ready (it's opening a new thread!):
	[false, _side, _tag, _callsign, _fmTargetMkrs, _fireSetup, _fireTriggers] spawn THY_fnc_DAP_trigger;
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
		"\n" +
		"\n--- DAP DEBUG MONITOR ---" +
		"\n Scheduled fire-missions: %1" +
		//"\n ---" +
		// "\n BLU Fire-missions: 0/10 (WIP)" +
		// "\n BLU Real Pieces: 10/10 (WIP)" +
		// "\n BLU Virtual ones: 10 (WIP)" +
		// "\n ---" +
		// "\n OPF Fire-missions: 0/10 (WIP)" +
		// "\n OPF Real Pieces: 10/10 (WIP)" +
		// "\n OPF Virtual ones: 10 (WIP)" +
		// "\n ---" +
		// "\n IND Fire-missions: 0/10 (WIP)" +
		// "\n IND Real Pieces: 10/10 (WIP)" +
		// "\n IND Virtual ones: 10 (WIP)" +
		"\n%2" +
		"\n\n",
		DAP_fmQueueAmount,
		if DAP_debug_isOnAmmo then {
			format [
				"---" +
				"\nAMMO MAGAZINES:" +
				"\n" + 
				"%1" +
				"%2" +
				"%3",
				if DAP_BLU_isOn then {format [
					"\n1st BLU PIECE FOUND:\nVariable-name: %1\nGroup: %2\nPiece: %3\nMagazine types available:\n%4\n", 
					DAP_piecesBLU # 0, 
					groupId (group (DAP_piecesBLU # 0)),
					typeOf (DAP_piecesBLU # 0), 
					getArtilleryAmmo [DAP_piecesBLU # 0]
				]} else {""},
				if DAP_OPF_isOn then {format [
					"\n1st OPF PIECE FOUND:\nVariable-name: %1\nGroup: %2\nPiece: %3\nMagazine types available:\n%4\n",
					DAP_piecesOPF # 0, 
					groupId (group (DAP_piecesOPF # 0)),
					typeOf (DAP_piecesOPF # 0), 
					getArtilleryAmmo [DAP_piecesOPF # 0]
				]} else {""},
				if DAP_IND_isOn then {format [
					"\n1st IND PIECE FOUND:\nVariable-name: %1\nGroup: %2\nPiece: %3\nMagazine types available:\n%4\n",
					DAP_piecesIND # 0, 
					groupId (group (DAP_piecesIND # 0)),
					typeOf (DAP_piecesIND # 0), 
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