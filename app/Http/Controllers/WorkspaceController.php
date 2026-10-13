<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;

use Illuminate\Support\Facades\DB;

use Illuminate\Support\Facades\Hash;

use Illuminate\Validation\Rule;

use App\Models\User;

use App\Services\InventoryService;

use App\Support\Legacy as L;

use Carbon\Carbon;

class WorkspaceController extends Controller {

 public function __construct(private InventoryService $inventory){}

 private const CATALOGS=[

  'productos'=>['catalogoitem','cataitm_id',['cataitm_id','cataitm_nombre','catitm_id','cataitmunimed_id','cataitm_activo']],

  'almacenes'=>['almacen','alm_id',['alm_id','alm_nombre','ofi_id','almfuefin_id','alm_activo','alm_fecha_inicio_operacion']],

  'proveedores'=>['proveedor','prv_id',['prv_id','prv_nombre','prv_telefono_fijo','prv_telefono_movil','prv_direccion','prvtipprv_id','prv_activo']],

  'personal'=>['personal','per_id',['per_id','per_nombres','per_primer_apellido','per_segundo_apellido','per_nro_documento','per_cargo','per_activo']],

  'oficinas'=>['oficinas','ofi_id',['ofi_id','ofi_nombre','ofi_direccion','ofi_telefono','ofican_id','ofi_id_nodo_superior','ccos_id','ofi_activo']],

  'familias'=>['familiaitem','famitm_id',['famitm_id','famitm_nombre','famitm_prefijo','famitm_tipo','famitm_activo']],

  'grupos'=>['grupoitem','gruitm_id',['gruitm_id','gruitm_nombre','famitm_id','gruitm_activo']],

  'categorias'=>['categoriaitem','catitm_id',['catitm_id','catitm_nombre','gruitm_id','catitm_activo']],

  'centros'=>['centrocosto','ccos_id',['ccos_id','ccos_nombre','ccosgru_id','ccos_activo']],

  'cargos'=>['cargo','car_id',['car_id','car_nombre','car_active']],

  'asignaciones'=>['asignacionpersonal','asgper_id',['asgper_id','asgperper_id','asgpercar_id','asgper_fecha_inicio','asgper_fecha_final','asgper_asignacion_fill','asgper_activo']],

  'rangos'=>['rangodiaexpiracion','ranexp_id',['ranexp_id','ranexp_descripcion','ranexp_valor_dia']],

 ];

 private function manager():void{if(!in_array(auth()->user()->role,['admin','manager']))abort(403);}

 private function admin():void{if(auth()->user()->role!=='admin')abort(403);}

 public function session(){return ['user'=>auth()->user()?->only(['id','name','username','role']),'csrf'=>csrf_token()];}

 public function login(Request $r){$v=$r->validate(['username'=>'required|string','password'=>'required|string']);if(!Auth::attempt($v))InventoryService::fail('Usuario o contraseña incorrectos.');$r->session()->regenerate();return $this->session();}

 public function logout(Request $r){Auth::logout();$r->session()->invalidate();$r->session()->regenerateToken();return ['ok'=>true];}

 private function scope($q,$column,Request $r){$u=auth()->user();if($u->role!=='admin')$q->whereIn($column,json_decode($u->warehouses??'[]',true)??[]);if($r->filled('warehouse')){$this->inventory->authorize((int)$r->warehouse);$q->where($column,(int)$r->warehouse);}return $q;}

 private function lots(Request $r){

  $q=L::table('ingresoalmacenitem as l')->join('msib.ingresoalmacen as h','h.ingalm_id','=','l.ingalm_id')->join('msib.catalogoitem as c','c.cataitm_id','=','l.cataitm_id')->join('msib.almacen as a','a.alm_id','=','l.almcataitmalm_id')->leftJoin('msib.tablabasedata as f','f.tabbasdat_id','=','l.ingalmitmfuefin_id')->leftJoin('msib.almacencatalogoitem as cfg',function($j){$j->on('cfg.cataitm_id','=','l.cataitm_id')->on('cfg.almcataitmalm_id','=','l.almcataitmalm_id');})->where('h.ingalm_estado_id',5002);

  return $this->scope($q,'l.almcataitmalm_id',$r)->selectRaw("l.ingalm_id as receipt_id,l.ingalmitm_id as receipt_line_id,l.cataitm_id as product_id,c.cataitm_nombre as producto,l.almcataitmalm_id as warehouse_id,a.alm_nombre as almacen,l.ingalmitm_lote as lote,l.ingalmitm_fecha_exp as vencimiento,l.ingalmitmfuefin_id as funding_id,f.tabbasdat_descripcion as financiamiento,(l.ingalmitm_cantidad_ingreso+l.ingalmitm_cantidad_ingreso_ajuste+l.ingalmitm_cantidad_ajuste-l.ingalmitm_cantidad_salida) as saldo,l.ingalmitm_costo_unitario as costo,cfg.almcataitm_stock_min as minimo,cfg.almcataitm_stock_max as maximo,cfg.almcataitm_control_stock as controlar_stock,cfg.almcataitm_control_vencimiento as controlar_vencimiento");

 }

