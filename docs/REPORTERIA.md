# Documentos y reportes de yanarteaga

La reportería se implementó revisando el código, los parámetros y los bloques de impresión del XPZ. El inventario extraído de 131 objetos con impresión o Excel está en `XPZ-REPORTES.json`: incluye formularios, exportaciones automáticas y plantillas auxiliares; no significa que existan 131 reportes independientes en el menú.

## Cómo usarlos

1. Entra en **Centro de reportes**, en la sección Análisis.
2. Selecciona un formulario o listado.
3. Completa sus filtros y presiona **Consultar reporte**.
4. Revisa los datos y usa **Ver / imprimir PDF**, **Descargar Excel** o **Vista imprimible**.

La vista previa muestra hasta 100 filas por sección. Las descargas incluyen los resultados completos según los filtros. Si el reporte supera el límite, se solicita acotar la consulta; no se entrega un archivo recortado.

Los documentos de ingreso, salida, transferencia y ajuste tienen **Imprimir PDF** y **Excel** dentro de su detalle. Los conteos nuevos también ofrecen **Formulario en blanco** y **PDF del conteo**. En los activos fijos, el botón de documento abre su ficha y constancia de custodia.

Las emisiones se consultan en **Más opciones → Emisión de reportes**. Un administrador consulta todas; cada otro usuario consulta las suyas. El registro guarda emisor, fecha, filtros, formato, referencia, número de filas y SHA-256. Guarda el registro y la huella de la descarga, no una copia archivada del archivo.

## Correspondencia con el XPZ

| Objeto original | Nuevo documento / reporte | Contenido y criterio |
|---|---|---|
| `Almacenes.Reporte_001` | IT-A-0001, ingreso | Oficina, almacén, tipo, fecha, estado, proveedor o personal, origen de transferencia, código, producto, categoría, unidad, cantidad, costo neto, lote, vencimiento, financiamiento, subtotal, total, notas y elaboración/aprobación |
| `Almacenes.Reporte_002` | IT-A-0002, salida / transferencia | Misma estructura documental; destino de transferencia y cantidades de salida |
| `Almacenes.Reporte_004` | IT-A-0004, ajuste | Cantidad de ajuste con signo y total según la fórmula del ítem original |
| `Parametros.Reporte_003` | IT-A-0003, kardex valorado | Producto y almacén obligatorios; saldo anterior, movimientos aprobados, ingresos, salidas, ajustes y saldos corridos de cantidades y costos; lote, financiamiento y vencimiento |
| `Almacenes.Reporte_005` | IT-A-0005, kardex mensual por lote | Período, clasificación, almacén, producto, lote, financiamiento, precio, cantidades y costos anteriores, ingresos, salidas, ajustes, traspasos y saldos; subtotales por producto |
| `Almacenes.ReporteExcel_001` | Excel del kardex mensual | Se conservan sus 23 columnas principales, tipos numéricos, importes y fechas de Excel |
| `Almacenes.ReporteExcel_002` | EX-A-0002, movimientos por período | Agrupa por producto, almacén y mes. Lotes/financiamiento agregados se identifican como “TODOS”. El saldo anterior se muestra en el primer mes; los saldos de meses sucesivos no se suman como un saldo final único |
| `Almacenes.Reporte_006` | IT-A-0006, vencimientos mensuales | Lotes con saldo positivo, vencimiento hasta el umbral de cada rango y días faltantes o “EXPIRADO” |
| `Almacenes.Reporte_007` | IT-A-0007, inventario físico en blanco | Conserva productos, lotes, fuente, costo y saldo del sistema; deja recuento, diferencia y observaciones en blanco |
| `Almacenes.Reporte_008` | IT-A-0008, inventario con resultados | Datos anteriores más recuento físico, diferencia física menos sistema y observaciones. Lee inventarios originales y nuevos |
| `Almacenes.ExcelExport_Resumen_Costos_Inventario` / `CargarResumenCostoInventario` | Resumen de costos | Lee el resumen histórico almacenado; filtros de período, almacén, financiamiento, clasificación y grupo de centro de costo |
| Exportaciones `WWExportReport` / `Export` de los módulos migrados | PDF y Excel de listados | Catálogos, movimientos, stock actual, períodos, solicitudes, activos, conteos, planes, usuarios y auditoría. Usa las mismas consultas y permisos que las pantallas, con todos los registros filtrados |
| `Activos.ActivoFijoWWExportReport` y entidades de actas | Ficha de activo y constancia adaptada | Características, costo, ubicación, custodio e historial de asignaciones. En el XPZ revisado no apareció un procedimiento de impresión final de acta; esta constancia se identifica como adaptación, no como reproducción de una acta original |

Los reportes automáticos de pantallas equivalentes se unifican en listados. Los objetos exclusivos de integraciones no migradas, GAM/seguridad original, mensajería y archivos digitales no se presentan como reportes operativos implementados. El catálogo JSON conserva la evidencia de esos objetos para una migración posterior de sus módulos.

## Cálculos recuperados

- **Subtotal de ingreso:** `(cantidad de ingreso + ingreso por ajuste) × costo unitario neto`.
- **Subtotal de salida/ajuste:** `(cantidad de salida + cantidad de ajuste) × costo unitario`.
- **Saldo mensual:** `anterior + ingresos − salidas + ajustes + traspasos`, tanto para cantidades como para costos.
- **Transferencia recibida (tipo 1000):** traspaso positivo, separado de los ingresos normales.
- **Transferencia enviada (tipo 2000):** traspaso negativo, separado del consumo/salidas normales.
- **Ingreso por ajuste manual (tipo 9):** se presenta en ajustes.
- **Diferencia de inventario físico:** `recuento físico − cantidad del sistema`.
- **Resumen histórico de costos:** conserva la fórmula del atributo original `ResCosInv_Costo_Saldo`: `anterior + ingresos + salidas + ajustes + traspasos`. El signo de las salidas es el almacenado; no se cambia silenciosamente por una resta.

