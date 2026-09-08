# Plan: backend Elixir para acceso docente autorizado

> Documento de diseño — borrador para discusión. Agosto 2026.

## 1. Objetivo

Crear un backend propio (Elixir/Phoenix) que dé a **docentes autorizados** una vista
del estudiante — notas, horarios y (a evaluar) pagos — limitada a **sus propias
asignaturas**, replicando el principio de SIGMA: cada docente ve solo lo suyo.
El backend además ordena lo que hoy no existe: autorización explícita, auditoría
de accesos y una base para funcionalidades futuras que SIGMA no ofrece.

## 2. Punto de partida (lo que ya existe)

- La app tiene rol docente básico: `TeacherRepository` llama endpoints SIGMA
  (`Teacher/GetInfoDocenteV1`, `ListarEstudianteComple`, `NotasEstudianteResumenV1`,
  asistencia, edición de notas) **con el token del propio docente**. El scoping lo
  hace SIGMA, no nosotros.
- No hay backend propio: la app habla directo con SIGMA e Intranet.
- No hay distinción entre "docente" y "docente autorizado para Nexo": cualquier
  docente UPLA que entre a la app tiene el módulo.
- Los pagos y el horario completo del estudiante **no** son visibles para el
  docente en SIGMA. Eso es importante (ver §4).

## 3. Decisión crítica de alcance: ¿qué datos puede ver un docente?

| Dato | ¿SIGMA se lo da al docente hoy? | Riesgo | Recomendación |
|---|---|---|---|
| Notas de alumnos de sus secciones | Sí | Bajo | ✅ Incluir (fase 1) |
| Asistencia de sus secciones | Sí | Bajo | ✅ Incluir (fase 1) |
| Horario del alumno (completo) | No | Medio | ⚠️ Solo con consentimiento del alumno |
| Pagos/deudas del alumno | **No** | **Alto** | ❌ No por defecto; solo consentimiento explícito o rol administrativo avalado por UPLA |

**Por qué:** la Ley N.º 29733 (Protección de Datos Personales, Perú) exige base
legal para cada tratamiento. Cuando el docente ve notas de su sección, la base es
la relación académica (lo mismo que ya le da SIGMA). Pero los **datos financieros
de un estudiante son datos de terceros que la universidad nunca puso a disposición
del docente**: dárselos nosotros crea un tratamiento sin base legal, con
responsabilidad directa para el proyecto. La salida limpia:

- **Modelo de consentimiento**: el estudiante, desde su app, autoriza compartir
  módulos concretos (horario, avance, pagos) con un docente concreto (ej. su
  tutor/asesor). Consentimiento granular, con fecha, revocable, auditado. Esto es
  exactamente lo que la ley pide y además es un feature diferenciador honesto.
- Si UPLA algún día avala un rol "tutor académico" con más visibilidad, se agrega
  como rol del backend sin rediseñar nada.

## 4. Arquitectura propuesta

```
┌──────────────┐        ┌──────────────────────────────┐
│  Nexo app     │ HTTPS  │  Backend Elixir (Phoenix)     │
│  (estudiante/ │───────▶│  - Auth propia (JWT corto +   │
│   docente)    │        │    refresh, revocables)       │
└──────────────┘        │  - Allowlist de docentes      │
                        │  - Autorización por sección   │
                        │  - Consentimientos            │
                        │  - Auditoría de accesos       │
                        │  - Snapshots compartidos      │
                        └──────────┬───────────────────┘
                                   │ (verificación de identidad
                                   │  en el login, vía SIGMA)
                              ┌────▼────┐   ┌──────────┐
                              │  SIGMA  │   │ Postgres │
                              └─────────┘   └──────────┘
```

### Principios de diseño

1. **El backend nunca almacena contraseñas UPLA.** En el login, verifica la
   identidad haciendo un login de paso contra SIGMA (o validando el JWT de SIGMA
   que la app ya tiene) y a partir de ahí emite **sus propios tokens**. Las
   credenciales viajan una vez y no se persisten.
2. **Los datos del estudiante llegan por consentimiento, no por scraping central.**
   La app del estudiante (que ya tiene sus datos de SIGMA/Intranet) sube un
   snapshot de los módulos que el estudiante decidió compartir. El backend nunca
   tiene credenciales de estudiantes ni consulta el Intranet en su nombre.
   - Ventaja legal: cada dato en el backend tiene un consentimiento asociado.
   - Ventaja técnica: no hay que replicar el scraping del Intranet en Elixir ni
     mantener sesiones de cientos de estudiantes.
   - Contra conocida: el snapshot se actualiza cuando el estudiante abre su app.
     Aceptable para tutoría; se mitiga con push silencioso más adelante.
