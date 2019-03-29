
//calculate gun traverse and elevation
AMP_calc_doorgun = {
	onEachFrame {
		private _h = vehicle player;
		//camera vector
		private _vc = (_h worldToModelVisual (positionCameraToWorld [0, 0, 0])) vectorFromTo (_h worldToModelVisual (positionCameraToWorld [0, 0, 1]));
		private _vcx = _vc # 0;
		private _vcy = _vc # 1;
		private _vcz = _vc # 2;
		private _w = sqrt (_vcx^2 + _vcy^2);
		private _travdp = [0,1,0] vectorDotProduct [_vcx, _vcy, 0];
		private _travrad = rad(([-1,1] select (_vcx < 0)) * acos (_travdp/_w));
		private _elevdp = [_vcx, _vcy, 0] vectorDotProduct _vc;
		private _elevrad = rad(([1,-1] select (_vcz < 0)) * acos (_elevdp/_w));
		
		_h animateSource ["MainTurret", _travrad];
		_h animateSource ["turret_2", _travrad];
		_h animateSource ["MainGun", _elevrad];
		_h animateSource ["gun_2", _elevrad];
		
		hint format ["Trav A %1 | C %2\nElev A %3 | C %4", (_h animationPhase "MainTurret"), _travrad, (_h animationPhase "MainGun"), _elevrad];
	};
};