En el kardex valorado se toma el saldo del mes anterior y se incorporan los movimientos aprobados previos al inicio dentro del mes. El filtro de financiamiento se aplica también al saldo inicial. Si la nueva app modificó meses anteriores, el cálculo en vivo arrastra esas modificaciones hasta el mes consultado.

## Consolidado histórico o cálculo en vivo

Los reportes mensuales ofrecen dos bases claramente identificadas:

- **Calcular con documentos aprobados:** parte del consolidado anterior y reconstruye el mes consultado desde ingresos/salidas aprobados. Incluye los movimientos de la nueva app y sus anulaciones. Arrastra los cambios de meses anteriores realizados por la app, con un máximo de 60 meses por reconstrucción de consulta. Este cálculo no actualiza tablas de inventario.
- **Consolidado histórico almacenado:** reproduce los valores de `kardexconsolidadomensual`. Permite contrastar el reporte con el respaldo y no se presenta como un cálculo actualizado después de operaciones nuevas.

En movimientos por período se usan meses completos, aunque los filtros indiquen días intermedios. Se corrige la selección original de rangos de año/mes para incluir períodos que cruzan de diciembre a enero.

Los rangos de vencimiento del XPZ son acumulativos: un lote puede aparecer en varios. Se conserva ese comportamiento y se explica en el documento. La comparación se hace con la fecha de emisión; el período seleccionado define el saldo histórico.

## Firmas y estados

- Se consultan primero los registros de elaboración/aprobación de la nueva app y, para documentos anteriores, `flujoaprobaciondocumento`.
- Elaborar y aprobar registra quién realizó la transición, su nombre, rol y fecha. Recibir una transferencia registra al receptor de su ingreso destino.
- Si falta un registro, el espacio de firma se deja pendiente. No se reemplaza por el nombre de quien descarga, ni por nombres ficticios.
- Los datos impresos son constancias del sistema y espacios para firma manuscrita; no se anuncian como firmas digitales certificadas.
- Borradores, elaborados sin aprobación, rechazados y anulados llevan estado destacado y marca de agua. Los aprobados se identifican mediante su estado y sus registros disponibles.
- Imprimir o descargar no elabora, aprueba, recibe, anula ni altera saldos.

## Formato y decisiones documentales

- Encabezado textual `yanarteaga`, sin logos, con código de formulario, usuario emisor, fecha y número de página.
- Se conservaron los campos y cálculos; la diagramación se adaptó a A4 legible. Los reportes muy anchos se dividen en bloques de columnas con identificadores repetidos para mantener la correspondencia entre filas.
- En el XPZ algunos formularios reutilizaban códigos/nombres de salida de otros reportes. Aquí los ocho formularios se identifican de forma coherente como IT-A-0001 a IT-A-0008.
- El QR de los formularios originales apuntaba a una URL genérica, no a una verificación del documento. No se reproduce como si validara autenticidad. El nuevo identificador de emisión permite buscar la huella registrada en la auditoría.
- Los importes se muestran en Bs con dos decimales. Las columnas monetarias y las fechas tienen tipos de Excel; los códigos se conservan como texto y no pierden ceros iniciales.
- Los campos de texto de Excel se escriben como texto explícito. El contenido que comienza con `=` no se convierte en fórmula.

## Límites y permisos

Se requiere inicio de sesión. Se verifica el alcance por almacén y se mantienen las restricciones de usuarios/auditoría de cada pantalla. Una descarga no amplía permisos ni incluye datos de almacenes no asignados.

La lectura para emitir un reporte usa una transacción PostgreSQL de solo lectura con aislamiento repetible. El registro de emisión se guarda después, sin modificar el inventario. Los PDF no cargan imágenes ni recursos remotos y no ejecutan PHP/JavaScript suministrado por datos del reporte.

Límites explícitos: 10.000 filas de reporte; PDF hasta 1.500 filas de impresión, contando los bloques; movimientos por período hasta 24 meses. Si se supera un límite, se devuelve un mensaje para acotar filtros o usar Excel. No se truncan descargas.

## Archivos y actualización

Código: `app/Services/Reports`, `app/Http/Controllers/ReportController.php`, `resources/views/reports/document.blade.php`, `resources/js/report-center.jsx` y migración `000004_create_document_reporting`.

En la copia preparada ya se ejecutó la migración. Para actualizar otra instalación:

```powershell
composer install
php artisan migrate
npm ci
npm run build
```

La dependencia PDF es Dompdf 3.1.6, bloqueada en `composer.lock`. Excel se genera como XLSX con `ZipArchive`. Se necesitan las extensiones PHP existentes `dom`, `mbstring`, `zip`, `pdo_pgsql` y `fileinfo`. Las plantillas no requieren conexión a un servicio de conversión.

La suite de reportería cubre documentos, PDF, Excel, huellas, firmas, estados, saldos, ajustes, transferencias, apertura arrastrada, cruce de año, filtros, permisos y formularios de conteo. Los seis PDF de muestra se renderizaron y revisaron visualmente; los XLSX se abrieron con openpyxl para comprobar su estructura, tipos y ausencia de fórmulas inyectadas. La interfaz compiló; su revisión en navegador sigue limitada por el entorno local.
