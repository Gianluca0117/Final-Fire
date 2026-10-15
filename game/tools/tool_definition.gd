class_name ToolDefinition
extends Resource
## Una herramienta compartida (data/tools/*.tres). Los valores son de equilibrio
## PROVISIONAL hasta probarlos jugando (ver project-status.json → balance).

enum Kind { ANCHOR, HOOK }

@export var id: StringName = &"anchor"
@export var display_name := "Ancla"
@export var kind: Kind = Kind.ANCHOR
## Usos antes de consumirse (Ancla y Gancho: 1).
@export var uses := 1

@export_group("Ancla")
## Segundos que la plataforma queda estabilizada.
@export var anchor_duration := 6.0
## Últimos segundos del efecto en los que se avisa de que se va a soltar.
@export var anchor_warning := 1.5
## Distancia máxima (px) desde el personaje al centro de la plataforma objetivo.
@export var anchor_range := 260.0

@export_group("Gancho")
@export var hook_range := 380.0
@export var hook_min_range := 48.0
## Apertura (grados a cada lado) de la búsqueda de una superficie alrededor de la dirección apuntada.
@export var hook_cone_deg := 24.0
@export var hook_speed := 1150.0
@export var hook_max_time := 0.7
## Impulso hacia arriba al llegar, para subir al borde de la superficie.
@export var hook_end_boost := -520.0
