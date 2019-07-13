
params ["_heli"];

if !(_heli isKindOf "Helicopter") exitWith {"Not Helicopter"};
if (_heli weaponsTurret [1] isEqualTo []) exitWith {"No door gun turret"};
private _doorGunWeapon = _heli weaponsTurret [1] select 0;
_heli addWeaponTurret [_doorGunWeapon, [-1]];
private _doorGunMagazines = (magazinesAllTurrets _heli) select {_x select 1 isEqualTo [1]};
{
	_x params ["_doorGunMag", "_doorGunTurretPath", "_doorGunAmmo"];
	_heli addMagazineTurret [_doorGunMag, [-1], _doorGunAmmo];
} forEach _doorGunMagazines;