 public function bootstrap(Request $r){

  $lots=$this->lots($r)->get();$positive=$lots->where('saldo','>',0);$warehouses=$this->scope(L::table('almacen'),'alm_id',$r)->orderBy('alm_nombre')->get(['alm_id as id','alm_nombre as name','alm_activo as active']);

  $products=L::table('catalogoitem')->orderBy('cataitm_nombre')->get(['cataitm_id as id','cataitm_nombre as name','cataitm_activo as active','catitm_id as category']);

  $pending=$this->scope(L::table('ingresoalmacen'),'ingalmalm_id',$r)->whereIn('ingalm_estado_id',[5000,5001])->count()+$this->scope(L::table('salidaalmacen'),'salalmalm_id',$r)->whereIn('salalm_estado_id',[5000,5001])->count();

  $cutoff=today()->addDays(90)->toDateString();$expiry=$positive->filter(fn($l)=>$l->controlar_vencimiento&&$l->vencimiento&&$l->vencimiento<=$cutoff);

  $group=$lots->groupBy(fn($l)=>$l->warehouse_id.':'.$l->product_id);$low=$group->filter(fn($g)=>$g->first()->controlar_stock&&$g->sum('saldo')<$g->first()->minimo)->count();

  $trend=$this->scope(L::table('kardexmovimientoitem'),'almcataitmalm_id',$r)->where('karmovitm_fecha','>=',today()->subMonths(5)->startOfMonth())->selectRaw("to_char(karmovitm_fecha,'YYYY-MM') as mes,sum(karmovitm_cantidad_ingreso) as ingresos,sum(karmovitm_cantidad_salida) as salidas")->groupByRaw("to_char(karmovitm_fecha,'YYYY-MM')")->orderBy('mes')->get();

  return ['user'=>auth()->user()->only(['id','name','username','role']),'today'=>today()->toDateString(),'warehouses'=>$warehouses,'products'=>$products,'lots'=>$positive->values(),'config'=>$this->scope(L::table('almacencatalogoitem'),'almcataitmalm_id',$r)->get(),'funding'=>L::table('tablabasedata')->where('tabbasgru_id',7)->get(['tabbasdat_id as id','tabbasdat_descripcion as name']),'categories'=>L::table('categoriaitem')->get(['catitm_id as id','catitm_nombre as name']),'base'=>L::table('tablabasedata')->get(['tabbasdat_id as id','tabbasdat_descripcion as name','tabbasgru_id as group']),'types'=>L::table('tipodocumento')->get(['tipdoc_id as id','tipdoc_nombre as name']),'suppliers'=>L::table('proveedor')->get(['prv_id as id','prv_nombre as name']),'people'=>L::table('asignacionpersonal')->get(['asgper_id as id','asgper_asignacion_fill as name']),'custodians'=>L::table('personal')->get(['per_id as id','per_nombres_fill as name']),'offices'=>L::table('oficinas')->get(['ofi_id as id','ofi_nombre as name']),'stats'=>['productos'=>$products->count(),'almacenes'=>$warehouses->where('active',1)->count(),'valor'=>$positive->sum(fn($l)=>$l->saldo*$l->costo),'pendientes'=>$pending,'vencimientos'=>$expiry->count(),'bajo_stock'=>$low],'trend'=>$trend,'alerts'=>$expiry->sortBy('vencimiento')->take(7)->values(),'period'=>L::table('logcierremesinventario')->where('logcieinv_anio',today()->year)->where('logcieinv_mes',today()->month)->first(),'csrf'=>csrf_token()];

 }

