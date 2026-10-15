# Recursos gráficos de Final Fire

Estado al 2026-10-14: **estilo v2 (revisión gráfica de una sección jugable), provisional y
pendiente de tu aprobación (D8).**
Todo el arte actual es **procedural** (formas vectoriales dibujadas por código y horneadas a
texturas al arrancar). **No es el arte definitivo.** La v2 se aplicó **solo a la cueva de lava**
(una sección jugable); antes de extender gráficos provisionales al resto del juego hay que decidir
qué ilustraciones externas se encargan: ver [§3](#3-recursos-externos-que-faltan-antes-de-extender-al-resto-del-juego).

Capturas reales (renderizador Compatibility, Intel HD 530): [`docs/previews/`](docs/previews/)
- **`comparacion/antes_despues_1.png` y `antes_despues_2.png`** — antes (v1, commit `079651d`) a la
  izquierda (franja gris) y después (v2) a la derecha (franja naranja). Misma pantalla (1280×720),
  misma semilla y mismo instante (semilla 11 a 7,2 s; semilla 22 a 4,0 s), con controles táctiles.
  Las capturas sueltas están en la misma carpeta (`antes_N.png`, `despues_N.png`).
- `estilo_galeria.png` — las 6 variantes, animaciones y estados de las superficies.
- `hoja_1.png` … `hoja_6.png` — hojas de sprites que genera el juego (32 fotogramas por variante).
- `partida_estilo.png`, `partida_herramienta.png`, `partida_ancha.png` (≈ 1,9:1), `menu.png`.

Las comparaciones se regeneran con:

```powershell
& $godot --path . --resolution 1280x720 --fixed-fps 60 -s res://tools/capture_preview.gd -- match docs/previews/comparacion/despues_1.png 7.2 11 touch
& $godot --path . --headless -s res://tools/compose_comparison.gd -- docs/previews/comparacion/antes_1.png docs/previews/comparacion/despues_1.png docs/previews/comparacion/antes_despues_1.png
```

---

## 1. Revisión v2: qué cambió y por qué

| # | Pedido | Cambio en v2 | Comprobación |
|---|---|---|---|
| 1 | Personajes más grandes y legibles sin cambiar colisiones | Cámara con zoom 1,2 centrada en la acción + escala visual del sprite 1,12 → el personaje mide ≈ 80 px en una pantalla de 720 (antes ≈ 60). **Colisión intacta: 40×56.** Capucha con sombreado, botas con brillo, etiqueta con fuente redondeada | Prueba «la vista no altera la simulación» (misma partida con y sin vistas) |
| 2 | Plataformas ilustradas con volumen, textura y deterioro | Piedra: bloques con cara frontal, juntas, borde superior iluminado por la lava, grietas y goteo; losa con bandas de hierro y remaches; suelo con rejilla que se enrojece al avisar. Madera: dos tablones con veta, travesaños y amarres de cuerda; **deterioro visible**: segura → combada con grietas → falta un trozo, chamuscada y astillada | Galería y capturas |
| 3 | Composición vertical con rutas alcanzables | Arena nueva en **5 niveles** (suelo, repisas laterales, puente y losa, salientes altos, plataforma central y atalaya); las herramientas aparecen arriba y a los lados para repartir la acción | Prueba de rutas: grafo de alcance con la altura real de salto (≤ 150 px arriba) y un **salto simulado** del suelo al puente |
| 4 | Controles más discretos, cómodos y ajustables | Joystick **flotante** (aparece donde tocas, en reposo solo un aro tenue); botones dibujados más pequeños pero con **área táctil 1,4× mayor** que el dibujo; **tamaño (75–130 %) y opacidad (25–100 %) ajustables** en el menú y guardados en el dispositivo. Botones y repisas recolocados para que no tapen superficies pisables | Pruebas de toques simulados; capturas |
| 5 | Estilo cartoon unificado | Fuente **Lilita One** (OFL) en HUD, menú, avisos y etiquetas; iconos de herramienta con el mismo contorno grueso; HUD con los mismos colores y bordes | Capturas |
| 6 | Fondo con profundidad, menos llamativo | 5 capas: cueva → ruinas lejanas de bajo contraste → banda de calima → pilares y arco con borde iluminado → marco oscuro de primer término; cascadas más estrechas y atenuadas | Capturas |
| 7 | Avisos breves en vez de mensajes centrales | Lista discreta bajo el marcador (máx. 3 líneas, 2,6 s): cabeza + nombre + icono (empujón, lava, herramienta). Cuenta atrás inicial pequeña bajo el reloj. Los avisos de peligro siguen en su capa sobre el escenario | Capturas |
| 8 | Animaciones con peso y personalidad | 32 fotogramas (antes 24): ciclo de carrera con contacto y paso, **derrape**, **despegue**, **ápice**, caída, **aterrizaje con aplastamiento proporcional a la velocidad de caída**, golpe de empujón + recuperación, impacto con **congelación de 0,07 s y destello**, aterrizaje tras golpe, mirar alrededor en reposo, respiración | Hojas `hoja_1…6.png`; prueba de clips obligatorios |

No se ha resuelto añadiendo partículas: los cambios son de dibujo (rig, superficies, fondo),
composición (cámara, arena, HUD, controles) y animación.

**Rendimiento** (`tools/bench_render.gd -- 20 6`, 6 maniquíes, 1280×720, Intel HD 530 vía ANGLE, sin vsync)

| Versión | FPS medio | FPS 1 % peor | Llamadas de dibujo |
|---|---|---|---|
| Gráficos provisionales de F1 | 31 | 25 | 145 |
| Estilo v1 | 55–59 | ≈ 31 | ≈ 290 |
| **Estilo v2** (superficies horneadas con `ArtCache`) | **64** | **31** | **178** |

Las piezas estáticas (bloques, suelo, tablones) se pintan una vez en una textura (`ArtCache`,
escala 2) y se reutilizan; solo se redibuja en vivo lo que cambia (brillo de aviso, lava, cuerdas).

---

## 2. Guía de estilo e inventario (todo provisional)

| Regla | Valor |
|---|---|
| Estilo | 2D cartoon, formas redondeadas, **contorno oscuro grueso** `#1b0f14` |
| Personaje | capucha grande, cuerpo pequeño, ≈ 80 px en pantalla sobre una colisión de 40×56 |
| Primer plano vs. fondo | lo jugable lleva contorno, volumen y luz cálida de la lava; el fondo no lleva contorno y es más oscuro |
| Tipografía | Lilita One (SIL OFL 1.1, `assets/fonts/`) |
| Avisos de peligro | capa propia **por encima** de personajes y efectos (z 9) |
| Efectos | ≤ 0,8 s, alfa ≤ 0,6, radio ≤ 44 px, debajo de los avisos |

Paleta en `presentation/view_palette.gd`; variantes en `presentation/character/character_look.gd`
(Brasa, Escarcha, Musgo, Chispa, Sombra, Marea: color + detalle de silueta).

| Recurso | Dónde | Estado |
|---|---|---|
| Rig del personaje y 6 variantes | `presentation/character/` | provisional v2 |
| 32 fotogramas por variante (hojas de 1200×600 px) | `character_animations.gd`, `character_sprites.gd` | provisional v2 |
| Animación en juego (aplastar/estirar, congelación, destello) | `presentation/fighter_view.gd` | provisional v2 |
| Superficies: piedra, losa, suelo con rejilla, tablones de madera con 3 niveles de deterioro | `presentation/style/arena_art.gd`, `block_view.gd`, `platform_view.gd`, `segment_view.gd` | provisional v2 |
| Fondo por capas + cascadas + brasas | `presentation/background_view.gd` | provisional v2 |
| Lava y avisos | `lava_pool_view.gd`, `segment_overlay.gd`, `shaders/` | provisional v2 |
| Iconos de herramienta | `presentation/tool_icons.gd` | provisional v2 |
| HUD, lista de avisos, menú | `ui/hud/`, `ui/menu/`, `ui/ui_theme.gd` | provisional v2 |
| Controles táctiles flotantes y ajustables | `ui/touch/`, `ui/ui_settings.gd` | provisional v2 |
| Fuente Lilita One | `assets/fonts/LilitaOne-Regular.ttf` + `OFL.txt` (Google Fonts, verificada por hash) | definitiva si se aprueba |
| Sonido | — | **no existe** (F5) |

---

## 3. Recursos externos que faltan antes de extender al resto del juego

La v2 llega hasta donde permite el dibujo vectorial por código. **Para alcanzar la calidad de la
referencia (ilustración pintada) hacen falta ilustraciones externas** — de un artista o de
herramientas de imagen que este entorno no tiene. Recomendación: **no extender los gráficos
provisionales a nuevas arenas, herramientas o menús hasta decidir (D8)** si se encargan estos
recursos, para no rehacer el trabajo dos veces.

Prioridad (lo que más mejora la imagen por cada recurso):

1. **Personajes** (§3.1): una hoja por variante. Es lo que más se mira.
2. **Superficies de la arena** (§3.2): piedra, madera con sus estados de deterioro y suelo.
3. **Fondo pintado en 3 capas** (§3.2).
4. **Iconos de herramienta y botones táctiles** (§3.4).
5. Efectos (§3.3): se pueden mantener los actuales más tiempo.

Especificaciones para que los recursos encajen **sin tocar la simulación ni las colisiones**:

### 3.1 Personajes (6 variantes)

- **Formato:** PNG RGBA de 32 bits, fondo transparente, celda fija (sin recortes por fotograma).
- **Celda:** 150 × 150 px (100 × 100 lógicos a escala 1,5). **Origen** (centro de la colisión) en
  (75, 96); **pies** en y = 138 px. Colisión de referencia: 60 × 84 px centrada en el origen.
- **Hoja:** 8 columnas × 4 filas; un archivo por variante: `assets/characters/<brasa|escarcha|musgo|chispa|sombra|marea>/sheet.png`.
- **Solo mirando a la derecha** (el juego refleja en horizontal).
- **Fotogramas** (mismo orden que `CharacterAnimations.CLIPS`, 32 en total):

| Clip | Fotogramas | Notas |
|---|---|---|
| idle | 4 | respiración suave |
| blink | 1 | |
| run | 8 | contacto, paso y empuje con la pierna trasera; cuerpo inclinado |
| skid | 1 | frenazo al cambiar de sentido |
| takeoff | 1 | agachado antes de despegar |
| jump | 1 | subida, brazos arriba |
| apex | 1 | punto más alto, piernas recogidas |
| fall | 2 | brazos agitándose |
| land | 2 | aplastado y recuperación |
| push | 1 | golpe con brazos extendidos |
| push_recover | 1 | |
| shield | 1 | guardia con brazos delante |
| hit | 2 | mareado, cuerpo hacia atrás |
| hook | 3 | brazo a 90°, 135° y 180° |
| dead | 1 | (idealmente 6: destello → carbonizado → humo) |
| look | 1 | mira alrededor en reposo |
| hit_land | 1 | aterriza aturdido |

- **Silueta:** cada variante debe reconocerse en negro por su detalle (cinta, gafas, hojas, pompón, antifaz, aletas).
- **Cabezas para el HUD y los avisos:** 64 × 64 px por variante, viva y eliminada.

### 3.2 Arena (cueva de lava)

| Recurso | Formato | Tamaño | Notas |
|---|---|---|---|
| Fondo lejano (cueva, ruinas) | WebP/JPG | 3360 × 2080 | sin contorno, bajo contraste |
| Fondo medio (pilares, arco, estandartes) | PNG RGBA | 3360 × 2080 | más oscuro que lo jugable |
| Primer término (marco de roca, estalactitas) | PNG RGBA | 3360 × 2080 | casi negro |
| Cascada de lava animada | PNG tira | 8 × (68 × 840) | bucle |
| Bloque de piedra | PNG 9-slice | 260 × 60 (×2) | borde superior claro = pisable |
| Saliente / atalaya | PNG | 232 × 56, 192 × 52 | con goteo y grietas |
| Puente de madera | PNG | 3 estados × 380 × 48 | seguro, agrietado/combado, roto y chamuscado |
| Losa inclinable + pivote | PNG | 380 × 48 + 32 × 32 | pivote separado |
| Cuerdas y cadenas | PNG mosaico vertical | 16 × 64 | |
| Tramo de suelo | PNG | 320 × 80 × 3 estados | seguro, aviso (rejilla al rojo), lava |
| Superficie de lava | PNG mosaico horizontal | 256 × 64 × 8 fotogramas | o se conserva el shader |

(Tamaños al doble de la resolución lógica, como hornea `ArtCache`.)

### 3.3 Efectos

| Efecto | Fotogramas | Celda |
|---|---|---|
| Polvo al aterrizar / derrapar | 6 | 64 × 32 |
| Impacto del empujón | 5 | 64 × 64 |
| Destello al recoger herramienta | 6 | 96 × 96 |
| Humo al ser eliminado | 8 | 64 × 64 |

### 3.4 Interfaz

| Recurso | Formato | Tamaño |
|---|---|---|
| Iconos Ancla y Gancho (y futuras herramientas) | SVG o PNG | 128 × 128 |
| Iconos de botones: salto, empujar, protección, herramienta | SVG o PNG | 128 × 128 (el aro lo dibuja el juego) |
| Iconos de avisos: empujón, lava, peligro | SVG o PNG | 48 × 48 |
| Panel 9-slice | PNG | 64 × 64 |
| Icono de la app | PNG | 512 × 512 (y adaptativo de Android 432 × 432 con capas) |

### 3.5 Organización propuesta

```
assets/
├─ characters/<variante>/sheet.png, head.png
├─ arena/lava_cave/{bg_far.webp, bg_mid.png, bg_near.png, lavafall.png, tiles/*.png}
├─ vfx/*.png
├─ ui/{icons/*.svg, panel.png}
└─ fonts/*.ttf (+ licencias)
```

Al llegar estos recursos solo cambian las vistas (`presentation/`) y la interfaz (`ui/`): celdas,
orígenes y tamaños coinciden con los actuales, así que la simulación, las colisiones y las
pruebas no cambian.

---

## 4. Proceso

1. **Ahora:** revisar la v2 en las comparaciones y en el APK 0.4.0, y decidir (D8).
2. Si se encargan ilustraciones: sustituir las vistas de la cueva según §3, sin tocar `game/`.
3. Solo después, extender el estilo a nuevas arenas, herramientas y menús.
