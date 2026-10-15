# Recursos gráficos de Final Fire

Estado al 2026-10-14: **propuesta de estilo v1, pendiente de tu aprobación.**
Todo el arte actual es **procedural** (formas vectoriales dibujadas por código y convertidas a
sprites al arrancar). **No es el arte definitivo**: sirve para revisar el estilo, la legibilidad y
el rendimiento dentro del juego. Las herramientas disponibles no permiten generar ilustración
pintada como la de la referencia; lo que faltaría para la versión definitiva está en
[Recursos que faltan](#recursos-que-faltan-para-el-arte-definitivo).

Capturas reales (renderizador Compatibility, Intel HD 530): [`docs/previews/`](docs/previews/)
- `estilo_galeria.png` — las 6 variantes, las 8 animaciones y la sección de arena en cada estado.
- `hoja_1.png` … `hoja_6.png` — las hojas de sprites que genera el juego (24 fotogramas por variante).
- `partida_estilo.png`, `partida_herramienta.png`, `partida_ancha.png`, `menu.png` — en partida, con HUD y controles táctiles.

---

## 1. Guía de estilo v1

| Regla | Valor |
|---|---|
| Estilo | 2D cartoon, formas redondeadas, **contorno oscuro grueso** `#1b0f14` (3 px a escala de juego) |
| Personaje | cabeza/capucha grande (expresión legible en móvil), cuerpo pequeño, ≈ 60 px de alto sobre una colisión de 40×56 |
| Primer plano vs. fondo | lo jugable lleva contorno y colores saturados; el fondo **no** lleva contorno, es más oscuro y apagado |
| Contraste | piedra fría (gris azulado) frente a lava cálida (naranja/amarillo) |
| Avisos | capa propia **por encima** de personajes y efectos (z 9): nunca quedan tapados |
| Efectos | ≤ 0,8 s, alfa ≤ 0,6, radio ≤ 44 px, **debajo** de los avisos (z 6) |
| Controles táctiles | aro doble (oscuro + claro); en reposo semitransparentes para ver el suelo; cálidos al pulsar |

**Paleta** (`presentation/view_palette.gd`)

| Uso | Colores |
|---|---|
| Contorno | `#1b0f14` |
| Piedra segura | `#5d6273` · borde `#8f97ab` · sombra `#373a47` |
| Madera frágil | `#9b5e33` · claro `#c98b52` · oscuro `#5c3218` |
| Lava | profunda `#a81d0c` · cuerpo `#ff5a14` · caliente `#ffb21f` · cresta `#fff0a6` · aviso `#ff3b1f` |
| Ancla | `#5fd8ff` |
| Interfaz | panel `#1c0f14` (86 %) · borde `#f2a33a` · texto `#fff3e0` · acento `#ffd23f` |
| Personajes | rojo `#e8433a`, azul `#3a7be8`, verde `#43b24a`, amarillo `#f2c230`, morado `#a35ee0`, cian `#2ec4c4` |

**Variantes** (color + detalle de silueta, `presentation/character/character_look.gd`)

| # | Nombre | Color | Detalle visible |
|---|---|---|---|
| 1 | Brasa | rojo | cinta en la frente con dos colas al viento, punta corta |
| 2 | Escarcha | azul | gafas sobre la capucha redonda |
| 3 | Musgo | verde | dos hojas en lo alto, bufanda más larga |
| 4 | Chispa | amarillo | pompón en la punta, rayo en el pecho |
| 5 | Sombra | morado | antifaz y punta larga caída |
| 6 | Marea | cian | aletas laterales, bufanda a rayas |

**Rendimiento** (medido con `tools/bench_render.gd`, 6 maniquíes, 1280×720, Intel HD 530 vía ANGLE, sin vsync)

| Versión | FPS medio | FPS 1 % peor | Llamadas de dibujo |
|---|---|---|---|
| Gráficos provisionales de F1 | 31 | 25 | 145 |
| Estilo v1 dibujado vectorialmente cada fotograma | 5 | 4 | 1 486 |
| **Estilo v1 actual** (personajes horneados a sprites, fondo horneado, lava con shader) | **55–59** | **≈ 31** | **≈ 290** |

Claves: cada personaje es 1 rectángulo con textura; el fondo estático se pinta una sola vez;
la lava es un shader en un rectángulo; plataformas, suelo e interfaz solo se redibujan al cambiar.

---

## 2. Inventario actual (todo provisional, estilo v1)

| Recurso | Dónde | Cómo se genera | Estado |
|---|---|---|---|
| Personaje base (rig) | `presentation/character/character_rig.gd` | vectorial por código | propuesta v1 |
| 6 variantes | `presentation/character/character_look.gd` | color + accesorio | propuesta v1 |
| 24 fotogramas por variante: reposo ×4, parpadeo ×1, correr ×8, saltar ×1, caer ×2, empujar ×1, protegerse ×1, impacto ×2, gancho ×3 (90°/135°/180°), eliminado ×1 | `presentation/character/character_animations.gd` | horneados al arrancar (`character_sprites.gd`, 1056×450 px por variante) | propuesta v1 |
| Efectos del personaje | `presentation/fighter_view.gd` | deformación al saltar/aterrizar, burbuja de protección, estrellas, quemadura | propuesta v1 |
| Bloque de piedra (normal) | `presentation/block_view.gd` | vectorial, dibujado una vez | propuesta v1 |
| Plataforma frágil (madera) e inclinable (losa con pivote) con estados segura / agrietada / crítica / a punto de caer / reaparece / anclada | `presentation/platform_view.gd`, `platform_overlay.gd` | vectorial | propuesta v1 |
| Suelo: seguro / aviso (calor + señal con cuenta atrás) / lava / enfriándose | `presentation/segment_view.gd`, `segment_overlay.gd` | vectorial | propuesta v1 |
| Lava inferior y aviso de subida | `presentation/lava_pool_view.gd`, `shaders/lava.gdshader`, `shaders/glow.gdshader` | shader | propuesta v1 |
| Fondo de cueva (ruinas, pilares, estandartes, estalactitas) + 2 cascadas + brasas | `presentation/background_view.gd`, `shaders/lavafall.gdshader` | horneado una vez + shader | propuesta v1 |
| Efectos: polvo, impacto, destello de recogida, humo | `presentation/vfx_layer.gd` | partículas dibujadas | propuesta v1 |
| Herramientas: iconos Ancla y Gancho, pedestal, vista previa | `presentation/tool_icons.gd`, `tools_view.gd` | vectorial | propuesta v1 |
| HUD (VIVOS con cabezas, fase y tiempo, pausa, ranuras, resultados) y tema | `ui/hud/*`, `ui/ui_theme.gd` | StyleBoxFlat + recortes de las hojas | propuesta v1 |
| Controles táctiles | `ui/touch/*` | vectorial | propuesta v1 |
| Menú con desfile de personajes | `ui/menu/*` | hojas de sprites | propuesta v1 |
| Tipografía | fuente por defecto de Godot | — | **provisional** (falta fuente propia) |
| Sonido | — | — | **no existe** (fase F5) |

---

## 3. Recursos que faltan para el arte definitivo

Para pasar del estilo vectorial a arte pintado como el de la referencia hace falta un artista (o
herramientas de ilustración/IA de imagen que este entorno no tiene). Especificaciones para que
los recursos encajen **sin tocar la simulación ni las colisiones**:

### 3.1 Personajes (6 variantes)

- **Formato:** PNG RGBA de 32 bits, fondo transparente, sin recortes por fotograma (celda fija).
- **Celda:** 132 × 150 px (88 × 100 lógicos a escala 1,5). **Origen** (centro de la colisión) en
  (66, 96); **pies** en y = 138 px. Colisión de referencia: 60 × 84 px centrada en el origen.
- **Hoja:** 8 columnas; un archivo por variante: `assets/characters/<brasa|escarcha|musgo|chispa|sombra|marea>/sheet.png`.
- **Solo mirando a la derecha** (el juego refleja en horizontal).
- **Animaciones y fotogramas mínimos** (12 fps salvo indicación):

| Animación | Fotogramas | Notas |
|---|---|---|
| Reposo | 4 + 1 parpadeo | respiración suave |
| Correr | 8 | ciclo completo; cuerpo inclinado hacia delante |
| Saltar | 2 | despegue y subida (brazos arriba) |
| Caer | 2 | brazos agitándose, ojos muy abiertos |
| Empujar | 3 | anticipación, golpe (brazos extendidos), recuperación |
| Protegerse | 2 | guardia con brazos delante |
| Recibir impacto | 2 | mareado (ojos en espiral), cuerpo hacia atrás |
| Gancho | 3 | brazo hacia delante, en diagonal y hacia arriba |
| Eliminado | 6 | destello → carbonizado → se deshace en humo |
| Aterrizar | 2 | aplastado (opcional; ahora se simula deformando el sprite) |

- **Silueta:** cada variante debe reconocerse en negro (sin color) por su detalle de la tabla de variantes.
- **Iconos de cabeza** para el HUD: 64 × 64 px por variante, vivo y eliminado.

### 3.2 Arena (cueva de lava)

| Recurso | Formato | Tamaño | Notas |
|---|---|---|---|
| Fondo lejano (ruinas, cascadas) | WebP/JPG | 2048 × 1152 | sin contorno, oscuro |
| Fondo medio (pilares, estandartes) | PNG RGBA | 2048 × 1152 | parallax opcional |
| Cascada de lava animada | PNG tira | 8 × (64 × 512) | bucle |
| Bloque de piedra | PNG 9-slice | 96 × 48 | borde superior claro = pisable |
| Plataforma frágil (madera) | PNG | 4 estados × 200 × 24 | segura, agrietada, crítica (bordes al rojo), restos al caer |
| Losa inclinable + pivote | PNG | 240 × 24 + 32 × 32 | pivote separado |
| Cuerdas y cadenas | PNG mosaico vertical | 16 × 64 | |
| Tramo de suelo | PNG | 192 × 40 × 3 estados | seguro, aviso (rejillas al rojo), lava (tira de 8 fotogramas) |
| Superficie de lava | PNG mosaico horizontal | 256 × 64 × 8 fotogramas | o se conserva el shader |
| Indicador del Ancla | PNG | 64 × 64 | normal y «se suelta» |

### 3.3 Efectos

| Efecto | Fotogramas | Celda |
|---|---|---|
| Polvo al aterrizar | 6 | 64 × 32 |
| Impacto del empujón | 5 | 64 × 64 |
| Destello al recoger herramienta | 6 | 96 × 96 |
| Humo al ser eliminado | 8 | 64 × 64 |
| Brasa | 1 | 8 × 8 |

### 3.4 Interfaz

| Recurso | Formato | Tamaño |
|---|---|---|
| Iconos Ancla y Gancho (y futuras herramientas) | SVG o PNG | 128 × 128 |
| Botones táctiles: salto, empujar, protección, herramienta, joystick (base y mando) | PNG | 256 × 256, normal y pulsado |
| Panel 9-slice | PNG | 64 × 64 |
| Fuente de títulos (redondeada, gruesa) y de texto | TTF/OTF con licencia OFL | — |
| Icono de la app | PNG | 512 × 512 (y adaptativo de Android 432 × 432 con capas) |

### 3.5 Organización propuesta

```
assets/
├─ characters/<variante>/sheet.png, head.png
├─ arena/lava_cave/{background_far.webp, background_mid.png, lavafall.png, tiles/*.png}
├─ vfx/*.png
├─ ui/{icons/*.svg, touch/*.png, panel.png}
└─ fonts/*.ttf (+ licencias)
```

Al llegar estos recursos solo cambian las vistas (`presentation/`) y la interfaz (`ui/`):
las celdas y orígenes coinciden con los actuales, así que la simulación, las colisiones y las
pruebas no cambian.

---

## 4. Proceso

1. **Ahora:** revisar el estilo v1 en el juego (APK 0.3.0 y capturas) y decidir (D8 en el panel).
2. Si se aprueba: extender el estilo (más variantes de plataforma, animación de aterrizaje y
   eliminado más larga, decoración de arena, iconos de herramientas futuras).
3. Arte definitivo: cuando haya ilustraciones según la sección 3, sustituir las vistas sin tocar `game/`.