 public function records(Request $r,string $module){

  if(isset(self::CATALOGS[$module])){[$table,$id,$cols]=self::CATALOGS[$module];$q=L::table($table)->select($cols);if($module==='almacenes')$this->scope($q,'alm_id',$r);$q->orderBy($id);$fields=DB::select("select column_name,data_type,character_maximum_length,is_nullable from information_schema.columns where table_schema='msib' and table_name=?",[$table]);return $this->paginate($q,$r,['fields'=>$fields,'editable'=>$cols,'key'=>$id]);}

  if(in_array($module,['ingresos','salidas','ajustes','transferencias'])){

   $in=$module==='ingresos';$p=$in?'ingalm':'salalm';$q=L::table(($in?'ingresoalmacen':'salidaalmacen').' as d')->join('msib.almacen as a','a.alm_id','=','d.'.$p.'alm_id')->join('msib.tipodocumento as t','t.tipdoc_id','=','d.'.$p.'tipdoc_id');

   if(!$in){if($module==='ajustes')$q->whereIn('d.salalmtipdoc_id',[6,7]);elseif($module==='transferencias')$q->where('d.salalmtipdoc_id',2000);else $q->whereNotIn('d.salalmtipdoc_id',[6,7,2000]);}

   $this->scope($q,'d.'.$p.'alm_id',$r);$q->select(['d.'.$p.'_id as id','d.'.$p.'_nro_documento as documento','d.'.$p.'_fecha_almacen as fecha','a.alm_nombre as almacen','d.'.$p.'alm_id as warehouse_id','t.tipdoc_nombre as tipo','d.'.$p.'_estado_id as estado','d.'.$p.'_createuser as creado_por','d.'.$p.'_glosa as detalle']);if(!$in)$q->addSelect('d.salalm_estadotrans_id as recepcion');if($r->filled('state'))$q->where('d.'.$p.'_estado_id',$r->state);if($r->filled('from'))$q->where('d.'.$p.'_fecha_almacen','>=',$r->from);if($r->filled('to'))$q->where('d.'.$p.'_fecha_almacen','<=',$r->to);$q->orderByDesc('d.'.$p.'_fecha_almacen')->orderByDesc('d.'.$p.'_nro_folio');return $this->paginate($q,$r);

  }

  if(in_array($module,['inventario','vencimientos'])){

   $q=$this->lots($r)->whereRaw('(l.ingalmitm_cantidad_ingreso+l.ingalmitm_cantidad_ingreso_ajuste+l.ingalmitm_cantidad_ajuste-l.ingalmitm_cantidad_salida) != 0');if($module==='vencimientos')$q->where('cfg.almcataitm_control_vencimiento',1)->where('l.ingalmitm_fecha_exp','<=',today()->addDays((int)$r->input('days',90)));$q->orderBy('l.ingalmitm_fecha_exp')->orderBy('c.cataitm_nombre');return $this->paginate($q,$r);

  }

  if($module==='kardex'){$q=$this->scope(L::table('kardexmovimientoitem as k')->join('msib.catalogoitem as c','c.cataitm_id','=','k.cataitm_id'),'k.almcataitmalm_id',$r)->select(['k.karmovitm_fecha as fecha','k.cataitm_id as codigo','c.cataitm_nombre as producto','k.karmovitm_tipo as tipo','k.karmovitm_nro_documento as documento','k.karmovitm_lote as lote','k.karmovitm_cantidad_ingreso as ingreso','k.karmovitm_cantidad_salida as salida','k.karmovitm_cantidad_ajuste as ajuste','k.karmovitm_costo_unitario as costo','k.karmovitm_usuario as usuario']);if($r->filled('from'))$q->where('k.karmovitm_fecha','>=',$r->from);if($r->filled('to'))$q->where('k.karmovitm_fecha','<=',$r->to);if($r->filled('product'))$q->where('k.cataitm_id',$r->product);return $this->paginate($q->orderByDesc('k.karmovitm_nro_orden'),$r);}

  if($module==='periodos')return $this->paginate(L::table('logcierremesinventario')->select(['logcieinv_anio as anio','logcieinv_mes as mes','logcieinv_estado as estado','logcieinv_comentario as comentario','logcieinv_abierto_user as abierto_por','logcieinv_cerrado_user as cerrado_por'])->orderByDesc('logcieinv_anio')->orderByDesc('logcieinv_mes'),$r);

  if($module==='anulaciones'){$q=L::table('autorizacionanulacion as n')->leftJoin('msib.ingresoalmacen as i','i.ingalm_id','=','n.autanu_transaccion_id')->leftJoin('msib.salidaalmacen as s','s.salalm_id','=','n.autanu_transaccion_id');$this->scope($q,DB::raw('COALESCE(i.ingalmalm_id,s.salalmalm_id)'),$r);return $this->paginate($q->selectRaw("n.autanu_id as id,n.autanu_transaccion_id as document_id,n.autanu_transaccion_descripcion as documento,n.autanu_fecha_solicitud as fecha,n.autanu_username_solicitud as solicitante,n.autanu_estado_id as estado,n.autanu_nota as nota,case when i.ingalm_id is not null then 'ingresos' when s.salalmtipdoc_id=2000 then 'transferencias' when s.salalmtipdoc_id in (6,7) then 'ajustes' else 'salidas' end as kind")->orderByDesc('n.autanu_fecha_solicitud'),$r);}

  if($module==='activos'){$q=L::table('activofijo as a')->leftJoin('msib.personal as p','p.per_id','=','a.actfij_cus_id')->join('msib.oficinas as o','o.ofi_id','=','a.ofi_id');$this->assetScope($q);return $this->paginate($q->select(['a.actfij_id as id','a.actfij_codigo as codigo','a.actfij_descripcion as descripcion','a.actfij_marca as marca','a.actfij_serie as serie','a.actfij_costo_activo_ml as costo','a.actfij_estado_bien_descripcion as estado','p.per_nombres_fill as custodio','o.ofi_nombre as oficina'])->orderBy('a.actfij_codigo'),$r);}

  if($module==='conteos')return $this->paginate($this->scope(DB::table('app_count_sessions'),'warehouse_id',$r)->select(['id','warehouse_id as almacen','date as fecha','status as estado','actor as encargado','notes as notas','lines'])->orderByDesc('created_at'),$r);

  if($module==='planificacion')return $this->paginate($this->scope(DB::table('app_purchase_plans'),'warehouse_id',$r)->select(['id','warehouse_id as almacen','months as meses','actor as creado_por','created_at as fecha','lines'])->orderByDesc('created_at'),$r);

  if($module==='auditoria'){$this->manager();$q=DB::table('app_audit');if(auth()->user()->role!=='admin')$q->where('actor',auth()->user()->username);return $this->paginate($q->select(['id','created_at as fecha','actor as usuario','action as accion','reference as referencia','detail'])->orderByDesc('id'),$r);}

  if($module==='usuarios'){$this->admin();return $this->paginate(DB::table('users')->select(['id','username as usuario','name as nombre','email','role as perfil','warehouses as almacenes'])->orderBy('id'),$r);}

  if($module==='emisiones'){$q=DB::table('app_report_issues');if(auth()->user()->role!=='admin')$q->where('actor',auth()->user()->username);if($r->filled('from'))$q->whereDate('created_at','>=',$r->from);if($r->filled('to'))$q->whereDate('created_at','<=',$r->to);return $this->paginate($q->select(['id','created_at as fecha','report as reporte','reference as referencia','actor as emisor','format as formato','row_count as filas','sha256'])->orderByDesc('created_at'),$r);}
  if($module==='financiamiento')return $this->paginate(L::table('tablabasedata')->where('tabbasgru_id',7)->select(['tabbasdat_id as codigo','tabbasdat_descripcion as nombre','tabbasdat_activo as activo'])->orderBy('tabbasdat_id'),$r);

  if($module==='configuracion')return $this->paginate($this->scope(L::table('almacencatalogoitem'),'almcataitmalm_id',$r)->orderBy('cataitm_id'),$r);

  if($module==='historico-conteos')return $this->paginate($this->scope(L::table('inventariofisico'),'invfisalm_id',$r)->select(['invfis_id as id','invfis_nro_documento as documento','invfis_fecha as fecha','invfis_estado as estado','invfis_nombre_encargado as encargado','invfis_notas as notas'])->orderByDesc('invfis_fecha'),$r);

  if($module==='historico-planes')return $this->paginate(L::table('planificar_compra_ratio')->select(['placomrat_id as id','placomrat_nombre as nombre','placomrat_anio as anio','placomrat_mes as mes','placomrat_periodicidad_pedido as periodicidad','placomrat_plazo_entrega as plazo_entrega'])->orderByDesc('placomrat_anio'),$r);

  abort(404);

 }

