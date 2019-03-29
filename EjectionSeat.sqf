//[_pilot] call AMP_fnc_EjectionSeat

_this spawn 
{
	params ["_pilot"];
	private _plane = vehicle _pilot;
	
	//make pilot invulnerable for the transition time
	_pilot allowDamage false;
	_plane allowDamage false;
	
	//create and position ejection seat
	private _ejectionSeatClass = "B_Ejection_Seat_Plane_Fighter_01_F";
	private _ejectionSeatForce = 50;
	private _ejectionSeat = createvehicle [_ejectionSeatClass,[0,0,1000],[],0,"CAN_COLLIDE"];

	_ejectionSeat attachTo [_plane, [0,0,(boundingBoxReal _plane # 1 # 2) + (boundingBoxReal _ejectionSeat # 0 # 2)]];
	
	//move pilot to ejection seat and lock it
	waitUntil{moveOut _pilot; vehicle _pilot != _plane};
	waitUntil{_pilot moveInCargo _ejectionSeat; vehicle _pilot == _ejectionSeat};
	_ejectionSeat lock 2;
	removeBackpack _pilot;
	_pilot addBackpack "ACE_NonSteerableParachute";

	detach _ejectionSeat; waitUntil{isNull attachedTo _ejectionSeat};
	_plane disableCollisionWith _ejectionSeat;
	_ejectionSeat disableCollisionWith _plane;

	private _planeVelocityModelSpace = velocityModelSpace _plane;

	private _planeFX = createvehicle ["B_Plane_Fighter_01_F",[0,0,1000],[],100,"NONE"];
	[_planeFX ,_ejectionSeat] spawn BIS_fnc_planeEjectionFX;
	
	_ejectionSeat setVelocityModelSpace (_planeVelocityModelSpace apply {_x/10} vectorAdd [0.5,0.5,_ejectionSeatForce]);
	
	//make player once more vulnerable
	[{{_x allowDamage true} forEach _this;}, [_plane, _pilot], 2] call CBA_fnc_waitAndExecute;
	
	//deleteVehicle _planeFX;
	[{deleteVehicle (_this # 0);}, [_planeFX], 10] call CBA_fnc_waitAndExecute;
};