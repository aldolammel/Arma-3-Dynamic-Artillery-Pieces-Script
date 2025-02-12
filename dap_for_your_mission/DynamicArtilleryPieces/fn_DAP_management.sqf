// DAP: Dynamic Artillery Pieces v1.5.5
// File: your_mission\DynamicArtilleryPieces\fnc_DAP_management.sqf
// Documentation: https://github.com/aldolammel/Arma-3-Dynamic-Artillery-Pieces-Script/blob/main/_DAP_Script_Documentation.pdf
// by thy (@aldolammel)

// Runs only in server:
if !isServer exitWith {};

// PARAMETERS OF EDITOR'S OPTIONS:
DAP_isOn = true;                         // Turn on or off the entire script without to touch your description.ext / Default: true;

// Debug:
	DAP_debug_isOn          = true;      // true = shows debugging info for the Mission Editor (turn it off before release your mission) / Default: false.
	DAP_debug_isOnAmmo      = true;      // true = additional debugging info about the 1st artillery piece of a side / Default: true;
	DAP_debug_isOnTeamCheck = true;      // true = additional debugging info about the fire-mission team assembly / Default: true;
	DAP_debug_isOnSectors   = false;     // true = additional debugging info for sectorization of artillery target analysis / Default: false;
	DAP_debug_readTime      = 1;         // (in seconds) time to read each Debug message (not warning ones) / Min 0.5, Max 5 / Default: 1;

// Sides to use:
	DAP_BLU_isOn = true;                    // true = Blufor artillery (real or virtual) will be available in your mission / false = turn them off.
	DAP_BLU_name = "BLU FIRE SUPPORT";      // Name used by DAP when referring to the Blufor artillery teams in side Command chat. Default: "";
	DAP_OPF_isOn = false;                   // true = Opfor artillery (real or virtual) will be available in your mission / false = turn them off.
	DAP_OPF_name = "OPF FIRE SUPPORT";      // Name used by DAP when referring to the Opfor artillery teams in side Command chat. Default: "";
	DAP_IND_isOn = false;                   // true = Independent artillery (real or virtual) will be available in your mission / false = turn them off.
	DAP_IND_name = "IND FIRE SUPPORT";      // Name used by DAP when referring to the Independent artillery teams in side Command chat. Default: "";

// Fire-mission general settings:
	DAP_fmVisible_isOnMap = true;                // true = only leaders can see the position of the fire-mission on the map / false = no markers / Default: true;
	DAP_fmVisible_alpha   = 1;                   // 0.5 = impact zone barely invisible on the map / 1 = quite visible. Default: 1;
	DAP_fmCaliber_shouldReportLight    = false;  // true = Light artillery/mortar reports each action via side command channel / false = No reports / Default: false;
	DAP_fmCaliber_shouldReportMedium   = true;   // true = Medium artillery/mortar reports each action via side command channel / false = No reports / Default: true;
	DAP_fmCaliber_shouldReportHeavy    = true;   // true = Heavy artillery/mortar reports each action via side command channel / false = No reports / Default: true;
	DAP_fmCaliber_shouldReportSuperH   = true;   // true = Super Heavy artillery/mortar reports each action via side command channel / false = No reports / Default: true;
	DAP_fmCaliber_shouldReportCombined = true;   // true = Combined mode (all calibers) reports each action via side command channel / false = No reports / Default: true;
	DAP_artill_isInfiniteAmmo          = true;   // true = after each fire-mission cycle, the piece is magically reloaded / false = no magic / Default: true;
	DAP_artill_forcedRearm             = true;   // (WIP) true = forced rearm even for piece with barely full ammo / false = only when low or no ammo / Default: true;
	DAP_artill_preventStartNoMags      = false;  // (WIP) true = DAP prevents pieces to start with no mags (mods are bugged and it'll help) / false = Editor decides / Default: false;
	DAP_artill_preventUnlocked         = true;   // true = DAP locks for players all artillery-pieces where it's possible / false = Editor decides / Default: true;
	DAP_artill_preventMoving           = true;   // true = DAP prevents piece self-propelled to change its position / false = Arma decides (NOT RECOMMENDED) / Default: true;
	DAP_artill_preventDynamicSim       = true;   // true = DAP prevents pieces to freeze at big distances / false = doesn't prevent (NOT RECOMMENDED) / Default: true;
	DAP_artill_isForcedThermalSignat   = false;  // (WIP) true = force DAP pieces emit heat signature, even if engines off / false = Arma decides / Default: false;
	DAP_artill_editableByZeus          = false;  // true = (or DAP_debug_isOn true) all DAP pieces are editable by Zeus / false = Not editable / Default: false;
	DAP_fmCaliber_timeRearmLight       = 30;   // in seconds, reload time for MRL light caliber. Minimal 15 / Default 30;
	DAP_fmCaliber_timeRearmMedium      = 60;   // in seconds, reload time for MRL medium caliber. Minimal 30 / Default 60;
	DAP_fmCaliber_timeRearmHeavy       = 120;  // in seconds, reload time for MRL heavy caliber. Minimal 60 / Default 120;
	DAP_fmCaliber_timeRearmSuperH      = 240;  // in seconds, reload time for MRL super heavy caliber. Minimal 120 / Default 240;
	
// Server:
	DAP_fmVirtualETA        = selectRandom [30, 38, 45];  // In secs, simulates the Estimated Time to Arrival from (if) virtual rounds. Default: selectRandom [30, 38, 45];
	DAP_fireMissionBreath   = 5;     // In seconds, time you give to the server reads each fire-mission. More secs save performance. Never lower than 2. Default: 5;
	DAP_wait                = 5;     // In seconds, If you need to make DAP waits more for other scripts load first, set a delay in seconds. Default: 5;