 private function paginate($q,Request $r,array $extra=[]){

  // Apply search outside the projection so aliases and decimal fields are searchable without SQL interpolation.

  $query=DB::query()->fromSub($q,'records');if($r->filled('search'))$query->whereRaw("to_jsonb(records)::text ILIKE ?",['%'.$r->search.'%']);

  if($r->attributes->get('report_export')===true){$rows=$query->limit(10001)->get();return ['data'=>$rows->all(),'total'=>$rows->count()]+$extra;}
  if($r->boolean('export')){$rows=$query->limit(20000)->get();return response()->streamDownload(function()use($rows){$f=fopen('php://output','w');fwrite($f,"\xEF\xBB\xBF");if($rows->isNotEmpty()){fputcsv($f,array_keys((array)$rows->first()),';');foreach($rows as $row)fputcsv($f,array_map(function($v){$v=is_scalar($v)||$v===null?(string)$v:json_encode($v);return preg_match('/^[=+@\-]/',$v)?"'".$v:$v;},(array)$row),';');}fclose($f);},'exportacion.csv',['Content-Type'=>'text/csv; charset=UTF-8']);}

  $result=$query->paginate(min(100,max(10,(int)$r->input('per_page',25))));return array_merge($result->toArray(),$extra);

 }

 public function detail(string $kind,string $id){$d=$this->inventory->document($kind,$id);return ['document'=>$d,'lines'=>$this->inventory->lines($kind,$id),'requests'=>L::table('autorizacionanulacion')->where('autanu_transaccion_id',$id)->get()];}

 public function saveDocument(Request $r,string $kind){$data=$r->validate(['id'=>'nullable|uuid','warehouse_id'=>'required|integer','destination_id'=>'nullable|integer','date'=>'required|date_format:Y-m-d','type_id'=>'required|integer','funding_id'=>'required|integer','recipient_type'=>['required',Rule::in(['PROVEEDOR','PERSONAL'])],'supplier_id'=>'nullable|integer','person_id'=>'nullable|integer','notes'=>'nullable|string|max:300','lines'=>'required|array|min:1|max:500','lines.*.product_id'=>'required|string|max:20','lines.*.quantity'=>'required|integer|between:-999999,999999','lines.*.cost'=>'nullable|numeric|min:0|max:9999999','lines.*.tax'=>'nullable|numeric|between:0,100','lines.*.lot'=>'nullable|string|max:20','lines.*.expiry'=>'nullable|date_format:Y-m-d','lines.*.receipt_id'=>'nullable|uuid','lines.*.receipt_line_id'=>'nullable|integer']);return ['id'=>$this->inventory->save($kind,$data)];}

 public function action(Request $r,string $kind,string $id,string $action){$r->validate(['notes'=>'nullable|string|max:1000']);$this->inventory->action($kind,$id,$action,$r->only('notes'));return ['ok'=>true];}

