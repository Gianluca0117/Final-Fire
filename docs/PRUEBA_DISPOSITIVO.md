# Prueba en un teléfono Android

APK: `builds/android/FinalFire-debug.apk` — **Final Fire 0.4.0 (código 4)**,
paquete `com.elizsoft.finalfire`, firmado con la clave de **depuración** (no sirve para publicar).
Requiere Android 7.0 (API 24) o superior, con procesador ARM (casi todos los teléfonos).
Incluye F1, la herramienta compartida (F2) y el **estilo v2** (provisional, pendiente de aprobación).

> **Pendiente desde F1: todavía no se ha probado en ningún dispositivo.** Las 152 pruebas
> automáticas se ejecutan en el PC sin pantalla y no sustituyen esta prueba.

## Instalar

**Por cable (recomendado).** En el teléfono: Ajustes → Información del teléfono → pulsa 7 veces
*Número de compilación*; luego *Opciones para desarrolladores* → *Depuración USB*. Conéctalo,
acepta el aviso y ejecuta en la carpeta del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File tools\install-apk.ps1
```

Usa `adb install -r`: si ya tenías una versión anterior la **actualiza conservando sus datos** (mismo paquete
y código de versión mayor). No toca otras aplicaciones.

**Sin cable.** Copia el APK al teléfono, ábrelo y permite «Instalar apps desconocidas».

## Lista breve (marca ✅ / ❌ y cuéntame qué viste)

**F1 · base**
1. [ ] Abre sin cerrarse, en horizontal, y nada queda bajo la muesca o la cámara.
2. [ ] Menú: «−»/«+» y **Jugar** responden al tacto.
3. [ ] Joystick mueve; flecha salta (más alto si la mantienes); se puede mover y saltar a la vez.
4. [ ] Mano empuja; escudo pone la burbuja y apenas te mueven.
5. [ ] El suelo **avisa** (señal con cuenta atrás) **antes** de volverse lava; caer a la lava elimina y baja **VIVOS**.
6. [ ] Plataforma de madera: se agrieta, tiembla con «!» y cae. Losa colgante: se inclina y resbalas.
7. [ ] Al quedar uno: «¡Gana …!», **Revancha** y **Menú** funcionan. Pausa (II y botón atrás) funciona.

**F2 · herramienta compartida**
8. [ ] Al empezar cada fase se **anuncia** dónde y qué herramienta aparece (haz de luz y nombre).
9. [ ] Al tocarla la recoges: aparece sobre tu cabeza y en el botón de herramienta (con «1»).
10. [ ] **Ancla:** sobre una plataforma, pulsa y suelta el botón → se nivela, brilla en cian y no cae; avisa «¡SE SUELTA!» antes de terminar.
11. [ ] **Gancho:** mantén el botón y **arrastra** hacia una plataforma → ves la línea y el destino verde; al soltar te lanza. Apuntando a la nada, sale rojo y **no se gasta**.
12. [ ] Avisa «caduca en 3 s» y desaparece al acabar la fase.

**Estilo v2 · legibilidad y controles**
13. [ ] Distingues a los personajes por color **y** por su detalle (cinta, gafas, hojas, pompón, antifaz, aletas).
14. [ ] Se distinguen plataforma segura, frágil, inclinable y a punto de caer; la lava y sus avisos se ven claros.
15. [ ] El joystick aparece donde pones el pulgar (mitad izquierda) y los botones se pulsan con comodidad aunque se vean pequeños; no tapan plataformas.
15b. [ ] En el menú, «Controles: tamaño / opacidad» cambia los botones y se conserva al reiniciar la app.
15c. [ ] Los avisos pequeños bajo el marcador se leen (quién empujó a quién, herramienta, lava) sin distraer.
15d. [ ] Saltos, aterrizajes y golpes se sienten con peso (aplastamiento, pausa breve al golpear).
16. [ ] Fluidez: ¿va suave o a tirones? ¿Se calienta? **Modelo del teléfono y versión de Android.**

Con tus respuestas actualizo `project-status.json`: la prueba **TEST-05** pasará a aprobada o fallida,
y la compilación solo se marcará como probada en dispositivo si realmente funcionó.