// Library of Known Artillery Pieces:
	// Below, all howitzers, multiple rocket launchers and mortars from: Arma 3, DLC Apex, DLC Contact, DLC Tanks, CDLC Western Sahara, CDLC Reaction Forces, CDLC Global Mobilization, CDLC Expeditionary Forces, Mod RHS, and Mod CUP. Fell free to add more, respecting their classes and subclasses. Check DAP documentation link on this file header.
	DAP_knownPieces_howitzer = [
		// Howitzer Light (crucial: < 123mm)
		["LIGHT",      ["RHS_M119_D","RHS_M119_WD"]],
		// Howitzer Medium (crucial: >= 123mm, < 160mm)
		["MEDIUM",     ["B_D_MBT_01_arty_lxWS","gm_ge_army_m109g","gm_dk_army_m109","gm_gc_army_2s1","gm_pl_army_2s1","rhsgref_cdf_b_2s1","rhsgref_cdf_b_2s1_at","rhsgref_ins_2s1","rhsgref_ins_2s1_at","rhs_2s1_tv","rhs_2s1_at_tv","rhs_2s1_vmf","rhs_2s1_at_vmf","rhssaf_army_o_2s1","rhsgref_cdf_2s1","rhsgref_cdf_2s1_at","rhsgref_ins_g_2s1","rhsgref_ins_g_2s1_at","rhssaf_army_2s1","rhs_2s3_tv","rhsusf_m109_usarmy","rhsusf_m109d_usarmy", "O_MBT_02_arty_F","O_T_MBT_02_arty_ghex_F","B_MBT_01_arty_F","B_T_MBT_01_arty_F","rhs_D30_msv","rhs_D30_vdv","rhs_D30_vmf","rhsgref_ins_d30","rhsgref_cdf_b_reg_d30","rhssaf_army_o_d30","rhsgref_cdf_reg_d30","rhsgref_ins_g_d30","rhsgref_nat_d30","rhssaf_army_d30"]],
		// Howitzer Heavy (crucial: >= 160mm, < 300mm)
		["HEAVY",      []],
		// Howitzer Super Heavy (crucial: >= 300mm)
		["SUPERHEAVY", []]
	];
	DAP_knownPieces_mrl = [
		// Multiple Rocket Launcher Light (crucial: < 123mm)
		["LIGHT",      ["I_G_Pickup_mrl_rf","O_G_Pickup_mrl_rf","B_G_Pickup_mrl_rf","I_C_Pickup_mrl_rf","rhsgref_cdf_b_reg_BM21","rhsgref_ins_BM21","RHS_BM21_MSV_01","RHS_BM21_VMF_01","RHS_BM21_VV_01","rhsgref_cdf_reg_BM21","rhsgref_ins_g_BM21","CUP_B_RM70_CZ","CUP_B_BM21_AFU","CUP_B_BM21_CDF","CUP_O_BM21_RU","CUP_O_BM21_CHDKZ","CUP_O_BM21_SLA","CUP_O_BM21_TKA"]],
		// Multiple Rocket Launcher Medium (crucial: >= 123mm, < 160mm)
		["MEDIUM",     ["B_D_MBT_01_mlrs_lxWS","O_SFIA_Truck_02_MRL_lxWS"]],
		// Multiple Rocket Launcher Heavy (crucial: >= 160mm, < 300mm)
		["HEAVY",      ["rhsusf_M142_usmc_WD","rhsusf_M142_usarmy_WD","rhsusf_M142_usarmy_D","CUP_B_M270_DPICM_BAF_WOOD","CUP_B_M270_DPICM_BAF_DES","CUP_B_M270_HE_BAF_DES","CUP_B_M270_HE_BAF_WOOD","CUP_B_M270_DPICM_HIL","CUP_B_M270_HE_HIL","CUP_B_M270_DPICM_USA","CUP_B_M270_HE_USA","CUP_B_M270_DPICM_USMC","CUP_B_M270_HE_USMC","CUP_I_M270_DPICM_AAF","CUP_I_M270_HE_AAF","CUP_I_M270_DPICM_RACS","CUP_I_M270_HE_RACS"]],
		// Multiple Rocket Launcher Super Heavy (crucial: >= 300mm)
		["SUPERHEAVY", ["I_Truck_02_MRL_F","I_E_Truck_02_MRL_F","B_MBT_01_mlrs_F","B_T_MBT_01_mlrs_F","EF_B_MBT_01_mlrs_MJTF_Wdl","EF_B_MBT_01_mlrs_MJTF_Des"]]
	];
	DAP_knownPieces_mortar = [
		// Mortar Light (crucial: < 123mm)
		["LIGHT",      ["B_G_Mortar_01_F","B_Mortar_01_F","B_D_Mortar_01_lxWS","B_T_Mortar_01_F","B_Tura_Mortar_lxWS","O_Mortar_01_F","O_G_Mortar_01_F","O_SFIA_Mortar_lxWS","O_Tura_Mortar_lxWS","I_Mortar_01_F","I_G_Mortar_01_F","I_E_Mortar_01_F","I_Tura_Mortar_lxWS","B_D_APC_Wheeled_01_mortar_lxWS","B_APC_Wheeled_01_mortar_lxWS","B_T_APC_Wheeled_01_mortar_lxWS","B_D_CTRG_CommandoMortar_RF","B_G_CommandoMortar_RF","B_CommandoMortar_RF","O_CommandoMortar_RF","O_G_CommandoMortar_RF","I_CommandoMortar_RF","I_G_CommandoMortar_RF","I_E_CommandoMortar_RF","EF_B_Mortar_01_MJTF_Wdl","EF_B_Mortar_01_MJTF_Des","rhssaf_army_m252","rhsgref_cdf_reg_M252","rhssaf_army_o_m252","RHS_M252_WD","RHS_M252_USMC_D","RHS_M252_USMC_WD","rhsgref_cdf_b_reg_M252","rhs_2b14_82mm_vmf","rhs_2b14_82mm_vdv","RHS_M252_D","CUP_I_M252_RACS","CUP_B_M252_HIL","CUP_B_M252_US","CUP_B_M252_USMC","CUP_B_L16A2_BAF_DDPM","CUP_B_L16A2_BAF_MPT","CUP_B_L16A2_BAF_WDL","rhs_2b14_82mm_msv","rhsgref_tla_g_2b14","rhsgref_nat_2b14","rhsgref_ins_g_2b14","rhsgref_tla_2b14","rhsgref_ins_2b14","CUP_I_2b14_82mm_TK_GUE","CUP_I_2b14_82mm_NAPA","CUP_B_2b14_82mm_AFU","CUP_B_2b14_82mm_ACR","CUP_B_2b14_82mm_CDF"]],
		// Mortar Medium (crucial: >= 123mm, < 160mm)
		["MEDIUM",     ["CUP_B_M1129_MC_MK19_Desert","CUP_B_M1129_MC_MK19_Woodland","B_TwinMortar_RF","B_T_TwinMortar_RF","I_TwinMortar_RF"]],
		// Mortar Heavy (crucial: <= 160mm, < 300mm)
		["HEAVY",      []],
		// Mortar Super Heavy (crucial: > 300mm)
		["SUPERHEAVY", []]
	];
	// These vehicles and equipments have features that meant to be part of DAP but for any reason are bugged or conflicting DAP dynamics:
	DAP_pieces_forbidden = ["CUP_B_FV432_Mortar","gm_ge_army_kat1_463_mlrs","gm_pl_army_ural375d_mlrs","gm_gc_army_ural375d_mlrs","gm_pl_army_2p16","gm_gc_army_2p16","rhsgref_cdf_b_reg_d30_at","rhsgref_ins_d30_at","rhs_D30_at_msv","rhs_D30_at_vdv","rhs_D30_at_vmf","rhsgref_cdf_reg_d30_at","rhsgref_ins_g_d30_at","rhsgref_nat_d30_at","rhs_2s3_at_tv","rhs_9k79","rhs_9k79_K","rhs_9k79_B"];