 public function saveCatalog(Request $r,string $module){$this->admin();if(!isset(self::CATALOGS[$module]))abort(404);[$table,$id,$cols]=self::CATALOGS[$module];$v=$r->validate(['values'=>'required|array','original_id'=>'nullable']);$row=array_intersect_key($v['values'],array_flip($cols));if(empty($row[$id]))InventoryService::fail('El código es obligatorio.');$meta=DB::select("select column_name,data_type,character_maximum_length from information_schema.columns where table_schema='msib' and table_name=?",[$table]);$rules=[];foreach($meta as $c){if(!in_array($c->column_name,$cols))continue;$rules[$c->column_name]=in_array($c->data_type,['integer','smallint','numeric'])?'required|numeric':($c->data_type==='date'?'required|date':'nullable|string'.($c->character_maximum_length?'|max:'.$c->character_maximum_length:''));}$row=validator($row,$rules)->validate();

  DB::transaction(function()use($v,$row,$table,$id){DB::statement("select pg_advisory_xact_lock(hashtext(?))",['catalog:'.$table]);if(isset($v['original_id'])){if((string)$v['original_id']!==(string)$row[$id])InventoryService::fail('No se puede cambiar el código de un registro.');$existing=L::table($table)->where($id,$v['original_id'])->lockForUpdate()->first();if(!$existing)abort(404);$row=$this->catalogFields($table,$row);L::table($table)->where($id,$row[$id])->update($row);}else{if(L::table($table)->where($id,$row[$id])->exists())InventoryService::fail('El código ya existe.');L::insert($table,$this->catalogFields($table,$row));}L::audit('catalogo_'.$table,(string)$row[$id],$row);});return ['ok'=>true];

 }

 private function catalogFields(string $table,array $row):array {

  if($table==='personal')$row['per_nombres_fill']=trim(($row['per_nombres']??'').' '.($row['per_primer_apellido']??'').' '.($row['per_segundo_apellido']??''));

  if($table==='catalogoitem'){$cat=L::table('categoriaitem')->where('catitm_id',$row['catitm_id'])->first();$unit=L::table('tablabasedata')->where('tabbasdat_id',$row['cataitmunimed_id'])->first();if(!$cat||!$unit)InventoryService::fail('Categoría o unidad inexistentes.');$row['cataitm_cod_secuencial']=substr($row['cataitm_id'],0,10);}

  return $row;

 }

 public function period(Request $r){$this->admin();$v=$r->validate(['year'=>'required|integer|between:2000,2100','month'=>'required|integer|between:1,12','state'=>['required',Rule::in(['ABIERTO','CERRADO'])],'notes'=>'required|string|max:2000']);$date=Carbon::create($v['year'],$v['month'],1);if($date->gt(today()))InventoryService::fail('No se abren períodos futuros.');

  DB::transaction(function()use($v,$date){DB::statement("select pg_advisory_xact_lock(hashtext('periods'))");$q=L::table('logcierremesinventario')->where('logcieinv_anio',$v['year'])->where('logcieinv_mes',$v['month']);$old=(clone $q)->lockForUpdate()->first();if($v['state']==='CERRADO'){

   $pending=L::table('ingresoalmacen')->whereYear('ingalm_fecha_almacen',$v['year'])->whereMonth('ingalm_fecha_almacen',$v['month'])->whereIn('ingalm_estado_id',[5000,5001])->count()+L::table('salidaalmacen')->whereYear('salalm_fecha_almacen',$v['year'])->whereMonth('salalm_fecha_almacen',$v['month'])->whereIn('salalm_estado_id',[5000,5001])->count();if($pending)InventoryService::fail('Hay documentos pendientes: '.$pending);if(DB::table('app_count_sessions')->where('status','BORRADOR')->exists())InventoryService::fail('Hay conteos sin concluir.');

   $this->rebuildMonthly($date);

  }$row=['logcieinv_anio'=>$v['year'],'logcieinv_mes'=>$v['month'],'logcieinv_estado'=>$v['state'],'logcieinv_comentario'=>$v['notes'],'logcieinv_fecha_inicio'=>$date->toDateString(),'logcieinv_fecha_final'=>$date->copy()->endOfMonth()->toDateString(),'logcieinv_updateuser'=>auth()->user()->username,'logcieinv_updatedate'=>now()];if($v['state']==='ABIERTO'){$row['logcieinv_abierto_date']=now();$row['logcieinv_abierto_user']=auth()->user()->username;}else{$row['logcieinv_cerrado_date']=now();$row['logcieinv_cerrado_user']=auth()->user()->username;}if($old)$q->update($row);else L::insert('logcierremesinventario',$row);L::audit('periodo',$date->format('Y-m'),$v);});return ['ok'=>true];

 }

 private function rebuildMonthly(Carbon $date):void {

  $prev=$date->copy()->subMonth();L::table('kardexmovimientomensual')->where('karmovmes_anio',$date->year)->where('karmovmes_mes',$date->month)->delete();

  foreach(L::table('almacencatalogoitem')->get() as $c){$old=L::table('kardexmovimientomensual')->where('karmovmes_anio',$prev->year)->where('karmovmes_mes',$prev->month)->where('almcataitmalm_id',$c->almcataitmalm_id)->where('cataitm_id',$c->cataitm_id)->first();$m=L::table('kardexmovimientoitem')->whereYear('karmovitm_fecha',$date->year)->whereMonth('karmovitm_fecha',$date->month)->where('almcataitmalm_id',$c->almcataitmalm_id)->where('cataitm_id',$c->cataitm_id)->selectRaw('sum(karmovitm_cantidad_ingreso+karmovitm_cantidad_ajuste) as ingreso,sum(karmovitm_cantidad_salida) as salida,sum(karmovitm_costo_ingreso+karmovitm_costo_ajuste) as costo_ingreso,sum(karmovitm_costo_salida) as costo_salida')->first();L::insert('kardexmovimientomensual',['karmovmes_id'=>L::uuid(),'karmovmes_anio'=>$date->year,'karmovmes_mes'=>$date->month,'almcataitmalm_id'=>$c->almcataitmalm_id,'cataitm_id'=>$c->cataitm_id,'karmovmes_cantidad_saldo_anterior'=>$old?($old->karmovmes_cantidad_saldo_anterior+$old->karmovmes_cantidad_ingreso-$old->karmovmes_cantidad_salida):0,'karmovmes_costo_saldo_anterior'=>$old?($old->karmovmes_costo_saldo_anterior+$old->karmovmes_costo_ingreso-$old->karmovmes_costo_salida):0,'karmovmes_cantidad_ingreso'=>$m->ingreso??0,'karmovmes_cantidad_salida'=>$m->salida??0,'karmovmes_costo_ingreso'=>$m->costo_ingreso??0,'karmovmes_costo_salida'=>$m->costo_salida??0]);}

 }

