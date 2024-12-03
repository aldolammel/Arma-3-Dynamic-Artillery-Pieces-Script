// DAP: Dynamic Artillery Pieces v1.5
// File: your_mission\DynamicArtilleryPieces\fnc_DAP_fireMissions.sqf
// Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf
// by thy (@aldolammel)


if ( !DAP_isOn || !isServer ) exitWith {};

[] spawn {
    // DAP CORE > DONT TOUCH > Wait if needed:
    private _time = time + DAP_wait;
    waitUntil { sleep 0.2; time > _time };
    // DAP CORE > DONT TOUCH > Object declarations:
    private ["_caliber_COMBINED","_caliber_LIGHT","_caliber_MEDIUM","_caliber_HEAVY","_caliber_SUPERHEAVY","_ammo_HE","_ammo_CLUSTER","_ammo_CLUSTER_MINE_AP","_ammo_CLUSTER_MINE_AT","_ammo_GUIDED","_ammo_GUIDED_LASER","_ammo_SMOKE","_ammo_FLARE"]; _caliber_COMBINED="COMBINED";_caliber_LIGHT="LIGHT";_caliber_MEDIUM="MEDIUM";_caliber_HEAVY="HEAVY";_caliber_SUPERHEAVY="SUPERHEAVY";_ammo_HE="HE";_ammo_CLUSTER="CLUSTER";_ammo_CLUSTER_MINE_AP="CLUSTER_MINE_AP";_ammo_CLUSTER_MINE_AT="CLUSTER_MINE_AT";_ammo_GUIDED="GUIDED";_ammo_GUIDED_LASER="GUIDED_LASER";_ammo_SMOKE="SMOKE";_ammo_FLARE="FLARE";



    // POCKET GUIDE FOR YOU .........................................................................................................

    // ARTILLERY PIECES OPTIONS:
        // _caliber_LIGHT ........... Only caliber less than 123mm, regardless if it belongs to Howitzer, MRL or mortar.
        // _caliber_MEDIUM .......... Only caliber between 123mm and 159mm, regardless if it belongs to Howitzer, MRL or mortar.
        // _caliber_HEAVY ........... Only caliber between 160mm and 299mm, regardless if it belongs to Howitzer, MRL or mortar.
        // _caliber_SUPERHEAVY ...... Only caliber equal or greater than 300mm, regardless if it belongs to Howitzer, MRL or mortar.
        // _caliber_COMBINED ........ Random calibers are combined is different pieces are available.

    // AMMO MAGAZINES OPTIONS:
        // _ammo_HE ................. High Explosive ammo, great choice against infantry, buildings and light-medium armor vehicles.
        // _ammo_CLUSTER ............ Cluster ammo, greatest choice against infantry in trenches and forests.
        // _ammo_CLUSTER_MINE_AP .... Cluster dropping Anti-personnel-mines.
        // _ammo_CLUSTER_MINE_AT .... Cluster dropping Anti-tank-mines.
        // _ammo_GUIDED ............. Commonly a HE ammunition with superior accuracy.
        // _ammo_GUIDED_LASER ....... Commonly a HE ammunition with maximum accuracy.
        // _ammo_SMOKE .............. Smoke ammo, recommended choice to preserve structures but blinding the enemy for a while.
        // _ammo_FLARE .............. Flare ammo, recommended choice to paint an area or bring temporary light in the dark.

    // ..............................................................................................................................

    if ( DAP_BLU_isOn && count DAP_targetMrksBLU > 0 ) then {

        // FIRE-MISSIONS PLAN: BLUFOR
        // Define each fire-mission should be available for this side. You can add or remove fire-mission rows as you wish.

            // Which column means:
            // [ From BLU [ Target markers, "Sector" ], [ Number of pieces, Pieces Caliber, Ammo type, Rounds per piece, Repetition cycle ], [ Triggers ] ]

            //[BLUFOR, [DAP_targetMrksBLU, "A"], [5, _caliber_MEDIUM, _ammo_CLUSTER, 2, 2], [trg_fm_1, 5]] call THY_fnc_DAP_add_firemission;

            [BLUFOR, [DAP_targetMrksBLU, "A"], [true, 2, _caliber_MEDIUM, _ammo_FLARE, 1, 1], [trg_fm_2, unit_target_1]] call THY_fnc_DAP_add_firemission;

            //[BLUFOR, [DAP_targetMrksBLU, "B"], [3, _caliber_LIGHT, _ammo_HE, 6, 1], [trg_fm_3]] call THY_fnc_DAP_add_firemission;

            //[BLUFOR, [DAP_targetMrksBLU, "A"], [5, _caliber_COMBINED, _ammo_HE, 5, 2], [trg_fm_4]] call THY_fnc_DAP_add_firemission;
            

    }; // blufor ends.

    // ..............................................................................................................................

    if ( DAP_OPF_isOn && count DAP_targetMrksOPF > 0 ) then {

        // FIRE-MISSIONS PLAN: OPFOR
        // Define each fire-mission should be available for this side. You can add or remove fire-mission rows as you wish.

            // Which column means:
            // [ From OPF [ Target markers, "Sector" ], [ Number of pieces, Pieces Caliber, Ammo type, Rounds per piece, Repetition cycle ], [ Triggers ] ]

            [OPFOR, [DAP_targetMrksOPF, "K"], [10, _caliber_COMBINED, _ammo_HE, 5, 2], [trg_fm_5, 2]] call THY_fnc_DAP_add_firemission;
            
            [OPFOR, [DAP_targetMrksOPF, "K"], [5, _caliber_SUPERHEAVY, _ammo_HE, 12, 2], [trg_fm_6]] call THY_fnc_DAP_add_firemission;

    }; // opfor ends.

    // ..............................................................................................................................


    if ( DAP_IND_isOn && count DAP_targetMrksIND > 0 ) then {

        // FIRE-MISSIONS PLAN: INDEPENDENT
        // Define each fire-mission should be available for this side. You can add or remove fire-mission rows as you wish.

            // Which column means:
            // [ From IND [ Target markers, "Sector" ], [ Number of pieces, Pieces Caliber, Ammo type, Rounds per piece, Repetition cycle ], [ Triggers ] ]

            [INDEPENDENT, [DAP_targetMrksIND, "A"], [1, _caliber_MEDIUM, _ammo_HE, 5, 1], [unit_target_1]] call THY_fnc_DAP_add_firemission;
            

    }; // ind ends.


};  // spawn ends.
// Return:
true;
