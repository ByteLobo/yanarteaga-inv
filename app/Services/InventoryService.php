<?php

namespace App\Services;

use App\Support\Legacy as L;

use Illuminate\Support\Facades\DB;

use Illuminate\Validation\ValidationException;

use Carbon\Carbon;

class InventoryService {

 const APPROVED=5002;const DRAFT=5000;

 public static function fail(string $message):never{throw ValidationException::withMessages(['operation'=>$message]);}

 public function authorize(int $warehouse,string $operation='read'):void {

  $u=auth()->user();if(!$u)abort(401);if($operation!=='read'&&$u->role==='viewer')abort(403,'Su perfil es de consulta.');

  if(in_array($operation,['approve','period','cancel','users'],true)&&!in_array($u->role,['manager','admin'],true))abort(403,'Se requiere un gestionador.');

  if($u->role!=='admin'&&!in_array($warehouse,json_decode($u->warehouses??'[]',true)??[],true))abort(403,'Almacén no asignado.');

 }

 public function period(string $date,bool $lock=true):void {

  $d=Carbon::parse($date);if($d->startOfDay()->gt(today()))self::fail('La fecha no puede ser posterior a hoy.');

  $q=L::table('logcierremesinventario')->where('logcieinv_anio',$d->year)->where('logcieinv_mes',$d->month);if($lock)$q->lockForUpdate();

  $p=$q->first();if(!$p||$p->logcieinv_estado!=='ABIERTO')self::fail('El período está cerrado o no fue abierto.');

 }

 public function document(string $kind,string $id,bool $lock=false):object {

  if(!in_array($kind,['ingresos','salidas','ajustes','transferencias'],true))abort(404);

  $in=$kind==='ingresos';$p=$in?'ingalm':'salalm';$q=L::table($in?'ingresoalmacen':'salidaalmacen')->where($p.'_id',$id);if($lock)$q->lockForUpdate();$doc=$q->first();if(!$doc)abort(404);

  if(!$in){$type=(int)$doc->salalmtipdoc_id;if(($kind==='ajustes'&&!in_array($type,[6,7]))||($kind==='transferencias'&&$type!==2000)||($kind==='salidas'&&in_array($type,[6,7,2000])))abort(404);}

  $this->authorize((int)$doc->{$p.'alm_id'});return $doc;

 }

 public function balance(object $lot):int {return $lot->ingalmitm_cantidad_ingreso+$lot->ingalmitm_cantidad_ingreso_ajuste+$lot->ingalmitm_cantidad_ajuste-$lot->ingalmitm_cantidad_salida;}

 public function lines(string $kind,string $id){$p=$kind==='ingresos'?'ingalm':'salalm';return L::table($p==='ingalm'?'ingresoalmacenitem':'salidaalmacenitem')->where($p.'_id',$id)->orderBy($p.'itm_id')->get();}

