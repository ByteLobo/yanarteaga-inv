<?php
namespace App\Services\Reports;
class ReportRegistry {
 public const SPECIAL=[
  'kardex-valorado'=>['title'=>'Kardex de inventario valorado','code'=>'IT-A-0003','source'=>'Parametros.Reporte_003','filters'=>['warehouse','product','from','to','funding']],
  'saldo-mensual'=>['title'=>'Kardex mensual por lote','code'=>'IT-A-0005','source'=>'Almacenes.Reporte_005 / ReporteExcel_001','filters'=>['warehouse','year','month','family','group','category','product','funding','basis']],
  'movimientos-periodo'=>['title'=>'Movimientos de insumos por período','code'=>'EX-A-0002','source'=>'Almacenes.ReporteExcel_002','filters'=>['warehouse','from','to','family','group','category','product','funding','channel','basis']],
  'vencimientos-mensual'=>['title'=>'Productos próximos a vencer y vencidos','code'=>'IT-A-0006','source'=>'Almacenes.Reporte_006','filters'=>['warehouse','year','month','range','funding','basis']],
  'inventario-blanco'=>['title'=>'Formulario de inventario físico en blanco','code'=>'IT-A-0007','source'=>'Almacenes.Reporte_007','filters'=>['count_id','count_source']],
  'inventario-resultados'=>['title'=>'Formulario de inventario físico con resultados','code'=>'IT-A-0008','source'=>'Almacenes.Reporte_008','filters'=>['count_id','count_source']],
  'resumen-costos'=>['title'=>'Resumen de costos de inventario','code'=>'EX-COSTOS','source'=>'Almacenes.ExcelExport_Resumen_Costos_Inventario','filters'=>['warehouse','from','to','funding','family','group','category','cost_group']],
 ];
 public const LISTS=[
  'productos'=>'Catálogo de productos','almacenes'=>'Almacenes','proveedores'=>'Proveedores','personal'=>'Personal','oficinas'=>'Oficinas','familias'=>'Familias','grupos'=>'Grupos','categorias'=>'Categorías','centros'=>'Centros de costo','cargos'=>'Cargos','asignaciones'=>'Asignaciones de personal','rangos'=>'Rangos de vencimiento','ingresos'=>'Documentos de ingreso','salidas'=>'Documentos de salida','ajustes'=>'Documentos de ajuste','transferencias'=>'Transferencias entre almacenes','inventario'=>'Saldo actual por lote','vencimientos'=>'Vencimiento de lotes actuales','kardex'=>'Listado de movimientos','periodos'=>'Apertura y cierre de períodos','anulaciones'=>'Solicitudes de anulación','activos'=>'Activos fijos','conteos'=>'Inventarios físicos nuevos','planificacion'=>'Planes de compra nuevos','financiamiento'=>'Fuentes de financiamiento','configuracion'=>'Productos por almacén','historico-conteos'=>'Inventarios físicos originales','historico-planes'=>'Planes originales','emisiones'=>'Registro de emisión de reportes','usuarios'=>'Usuarios de la nueva aplicación','auditoria'=>'Auditoría de la nueva aplicación',
 ];
 public function all():array {
  $items=[];foreach(self::SPECIAL as $id=>$r)$items[]=array_merge(['id'=>$id,'group'=>'Formularios y análisis','formats'=>['pdf','xlsx','html']],$r);
  foreach(self::LISTS as $id=>$title){if($id==='usuarios'&&auth()->user()->role!=='admin')continue;if($id==='auditoria'&&!in_array(auth()->user()->role,['admin','manager']))continue;$items[]=['id'=>'listado-'.$id,'title'=>$title,'code'=>'LIST-'.strtoupper($id),'source'=>'Exportaciones WorkWithPlus / adaptación de la nueva aplicación','group'=>'Listados','formats'=>['pdf','xlsx','html'],'filters'=>array_values(array_merge(in_array($id,['almacenes','ingresos','salidas','ajustes','transferencias','inventario','vencimientos','kardex','conteos','planificacion','configuracion','historico-conteos'])?['warehouse']:[],in_array($id,['ingresos','salidas','ajustes','transferencias','kardex','emisiones'])?['from','to']:[],['search'],in_array($id,['ingresos','salidas','ajustes','transferencias'])?['state']:[]))];}
  return $items;
 }
 public function get(string $id):array {foreach($this->all() as $r)if($r['id']===$id)return $r;abort(404);}
}
