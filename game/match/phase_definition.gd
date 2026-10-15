class_name PhaseDefinition
extends Resource
## Una fase de la partida (data/phases/*.tres): duración y herramienta compartida que aparece.
## Los peligros de la arena (lava) siguen su propio calendario: HazardSchedule.

@export var display_name := "Fase"
@export var duration := 20.0
## Herramientas posibles; se elige una por fase con la semilla de la partida.
@export var tool_pool: Array[ToolDefinition] = []
## Segundos tras el inicio de la fase hasta anunciar la herramienta.
@export var announce_delay := 1.0
## Duración del aviso (ubicación y tipo) antes de que aparezca.
@export var announce_warning := 2.5
## Segundos antes del final de la fase en que se avisa de que la herramienta caduca.
@export var expire_warning := 3.0
