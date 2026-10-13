<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
return new class extends Migration {
 public function up():void {
  DB::table('msib.tablabasegrupo')->insertOrIgnore(['tabbasgru_id'=>9,'tabbasgru_descripcion'=>'Estados de activos fijos','tabbasgru_nombre_tabla'=>'activofijo']);
  // XPZ requires 9000 and 9011 as initial states. Backup has no asset state rows.
  foreach([9000=>'REGISTRADO',9011=>'SIN ASIGNACIÓN',9012=>'ASIGNADO',9020=>'SIN EVALUAR',9021=>'BUENO',9022=>'REGULAR',9023=>'MALO'] as $id=>$name)DB::table('msib.tablabasedata')->insertOrIgnore(['tabbasdat_id'=>$id,'tabbasgru_id'=>9,'tabbasdat_descripcion'=>$name,'tabbasdat_id_interno'=>(string)$id,'tabbasdat_activo'=>1]);
 }
 public function down():void {}
};
