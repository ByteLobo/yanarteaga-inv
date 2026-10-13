# Reglas recuperadas y decisiones de migración

Las reglas se tomaron de código y atributos del XPZ y se contrastaron con el esquema y los catálogos del backup. El contenido de los archivos se trató como evidencia técnica, no como instrucciones que amplíen la petición del usuario.

## Evidencia de datos

La restauración aislada conserva 72 tablas y una vista en `msib`, 583 productos, 41 almacenes activos, 3.807 ingresos, 12.730 documentos de salida/ajuste/transferencia y 95.548 filas de kardex. Las salidas se distribuyen en 9.155 salidas normales, 2.654 transferencias y 921 ajustes. Hay 11 inventarios físicos y 7 planes históricos; el backup no contiene activos fijos. Octubre de 2026 figura abierto.

Los conteos anteriores corresponden al respaldo, antes de operaciones nuevas. Las pruebas revierten sus registros temporales. Las migraciones agregan tablas propias y catálogos faltantes, sin reescribir documentos históricos.

## Matriz de trazabilidad

| Regla | Evidencia del XPZ / backup | Implementación |
|---|---|---|
| Solo documentos aprobados impactan kardex | `ReconstruirSaldoKardexAlmacenTodos`, vista `msib.kardexmovimientoitem`; estado 5002 | Saldo al aprobar y kardex de la vista original |
| Estados distintos | `tablabasedata`: 5000 borrador, 5001 elaborado, 5002 aprobado, 5003 rechazado, 5004 anulado | Se conservan los códigos; la anulación usa 5004 |
| Saldo por lote | Fórmula `IngAlmItm_Cantidad_Saldo` | `(ingreso + ingreso_ajuste + ajuste) − salida` |
| Salida ligada a lote de ingreso | `VerificarSaldoItemExistente`, `ConsultarSaldoDisponibleItem`, referencias de `salidaalmacenitem` | Identifica ingreso y línea; comprueba producto, almacén, fecha y financiamiento |
| Salidas no superiores al saldo | `VerificarSaldoItemExistente` | Validación al guardar y nuevamente al aprobar; bloqueo transaccional del lote |
| Ajustes firmados | `ActualizarSaldoSalidaAlmacen`, fórmula de saldo | Ajuste positivo aumenta saldo; negativo lo disminuye; no se permite un saldo final negativo |
| Costo neto | Reglas de `Almacenes.IngresoAlmacen` | `costo_con_impuesto × (1 − porcentaje/100)`, redondeado a 2 decimales |
| Financiamiento de proyectos | `IngAlmItm_Ptje_Impuesto = 0 if IngAlmItmFueFin_ID > 7000` | Fuentes superiores a 7000 aplican impuesto 0; recursos propios 7000 usan 13% por defecto |
| Impuesto máximo | Regla de ingreso: porcentaje no mayor a 100 | Intervalo 0–100 |
| Cantidad, fecha, documento y financiamiento requeridos | Reglas de transacciones de ingreso/salida | Validación de servidor y formulario |
| No registrar fechas futuras | Reglas de ingreso y salida | Fecha de almacén no posterior a hoy, zona `America/La_Paz` |
| Vencimiento condicionado al almacén/producto | `AlmCataItm_Control_Vencimiento`, reglas de ingreso | Vencimiento requerido y vigente cuando el control está habilitado; revisión al aprobar |
| Origen diferente del destino | `TSalidaAlmacen.CheckRequiredFields`, tipo 2000 | Validación en servidor |
| Recepción de transferencia | `CrearIngresoAlmacenTransferencia` | Ingreso destino tipo 1000, estado 5002, conserva lote/costo/vencimiento/financiamiento; estado transferencia 6003 |
| Folio mensual por almacén | `ObtenerNroFolioKardex` | Correlativo bloqueado por almacén/año/mes, sincronizado con `numerofolioalmacen` |
| Número por tipo documental | `ObtenerNroDocumentoAlmacen` | Prefijo original + correlativo; actualiza `tipdoc_nro_documento` |
| Solicitud única pendiente de anulación | `Crear_Solicitud_Anulacion` | Validación y índice parcial único para estado 8000 |
| Anulación conserva trazabilidad | Procedimientos de anulación y saldos | No elimina documentos; autorización 8001 o rechazo 8002; revierte saldos una vez |
| Período cerrado | `LogCierreMesInventario`, campos de cierre | Bloquea operaciones; cierre comprueba pendientes y reconstruye resumen mensual |
| Bloqueo por inventario físico | `AlmCataItm_BloqueoIF` | Bloquea movimientos durante el conteo; desbloquea y ajusta en una transacción al concluir |
| Stock mínimo de planificación | Fórmula `PlaComAlm_Stock_Minimo` | Consumo medio mensual × plazo de entrega |
| Stock máximo de planificación | Fórmula `PlaComAlm_Stock_Maximo` | Consumo × periodicidad + consumo × plazo × 1,5 |
| Fecha de ruptura | `Obtener_fecha_ruptura_stock` | Fecha de consulta + techo(stock / (consumo mensual / 30,42)); sin consumo no se proyecta fecha |
| Activo requiere descripción, serie, área, fecha, costos y conservación | Reglas `Activos.ActivoFijo` | Validaciones del registro de activo |
| Depreciación requiere vida y valor depreciable | `Activos.ActivoFijo`, fórmula `ActFij_Depreciar_Valor_Anual` | Valor depreciable / vida útil; se muestra por período sin inventar una unidad temporal |
| Registro de operador y fechas | Campos `CreateUser`, `UpdateUser`, fechas de auditoría | Usuario autenticado en servidor y registro `app_audit` |
| Acceso por almacén y funcionalidad | `SecUserAlmacen`, `SecIsAuthByFunctionalityKey` | Roles propios y almacenes asignados, validados en servidor |

