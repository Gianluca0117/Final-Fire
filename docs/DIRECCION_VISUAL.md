# Dirección visual (referencia)

Imagen de referencia compartida el 2026-10-14 («así debería quedar»). Es una **meta visual**, no un
recurso del juego. Desde la versión 0.3.0 el juego usa la **propuesta de estilo v1** inspirada en
ella (procedural, pendiente de aprobación): guía de estilo, inventario y recursos que faltan en
[ASSETS.md](../ASSETS.md).

> Guarda la imagen como `docs/referencias/estilo-objetivo.png` para que el panel la muestre
> (Inventario → Referencias).

## Lo que muestra

**Escenario.** Cueva volcánica con fondo de castillo en ruinas, cascadas de lava y estandartes con
calavera. Piso inferior de lava con rocas. Elementos jugables visibles:
- Plataformas de piedra suspendidas por cadenas.
- Puente de madera que se rompe (fragmentos cayendo).
- Plataformas que se desmoronan o se calientan (bordes rojos incandescentes).
- Varias alturas: repisas laterales, plataforma central y pequeños pilares sobre la lava.

**Personajes.** Seis personajes pequeños y encapuchados, cada uno de un color
(rojo, azul, verde, amarillo, morado, cian), con bufanda o capa. Estilo 2D cartoon pintado,
contorno marcado y líneas de movimiento. Acciones vistas: correr, saltar, empujar a otro y
balancearse con una cuerda.

**Herramientas** (sobre pedestales brillantes): escudo, tablón de madera y un gancho/arpón con cuerda.

**HUD (horizontal):**
- Arriba a la izquierda: `VIVOS 6/6` con un icono de capucha por color.
- Arriba al centro: cronómetro (`01:24`).
- Arriba a la derecha: pausa.
- Abajo a la izquierda: **joystick virtual** con cuatro direcciones.
- Abajo a la derecha: **salto** (el botón más grande), **agarrar/empujar** (mano),
  **usar herramienta** (escudo) y una **ranura de objeto** con contador.

## Diferencias con el proyecto actual

| Referencia | Ahora (0.3.0, estilo v1) | Tarea |
|---|---|---|
| Joystick + 4 botones de acción | Joystick, salto, mano, escudo y ranura de herramienta | T-017 |
| Agarrar / empujar | Empujón con autoría | T-013 |
| Plataformas que se rompen, puente de madera y lava | Madera frágil, losa inclinable, suelo que se vuelve lava, lava que sube | T-014, T-015 |
| VIVOS n/6 con capuchas, cronómetro, pausa | VIVOS con cabezas de personaje, fase y tiempo, pausa | T-021 |
| Escudo, tablón, gancho sobre pedestales | Ancla y Gancho sobre pedestal; escudo y tablón pendientes | T-020, T-041 |
| 6 personajes encapuchados y cueva de lava | 6 variantes cartoon con detalle propio; cueva con ruinas, estandartes y cascadas (procedural) | T-042, T-043 |
| Ilustración pintada | **No** (requiere artista; especificaciones en ASSETS.md) | T-046 |

Diferencias deliberadas con la referencia: el fondo es más oscuro y sin contorno (para que lo
jugable destaque en un móvil) y los avisos de peligro tienen una capa propia que nada puede tapar.