 public function countInventory(Request $r){$v=$r->validate(['id'=>'nullable|uuid','warehouse_id'=>'required|integer','date'=>'required|date_format:Y-m-d','notes'=>'required|string|max:1000','lines'=>'required|array|min:1','lines.*.receipt_id'=>'required|uuid','lines.*.receipt_line_id'=>'required|integer','lines.*.count'=>'required|integer|min:0','finish'=>'boolean']);$this->inventory->authorize($v['warehouse_id'],'write');

  $id=DB::transaction(function()use($v){$this->inventory->period($v['date']);$id=$v['id']??L::uuid();$old=DB::table('app_count_sessions')->where('id',$id)->lockForUpdate()->first();if(isset($v['id'])&&!$old)abort(404);if($old&&($old->status!=='BORRADOR'||(int)$old->warehouse_id!==$v['warehouse_id']))InventoryService::fail('El conteo ya fue concluido o corresponde a otro almacén.');

   $lines=[];$seen=[];foreach($v['lines'] as $line){$key=$line['receipt_id'].':'.$line['receipt_line_id'];if(isset($seen[$key]))InventoryService::fail('Lote repetido.');$seen[$key]=true;$lot=L::table('ingresoalmacenitem')->where('ingalm_id',$line['receipt_id'])->where('ingalmitm_id',$line['receipt_line_id'])->lockForUpdate()->first();if(!$lot||(int)$lot->almcataitmalm_id!==$v['warehouse_id'])InventoryService::fail('Lote incompatible.');$head=L::table('ingresoalmacen')->where('ingalm_id',$lot->ingalm_id)->first();if($head->ingalm_estado_id!==5002)InventoryService::fail('Ingreso sin aprobar.');$cfg=L::table('almacencatalogoitem')->where('almcataitmalm_id',$v['warehouse_id'])->where('cataitm_id',$lot->cataitm_id)->lockForUpdate()->first();if(!$old&&$cfg->almcataitm_bloqueoif)InventoryService::fail('El producto ya tiene un conteo activo.');$lines[]=array_merge($line,['product_id'=>$lot->cataitm_id,'producto'=>L::table('catalogoitem')->where('cataitm_id',$lot->cataitm_id)->value('cataitm_nombre'),'system'=>$this->inventory->balance($lot),'difference'=>$line['count']-$this->inventory->balance($lot),'funding_id'=>$lot->ingalmitmfuefin_id]);

   }

   if($old){$oldLines=json_decode($old->lines,true);$before=array_map(fn($l)=>$l['receipt_id'].':'.$l['receipt_line_id'],$oldLines);sort($before);$after=array_keys($seen);sort($after);if($before!==$after)InventoryService::fail('No se pueden cambiar los lotes de un conteo iniciado.');}

   $finish=$v['finish']??false;if($finish){$this->manager();foreach($lines as $line)L::table('almacencatalogoitem')->where('almcataitmalm_id',$v['warehouse_id'])->where('cataitm_id',$line['product_id'])->update(['almcataitm_bloqueoif'=>0]);foreach($lines as $line){if($line['difference']===0)continue;$doc=$this->inventory->save('ajustes',['warehouse_id'=>$v['warehouse_id'],'date'=>$v['date'],'type_id'=>6,'funding_id'=>$line['funding_id'],'recipient_type'=>'PERSONAL','person_id'=>99999999,'notes'=>'Inventario físico '.$id,'lines'=>[['product_id'=>$line['product_id'],'quantity'=>$line['difference'],'receipt_id'=>$line['receipt_id'],'receipt_line_id'=>$line['receipt_line_id']]]]);$this->inventory->action('ajustes',$doc,'submit');$this->inventory->action('ajustes',$doc,'approve');}}

   foreach($lines as $line)L::table('almacencatalogoitem')->where('almcataitmalm_id',$v['warehouse_id'])->where('cataitm_id',$line['product_id'])->update(['almcataitm_bloqueoif'=>$finish?0:1]);

   DB::table('app_count_sessions')->updateOrInsert(['id'=>$id],['warehouse_id'=>$v['warehouse_id'],'date'=>$v['date'],'actor'=>auth()->user()->username,'status'=>$finish?'CONCLUIDO':'BORRADOR','lines'=>json_encode($lines),'notes'=>$v['notes'],'created_at'=>$old->created_at??now(),'updated_at'=>now()]);L::audit('inventario_fisico',$id,['finish'=>$finish,'lines'=>$lines]);return $id;

  });return ['id'=>$id];

 }