 public function save(string $kind,array $data):string {

  return DB::transaction(function()use($kind,$data){

   if(!in_array($kind,['ingresos','salidas','ajustes','transferencias']))abort(404);

   $in=$kind==='ingresos';$p=$in?'ingalm':'salalm';$table=$in?'ingresoalmacen':'salidaalmacen';$w=(int)$data['warehouse_id'];$this->authorize($w,'write');$this->period($data['date']);

   if(!L::table('almacen')->where('alm_id',$w)->where('alm_activo',1)->exists())self::fail('Almacén inactivo.');

   $type=(int)$data['type_id'];$types=$in?[1,2,3,8,9]:($kind==='ajustes'?[6,7]:($kind==='transferencias'?[2000]:[4,5,10]));if(!in_array($type,$types))self::fail('Tipo de documento incompatible.');

   $destination=$kind==='transferencias'?(int)($data['destination_id']??0):$w;

   if($kind==='transferencias'){if($w===$destination)self::fail('Origen y destino deben ser diferentes.');if(!L::table('almacen')->where('alm_id',$destination)->where('alm_activo',1)->exists())self::fail('Destino inactivo.');}

   $id=$data['id']??L::uuid();$existing=isset($data['id'])?$this->document($kind,$id,true):null;

   if($existing){if($existing->{$p.'_estado_id'}!==self::DRAFT)self::fail('Solo se puede editar un borrador.');$this->period($existing->{$p.'_fecha_almacen'});if((int)$existing->{$p.'alm_id'}!==$w)self::fail('No se puede cambiar el almacén del documento.');

    if(!$in&&Carbon::parse($data['date'])->lte(Carbon::parse($existing->salalm_fecha_registro)->subDays(5))&&Carbon::parse($data['date'])->month!==Carbon::parse($existing->salalm_fecha_registro)->month)self::fail('Fecha fuera del intervalo permitido al cambiar de mes (5 días).');

   }

   $ff=(int)$data['funding_id'];if(!L::table('tablabasedata')->where('tabbasdat_id',$ff)->where('tabbasgru_id',7)->where('tabbasdat_activo',1)->exists())self::fail('Fuente de financiamiento inexistente o inactiva.');

   $recipient=$data['recipient_type']??($in?'PROVEEDOR':'PERSONAL');$supplier=$recipient==='PROVEEDOR'?(int)($data['supplier_id']??9999):9999;$person=$recipient==='PERSONAL'?(int)($data['person_id']??99999999):99999999;

   if(!L::table('proveedor')->where('prv_id',$supplier)->exists()||!L::table('asignacionpersonal')->where('asgper_id',$person)->exists())self::fail('Proveedor o asignación de personal inexistente.');

   $row=[$p.'_id'=>$id,$p.'_fecha_almacen'=>$data['date'],$p.'alm_id'=>$w,$p.'almori_id'=>$w,$p.'almdes_id'=>$destination,$p.'tipdoc_id'=>$type,$p.'_estado_id'=>self::DRAFT,$p.'fuefin_id'=>$ff,$p.'_tipo_proveedor'=>$recipient,$p.'prv_id'=>$supplier,$p.'asgper_id'=>$person,$in?'ingalm_nota':'salalmnota'=>$data['notes']??'',$p.'_glosa'=>$data['notes']??'',$p.'_serial_item'=>count($data['lines']),$p.'_updateuser'=>auth()->user()->username,$p.'_updatedate'=>now()];

   if($existing){L::table($table)->where($p.'_id',$id)->update($row);L::table($table.'item')->where($p.'_id',$id)->delete();}

   else{$row[$p.'_fecha_registro']=today()->toDateString();$row[$p.'_nro_documento']='';$row[$p.'_createuser']=auth()->user()->username;$row[$p.'_createdate']=now();if(!$in)$row['salalm_estadotrans_id']=6000;L::insert($table,$row);}

   $seen=[];foreach($data['lines'] as $i=>$line){

    $product=$line['product_id'];$config=L::table('almacencatalogoitem')->where('almcataitmalm_id',$w)->where('cataitm_id',$product)->first();

    if(!$config||$config->almcataitm_activo!==1)self::fail('Producto no habilitado para el almacén.');if($config->almcataitm_bloqueoif)self::fail('Producto bloqueado por inventario físico.');

    if(!L::table('catalogoitem')->where('cataitm_id',$product)->where('cataitm_activo',1)->exists())self::fail('Producto inactivo.');

    $qty=(int)$line['quantity'];if($kind!=='ajustes'&&$qty<=0)self::fail('La cantidad debe ser positiva.');if($kind==='ajustes'&&$qty===0)self::fail('El ajuste no puede ser cero.');

    if($in){$expiry=$line['expiry']??null;if($config->almcataitm_control_vencimiento===1&&(!$expiry||Carbon::parse($expiry)->lt(today())))self::fail('El producto requiere una fecha de vencimiento vigente.');

     $tax=$ff>7000?0:(float)($line['tax']??13);if($tax<0||$tax>100)self::fail('El impuesto debe estar entre 0 y 100.');$gross=(float)($line['cost']??0);if($gross<0)self::fail('Costo inválido.');$net=round($gross*(1-$tax/100),2);

     L::insert('ingresoalmacenitem',['ingalm_id'=>$id,'ingalmitm_id'=>$i+1,'cataitm_id'=>$product,'almcataitmalm_id'=>$w,'ingalmitm_cantidad_ingreso'=>$qty,'ingalmitm_lote'=>$line['lot']??'','ingalmitm_fecha_exp'=>$expiry,'ingalmitm_costo_unitario'=>$net,'ingalmitm_costo_unitario_con_imp'=>$gross,'ingalmitm_ptje_impuesto'=>$tax,'ingalmitmfuefin_id'=>$ff]);

    }else{

     $lot=L::table('ingresoalmacenitem')->where('ingalm_id',$line['receipt_id']??'')->where('ingalmitm_id',$line['receipt_line_id']??0)->lockForUpdate()->first();

     if(!$lot)self::fail('Seleccione un lote de ingreso.');$header=L::table('ingresoalmacen')->where('ingalm_id',$lot->ingalm_id)->first();

     if($header->ingalm_estado_id!==self::APPROVED||$lot->cataitm_id!==$product||(int)$lot->almcataitmalm_id!==$w||(int)$lot->ingalmitmfuefin_id!==$ff)self::fail('Lote, producto, almacén o financiamiento incompatibles.');

     if($header->ingalm_fecha_almacen>$data['date'])self::fail('La salida no puede preceder al ingreso.');$key=$lot->ingalm_id.':'.$lot->ingalmitm_id;if(isset($seen[$key]))self::fail('No repita el mismo lote; agrupe la cantidad.');$seen[$key]=true;

     if(($kind!=='ajustes'&&$qty>$this->balance($lot))||($kind==='ajustes'&&$this->balance($lot)+$qty<0))self::fail('La operación excede el saldo disponible.');

     L::insert('salidaalmacenitem',['salalm_id'=>$id,'salalmitm_id'=>$i+1,'almcataitmalm_id'=>$w,'cataitm_id'=>$product,'salalmitm_cantidad_salida'=>$kind==='ajustes'?0:$qty,'salalmitm_cantidad_ajuste'=>$kind==='ajustes'?$qty:0,'salalmitm_costo_unitario'=>$lot->ingalmitm_costo_unitario,'salalmitm_lote'=>$lot->ingalmitm_lote??'','salalmitm_fecha_exp'=>$lot->ingalmitm_fecha_exp??'0001-01-01','ingalm_id_referencia'=>$lot->ingalm_id,'ingalmitm_id_referencia'=>$lot->ingalmitm_id,'salalmitmfuefin_id'=>$ff]);

    }

   }L::audit('guardar_'.$kind,$id,$data);return $id;

  },3);

 }

