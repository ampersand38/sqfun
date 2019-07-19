private _veh = vehicle player;
private _new = createVehicle [typeOf _veh, _veh modelToWorld [0,50,0]];
moveOut player;
player moveInDriver _new;