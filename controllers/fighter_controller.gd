class_name FighterController
extends RefCounted
## Contrato común de todos los controladores: producir un InputFrame por tick.
## La partida lo entrega al personaje; el controlador nunca mueve al personaje.


func sample(p_tick: int, _fighter: Fighter, _match: MatchController) -> InputFrame:
	return InputFrame.idle(p_tick)