 private function sequence(string $key,int $minimum=0):int {

  DB::table('app_sequences')->insertOrIgnore(['key'=>$key,'value'=>$minimum]);$row=DB::table('app_sequences')->where('key',$key)->lockForUpdate()->first();$n=max($minimum,$row->value)+1;DB::table('app_sequences')->where('key',$key)->update(['value'=>$n]);return $n;

 }

 private function number(string $kind,object $doc):void {

  $p=$kind==='ingresos'?'ingalm':'salalm';$type=L::table('tipodocumento')->where('tipdoc_id',$doc->{$p.'tipdoc_id'})->lockForUpdate()->first();

  $last=max((int)($type->tipdoc_nro_correlativo??0),(int)($type->tipdoc_nro_documento??0));$n=$this->sequence('doc:'.$type->tipdoc_id,$last);

  L::table('tipodocumento')->where('tipdoc_id',$type->tipdoc_id)->update(['tipdoc_nro_documento'=>$n]);

  $date=Carbon::parse($doc->{$p.'_fecha_almacen'});$w=$doc->{$p.'alm_id'};$max=max((int)L::table('ingresoalmacen')->where('ingalmalm_id',$w)->whereYear('ingalm_fecha_almacen',$date->year)->whereMonth('ingalm_fecha_almacen',$date->month)->max('ingalm_nro_folio'),(int)L::table('salidaalmacen')->where('salalmalm_id',$w)->whereYear('salalm_fecha_almacen',$date->year)->whereMonth('salalm_fecha_almacen',$date->month)->max('salalm_nro_folio'));

  $max=max($max,(int)L::table('numerofolioalmacen')->where('alm_id',$w)->where('numfolalm_anio',$date->year)->where('numfolalm_mes',$date->month)->value('numfolalm_ultimo_folio'));$folio=$this->sequence("folio:$w:".$date->format('Ym'),$max);L::table('numerofolioalmacen')->updateOrInsert(['alm_id'=>$w,'numfolalm_anio'=>$date->year,'numfolalm_mes'=>$date->month],['numfolalm_ultimo_folio'=>$folio]);L::table($p==='ingalm'?'ingresoalmacen':'salidaalmacen')->where($p.'_id',$doc->{$p.'_id'})->update([$p.'_nro_documento'=>trim($type->tipdoc_prefijo).$n,$p.'_nro_folio'=>$folio,$p.'_nro_orden'=>$date->format('Ymd').str_pad((string)$folio,8,'0',STR_PAD_LEFT)]);

 }

