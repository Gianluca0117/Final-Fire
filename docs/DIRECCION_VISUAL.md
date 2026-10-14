# Dirección visual (referencia)

Imagen de referencia compartida el 2026-10-14 («así debería quedar»). Es una **meta visual**, no un
recurso del juego: el proyecto actual solo usa formas provisionales.

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

| Referencia | Ahora | Tarea |
|---|---|---|
| Joystick + 4 botones de acción | Botones `<` `>` `SALTO` | T-017 |
| Agarrar / empujar | No existe | T-013 |
| Plataformas que se rompen y lava | No existe | T-014, T-015 |
| VIVOS n/6, cronómetro, pausa | Solo un texto de depuración | T-021 |
| Escudo, tablón, gancho | No existe | T-020 |
| 6 personajes y cueva de lava | Rectángulo naranja y fondo liso | T-028 |

Los controles táctiles actuales ya tienen la base necesaria (multitáctil, anclaje a las esquinas
y área segura); el joystick y los botones nuevos se construirán sobre `touch_button.gd`.
