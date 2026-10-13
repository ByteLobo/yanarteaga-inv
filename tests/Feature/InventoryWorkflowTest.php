<?php
namespace Tests\Feature;
use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Services\InventoryService;
use App\Support\Legacy as L;
class InventoryWorkflowTest extends TestCase {
 use DatabaseTransactions;
 private object $cfg;
 protected function setUp():void {
  parent::setUp();
  $u=User::where('username','yanarteaga')->firstOrFail();$this->actingAs($u);
  $this->cfg=L::table('almacencatalogoitem as x')->join('msib.almacen as a','a.alm_id','=','x.almcataitmalm_id')->join('msib.catalogoitem as c','c.cataitm_id','=','x.cataitm_id')->where('a.alm_activo',1)->where('c.cataitm_activo',1)->first(['x.*']);
  L::table('almacencatalogoitem')->where('almcataitmalm_id',$this->cfg->almcataitmalm_id)->where('cataitm_id',$this->cfg->cataitm_id)->update(['almcataitm_activo'=>1,'almcataitm_control_vencimiento'=>0,'almcataitm_bloqueoif'=>0]);
  L::table('logcierremesinventario')->where('logcieinv_anio',today()->year)->where('logcieinv_mes',today()->month)->update(['logcieinv_estado'=>'ABIERTO']);
 }
 private function receipt(int $qty=10,int $funding=7000):string {
  $r=$this->postJson('/api/documents/ingresos',['warehouse_id'=>$this->cfg->almcataitmalm_id,'date'=>today()->toDateString(),'type_id'=>1,'funding_id'=>$funding,'recipient_type'=>'PROVEEDOR','supplier_id'=>9999,'notes'=>'Prueba automatizada','lines'=>[['product_id'=>$this->cfg->cataitm_id,'quantity'=>$qty,'cost'=>100,'tax'=>13,'lot'=>'TEST-LOT']]]);
  $r->assertOk();return $r->json('id');
 }
 private function approve(string $kind,string $id):void {$this->postJson("/api/documents/$kind/$id/submit",[])->assertOk();$this->postJson("/api/documents/$kind/$id/approve",[])->assertOk();}
 private function outgoing(string $receipt,int $qty,string $kind='salidas',?int $dest=null):string {
  $r=$this->postJson('/api/documents/'.$kind,['warehouse_id'=>$this->cfg->almcataitmalm_id,'destination_id'=>$dest,'date'=>today()->toDateString(),'type_id'=>$kind==='transferencias'?2000:($kind==='ajustes'?6:5),'funding_id'=>7000,'recipient_type'=>'PERSONAL','person_id'=>99999999,'notes'=>'Prueba salida','lines'=>[['product_id'=>$this->cfg->cataitm_id,'quantity'=>$qty,'receipt_id'=>$receipt,'receipt_line_id'=>1]]]);$r->assertOk();return $r->json('id');
 }
 private function balance(string $receipt):int {$lot=L::table('ingresoalmacenitem')->where('ingalm_id',$receipt)->first();return app(InventoryService::class)->balance($lot);}
 public function test_reads_all_modules_and_searches_export():void {
  foreach(['productos','almacenes','proveedores','personal','oficinas','familias','grupos','categorias','centros','cargos','asignaciones','rangos','ingresos','salidas','ajustes','transferencias','inventario','vencimientos','kardex','periodos','anulaciones','activos','conteos','planificacion','auditoria','usuarios','financiamiento','configuracion','historico-conteos','historico-planes'] as $m)$this->getJson('/api/records/'.$m)->assertOk()->assertJsonStructure(['data','total']);
  $this->getJson('/api/bootstrap')->assertOk()->assertJsonPath('stats.productos',583);
  $this->getJson('/api/records/productos?search=xyz-never-exists')->assertOk()->assertJsonPath('total',0);
  $this->get('/api/records/productos?export=1')->assertOk()->assertDownload('exportacion.csv');
 }
 public function test_stock_approval_is_exactly_once_and_cancel_restores():void {
  $in=$this->receipt();$this->assertSame(87.0,(float)L::table('ingresoalmacenitem')->where('ingalm_id',$in)->value('ingalmitm_costo_unitario'));
  $this->approve('ingresos',$in);$out=$this->outgoing($in,4);$this->assertSame(10,$this->balance($in));$this->approve('salidas',$out);$this->assertSame(6,$this->balance($in));
  $this->postJson("/api/documents/salidas/$out/approve",[])->assertUnprocessable();$this->assertSame(6,$this->balance($in));
  $this->postJson("/api/documents/salidas/$out/request-cancel",['notes'=>'Reversión de prueba'])->assertOk();
  $this->postJson("/api/documents/salidas/$out/request-cancel",[])->assertUnprocessable();
  $this->postJson("/api/documents/salidas/$out/cancel",['notes'=>'Autorizado'])->assertOk();$this->assertSame(10,$this->balance($in));
  $this->assertSame(5004,L::table('salidaalmacen')->where('salalm_id',$out)->value('salalm_estado_id'));
 }
 public function test_rechecks_balance_at_approval_for_competing_drafts():void {
  $in=$this->receipt();$this->approve('ingresos',$in);$a=$this->outgoing($in,8);$b=$this->outgoing($in,8);$this->approve('salidas',$a);$this->postJson("/api/documents/salidas/$b/submit",[])->assertOk();$this->postJson("/api/documents/salidas/$b/approve",[])->assertUnprocessable();$this->assertSame(2,$this->balance($in));
 }
 public function test_project_tax_is_zero_and_future_date_closed_period_expiry_are_rejected():void {
  $in=$this->receipt(2,7001);$this->assertSame(100.0,(float)L::table('ingresoalmacenitem')->where('ingalm_id',$in)->value('ingalmitm_costo_unitario'));
  $payload=['warehouse_id'=>$this->cfg->almcataitmalm_id,'date'=>today()->addDay()->toDateString(),'type_id'=>1,'funding_id'=>7000,'recipient_type'=>'PROVEEDOR','lines'=>[['product_id'=>$this->cfg->cataitm_id,'quantity'=>1,'cost'=>100]]];$this->postJson('/api/documents/ingresos',$payload)->assertUnprocessable();
  $payload['date']=today()->toDateString();L::table('logcierremesinventario')->where('logcieinv_anio',today()->year)->where('logcieinv_mes',today()->month)->update(['logcieinv_estado'=>'CERRADO']);$this->postJson('/api/documents/ingresos',$payload)->assertUnprocessable();
  L::table('logcierremesinventario')->where('logcieinv_anio',today()->year)->where('logcieinv_mes',today()->month)->update(['logcieinv_estado'=>'ABIERTO']);L::table('almacencatalogoitem')->where('almcataitmalm_id',$this->cfg->almcataitmalm_id)->where('cataitm_id',$this->cfg->cataitm_id)->update(['almcataitm_control_vencimiento'=>1]);$this->postJson('/api/documents/ingresos',$payload)->assertUnprocessable();
 }
 public function test_transfer_receives_once_and_preserves_lot_cost_funding():void {
  $dest=L::table('almacencatalogoitem as c')->join('msib.almacen as a','a.alm_id','=','c.almcataitmalm_id')->where('c.cataitm_id',$this->cfg->cataitm_id)->where('a.alm_activo',1)->where('a.alm_id','!=',$this->cfg->almcataitmalm_id)->first(['c.*']);$this->assertNotNull($dest);
  L::table('almacencatalogoitem')->where('almcataitmalm_id',$dest->almcataitmalm_id)->where('cataitm_id',$this->cfg->cataitm_id)->update(['almcataitm_activo'=>1,'almcataitm_bloqueoif'=>0]);$in=$this->receipt();$this->approve('ingresos',$in);$out=$this->outgoing($in,3,'transferencias',$dest->almcataitmalm_id);$this->approve('transferencias',$out);$this->postJson("/api/documents/transferencias/$out/receive",[])->assertOk();$this->postJson("/api/documents/transferencias/$out/receive",[])->assertUnprocessable();$this->assertSame(7,$this->balance($in));$received=L::table('ingresoalmacen')->where('ingalm_ref_transferencia_salalm_id',$out)->first();$lot=L::table('ingresoalmacenitem')->where('ingalm_id',$received->ingalm_id)->first();$this->assertSame('TEST-LOT',$lot->ingalmitm_lote);$this->assertSame(7000,$lot->ingalmitmfuefin_id);$this->assertSame(87.0,(float)$lot->ingalmitm_costo_unitario);$this->assertSame(3,$this->balance($received->ingalm_id));
 }
 public function test_positive_and_negative_adjustments():void {
  $in=$this->receipt();$this->approve('ingresos',$in);$up=$this->outgoing($in,3,'ajustes');$this->approve('ajustes',$up);$this->assertSame(13,$this->balance($in));$down=$this->outgoing($in,-2,'ajustes');$this->approve('ajustes',$down);$this->assertSame(11,$this->balance($in));
 }
 public function test_physical_count_blocks_then_posts_difference():void {
  $in=$this->receipt();$this->approve('ingresos',$in);$pending=$this->outgoing($in,1);$this->postJson("/api/documents/salidas/$pending/submit",[])->assertOk();$data=['warehouse_id'=>$this->cfg->almcataitmalm_id,'date'=>today()->toDateString(),'notes'=>'Conteo de prueba','lines'=>[['receipt_id'=>$in,'receipt_line_id'=>1,'count'=>7]],'finish'=>false];$r=$this->postJson('/api/counts',$data);$r->assertOk();$this->postJson("/api/documents/salidas/$pending/approve",[])->assertUnprocessable();$data['id']=$r->json('id');$data['finish']=true;$this->postJson('/api/counts',$data)->assertOk();$this->assertSame(7,$this->balance($in));$this->postJson('/api/counts',$data)->assertUnprocessable();
 }
 public function test_configuration_assets_and_planning_formulas():void {
  $this->postJson('/api/configuration',['warehouse_id'=>$this->cfg->almcataitmalm_id,'product_id'=>$this->cfg->cataitm_id,'minimum'=>3,'maximum'=>10,'control_stock'=>1,'control_expiry'=>0,'control_balance'=>1,'active'=>1])->assertOk();
  $office=L::table('oficinas')->where('ofi_activo',1)->value('ofi_id');$category=L::table('categoriaitem')->value('catitm_id');
  $r=$this->postJson('/api/assets',['code'=>'TEST-ASSET-1','description'=>'Equipo de prueba','serial'=>'TEST-SERIAL','purchase_date'=>today()->toDateString(),'purchase_cost'=>100,'asset_cost'=>100,'supplier_id'=>9999,'category_id'=>$category,'office_id'=>$office,'area'=>'Administración','conservation_id'=>9020,'depreciate'=>false]);$r->assertOk();$id=$r->json('id');
  $person=L::table('personal')->where('per_activo',1)->value('per_id');$this->postJson("/api/assets/$id/assign",['custodian_id'=>$person,'office_id'=>$office,'notes'=>'Custodia de prueba'])->assertOk();$this->assertSame(9012,L::table('activofijo')->where('actfij_id',$id)->value('actfij_estado_custodia_id'));
  $plan=$this->postJson('/api/planning',['warehouse_id'=>$this->cfg->almcataitmalm_id,'months'=>6,'lead_time'=>1,'periodicity'=>2]);$plan->assertOk();foreach($plan->json('lines') as $line){$this->assertEqualsWithDelta($line['consumo_medio']*3.5,$line['stock_maximo'],0.03);$this->assertEqualsWithDelta($line['consumo_medio'],$line['stock_minimo'],0.02);}
 }
 public function test_permissions_and_scope_and_anonymous_access():void {
  $u=new User;$u->id=99998;$u->username='viewer-test';$u->role='viewer';$u->warehouses='[]';$this->actingAs($u);$this->getJson('/api/records/inventario')->assertOk()->assertJsonPath('total',0);$this->postJson('/api/periods',['year'=>2026,'month'=>10,'state'=>'ABIERTO','notes'=>'x'])->assertForbidden();$this->getJson('/api/records/usuarios')->assertForbidden();$this->postJson('/api/documents/ingresos',['warehouse_id'=>$this->cfg->almcataitmalm_id,'date'=>today()->toDateString(),'type_id'=>1,'funding_id'=>7000,'recipient_type'=>'PROVEEDOR','lines'=>[['product_id'=>$this->cfg->cataitm_id,'quantity'=>1]]])->assertForbidden();auth()->logout();$this->getJson('/api/bootstrap')->assertUnauthorized();
 }
}


