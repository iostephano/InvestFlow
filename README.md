<img width="1999" height="856" alt="Cover" src="https://github.com/user-attachments/assets/7351f9c0-5cc2-4359-a59e-c7485cc2c6b6" />
# 📈 InvestFlow — Demo de arquitectura iOS FinTech

InvestFlow es una aplicación demo de iOS que simula la compra y venta de acciones, ETFs y criptomonedas. Fue creada como proyecto de portafolio para mostrar cómo construyo una app de inversión de principio a fin: desde la lógica de negocio hasta la interfaz, pasando por buenas prácticas de organización de código y pruebas automatizadas.

---

## 🚀 Tecnologías usadas

- Swift (última versión, con verificación estricta de concurrencia)
- SwiftUI
- `@Observable` — el mecanismo moderno de Apple para que la interfaz se actualice sola cuando cambian los datos
- Programación asíncrona (`async`/`await`) para manejar operaciones que toman tiempo (como pedir datos de mercado) sin congelar la app
- Arquitectura por capas (Clean Architecture)
- Patrón MVVM + un Coordinator que centraliza la navegación
- Dos módulos separados hechos con Swift Package Manager: `FinCore` (la lógica de negocio) y `FinUI` (el sistema de diseño visual)
- Sistema propio para inyectar dependencias, sin librerías externas de terceros
- Swift Testing para las pruebas automatizadas
- Integración continua con GitHub Actions: cada cambio se compila y se prueba automáticamente
- Cero dependencias externas — todo el código corre sobre frameworks propios de Apple

---

## 🧱 Cómo está organizado el proyecto

El proyecto separa responsabilidades en capas claras:

App → Presentación → Dominio (FinCore) → Datos → Core, con FinUI como sistema de diseño compartido por toda la interfaz.

### Ideas clave:

- **El Dominio (`FinCore`) es independiente de todo lo demás** — no depende de la interfaz ni de la red, así que se puede probar y reutilizar sin cambios.
- **La lógica de negocio vive en "casos de uso"** (por ejemplo, "colocar una orden" o "calcular ganancias/pérdidas"), separada de la interfaz.
- **Los repositorios abstraen de dónde vienen los datos** — la app no necesita saber si la información viene de un servidor real o de datos simulados.
- **La interfaz nunca habla directamente con la capa de datos** — siempre pasa por los casos de uso.
- Cada repositorio tiene dos versiones: una **simulada** (para la demo, sin necesidad de un servidor real) y una **real** (lista para conectarse a un backend cuando exista).

---

## 🔁 Cómo fluye una acción típica

1. El usuario interactúa con una pantalla.
2. La pantalla le pide a su ViewModel que haga algo.
3. El ViewModel llama a un caso de uso (la lógica de negocio).
4. El caso de uso pide o guarda datos a través de un repositorio.
5. El ViewModel actualiza su estado, y la interfaz se refresca sola.

---

## 🧠 Lógica de negocio (`FinCore`)

- Completamente independiente y fácil de probar, sin dependencias externas.
- Usa el tipo `Decimal` para todos los cálculos de dinero (más preciso que usar números decimales comunes, evitando errores de redondeo).
- Cubre autenticación, datos de mercado, colocación de órdenes, análisis de portafolio (ganancias/pérdidas, distribución de activos), lista de seguimiento, historial de transacciones y el flujo de transferencia de fondos.

### Ejemplos de lo que modela:
- Instrumentos financieros, cotizaciones, órdenes
- Portafolio, posiciones, desglose y análisis del portafolio
- Transacciones, solicitudes de transferencia
- Perfil de usuario, lista de seguimiento

---

## 🗄 Capa de Datos

- Cada repositorio tiene una versión simulada (datos de ejemplo, útil para la demo) y una versión real (lista para conectarse a un servidor).
- Los datos que llegan de fuera se traducen a los tipos internos de la app mediante "mappers" dedicados, para mantener todo prolijo y desacoplado.
- El portafolio y la lista de seguimiento usan un sistema de caché con expiración, para no repetir peticiones innecesarias.
- Las noticias de mercado y el historial de precios se generan de forma simulada para la demo — no hay un proveedor de datos de mercado real conectado.
- Los repositorios simulados de órdenes y portafolio comparten un mismo almacén en memoria (`MockBrokerStore`): al comprar o vender algo, el saldo y las posiciones se actualizan de verdad dentro de esa sesión de uso, aunque no haya un servidor real detrás.