3. **Autorización en dos capas**: (a) allowlist — ser docente UPLA no basta, el
   acceso especial se otorga por registro (aprobación manual del equipo o de un
   coordinador); (b) scoping — cada consulta valida docente→sección→alumno contra
   la matrícula vigente o contra un consentimiento activo.
4. **Auditoría total**: toda lectura de datos de un alumno queda registrada
   (quién, qué, de quién, cuándo, desde dónde). La ley exige poder demostrarlo y
   es la única defensa seria ante un reclamo.

### Stack

- **Phoenix 1.8** (API JSON; LiveView opcional para un panel admin interno).
- **PostgreSQL** (Ecto). Cifrado at-rest de campos sensibles con `cloak_ecto`.
- **Auth**: `Phoenix.Token` o `Joken` para JWT cortos (15 min) + refresh tokens
  opacos revocables en DB. Argon2 solo si algún día hay cuentas con contraseña
  propia (admins).
- **Rate limiting**: `hammer`. **CORS** cerrado (solo la app).
- **Despliegue**: Fly.io o un VPS con releases de Elixir (`mix release`).
  Fly tiene free tier suficiente para empezar; Postgres gestionado pequeño.
- **Observabilidad**: `telemetry` + logs estructurados; Sentry (`sentry-elixir`).

### Modelo de datos (mínimo viable)

```
teachers            id, sigma_code, nombre, estado(pendiente|autorizado|suspendido),
                    autorizado_por, autorizado_en
teacher_sections    teacher_id, periodo, cle_auto/seccion, fuente(sigma), sync_en
students            id, codigo (SOLO código y nombre; nada más sin consentimiento)
consents            id, student_id, teacher_id, modulo(horario|notas|pagos|avance),
                    otorgado_en, revocado_en, version_terminos
snapshots           id, student_id, modulo, payload(jsonb cifrado), actualizado_en
refresh_tokens      id, subject_id, hash, expira_en, revocado_en
audit_log           id, actor(teacher_id), accion, student_id, modulo, ip, ts
```

### Endpoints (bosquejo)

```
POST /api/v1/auth/teacher/login      credenciales UPLA → verifica en SIGMA → JWT propio
POST /api/v1/auth/refresh
GET  /api/v1/teacher/me              estado de autorización, secciones
GET  /api/v1/teacher/sections/:id/students
GET  /api/v1/teacher/students/:codigo/grades     (scoped a su sección)
GET  /api/v1/teacher/students/:codigo/schedule   (requiere consentimiento)
GET  /api/v1/teacher/students/:codigo/payments   (requiere consentimiento)
-- lado estudiante --
GET/POST /api/v1/student/consents                otorgar/revocar por módulo+docente
PUT  /api/v1/student/snapshots/:modulo           subir snapshot (app estudiante)
-- admin --
GET/PUT /api/v1/admin/teachers                   aprobar/suspender allowlist
GET  /api/v1/admin/audit
```

### Decisión tomada (ago 2026) — modo piloto

- El proyecto está en proceso de legalización con decanos y profesores nombrados;
  mientras tanto se opera como **piloto de desarrollo**.
- **Opt-in de desarrollo**: a los estudiantes que ya usan Nexo se les muestra un
  mensaje en la app para **aceptar o rechazar** el uso de sus datos con fines de
  desarrollo del módulo docente. Solo los datos de quienes aceptan entran al
  backend del piloto. El consentimiento queda registrado (fecha, versión del
  texto) y es revocable desde Ajustes.
- Dentro del piloto, los docentes autorizados (allowlist) ven notas, horarios y
  pagos de los alumnos **que consintieron**, limitado a sus secciones.
- Al presentarse el proyecto y formalizarse con la universidad, se migra del
  opt-in de desarrollo a la base legal institucional y datos reales completos.

## 5. Fases

- **F0 — Decisiones y base legal (antes de codear)**: cerrar el alcance de §3;
  redactar consentimiento y nueva política de privacidad; definir quién aprueba
  la allowlist. *Ideal: buscar una no-objeción escrita de UPLA (ver §7).*
- **F1 — Esqueleto**: proyecto Phoenix, auth docente (verificación vía SIGMA +
  allowlist), tokens, auditoría, panel admin mínimo. Sin datos de alumnos aún.
- **F2 — Paridad SIGMA**: notas/asistencia de sus secciones a través del backend
  (el backend actúa de proxy autorizado con el token del docente), ya con
  auditoría y scoping propios. La app docente migra de llamar SIGMA directo a
  llamar al backend.