 private function assetScope($q):void{if(auth()->user()->role!=='admin'){$offices=L::table('almacen')->whereIn('alm_id',json_decode(auth()->user()->warehouses??'[]',true))->pluck('ofi_id');$q->whereIn('a.ofi_id',$offices);}}

 public function assignAsset(Request $r,string $id){$this->manager();$v=$r->validate(['custodian_id'=>'required|integer','office_id'=>'required|integer','notes'=>'required|string|max:1000']);DB::transaction(function()use($v,$id){$q=L::table('activofijo as a')->where('a.actfij_id',$id);$this->assetScope($q);$asset=$q->lockForUpdate()->first();if(!$asset)abort(404);if(!L::table('personal')->where('per_id',$v['custodian_id'])->where('per_activo',1)->exists())InventoryService::fail('Custodio inactivo.');if(!L::table('oficinas')->where('ofi_id',$v['office_id'])->where('ofi_activo',1)->exists())InventoryService::fail('Oficina inactiva.');if(auth()->user()->role!=='admin'&&!L::table('almacen')->whereIn('alm_id',json_decode(auth()->user()->warehouses??'[]',true))->where('ofi_id',$v['office_id'])->exists())abort(403);L::table('activofijo')->where('actfij_id',$id)->update(['actfij_cus_id'=>$v['custodian_id'],'ofi_id'=>$v['office_id'],'actfij_estado_custodia_id'=>9012,'actfij_cus_fecha_asignacion'=>today()->toDateString(),'actfij_updateuser'=>auth()->user()->username,'actfij_updatedate'=>now()]);DB::table('app_asset_assignments')->insert(['id'=>L::uuid(),'asset_id'=>$id,'custodian_id'=>$v['custodian_id'],'office_id'=>$v['office_id'],'actor'=>auth()->user()->username,'notes'=>$v['notes'],'created_at'=>now()]);L::audit('asignar_activo',$id,$v);});return ['ok'=>true];}

