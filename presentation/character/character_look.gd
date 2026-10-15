class_name CharacterLook
extends RefCounted
## Aspecto de una variante del personaje base. Cada una se distingue por el color Y por un
## detalle de silueta visible a tamaño de móvil (capucha y accesorio).

enum Accessory {
	HEADBAND,    ## 0 Rojo «Brasa»: cinta en la frente con dos colas al viento
	GOGGLES,     ## 1 Azul «Escarcha»: gafas sobre la capucha redonda
	SPROUT,      ## 2 Verde «Musgo»: dos hojas en lo alto de la capucha
	POMPOM,      ## 3 Amarillo «Chispa»: pompón en la punta y rayo en el pecho
	MASK,        ## 4 Morado «Sombra»: antifaz y punta larga y caída
	FINS,        ## 5 Cian «Marea»: aletas laterales y bufanda a rayas
}

const NAMES := ["Brasa", "Escarcha", "Musgo", "Chispa", "Sombra", "Marea"]

var index := 0
var name := ""
var accessory: Accessory = Accessory.HEADBAND
var main := Color.WHITE
var dark := Color.WHITE
var light := Color.WHITE
var accent := Color.WHITE
var skin := Color("ffd9b8")


static func for_index(i: int, base: Color) -> CharacterLook:
	var l := CharacterLook.new()
	l.index = i
	l.accessory = (i % 6) as Accessory
	l.name = NAMES[i % 6]
	l.main = base
	l.dark = base.darkened(0.35)
	l.light = base.lightened(0.3)
	match l.accessory:
		Accessory.HEADBAND: l.accent = Color("fff1c9")
		Accessory.GOGGLES: l.accent = Color("ffd23f")
		Accessory.SPROUT: l.accent = Color("9be36a")
		Accessory.POMPOM: l.accent = Color("ff7a1f")
		Accessory.MASK: l.accent = Color("2a1838")
		Accessory.FINS: l.accent = Color("f2fbff")
	return l