---

## ⚙️ Capa Core (infraestructura)

- Cliente de red propio, con reintento automático cuando expira la sesión.
- Manejo seguro de tokens de sesión mediante el Keychain de iOS (el almacén cifrado del sistema).
- Sistema de caché con expiración automática.
- Un logger propio con puntos de extensión ya preparados para conectar en el futuro un servicio de reportes de errores o analítica — hoy no están conectados a ningún servicio externo.

---

## 🎨 Interfaz

- SwiftUI + MVVM.
- Un Coordinator centraliza la navegación de toda la app.
- Sistema de diseño propio: colores, tipografía y componentes reutilizables viven en `FinUI`; los efectos visuales más elaborados (brillos, bordes con reflejo, animaciones) viven directamente en la app.

---

## ⚡ Manejo de tareas en paralelo

- El proyecto usa el modelo de concurrencia más reciente de Swift, que evita errores comunes de acceso simultáneo a datos compartidos.
- Se usan actores para proteger el estado compartido (por ejemplo, la caché o el token de sesión).
- Las cargas independientes (por ejemplo, perfil y lista de seguimiento en la pantalla de inicio) se piden en paralelo para que la app se sienta más rápida.

---

## 📱 Funcionalidades

- Inicio de sesión, restauración de sesión y cierre de sesión, con opción de desbloqueo biométrico (Face ID / Touch ID).
- Pantalla de inicio: saldo disponible, accesos rápidos, promociones, resumen de la lista de seguimiento.
- Mercado: búsqueda, filtros por categoría, activos más destacados del día, noticias.
- Detalle de un activo: cotización, gráfico de precio, opción de seguirlo, compra/venta.
- Formulario de orden: compra a precio de mercado, con precio límite, o con stop-loss, validando que haya saldo suficiente.
- Lista de seguimiento: agregar y quitar activos.
- Portafolio: ganancias/pérdidas, distribución por categoría, sugerencias de rebalanceo.
- Historial de transacciones, con filtros y agrupación por mes.
- Flujo de transferencia de fondos: país → verificación de identidad → método → monto → confirmación.
- Perfil: foto de usuario, ajustes de seguridad biométrica, cierre de sesión.

---

## 🧪 Pruebas automatizadas

- El proyecto tiene una suite de pruebas automatizadas que cubre la lógica de negocio, las pantallas y la infraestructura, para detectar errores antes de que lleguen a producción.
- Cada cambio subido al repositorio se compila y se prueba automáticamente antes de aceptarse.

---

## ⚠️ Cosas que quedan pendientes o limitadas (a propósito)

- No hay un servidor real conectado — la demo funciona completamente con datos simulados. La versión "real" de cada repositorio ya está escrita y lista para conectarse el día que exista un backend.
- El envío de una orden no incluye todavía una protección contra duplicados en caso de que la conexión falle a mitad de camino — es un detalle pendiente de resolver junto con un backend real.
- El estado del portafolio simulado vive solo mientras la app está abierta — al reiniciarla, vuelve a los valores iniciales, ya que no hay almacenamiento permanente ni servidor detrás. Las órdenes con precio límite o stop-loss quedan registradas como pendientes, pero nada las ejecuta automáticamente en esta demo.
- El flujo de transferencia de fondos está preparado en el diseño, pero su conexión a un servidor real todavía no está implementada.
- Las noticias y el historial de precios son datos de ejemplo, no información de mercado real.
- No hay todavía un servicio de reportes de errores ni de analítica conectado.
- No hay registro de nuevos usuarios ni recuperación de contraseña — solo inicio de sesión.
- El perfil se puede ver, pero no editar todavía.

---

## 🎯 Qué busca demostrar este proyecto

- Una arquitectura organizada y fácil de mantener, con la lógica de negocio separada de todo lo demás.
- Buen manejo de la concurrencia moderna de Swift.
- Un sistema de diseño visual propio y reutilizable.
- Honestidad técnica: qué está simulado y qué está listo para producción, sin ocultar nada.

---

## Autor

Stephano Portella