 private function apply(string $kind,string $id,int $direction):void {

  if($kind==='ingresos')return;

  foreach($this->lines($kind,$id) as $line){$lot=L::table('ingresoalmacenitem')->where('ingalm_id',$line->ingalm_id_referencia)->where('ingalmitm_id',$line->ingalmitm_id_referencia)->lockForUpdate()->first();if(!$lot)self::fail('El lote de referencia no existe.');

   $h=L::table('ingresoalmacen')->where('ingalm_id',$lot->ingalm_id)->first();if($h->ingalm_estado_id!==self::APPROVED)self::fail('El lote de origen no está aprobado.');

   $config=L::table('almacencatalogoitem')->where('almcataitmalm_id',$lot->almcataitmalm_id)->where('cataitm_id',$lot->cataitm_id)->first();if($direction===1&&(!$config||!$config->almcataitm_activo||$config->almcataitm_bloqueoif))self::fail('Producto bloqueado por conteo físico.');

   $new=$this->balance($lot)-$direction*$line->salalmitm_cantidad_salida+$direction*$line->salalmitm_cantidad_ajuste;if($new<0)self::fail('Saldo insuficiente al aprobar o revertir.');

   L::table('ingresoalmacenitem')->where('ingalm_id',$lot->ingalm_id)->where('ingalmitm_id',$lot->ingalmitm_id)->update(['ingalmitm_cantidad_salida'=>$lot->ingalmitm_cantidad_salida+$direction*$line->salalmitm_cantidad_salida,'ingalmitm_cantidad_ajuste'=>$lot->ingalmitm_cantidad_ajuste+$direction*$line->salalmitm_cantidad_ajuste]);

  }

 }

