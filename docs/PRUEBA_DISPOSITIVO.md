# Prueba en un teléfono Android

APK: `builds/android/FinalFire-debug.apk` — **Final Fire 0.2.0 (código 2)**,
paquete `com.elizsoft.finalfire`, firmado con la clave de **depuración** (no sirve para publicar).
Requiere Android 7.0 (API 24) o superior, con procesador ARM (casi todos los teléfonos).

> Hasta ahora **no se ha probado en ningún dispositivo**. Las 83 pruebas automáticas se
> ejecutan en el PC sin pantalla y no sustituyen esta prueba.

## Opción A: por cable (recomendada)

1. En el teléfono: **Ajustes → Información del teléfono** → pulsa 7 veces **Número de compilación**.
2. **Ajustes → Sistema → Opciones para desarrolladores** → activa **Depuración USB**.
3. Conecta el teléfono al PC por USB y acepta **«¿Permitir depuración USB?»** en el teléfono.
4. En PowerShell, dentro de la carpeta del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File tools\install-apk.ps1
```

Instala con `adb install -r` (si ya existía la app la actualiza **conservando sus datos**;
no toca otras aplicaciones), la abre y muestra el registro del juego. `Ctrl+C` para salir.

## Opción B: sin cable

Copia el APK al teléfono (USB, Drive, correo…), ábrelo y permite **«Instalar apps desconocidas»**
para la app con la que lo abras. Android puede mostrar un aviso de Play Protect por ser una app
de depuración sin publicar: es esperable.

## Sobre el cambio de identificador

El APK anterior (0.1.0) usaba `com.finalfire.game`. Android trata un identificador distinto como
**otra aplicación**: el nuevo APK **no actualiza** al anterior, se instala aparte. Como el APK
anterior nunca llegó a instalarse en un teléfono, no hay nada que migrar. Si lo hubieras instalado,
desinstálalo a mano (Ajustes → Aplicaciones → Final Fire → Desinstalar). A partir de ahora todas
las versiones usarán `com.elizsoft.finalfire` y sí se actualizarán entre sí.

## Qué comprobar (y contarme)

Marca cada punto como ✅, ❌ o «no sé», y si algo falla dime qué viste:

1. [ ] La app se instala y abre sin cerrarse.
2. [ ] Se ve en **horizontal** y no se sale nada de la pantalla (ni bajo la muesca o la cámara).
3. [ ] El menú responde al tacto: «−»/«+» cambian el número de maniquíes y **Jugar** inicia la partida.
4. [ ] Cuenta atrás 3-2-1-¡YA! y luego el personaje **J1** responde al **joystick** (izquierda/derecha).
5. [ ] **Salto** (flecha): salta; mantenerlo pulsado salta más alto.
6. [ ] Se puede **mover y saltar a la vez** (dos dedos).
7. [ ] **Mano**: empuja a un maniquí cercano.
8. [ ] **Escudo**: aparece una burbuja y los empujones apenas te mueven.
9. [ ] Las plataformas colgantes **se inclinan** y, si te quedas encima, **se agrietan, tiemblan y caen**.
10. [ ] Un tramo del suelo **avisa** (parpadea con cuenta atrás) **antes** de convertirse en lava.
11. [ ] Caer a la lava **elimina** y el contador **VIVOS** baja.
12. [ ] Al quedar uno, aparece **«¡Gana …!»** con la clasificación; **Revancha** y **Menú** funcionan.
13. [ ] **Pausa** (botón II y botón «atrás» de Android) detiene la partida.
14. [ ] Fluidez: ¿va suave o a tirones? ¿Se calienta el teléfono?
15. [ ] Modelo del teléfono y versión de Android.

Con tus respuestas actualizo `project-status.json`: la prueba **TEST-05** pasa a aprobada o fallida
y la compilación queda marcada como probada en dispositivo solo si realmente funcionó.