// Library of Known Magazines (ammo):
	// Below, almost or all magazines used by artillery and mortar in: Arma 3, DLC Apex, DLC Contact, DLC Tanks, CDLC Western Sahara, CDLC Reaction Forces, CDLC Global Mobilization, CDLC Expeditionary Forces, Mod RHS, and Mod CUP. Fell free to add more, respecting their types and what will use them. Check DAP documentation link on this file header.
	DAP_knownMagazines_howitzer = [
		["HE",              ["32Rnd_155mm_Mo_shells","32Rnd_155mm_Mo_shells_O","gm_28Rnd_122x447mm_he_of462","rhs_mag_155mm_m795_28","rhs_mag_3of56_10","RHS_mag_m1_he_12","rhs_mag_3of56_35"]],
		["GUIDED",          ["2Rnd_155mm_Mo_guided","4Rnd_155mm_Mo_guided","4Rnd_155mm_Mo_guided_O"]],
		["GUIDED_LASER",    ["2Rnd_155mm_Mo_LG","4Rnd_155mm_Mo_LG","4Rnd_155mm_Mo_LG_O","rhs_mag_155mm_m712_2","rhs_mag_3of69m_2"]],
		["CLUSTER",         ["2Rnd_155mm_Mo_Cluster","2Rnd_155mm_Mo_Cluster_O","rhs_mag_155mm_m864_3"]],
		["CLUSTER_MINE_AP", ["6Rnd_155mm_Mo_mine","6Rnd_155mm_Mo_mine_O"]],
		["CLUSTER_MINE_AT", ["6Rnd_155mm_Mo_AT_mine","6Rnd_155mm_Mo_AT_mine_O"]],
		["SMOKE",           ["6Rnd_155mm_Mo_smoke","6Rnd_155mm_Mo_smoke_O","gm_4Rnd_155mm_smoke_m110","gm_9Rnd_122x447mm_smoke_d462","rhs_mag_155mm_m825a1_2","rhs_mag_d462_2","rhs_mag_m60a2_smoke_4"]],
		["FLARE",           ["gm_4Rnd_155mm_illum_m485","rhs_mag_155mm_485_2","rhs_mag_s463_2","rhs_mag_m314_ilum_4"]]
	];
	DAP_knownMagazines_mrl = [
		["HE",              ["12Rnd_230mm_rockets","14Rnd_80mm_rockets_rf","rhs_mag_m31_6","rhs_mag_mgm168_block4_1","rhs_mag_m21of_1","rhs_mag_9m28f_1","rhs_mag_9m521_1","rhs_mag_9m522_1","CUP_40Rnd_GRAD_HE","CUP_12Rnd_MLRS_HE"]],
		["GUIDED",          []],
		["GUIDED_LASER",    []],
		["CLUSTER",         ["12Rnd_230mm_rockets_cluster","rhs_mag_m26a1_6","rhs_mag_m30_6","rhs_mag_mgm140a_1","rhs_mag_mgm140b_1","rhs_mag_9m218_1","CUP_12Rnd_MLRS_DPICM"]],
		["CLUSTER_MINE_AP", []],
		["CLUSTER_MINE_AT", []],
		["SMOKE",           []],
		["FLARE",           []]
	];
	DAP_knownMagazines_mortar = [
		["HE",              ["8Rnd_82mm_Mo_shells","rhs_12Rnd_m821_HE","rhs_mag_3vo18_10","CUP_32Rnd_120mm_HE_M934"]],
		["GUIDED",          ["8Rnd_82mm_Mo_guided"]],
		["GUIDED_LASER",    ["8Rnd_82mm_Mo_LG"]],
		["CLUSTER",         []],
		["CLUSTER_MINE_AP", []],
		["CLUSTER_MINE_AT", []],
		["SMOKE",           ["8Rnd_82mm_Mo_Smoke_white","CUP_6Rnd_120mm_Smoke_M929"]],
		["FLARE",           ["8Rnd_82mm_Mo_Flare_white","rhs_mag_3vs25m_10","rhs_mag_d832du_10"]]
	];
	// These magazines are bugged or conflicting with DAP dynamics:
	DAP_maganizes_forbidden = ["rhs_mag_bk13_5","rhs_mag_155mm_raams_1","rhs_mag_155mm_m731_1","rhs_mag_9m28k_1","rhs_mag_m26_6","gm_3Rnd_122x447mm_heat_t_bk13","gm_40Rnd_mlrs_122mm_he_9m22u","gm_36Rnd_mlrs_110mm_he_dm21","gm_1Rnd_luna_he_3r9"];