- **F3 — Consentimiento estudiante**: UI en la app del estudiante para compartir
  horario/avance/pagos con un docente; snapshots; vistas del docente.
- **F4 — Extras**: notificaciones push, mensajería/avisos por sección, exportes.

## 6. Términos y condiciones — qué les falta hoy

Los T&C actuales están pensados para "app personal que usa tus propias
credenciales". Con el backend cambia la naturaleza del producto. Deben añadirse:

1. **Identidad del responsable** del tratamiento (nombre, contacto real).
2. **Política de privacidad separada** de los T&C (las stores la exigen como URL
   pública): qué datos se recogen, finalidad, plazo de conservación, encargados
   (hosting), derechos ARCO y canal para ejercerlos, y que las credenciales UPLA
   no se transmiten a terceros ni se almacenan en el backend.
3. **Sección específica de cuentas docentes**: alcance del acceso, prohibición de
   uso fuera de la finalidad académica, responsabilidad del docente sobre lo que
   consulta, y que todo acceso queda auditado.
4. **Consentimiento granular del estudiante** para compartir módulos, con
   revocación en cualquier momento y efecto inmediato.
5. **Deslinde de UPLA**: declarar que Nexo es un proyecto independiente no
   afiliado ni avalado por la UPLA, y que la información oficial es la de los
   sistemas de la universidad.
6. **Menores de edad**: hay ingresantes de 16–17 años; la ley trata sus datos
   como sensibles a efectos de consentimiento. Mencionarlo y, para el módulo de
   compartir datos, restringir a mayores de 18 o pedir declaración.
7. **Limitación de responsabilidad, ley aplicable (Perú) y jurisdicción**, y
   procedimiento de cambios de términos (aviso + re-aceptación en la app).
8. **Registro del banco de datos** ante la Autoridad Nacional de Protección de
   Datos Personales (MINJUSDH) cuando el backend entre en producción — es un
   trámite administrativo, no costoso, pero obligatorio.

## 7. Publicación en stores y legalización — evaluación honesta

**El bloqueo real no es técnico.** Flutter ya compila a las tres plataformas.

- **Windows**: ya resuelto (ZIP + asistente propio). Microsoft Store es opcional
  (cuenta $19 única, empaquetado MSIX) y elimina el problema de SmartScreen sin
  pagar certificado de firma.
- **Android / Play Store**: cuenta $25 única. Exige URL de política de privacidad
  y el formulario Data Safety (declarar que se recogen credenciales y datos
  académicos, y cómo se protegen). Riesgo de política: apps que piden credenciales
  de un servicio de terceros pueden ser cuestionadas; con transparencia total en
  la declaración suele pasar.
- **iOS / App Store**: cuenta $99/año + se necesita un Mac para compilar. El
  riesgo grande es el guideline **5.2.1** (uso de servicios de terceros sin
  autorización): si UPLA reclama, Apple baja la app. También el nombre/marca.
- **Marca "UPLA"**: el nombre, siglas y escudo son marca de la universidad. En
  las stores conviene (a) no usar "UPLA" en el nombre de la app ni el ícono, y
  (b) el deslinde de §6.5. "Nexo" a secas + "para estudiantes de la UPLA" en la
  descripción es defendible como uso referencial.
- **La jugada que cambia todo**: conseguir de UPLA una **no-objeción o convenio**
  (aunque sea vía una facultad o la oficina de informática). Con eso, el riesgo
  5.2.1 desaparece, la marca se puede licenciar y el acceso docente hasta podría
  ser oficial. Sin eso, el proyecto vive en tolerancia tácita: publicable, pero
  con riesgo permanente de takedown. Recomendación: intentarlo en paralelo a F1,
  presentando el proyecto como beneficio para la universidad (ya hay usuarios
  reales y el backend añade auditoría que el scraping directo no tiene).

## 8. Riesgos principales

| Riesgo | Mitigación |
|---|---|
| UPLA pide bajar la app / cambia SIGMA | Deslinde + no-objeción; capa Resolver ya aísla las fuentes |
| Filtración de datos del backend | Minimizar datos (solo snapshots consentidos), cifrado, auditoría, tokens cortos |
| Docente abusa del acceso | Allowlist + scoping + auditoría + términos específicos |
| Rechazo en App Store (5.2.1) | Lanzar Android/Windows primero; iOS tras no-objeción |
| Costo/mantenimiento del backend | Fly.io free tier; Elixir es barato de operar; empezar solo con F1–F2 |
