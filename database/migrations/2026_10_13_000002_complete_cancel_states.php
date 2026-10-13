<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
return new class extends Migration {
 public function up():void {
  DB::table('msib.tablabasegrupo')->insertOrIgnore(['tabbasgru_id'=>8,'tabbasgru_descripcion'=>'Estado de solicitud de anulación','tabbasgru_nombre_tabla'=>'autorizacionanulacion']);
  foreach([8000=>'SOLICITADO',8001=>'APROBADO',8002=>'RECHAZADO'] as $id=>$name)DB::table('msib.tablabasedata')->insertOrIgnore(['tabbasdat_id'=>$id,'tabbasgru_id'=>8,'tabbasdat_descripcion'=>$name,'tabbasdat_id_interno'=>(string)$id,'tabbasdat_activo'=>1]);
 }
 // Values may become referenced by historical requests. Preserve them on rollback.
 public function down():void {}
};