// Codenames for fire-missions (fill free to custom):
	DAP_firemissions_codenames = [
		// Blufor codenames
		["NEWYORK","LONDON","TOKYO","PARIS","CAEN","VALENCIA","HONGKONG","SINGAPORE","LOSANGELES","BEIJING","SHANGHAI","DUBAI","MUMBAI","SEOUL","SYDNEY","SANFRANCISCO","MOSCOW","BERLIN","MADRID","TORONTO","CHICAGO","ISTANBUL","BANGKOK","KUALALUMPUR","BUENOSAIRES","SAOPAULO","MEXICOCITY","JOHANNESBURG","ROME","MELBOURNE","JAKARTA","CAIRO","DELHI","SHENZHEN","GUANGZHOU","VIENNA","ZURICH","MUNICH","AMSTERDAM","GENEVA","HOUSTON","ABUDHABI","WASHINGTON","BOSTON","MIAMI","BARCELONA","STOCKHOLM","COPENHAGEN","DUBLIN","OSLO","BRUSSELS","FRANKFURT","PRAGUE","BRNO","WARSAW","BUDAPEST","HELSINKI","LISBON","ATHENS","TELAVIV","DOHA","RIYADH","MANILA","CHENNAI","BANGALORE","CAPETOWN","DURBAN","LAGOS","CASABLANCA","ADDISABABA","NAIROBI","HANOI","TAIPEI","KOLKATA","KARACHI","TEHRAN","BAGHDAD","DAMASCUS","RABAT","ALGIERS","ANKARA","BUCHAREST","SOFIA","BELGRADE","LIMA","SANTIAGO","BOGOTA","RIO","MONTEVIDEO","ASUNCION","QUITO","CARACAS","HAVANA","PANAMACITY","SANJOSE","KINGSTON","LAPAZ","SANTACRUZ","SANSALVADOR","GUATEMALACITY","TEGUCIGALPA","PORTOALEGRE","CHARQUEADAS","TBILISI","MILAN","SANREMO","BASTOGNE","MEDELLIN"],
		// Opfor codenames
		["NEWYORK","LONDON","TOKYO","PARIS","CAEN","VALENCIA","HONGKONG","SINGAPORE","LOSANGELES","BEIJING","SHANGHAI","DUBAI","MUMBAI","SEOUL","SYDNEY","SANFRANCISCO","MOSCOW","BERLIN","MADRID","TORONTO","CHICAGO","ISTANBUL","BANGKOK","KUALALUMPUR","BUENOSAIRES","SAOPAULO","MEXICOCITY","JOHANNESBURG","ROME","MELBOURNE","JAKARTA","CAIRO","DELHI","SHENZHEN","GUANGZHOU","VIENNA","ZURICH","MUNICH","AMSTERDAM","GENEVA","HOUSTON","ABUDHABI","WASHINGTON","BOSTON","MIAMI","BARCELONA","STOCKHOLM","COPENHAGEN","DUBLIN","OSLO","BRUSSELS","FRANKFURT","PRAGUE","BRNO","WARSAW","BUDAPEST","HELSINKI","LISBON","ATHENS","TELAVIV","DOHA","RIYADH","MANILA","CHENNAI","BANGALORE","CAPETOWN","DURBAN","LAGOS","CASABLANCA","ADDISABABA","NAIROBI","HANOI","TAIPEI","KOLKATA","KARACHI","TEHRAN","BAGHDAD","DAMASCUS","RABAT","ALGIERS","ANKARA","BUCHAREST","SOFIA","BELGRADE","LIMA","SANTIAGO","BOGOTA","RIO","MONTEVIDEO","ASUNCION","QUITO","CARACAS","HAVANA","PANAMACITY","SANJOSE","KINGSTON","LAPAZ","SANTACRUZ","SANSALVADOR","GUATEMALACITY","TEGUCIGALPA","PORTOALEGRE","CHARQUEADAS","TBILISI","MILAN","SANREMO","BASTOGNE","MEDELLIN"],
		// Independent codenames
		["NEWYORK","LONDON","TOKYO","PARIS","CAEN","VALENCIA","HONGKONG","SINGAPORE","LOSANGELES","BEIJING","SHANGHAI","DUBAI","MUMBAI","SEOUL","SYDNEY","SANFRANCISCO","MOSCOW","BERLIN","MADRID","TORONTO","CHICAGO","ISTANBUL","BANGKOK","KUALALUMPUR","BUENOSAIRES","SAOPAULO","MEXICOCITY","JOHANNESBURG","ROME","MELBOURNE","JAKARTA","CAIRO","DELHI","SHENZHEN","GUANGZHOU","VIENNA","ZURICH","MUNICH","AMSTERDAM","GENEVA","HOUSTON","ABUDHABI","WASHINGTON","BOSTON","MIAMI","BARCELONA","STOCKHOLM","COPENHAGEN","DUBLIN","OSLO","BRUSSELS","FRANKFURT","PRAGUE","BRNO","WARSAW","BUDAPEST","HELSINKI","LISBON","ATHENS","TELAVIV","DOHA","RIYADH","MANILA","CHENNAI","BANGALORE","CAPETOWN","DURBAN","LAGOS","CASABLANCA","ADDISABABA","NAIROBI","HANOI","TAIPEI","KOLKATA","KARACHI","TEHRAN","BAGHDAD","DAMASCUS","RABAT","ALGIERS","ANKARA","BUCHAREST","SOFIA","BELGRADE","LIMA","SANTIAGO","BOGOTA","RIO","MONTEVIDEO","ASUNCION","QUITO","CARACAS","HAVANA","PANAMACITY","SANJOSE","KINGSTON","LAPAZ","SANTACRUZ","SANSALVADOR","GUATEMALACITY","TEGUCIGALPA","PORTOALEGRE","CHARQUEADAS","TBILISI","MILAN","SANREMO","BASTOGNE","MEDELLIN"]
	];