 public function saveConfiguration(Request $r){
  $v=$r->validate(['warehouse_id'=>'required|integer|exists:pgsql.msib.almacen,alm_id','product_id'=>'required|string|exists:pgsql.msib.catalogoitem,cataitm_id','minimum'=>'required|numeric|between:0,99999.99','maximum'=>'required|numeric|between:0,99999.99|gte:minimum','control_stock'=>'required|integer|in:0,1','control_expiry'=>'required|integer|in:0,1','control_balance'=>'required|integer|in:0,1','active'=>'required|integer|in:0,1']);$this->inventory->authorize($v['warehouse_id'],'approve');
  DB::transaction(function()use($v){$q=L::table('almacencatalogoitem')->where('almcataitmalm_id',$v['warehouse_id'])->where('cataitm_id',$v['product_id']);$old=(clone $q)->lockForUpdate()->first();if($old?->almcataitm_bloqueoif)InventoryService::fail('El producto tiene un conteo activo.');$row=['almcataitmalm_id'=>$v['warehouse_id'],'cataitm_id'=>$v['product_id'],'almcataitm_stock_min'=>$v['minimum'],'almcataitm_stock_max'=>$v['maximum'],'almcataitm_control_stock'=>$v['control_stock'],'almcataitm_control_vencimiento'=>$v['control_expiry'],'almcataitm_control_saldo'=>$v['control_balance'],'almcataitm_activo'=>$v['active'],'almcataitm_updateuser'=>auth()->user()->username,'almcataitm_updatedate'=>now()];if($old)$q->update($row);else L::insert('almacencatalogoitem',$row);L::audit('configurar_producto',$v['warehouse_id'].':'.$v['product_id'],$v);});return ['ok'=>true];
 }
 public function saveAsset(Request $r){
  $this->manager();$v=$r->validate(['code'=>'required|string|max:20','description'=>'required|string|max:200','serial'=>'required|string|max:40','brand'=>'nullable|string|max:40','model'=>'nullable|string|max:40','purchase_date'=>'required|date_format:Y-m-d|before_or_equal:today','purchase_cost'=>'required|numeric|gt:0|max:99999.99','asset_cost'=>'required|numeric|gt:0|max:99999.99','supplier_id'=>'required|integer|exists:pgsql.msib.proveedor,prv_id','category_id'=>'required|integer|exists:pgsql.msib.categoriaitem,catitm_id','office_id'=>'required|integer|exists:pgsql.msib.oficinas,ofi_id','area'=>'required|string|max:100','room'=>'nullable|string|max:100','conservation_id'=>'required|integer|in:9020,9021,9022,9023|exists:pgsql.msib.tablabasedata,tabbasdat_id','depreciate'=>'required|boolean','life'=>'required_if:depreciate,true|integer|min:1|max:32767','depreciable'=>'required_if:depreciate,true|numeric|gt:0|max:99999.99','residual'=>'nullable|numeric|min:0|max:99999.99','notes'=>'nullable|string|max:2000']);
  if(auth()->user()->role!=='admin'&&!L::table('almacen')->whereIn('alm_id',json_decode(auth()->user()->warehouses??'[]',true))->where('ofi_id',$v['office_id'])->exists())abort(403);
  $id=DB::transaction(function()use($v){DB::statement("select pg_advisory_xact_lock(hashtext(?))",['asset:'.$v['code']]);if(L::table('activofijo')->where('actfij_codigo',$v['code'])->exists())InventoryService::fail('Código de activo duplicado.');$id=L::uuid();L::insert('activofijo',['actfij_id'=>$id,'actfij_codigo'=>$v['code'],'actfij_descripcion'=>$v['description'],'actfij_serie'=>$v['serial'],'actfij_marca'=>$v['brand']??'','actfij_modelo'=>$v['model']??'','actfij_fecha_adquisicion'=>$v['purchase_date'],'actfij_fecha_alta'=>today()->toDateString(),'actfij_precio_compra_ml'=>$v['purchase_cost'],'actfij_costo_activo_ml'=>$v['asset_cost'],'prv_id'=>$v['supplier_id'],'catitm_id'=>$v['category_id'],'ofi_id'=>$v['office_id'],'actfij_ubicacion_area'=>$v['area'],'actfij_ubicacion_ambiente'=>$v['room']??'','actfij_conservacion_id'=>$v['conservation_id'],'actfij_conservacion_descripcion'=>L::table('tablabasedata')->where('tabbasdat_id',$v['conservation_id'])->value('tabbasdat_descripcion'),'actfij_estado_bien_id'=>9000,'actfij_estado_bien_descripcion'=>'REGISTRADO','actfij_estado_custodia_id'=>9011,'actfij_cus_id'=>99999999,'actfij_is_depreciar'=>$v['depreciate'],'actfij_depreciar_vidautil'=>$v['life']??0,'actfij_depreciar_valor_depreciable'=>$v['depreciable']??0,'actfij_depreciar_valor_residual'=>$v['residual']??0,'actfij_observacion'=>$v['notes']??'']);L::audit('registrar_activo',$id,$v);return $id;});return ['id'=>$id];
 }
 public function planning(Request $r){$v=$r->validate(['warehouse_id'=>'required|integer','months'=>'required|integer|between:1,24','lead_time'=>'required|numeric|between:0,12','periodicity'=>'required|numeric|between:0.1,24']);$this->inventory->authorize($v['warehouse_id'],'write');$lots=$this->lots(new Request(['warehouse'=>$v['warehouse_id']]))->get();$cons=L::table('kardexmovimientoitem')->where('almcataitmalm_id',$v['warehouse_id'])->where('karmovitm_fecha','>=',today()->startOfMonth()->subMonths($v['months']))->where('karmovitm_fecha','<',today()->startOfMonth())->groupBy('cataitm_id')->selectRaw('cataitm_id,sum(karmovitm_cantidad_salida) as consumption')->get()->keyBy('cataitm_id');$lines=[];foreach($lots->groupBy('product_id') as $key=>$group){$avg=($cons[$key]->consumption??0)/$v['months'];$stock=$group->sum('saldo');$lines[]=['product_id'=>$key,'producto'=>$group->first()->producto,'stock'=>$stock,'consumo_medio'=>round($avg,2),'stock_minimo'=>round($avg*$v['lead_time'],2),'stock_maximo'=>round($avg*$v['periodicity']+$avg*$v['lead_time']*1.5,2),'fecha_ruptura'=>$avg>0?today()->addDays((int)ceil(max(0,$stock)/($avg/30.42)))->toDateString():null,'pedido_sugerido'=>max(0,(int)ceil($avg*$v['periodicity']+$avg*$v['lead_time']*1.5-$stock))];}$id=L::uuid();DB::table('app_purchase_plans')->insert(['id'=>$id,'warehouse_id'=>$v['warehouse_id'],'months'=>$v['months'],'lines'=>json_encode($lines),'actor'=>auth()->user()->username,'created_at'=>now(),'updated_at'=>now()]);L::audit('planificar_compra',$id,$v);return ['id'=>$id,'lines'=>$lines];}

 public function saveUser(Request $r){$this->admin();$v=$r->validate(['id'=>'nullable|integer','username'=>['required','string','max:40',Rule::unique('users')->ignore($r->id)],'name'=>'required|string|max:100','email'=>['required','email',Rule::unique('users')->ignore($r->id)],'password'=>($r->id?'nullable':'required').'|string|min:12','role'=>['required',Rule::in(['admin','manager','operator','viewer'])],'warehouses'=>'required|array','warehouses.*'=>'integer|exists:pgsql.msib.almacen,alm_id']);if($r->id&&((int)$r->id===auth()->id())&&$v['role']!=='admin')InventoryService::fail('No puede quitar su propio acceso de administrador.');$u=$r->id?User::findOrFail($r->id):new User;$u->name=$v['name'];$u->username=$v['username'];$u->email=$v['email'];$u->role=$v['role'];$u->warehouses=json_encode($v['warehouses']);if(!empty($v['password']))$u->password=Hash::make($v['password']);$u->save();L::audit('guardar_usuario',(string)$u->id,['username'=>$u->username,'role'=>$u->role]);return ['ok'=>true];}

}