 public function action(string $kind,string $id,string $action,array $data=[]):void {

  DB::transaction(function()use($kind,$id,$action,$data){$doc=$this->document($kind,$id,true);$p=$kind==='ingresos'?'ingalm':'salalm';$w=(int)$doc->{$p.'alm_id'};$this->authorize($w,in_array($action,['approve','receive'])?'approve':(in_array($action,['request-cancel','submit'])?'write':'cancel'));$this->period($doc->{$p.'_fecha_almacen'});$state=(int)$doc->{$p.'_estado_id'};if(in_array($action,['approve','cancel'],true)){foreach($this->lines($kind,$id) as $line){$cfg=L::table('almacencatalogoitem')->where('almcataitmalm_id',$w)->where('cataitm_id',$line->cataitm_id)->first();if($cfg?->almcataitm_bloqueoif)self::fail('Producto bloqueado por un conteo activo.');if($action==='approve'&&!L::table('catalogoitem')->where('cataitm_id',$line->cataitm_id)->where('cataitm_activo',1)->exists())self::fail('Producto inactivo.');}}

   if($action==='submit'){if($state!==5000)self::fail('Solo se elabora un borrador.');if($this->lines($kind,$id)->isEmpty())self::fail('Agregue líneas.');L::table($p==='ingalm'?'ingresoalmacen':'salidaalmacen')->where($p.'_id',$id)->update([$p.'_estado_id'=>5001]);

   }elseif($action==='approve'){

    if($state!==5001)self::fail('El documento ya fue aprobado o anulado.');if($this->lines($kind,$id)->isEmpty())self::fail('El documento no tiene líneas.');

    if($kind==='ingresos'){foreach($this->lines($kind,$id) as $l){$c=L::table('almacencatalogoitem')->where('almcataitmalm_id',$w)->where('cataitm_id',$l->cataitm_id)->first();if(!$c||!$c->almcataitm_activo||$c->almcataitm_bloqueoif)self::fail('Producto inactivo o bloqueado.');if($c->almcataitm_control_vencimiento&&(!$l->ingalmitm_fecha_exp||$l->ingalmitm_fecha_exp<today()->toDateString()))self::fail('Revise el vencimiento antes de aprobar.');}}

    $this->apply($kind,$id,1);$this->number($kind,$doc);L::table($p==='ingalm'?'ingresoalmacen':'salidaalmacen')->where($p.'_id',$id)->update([$p.'_estado_id'=>5002,$p.'_updateuser'=>auth()->user()->username,$p.'_updatedate'=>now()]);

   }elseif($action==='receive'){

    if($kind!=='transferencias'||$state!==5002||(int)$doc->salalm_estadotrans_id===6003||trim($doc->salalm_ref_transferencia_ingalm_id)!=='')self::fail('La transferencia no está pendiente de recepción.');$dest=(int)$doc->salalmalmdes_id;$this->authorize($dest,'approve');$new=L::uuid();

    foreach($this->lines($kind,$id) as $l){$cfg=L::table('almacencatalogoitem')->where('almcataitmalm_id',$dest)->where('cataitm_id',$l->cataitm_id)->first();if(!$cfg||!$cfg->almcataitm_activo||$cfg->almcataitm_bloqueoif)self::fail('Producto no habilitado o bloqueado en destino.');}

    L::insert('ingresoalmacen',['ingalm_id'=>$new,'ingalm_fecha_registro'=>today()->toDateString(),'ingalm_fecha_almacen'=>$doc->salalm_fecha_almacen,'ingalmalm_id'=>$dest,'ingalmalmori_id'=>$w,'ingalmalmdes_id'=>$dest,'ingalmtipdoc_id'=>1000,'ingalm_estado_id'=>5002,'ingalmprv_id'=>$doc->salalmprv_id,'ingalmasgper_id'=>$doc->salalmasgper_id,'ingalm_tipo_proveedor'=>$doc->salalm_tipo_proveedor,'ingalmfuefin_id'=>$doc->salalmfuefin_id,'ingalm_ref_transferencia_salalm_id'=>$id,'ingalm_glosa'=>'Transferencia '.$doc->salalm_nro_documento,'ingalm_serial_item'=>$doc->salalm_serial_item]);

    foreach($this->lines($kind,$id) as $i=>$l)L::insert('ingresoalmacenitem',['ingalm_id'=>$new,'ingalmitm_id'=>$i+1,'almcataitmalm_id'=>$dest,'cataitm_id'=>$l->cataitm_id,'ingalmitm_cantidad_ingreso'=>$l->salalmitm_cantidad_salida,'ingalmitm_costo_unitario'=>$l->salalmitm_costo_unitario,'ingalmitm_costo_unitario_con_imp'=>$l->salalmitm_costo_unitario,'ingalmitm_lote'=>$l->salalmitm_lote,'ingalmitm_fecha_exp'=>$l->salalmitm_fecha_exp,'ingalmitmfuefin_id'=>$l->salalmitmfuefin_id]);

    $this->number('ingresos',$this->document('ingresos',$new));L::table('salidaalmacen')->where('salalm_id',$id)->update(['salalm_estadotrans_id'=>6003,'salalm_ref_transferencia_ingalm_id'=>$new]);

   }elseif($action==='request-cancel'){

    if(trim($data['notes']??'')==='')self::fail('Indique el motivo de la solicitud.');if($state!==5002)self::fail('Solo se solicita anulación de documentos aprobados.');if(L::table('autorizacionanulacion')->where('autanu_transaccion_id',$id)->where('autanu_estado_id',8000)->exists())self::fail('Ya existe una solicitud pendiente.');

    L::insert('autorizacionanulacion',['autanu_id'=>L::uuid(),'autanu_fecha_solicitud'=>now(),'autanu_fecha_registro'=>today()->toDateString(),'autanu_username_solicitud'=>auth()->user()->username,'autanu_transaccion_id'=>$id,'autanu_transaccion_tipo'=>$kind==='ingresos'?1:($kind==='ajustes'?3:2),'autanu_estado_id'=>8000,'ofi_id'=>L::table('almacen')->where('alm_id',$w)->value('ofi_id'),'autanuper_id'=>99999999,'solanuper_id'=>99999999,'autanu_transaccion_descripcion'=>$doc->{$p.'_nro_documento'},'autanu_nota'=>$data['notes']??'']);

   }elseif(in_array($action,['cancel','reject-cancel'])){

    $req=L::table('autorizacionanulacion')->where('autanu_transaccion_id',$id)->where('autanu_estado_id',8000)->lockForUpdate()->first();if(!$req)self::fail('No existe una solicitud de anulación pendiente.');

    if($action==='cancel'){

     if($state!==5002)self::fail('El documento no está aprobado.');if($kind==='transferencias'&&(int)$doc->salalm_estadotrans_id===6003)self::fail('Anule primero el ingreso de la transferencia recibida.');

     if($kind==='ingresos'){foreach($this->lines($kind,$id) as $l){$ref=L::table('salidaalmacenitem as l')->join('msib.salidaalmacen as h','h.salalm_id','=','l.salalm_id')->where('l.ingalm_id_referencia',$id)->where('h.salalm_estado_id',5002)->exists();if($ref||$l->ingalmitm_cantidad_salida||$l->ingalmitm_cantidad_ajuste)self::fail('El ingreso tiene salidas o ajustes aprobados.');}

      if(trim($doc->ingalm_ref_transferencia_salalm_id)!=='')L::table('salidaalmacen')->where('salalm_id',$doc->ingalm_ref_transferencia_salalm_id)->update(['salalm_estadotrans_id'=>6000,'salalm_ref_transferencia_ingalm_id'=>'']);

     }$this->apply($kind,$id,-1);L::table($p==='ingalm'?'ingresoalmacen':'salidaalmacen')->where($p.'_id',$id)->update([$p.'_estado_id'=>5004,$p.'_updateuser'=>auth()->user()->username,$p.'_updatedate'=>now()]);

    }L::table('autorizacionanulacion')->where('autanu_id',$req->autanu_id)->update(['autanu_estado_id'=>$action==='cancel'?8001:8002,'autanu_fecha_respuesta'=>now(),'autanu_username_respuesta'=>auth()->user()->username,'autanu_nota'=>$data['notes']??$req->autanu_nota]);

   }else abort(404);
   if($action==='receive'){$u=auth()->user();DB::table('app_document_signatures')->insertOrIgnore(['document_id'=>$new,'state'=>5002,'user_id'=>$u->id,'username'=>$u->username,'name'=>$u->name,'role'=>'Recepción de almacén','statement'=>'Recepcionado por','signed_at'=>now()]);}
   if(in_array($action,['submit','approve'],true)){$u=auth()->user();DB::table('app_document_signatures')->insertOrIgnore(['document_id'=>$id,'state'=>$action==='submit'?5001:5002,'user_id'=>$u->id,'username'=>$u->username,'name'=>$u->name,'role'=>['admin'=>'Gestionador principal','manager'=>'Gestionador','operator'=>'Operador'][$u->role]??$u->role,'statement'=>$action==='submit'?'Elaborado por':'Aprobado por','signed_at'=>now()]);}
   L::audit($action,$id,$data);

  },3);

 }

}