// DAP CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
// When the mission starts:
[] spawn {
	// Local object declarations:
	private ["_knownPiecesAll","_knownMagsAll","_confirmedPieces","_confirmedMkrs"];
	// Initial values:
	DAP_targetMrksBLU = [];
	DAP_targetMrksOPF = [];
	DAP_targetMrksIND = [];
	DAP_assemblyFree         = [true,true,true];  // blu, opf, ind
	DAP_impactMrksForPlayers = [[/* blu */],[/* opf */],[/* ind */]];
	DAP_fmScheduled          = [[/* blu */],[/* opf */],[/* ind */]];
	DAP_piecesNeedRearm      = [[/* blu */],[/* opf */],[/* ind */]];
	DAP_groupIdsForDisbanded = [[/* blu */],[/* opf */],[/* ind */]];
	// Declarations - part 1/2:
	DAP_fmVisible_type = ["mil_destroy","hd_destroy"];
	DAP_txtDebugHeader = toUpper "DAP DEBUG >";
	DAP_txtWarnHeader  = toUpper "DAP WARNING >";
	DAP_prefix         = toUpper "DAP";  // CAUTION: NEVER include/insert the DAP_spacer character as part of the DAP_prefix too.
	DAP_spacer         = toUpper "_";    // CAUTION: try do not change it!
	// Global escape:
	if !DAP_isOn exitWith {publicVariable "DAP_isOn"; publicVariable "DAP_debug_isOn"; publicVariable "DAP_prefix"; publicVariable "DAP_spacer"; if DAP_debug_isOn then {systemChat format ["%1 The %2 script was turned off manually through 'fn_DAP_management.sqf' file.", DAP_txtWarnHeader, DAP_prefix]}};
	if (DAP_isOn && !DAP_BLU_isOn && !DAP_OPF_isOn && !DAP_IND_isOn) exitWith {DAP_isOn=false; publicVariable "DAP_isOn"; publicVariable "DAP_debug_isOn"; publicVariable "DAP_prefix"; publicVariable "DAP_spacer"; systemChat format ["%1 You turned off all sides but you're keeping the 'DAP_isOn' as 'true' in fn_DAP_management.sqf file. To fix it, turn one or more sides 'true', or turn the 'DAP_isOn' to 'false'. The %2 stopped automatically!", DAP_txtWarnHeader, DAP_prefix]};
	// Declarations - part 2/2:
	DAP_piecesCaliber_light =
		// Pieces Light
		((DAP_knownPieces_howitzer # 0) # 1) +  // Pieces Howitzer type
		((DAP_knownPieces_mrl      # 0) # 1) +  // Pieces Multiple Rocket Launcher type
		((DAP_knownPieces_mortar   # 0) # 1);   // Pieces Mortar type
	DAP_piecesCaliber_medium =
		// Pieces Medium
		((DAP_knownPieces_howitzer # 1) # 1) +
		((DAP_knownPieces_mrl      # 1) # 1) +
		((DAP_knownPieces_mortar   # 1) # 1);
	DAP_piecesCaliber_heavy =
		// Pieces Heavy
		((DAP_knownPieces_howitzer # 2) # 1) +
		((DAP_knownPieces_mrl      # 2) # 1) +
		((DAP_knownPieces_mortar   # 2) # 1);
	DAP_piecesCaliber_superHeavy =
		// Pieces Super Heavy
		((DAP_knownPieces_howitzer # 3) # 1) +
		((DAP_knownPieces_mrl      # 3) # 1) +
		((DAP_knownPieces_mortar   # 3) # 1);
	DAP_mags_he = 
		// Mags High Explosive
		((DAP_knownMagazines_howitzer # 0) # 1) +  // Ammo Howitzer
		((DAP_knownMagazines_mrl      # 0) # 1) +  // Ammo Multiple Rocket Launcher
		((DAP_knownMagazines_mortar   # 0) # 1);   // Ammo Mortar
	DAP_mags_guided = 
		// Mags Guided
		((DAP_knownMagazines_howitzer # 1) # 1) +
		((DAP_knownMagazines_mrl      # 1) # 1) +
		((DAP_knownMagazines_mortar   # 1) # 1);
	DAP_mags_guided_laser = 
		// Mags Laser Guided
		((DAP_knownMagazines_howitzer # 2) # 1) +
		((DAP_knownMagazines_mrl      # 2) # 1) +
		((DAP_knownMagazines_mortar   # 2) # 1);
	DAP_mags_cluster = 
		// Mags Cluster
		((DAP_knownMagazines_howitzer # 3) # 1) +
		((DAP_knownMagazines_mrl      # 3) # 1) +
		((DAP_knownMagazines_mortar   # 3) # 1);
	DAP_mags_cluster_mine_ap = 
		// Mags Cluster Mine
		((DAP_knownMagazines_howitzer # 4) # 1) +
		((DAP_knownMagazines_mrl      # 4) # 1) +
		((DAP_knownMagazines_mortar   # 4) # 1);
	DAP_mags_cluster_mine_at = 
		// Mags Cluster Anti-Tank
		((DAP_knownMagazines_howitzer # 5) # 1) +
		((DAP_knownMagazines_mrl      # 5) # 1) +
		((DAP_knownMagazines_mortar   # 5) # 1);
	DAP_mags_smoke = 
		// Mags Smoke
		((DAP_knownMagazines_howitzer # 6) # 1) +
		((DAP_knownMagazines_mrl      # 6) # 1) +
		((DAP_knownMagazines_mortar   # 6) # 1);
	DAP_mags_flare = 
		// Mags Flare
		((DAP_knownMagazines_howitzer # 7) # 1) +
		((DAP_knownMagazines_mrl      # 7) # 1) +
		((DAP_knownMagazines_mortar   # 7) # 1);
	_knownPiecesAll = DAP_piecesCaliber_light + DAP_piecesCaliber_medium + DAP_piecesCaliber_heavy + DAP_piecesCaliber_superHeavy;
	_knownMagsAll   = DAP_mags_he + DAP_mags_guided + DAP_mags_guided_laser + DAP_mags_cluster + DAP_mags_cluster_mine_ap + DAP_mags_cluster_mine_at + DAP_mags_smoke + DAP_mags_flare;
	
	// Debug txts:
		// Reserved space.
	// Main validations:
	if !(DAP_spacer in ["_", "-"]) exitWith { DAP_isOn = false; publicVariable "DAP_isOn"; publicVariable "DAP_targetMrksBLU"; publicVariable "DAP_targetMrksOPF"; publicVariable "DAP_targetMrksIND"; systemChat format ["%1 You have changed the 'DAP_spacer' and will broken some DAP logic that I couldn't turn around yet. Please, consider to use one of these as spacer: _ or -", DAP_txtWarnHeader]; systemChat format ["%1 The script stopped automatically!", DAP_txtWarnHeader]};
	// Needed here before THY_fnc_DAP_pieces_scanner:
	if (DAP_BLU_name isEqualTo "") then {DAP_BLU_name = "BLU FIRE SUPPORT"} else {DAP_BLU_name = toUpper DAP_BLU_name}; if (DAP_OPF_name isEqualTo "") then {DAP_OPF_name = "OPF FIRE SUPPORT"} else {DAP_OPF_name = toUpper DAP_OPF_name}; if (DAP_IND_name isEqualTo "") then {DAP_IND_name = "IND FIRE SUPPORT"} else {DAP_IND_name = toUpper DAP_IND_name}; 
	_confirmedPieces = [DAP_prefix, DAP_spacer] call THY_fnc_DAP_pieces_scanner;
	DAP_piecesBLU = (_confirmedPieces # 0) # 0; DAP_piecesOPF = (_confirmedPieces # 1) # 0; DAP_piecesIND = (_confirmedPieces # 2) # 0;
	// Escape > If no artillery pieces, abort (deprecated after virtual artillery implementation in v1.5):
	//if (count (DAP_piecesBLU + DAP_piecesOPF + DAP_piecesIND) isEqualTo 0) exitWith { DAP_isOn = false; publicVariable "DAP_isOn"; systemChat format ["%1 No specific artillery pieces available on the mission. The script stopped automatically!", DAP_txtWarnHeader]};
	_confirmedMkrs = [DAP_prefix, DAP_spacer] call THY_fnc_DAP_marker_scanner;
	DAP_targetMrksBLU = (_confirmedMkrs # 0) # 0; DAP_targetMrksOPF = (_confirmedMkrs # 1) # 0; DAP_targetMrksIND = (_confirmedMkrs # 2) # 0;
	// Escape > If no confirmed markers, abort:
	if (count (DAP_targetMrksBLU + DAP_targetMrksOPF + DAP_targetMrksIND) isEqualTo 0) exitWith { DAP_isOn = false; publicVariable "DAP_isOn"; publicVariable "DAP_targetMrksBLU"; publicVariable "DAP_targetMrksOPF"; publicVariable "DAP_targetMrksIND"; systemChat format ["%1 No target-markers on the mission. The script stopped automatically!", DAP_txtWarnHeader]};
	// Handling errors:
	if (DAP_wait < 1) then {DAP_wait = 1}; if DAP_debug_isOn then {if (DAP_debug_readTime < 0.5 || DAP_debug_readTime > 5) then {DAP_debug_readTime=1;systemChat format["%1 DEBUG SETUP > 'DAP_debug_readTime' CANNOT be lower than 0.5 or greater than 5 secs. The default value (%2) was restored.", DAP_txtWarnHeader, DAP_debug_readTime]}};
	if (DAP_fireMissionBreath < 2) then {DAP_fireMissionBreath=2; if DAP_debug_isOn then {systemChat format ["%1 'DAP_fireMissionBreath' CANNOT be set lower than %2s. DAP automatically changed it to the lowest value possible: (%2).", DAP_txtDebugHeader, DAP_fireMissionBreath]}}; DAP_fmVirtualETA = abs (round DAP_fmVirtualETA);
	// Escape > If an error that compromises the DAP consistency take place:
	if ([_knownPiecesAll, _knownMagsAll, DAP_pieces_forbidden, DAP_maganizes_forbidden, DAP_txtWarnHeader] call THY_fnc_DAP_initial_validation) exitWith { DAP_isOn = false; publicVariable "DAP_isOn"; publicVariable "DAP_targetMrksBLU"; publicVariable "DAP_targetMrksOPF"; publicVariable "DAP_targetMrksIND"; systemChat format ["%1 The script stopped automatically!", DAP_txtWarnHeader]};
	// Using debug mode:
	if DAP_debug_isOn then {
		if ( DAP_wait > 10 ) then { systemChat format ["%1 Don't forget the DAP is configurated to delay %2 seconds before to starts its tasks.", DAP_txtDebugHeader, DAP_wait] }; if ( DAP_fireMissionBreath >= 60 ) then { systemChat format ["%1 Don't forget the DAP is set to delay %2 secs between each fire-mission task. Default is 10.", DAP_txtDebugHeader, DAP_fireMissionBreath] }; DAP_fmCaliber_timeRearmLight = abs DAP_fmCaliber_timeRearmLight; DAP_fmCaliber_timeRearmMedium = abs DAP_fmCaliber_timeRearmMedium; DAP_fmCaliber_timeRearmHeavy = abs DAP_fmCaliber_timeRearmHeavy; DAP_fmCaliber_timeRearmSuperH = abs DAP_fmCaliber_timeRearmSuperH;
	} else {
		// After leave the debug mode:
		if (DAP_fmCaliber_timeRearmLight < 15) then {DAP_fmCaliber_timeRearmLight=15; systemChat format ["%1 AMMO LOGISTIC > 'DAP_fmCaliber_timeRearmLight' CANNOT be lower than the minimal value (%2) out of the Debug Mode. For now, DAP changed to the minimal until you fix it.", DAP_txtWarnHeader, DAP_fmCaliber_timeRearmLight]}; if (DAP_fmCaliber_timeRearmMedium < 30) then {DAP_fmCaliber_timeRearmMedium=30; systemChat format ["%1 AMMO LOGISTIC > 'DAP_fmCaliber_timeRearmMedium' CANNOT be lower than the minimal value (%2) out of the Debug Mode. For now, DAP changed to the minimal until you fix it.", DAP_txtWarnHeader, DAP_fmCaliber_timeRearmMedium]}; if (DAP_fmCaliber_timeRearmHeavy < 60) then {DAP_fmCaliber_timeRearmHeavy=60; systemChat format ["%1 AMMO LOGISTIC > 'DAP_fmCaliber_timeRearmHeavy' CANNOT be lower than the minimal value (%2) out of the Debug Mode. For now, DAP changed to the minimal until you fix it.", DAP_txtWarnHeader, DAP_fmCaliber_timeRearmHeavy]}; if (DAP_fmCaliber_timeRearmSuperH < 120) then {DAP_fmCaliber_timeRearmSuperH=120; systemChat format ["%1 AMMO LOGISTIC > 'DAP_fmCaliber_timeRearmSuperH' CANNOT be lower than the minimal value (%2) out of the Debug Mode. For now, DAP changed to the minimal until you fix it.", DAP_txtWarnHeader, DAP_fmCaliber_timeRearmSuperH]};
	};
	// Debug markers stylish:
	if DAP_debug_isOn then {
		// Visibility and colors:
		{ _x setMarkerAlpha 1; _x setMarkerColor "colorBLUFOR"      } forEach DAP_targetMrksBLU;
		{ _x setMarkerAlpha 1; _x setMarkerColor "colorOPFOR"       } forEach DAP_targetMrksOPF;
		{ _x setMarkerAlpha 1; _x setMarkerColor "colorIndependent" } forEach DAP_targetMrksIND;
	// Otherwise, hiding the DAP markers:
	} else { {_x setMarkerAlpha 0} forEach DAP_targetMrksBLU + DAP_targetMrksOPF + DAP_targetMrksIND };
	// Delete the useless DAP markers dropped on Eden:
	if !DAP_BLU_isOn then { { deleteMarker _x } forEach DAP_targetMrksBLU };
	if !DAP_OPF_isOn then { { deleteMarker _x } forEach DAP_targetMrksOPF };
	if !DAP_IND_isOn then { { deleteMarker _x } forEach DAP_targetMrksIND };
	// Broadcasting public variables:
	publicVariable "DAP_isOn"; publicVariable "DAP_prefix"; publicVariable "DAP_spacer"; publicVariable "DAP_debug_isOn"; publicVariable "DAP_fmVisible_isOnMap"; publicVariable "DAP_impactMrksForPlayers"; publicVariable "DAP_debug_isOnAmmo"; publicVariable "DAP_debug_isOnTeamCheck"; publicVariable "DAP_debug_isOnSectors"; publicVariable "DAP_debug_readTime"; publicVariable "DAP_BLU_isOn"; publicVariable "DAP_BLU_name"; publicVariable "DAP_OPF_isOn"; publicVariable "DAP_OPF_name"; publicVariable "DAP_IND_isOn"; publicVariable "DAP_IND_name";  publicVariable "DAP_fmVisible_type"; publicVariable "DAP_fmVisible_alpha"; publicVariable "DAP_fmCaliber_shouldReportLight"; publicVariable "DAP_fmCaliber_shouldReportMedium"; publicVariable "DAP_fmCaliber_shouldReportHeavy"; publicVariable "DAP_fmCaliber_shouldReportSuperH"; publicVariable "DAP_fmCaliber_shouldReportCombined"; publicVariable "DAP_artill_isInfiniteAmmo"; publicVariable "DAP_artill_forcedRearm"; publicVariable "DAP_artill_preventStartNoMags"; publicVariable "DAP_artill_preventUnlocked"; publicVariable "DAP_artill_preventMoving"; publicVariable "DAP_artill_preventDynamicSim"; publicVariable "DAP_artill_isForcedThermalSignat"; publicVariable "DAP_artill_editableByZeus"; publicVariable "DAP_fmCaliber_timeRearmLight"; publicVariable "DAP_fmCaliber_timeRearmMedium"; publicVariable "DAP_fmCaliber_timeRearmHeavy"; publicVariable "DAP_fmCaliber_timeRearmSuperH"; publicVariable "DAP_fmVirtualETA"; publicVariable "DAP_fireMissionBreath"; publicVariable "DAP_wait"; publicVariable "DAP_knownPieces_howitzer"; publicVariable "DAP_knownPieces_mrl"; publicVariable "DAP_knownPieces_mortar"; publicVariable "DAP_pieces_forbidden"; publicVariable "DAP_knownMagazines_howitzer"; publicVariable "DAP_knownMagazines_mrl"; publicVariable "DAP_knownMagazines_mortar"; publicVariable "DAP_maganizes_forbidden"; publicVariable "DAP_firemissions_codenames"; publicVariable "DAP_txtDebugHeader"; publicVariable "DAP_txtWarnHeader";  publicVariable "DAP_piecesCaliber_light"; publicVariable "DAP_piecesCaliber_medium"; publicVariable "DAP_piecesCaliber_heavy"; publicVariable "DAP_piecesCaliber_superHeavy"; publicVariable "DAP_mags_he"; publicVariable "DAP_mags_guided"; publicVariable "DAP_mags_guided_laser"; publicVariable "DAP_mags_cluster"; publicVariable "DAP_mags_cluster_mine_ap"; publicVariable "DAP_mags_cluster_mine_at"; publicVariable "DAP_mags_smoke"; publicVariable "DAP_mags_flare"; publicVariable "DAP_piecesBLU"; publicVariable "DAP_piecesOPF"; publicVariable "DAP_piecesIND"; publicVariable "DAP_targetMrksBLU"; publicVariable "DAP_targetMrksOPF"; publicVariable "DAP_targetMrksIND"; publicVariable "DAP_assemblyFree";  publicVariable "DAP_fmScheduled"; publicVariable "DAP_piecesNeedRearm"; publicVariable "DAP_groupIdsForDisbanded";
	// Debug:
	if DAP_debug_isOn then {
		// If the specific side is ON and has at least 1 spawnpoint:
		if ( DAP_BLU_isOn && count DAP_targetMrksBLU > 0 && count DAP_piecesBLU > 0 ) then {
			// Message:
			systemChat format ["%1 %2 got %3 real artillery-piece(s) ready for %4 target-marker(s).",
			DAP_txtDebugHeader, DAP_BLU_name, count DAP_piecesBLU, count DAP_targetMrksBLU];
		};
		// If the specific side is ON and has at least 1 spawnpoint:
		if ( DAP_OPF_isOn && count DAP_targetMrksOPF > 0 && count DAP_piecesOPF > 0 ) then {
			// Message:
			systemChat format ["%1 %2 got %3 real artillery-piece(s) ready for %4 target-marker(s).",
			DAP_txtDebugHeader, DAP_OPF_name, count DAP_piecesOPF, count DAP_targetMrksOPF];
		};
		// If the specific side is ON and has at least 1 spawnpoint:
		if ( DAP_IND_isOn && count DAP_targetMrksIND > 0 && count DAP_piecesIND > 0 ) then {
			// Message:
			systemChat format ["%1 %2 got %3 real artillery-piece(s) ready for %4 target-marker(s).",
			DAP_txtDebugHeader, DAP_IND_name, count DAP_piecesIND, count DAP_targetMrksIND];
		};
	};
	// Debug monitor looping:
	while { DAP_debug_isOn } do { call THY_fnc_DAP_debug };
};  // spawn ends.
// Return:
true;