//draw turret directions
AMP_drawlines_doorgun = {
	onEachFrame {
		_h = vehicle player;
		private _beg = ASLToAGL getPosASL gunner _h;
		private _gunLVector = (_h weaponDirection currentWeapon _h);
		_endL = (_beg vectorAdd (_gunLVector vectorMultiply 100));
		drawLine3D [ _beg, _endL, [1,0,0,1]];
		
		private _t = deg(_h animationPhase "turret_2");
		private _e = deg(_h animationPhase "gun_2");
		_gunRVector = _h vectorModelToWorld [-(sin _t), (cos _t), tan _e];
		_beg = _h modelToWorld [1.5, 3 ,0];
		_endR = (_beg vectorAdd (_gunRVector vectorMultiply 100));
		drawLine3D [ _beg, _endR, [0,0,1,1]];
		//hint str (((getPos _h) vectorFromTo (getPos cursorTarget)) vectorCos _gunRVector);
		
		//private _aimFactors = [];
		{
			//private _isPersonTurret = _x # 4;
			//if (!_isPersonTurret) exitWith{};
			//systemChat str _x;
			private _gunner = _x # 0;
			
			_begT = ASLToAGL eyePos _gunner;
			_gunTVector = _gunner weaponDirection currentWeapon _gunner;
			_endT = (_begT vectorAdd (_gunTVector vectorMultiply 100));
			drawLine3D [ _begT, _endT, [0,1,0,1]];
			//_aimFactors pushBack (((ASLToAGL eyePos _gunner) vectorFromTo (getPos cursorTarget)) vectorCos _gunTVector);
		} forEach ((fullCrew [(vehicle player), "turret"]) select {_x # 4});
		//hint str _aimFactors;
	};
};

//command door gun fire

//create doorgun target
AMP_control_doorgun = {
	_target = createVehicle ["LaserTargetW", [0,0,0], [], 0, "CAN_COLLIDE"];
	(vehicle player) setVehicleReceiveRemoteTargets true;
	(side player) reportRemoteTarget [_target, 300];
	{
		private _gunner = _x # 0;
		_gunner setSkill 1;
		_gunner doWatch _target;
		_gunner doTarget _target;
	} forEach fullCrew [(vehicle player), "turret"];
	_handle = [
		{
			private _targetPos = screenToWorld [0.5, 0.5];
			if ((player distance _targetPos) > 1000) then {
				_targetPos = positionCameraToWorld [0, 0, 1000];
			};
			(_this # 0 # 0) setPos (screenToWorld [0.5, 0.5]);
		},
		0,
		[_target]
	] call CBA_fnc_addPerFrameHandler;
	_logic = createGroup (side player) createUnit ["Logic", [0,0,0], [], 0, "NONE"];
	player setVariable ["AMP_doorgun_info", [_target, [_handle],[],_logic]];
	[_target, [_handle], []];
};

//ai gunners aim
AMP_fire_doorgun = {
	private _AMP_doorgun_info = player getVariable ["AMP_doorgun_info", []];
	private _target = _AMP_doorgun_info # 0;
	private _logic = _AMP_doorgun_info # 3;
	{	
		private _gunner = _x # 0;
		//private _role = _x # 1;
		//private _cargoIndex = _x # 2;
		private _turretPath = _x # 3;
		private _isPersonTurret = _x # 4;
		if (_gunner isEqualTo objNull) exitWith {};
		_gunner setSkill 1;
		_gunner doWatch _target;
		_gunner doTarget _target;
		_handle = [
			{
				//private _handle = (_this # 1);
				private _gunner = (_this # 0 # 0);
				private _target = (_this # 0 # 1);
				private _turretPath = (_this # 0 # 2);
				
				if (_turretPath isEqualTo [0]) then {
					if ((_gunner aimedAtTarget [_target]) > 0.5) exitWith {_gunner fireAtTarget [_target];};
				};
				if (_turretPath isEqualTo [2]) then {
					private _heli = vehicle _gunner;
					private _t = deg(_heli animationPhase "turret_2");
					private _e = deg(_heli animationPhase "gun_2");
					_gunRVector = _heli vectorModelToWorld [-(sin _t), (cos _t), tan _e];
					private _aimFactor = (((ASLToAGL eyePos _gunner) vectorFromTo (getPos _target)) vectorCos _gunRVector);
					if (_aimFactor > 0.999) exitWith {[_heli, (_heli weaponsTurret _turretPath) # 0, _turretPath] call BIS_fnc_fire;}; 
				};
				private _isPersonTurret = (_this # 0 # 3);
				private _logic = (_this # 0 # 4);
				if _isPersonTurret then {
					_gunTVector = _gunner weaponDirection currentWeapon _gunner;
					private _aimFactor = (((ASLToAGL eyePos _gunner) vectorFromTo (getPos _target)) vectorCos _gunTVector);
					//hint str _aimFactor;
					if (_aimFactor > 0.999) exitWith {
						_logic action ["useWeapon", _gunner, _gunner, 2];
					}; 
				};
			},
			0.3,
			[_gunner, _target, _turretPath, _isPersonTurret, _logic]
		] call CBA_fnc_addPerFrameHandler;
		(_AMP_doorgun_info # 2) pushBack _handle;
	} forEach fullCrew [(vehicle player), "turret"];
	player setVariable ["AMP_doorgun_info", _AMP_doorgun_info];
	_AMP_doorgun_info
};

//ai gunner stop
AMP_hold_doorgun = {
	private _AMP_doorgun_info = player getVariable ["AMP_doorgun_info", []];
	{
		[_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_AMP_doorgun_info # 2);
	_AMP_doorgun_info set [2, []];
	player setVariable ["AMP_doorgun_info", _AMP_doorgun_info];
};

//remove scripted target
AMP_release_doorgun = {
	{
		private _gunner = _x # 0;
		_gunner doWatch objNull;
	} forEach fullCrew [(vehicle player), "turret"];
	private _AMP_doorgun_info = player getVariable ["AMP_doorgun_info", []];
	deleteVehicle (_AMP_doorgun_info # 0);
	{
		[_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_AMP_doorgun_info # 1);
	{
		[_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_AMP_doorgun_info # 2);
	private _logic = _AMP_doorgun_info # 3;
	private _logicGroup = group _logic;
	deleteVehicle _logic;
	deleteGroup _logicGroup;
	player setVariable ["AMP_doorgun_info", nil];
};

AMP_toggle_doorgun_aim = {
	private _AMP_doorgun_info = player getVariable ["AMP_doorgun_info", []];
	if (_AMP_doorgun_info isEqualTo []) then {
		call AMP_control_doorgun;
	} else {
		call AMP_release_doorgun;
	};
};

AMP_toggle_doorgun_fire = {
	private _AMP_doorgun_info = player getVariable ["AMP_doorgun_info", []];
	if (count (_AMP_doorgun_info # 2) == 0) then {
		call AMP_fire_doorgun;
	} else {
		call AMP_hold_doorgun;
	};
};



AMP_enable_doorgun = {

	player addAction ["Toggle Door Gun Aim", AMP_toggle_doorgun_aim, nil, 0, false, true, "heliManualFire", "(player isEqualTo (driver vehicle player)) && count fullCrew [(vehicle player), 'turret'] > 0 && ((vehicle player) isKindOf 'Helicopter')", -1];
	player addAction ["Toggle Door Gun Fire", AMP_toggle_doorgun_fire, nil, 0, false, true, "LandGear", "(player isEqualTo (driver vehicle player)) && count fullCrew [(vehicle player), 'turret'] > 0 && ((vehicle player) isKindOf 'Helicopter')", -1];

};