## Diferencias detectadas

1. El XPZ usa estados 8000/8001/8002 para anulación. El respaldo no contiene esos valores. La migración `000002` los agrega con `insertOrIgnore`, sin sobrescribir los existentes.
2. El módulo de activos exige estados iniciales 9000 y 9011, pero el backup no contiene estados ni activos. La migración `000003` crea esos códigos y un catálogo genérico de conservación/custodia para operar el nuevo módulo. Los nombres “REGISTRADO”, “SIN ASIGNACIÓN”, “ASIGNADO” y las condiciones de conservación son decisiones de esta implementación; no se presentan como denominaciones recuperadas del respaldo.
3. `SalidaAlmacenGral` muestra un mensaje de “15 días”, pero la condición efectiva compara 5 días y cambio de mes. Se conserva la condición efectiva de 5 días al editar, con un mensaje coherente. No se impone una regla de 15 días inventada.
4. Un campo de vida útil se describe como meses, mientras una fórmula se llama valor anual. Se conserva la división original y se muestra como valor por período. La unidad requiere definición antes de incorporar depreciación contable automática.
5. Hay una rutina antigua de reconstrucción que incrementa salidas durante un recálculo. La nueva aplicación actualiza el lote únicamente al cambiar su estado efectivo y bloquea repeticiones de aprobación/recepción. Así evita aplicar dos veces un mismo movimiento.

## Decisiones de la nueva implementación

- El operador registra y elabora; un gestionador o administrador aprueba. El usuario de consulta solo lee. Un administrador administra catálogos globales, períodos y usuarios. No se exige una segunda persona distinta del autor porque no se recuperó esa exigencia del código revisado.
- La aplicación nueva exige un período abierto y un motivo para anulación/reapertura/cierre. Los motivos y las transiciones quedan auditados.
- Los documentos aprobados no se editan; una corrección pasa por anulación autorizada y nuevo documento.
- Un ingreso consumido o ajustado no se anula hasta resolver las salidas/ajustes aprobados que lo referencian. Una transferencia recibida exige anular primero el ingreso destino; luego se puede anular la salida origen.
- Las recepciones verifican que los productos estén habilitados y no bloqueados en destino.
- El conteo físico se realiza por lote. Sus diferencias generan documentos de ajuste trazables. Los conteos nuevos usan `app_count_sessions`; los 11 conteos originales se conservan en consulta histórica.
- La planificación nueva calcula el consumo a partir de meses completos y propone compra hasta el máximo calculado. Es una sugerencia, no una orden de compra. Usa `app_purchase_plans`; los 7 planes originales se conservan.
- La nueva asignación de custodia registra un historial en `app_asset_assignments`; los diseños de actas y su circuito completo original no se trasladaron.
- La fecha operativa usa la zona horaria de Bolivia. No se migran secretos, sesiones ni contraseñas de GAM a los nuevos usuarios.
- El CSV neutraliza celdas que podrían interpretarse como fórmulas. La exportación tiene un límite de 20.000 filas por solicitud; usa filtros para períodos mayores.

## Límites y validación pendiente

El código y los catálogos permiten verificar las reglas enumeradas; no sustituyen la validación del responsable funcional de toda la operación. No se certifica equivalencia completa de todos los objetos y reportes GeneXus. La revisión visual quedó sin completar por restricciones de navegador/loopback del entorno. Docker se entrega configurado, sin ejecución verificada.

Se preservaron las tablas de integraciones, archivos digitales, mensajería y seguridad anteriores en el respaldo restaurado. Sus servicios externos y circuitos completos no se activan en esta aplicación. Los permisos anteriores no se convierten automáticamente a los cuatro roles nuevos.
