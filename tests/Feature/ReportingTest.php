<?php
namespace Tests\Feature;
use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Support\Legacy as L;
use App\Services\Reports\ReportData;
class ReportingTest extends TestCase {
 use DatabaseTransactions;
 private int $warehouse;
 private int $destination;
 private string $product='RPT-TEST-01';
 protected function setUp():void {
  parent::setUp();$this->actingAs(User::where('username','yanarteaga')->firstOrFail());
  $warehouses=L::table('almacen')->where('alm_activo',1)->orderBy('alm_id')->pluck('alm_id');$this->warehouse=$warehouses[0];$this->destination=$warehouses[1];
  $copy=(array)L::table('catalogoitem')->where('cataitm_activo',1)->first();$copy['cataitm_id']=$this->product;$copy['cataitm_nombre']='Producto de prueba documental';$copy['cataitm_cod_secuencial']='RPTTEST01';L::table('catalogoitem')->insert($copy);
  foreach([$this->warehouse,$this->destination] as $w)L::insert('almacencatalogoitem',['almcataitmalm_id'=>$w,'cataitm_id'=>$this->product,'almcataitm_activo'=>1,'almcataitm_control_saldo'=>1]);
  L::table('logcierremesinventario')->where('logcieinv_anio',today()->year)->where('logcieinv_mes',today()->month)->update(['logcieinv_estado'=>'ABIERTO']);
 }
 private function receipt(bool $approve=true):string {
  $r=$this->postJson('/api/documents/ingresos',['warehouse_id'=>$this->warehouse,'date'=>today()->toDateString(),'type_id'=>1,'funding_id'=>7000,'recipient_type'=>'PROVEEDOR','supplier_id'=>9999,'notes'=>'Texto <script>alert(1)</script> de prueba','lines'=>[['product_id'=>$this->product,'quantity'=>10,'cost'=>100,'tax'=>13,'lot'=>'RPT-LOTE','expiry'=>today()->addYear()->toDateString()]]]);$r->assertOk();$id=$r->json('id');if($approve)$this->approve('ingresos',$id);return $id;
 }
 private function approve(string $kind,string $id):void {$this->postJson("/api/documents/$kind/$id/submit",[])->assertOk();$this->postJson("/api/documents/$kind/$id/approve",[])->assertOk();}
 private function outgoing(string $in,int $qty,string $kind='salidas'):string {
  $r=$this->postJson('/api/documents/'.$kind,['warehouse_id'=>$this->warehouse,'destination_id'=>$this->destination,'date'=>today()->toDateString(),'type_id'=>$kind==='transferencias'?2000:($kind==='ajustes'?6:5),'funding_id'=>7000,'recipient_type'=>'PERSONAL','person_id'=>99999999,'notes'=>'Prueba documental','lines'=>[['product_id'=>$this->product,'quantity'=>$qty,'receipt_id'=>$in,'receipt_line_id'=>1]]]);$r->assertOk();$id=$r->json('id');$this->approve($kind,$id);return $id;
 }
 public function test_document_pdf_excel_signatures_watermark_and_issuance():void {
  $id=$this->receipt(false);$url="/api/documents/ingresos/$id/print";
  $this->getJson($url)->assertOk()->assertJsonPath('watermark','BORRADOR')->assertJsonPath('sections.0.totals.subtotal',870)->assertJsonPath('signatures.0.name','');
  $this->get($url.'?format=html')->assertOk()->assertSee('&lt;script&gt;',false)->assertDontSee('<script>alert',false);
  $this->approve('ingresos',$id);$this->getJson($url)->assertJsonPath('watermark',null)->assertJsonPath('signatures.0.name','yanarteaga')->assertJsonPath('signatures.1.name','yanarteaga');
  $before=L::table('ingresoalmacenitem')->where('ingalm_id',$id)->value('ingalmitm_cantidad_salida');
  $pdf=$this->get($url.'?format=pdf');$pdf->assertOk()->assertHeader('Content-Type','application/pdf');$this->assertStringStartsWith('%PDF-',$pdf->getContent());$issue=DB::table('app_report_issues')->where('id',$pdf->headers->get('X-Report-Issue'))->first();$this->assertSame(hash('sha256',$pdf->getContent()),$issue->sha256);
  $excel=$this->get($url.'?format=xlsx');$excel->assertOk();$this->assertStringStartsWith('PK',$excel->getContent());$this->assertSame($before,L::table('ingresoalmacenitem')->where('ingalm_id',$id)->value('ingalmitm_cantidad_salida'));
 }
 public function test_monthly_transfer_and_adjustment_preserve_balance():void {
  $in=$this->receipt();$out=$this->outgoing($in,3);$this->outgoing($in,-2,'ajustes');$tr=$this->outgoing($in,2,'transferencias');$this->postJson("/api/documents/transferencias/$tr/receive",[])->assertOk();
  $f=['year'=>today()->year,'month'=>today()->month,'warehouse'=>$this->warehouse,'product'=>$this->product];$r=$this->getJson('/api/reports/saldo-mensual?'.http_build_query($f));$r->assertOk();$row=$r->json('sections.0.rows.0');$this->assertSame(10,$row['cantidad_ingreso']);$this->assertSame(3,$row['cantidad_salida']);$this->assertSame(-2,$row['cantidad_ajuste']);$this->assertSame(-2,$row['cantidad_traspaso']);$this->assertSame(3,$row['cantidad_saldo']);$this->assertEquals(261,$row['costo_saldo']);
  $f['warehouse']=$this->destination;$r=$this->getJson('/api/reports/saldo-mensual?'.http_build_query($f));$r->assertOk()->assertJsonPath('sections.0.rows.0.cantidad_traspaso',2)->assertJsonPath('sections.0.rows.0.cantidad_saldo',2);
  $this->postJson("/api/documents/salidas/$out/request-cancel",['notes'=>'Prueba'])->assertOk();$this->postJson("/api/documents/salidas/$out/cancel",['notes'=>'Autorizar'])->assertOk();$f['warehouse']=$this->warehouse;$this->getJson('/api/reports/saldo-mensual?'.http_build_query($f))->assertJsonPath('sections.0.rows.0.cantidad_saldo',6);
 }
 public function test_reports_use_full_list_not_first_pagination_page_and_validate_filters():void {
  $this->getJson('/api/reports/catalog')->assertOk()->assertJsonStructure(['reports','families','groups','categories','ranges']);$r=$this->getJson('/api/reports/listado-productos');$r->assertOk();$this->assertGreaterThan(100,count($r->json('sections.0.rows')));
  $this->getJson('/api/reports/kardex-valorado')->assertUnprocessable();$this->getJson('/api/reports/saldo-mensual?year=2026&month=13')->assertUnprocessable();$this->getJson('/api/reports/movimientos-periodo?from=2026-10-01&to=2025-01-01')->assertUnprocessable();$this->getJson('/api/reports/not-a-report')->assertNotFound();$this->getJson('/api/reports/listado-productos?format=exe')->assertUnprocessable();
 }
 public function test_kardex_running_totals_and_midmonth_opening():void {
  $in=$this->receipt();$this->outgoing($in,3);$f=['warehouse'=>$this->warehouse,'product'=>$this->product,'from'=>today()->startOfMonth()->toDateString(),'to'=>today()->toDateString()];$r=$this->getJson('/api/reports/kardex-valorado?'.http_build_query($f));$r->assertOk();$rows=$r->json('sections.0.rows');$this->assertCount(2,$rows);$this->assertSame(7,end($rows)['saldo']);$this->assertEquals(609,end($rows)['costo_saldo']);
 }
 public function test_historical_inventory_blank_omits_count_difference_and_observations():void {
  $h=L::table('inventariofisico as h')->join('msib.inventariofisicoitems as l','l.invfis_id','=','h.invfis_id')->first(['h.*']);$this->assertNotNull($h);$r=$this->getJson('/api/reports/inventario-blanco?count_source=legacy&count_id='.$h->invfis_id);$r->assertOk();foreach($r->json('sections.0.rows') as $row){$this->assertSame('',$row['recuento']);$this->assertSame('',$row['diferencia']);$this->assertSame('',$row['observaciones']);}
  $this->getJson('/api/reports/inventario-resultados?count_source=legacy&count_id='.$h->invfis_id)->assertOk();
 }
 public function test_expiry_ranges_and_historical_cost_sign_are_preserved():void {
  $prev=today()->copy()->startOfMonth()->subMonth();$unit=10;$expiry=today()->subDay()->toDateString();
  L::insert('kardexconsolidadomensual',['karconmes_id'=>L::uuid(),'karconmes_anio'=>$prev->year,'karconmes_mes'=>$prev->month,'almcataitmalm_id'=>$this->warehouse,'cataitm_id'=>$this->product,'karconmes_lote'=>'EXPIRED','karconmes_fecha_exp'=>$expiry,'karconmes_costo_unitario'=>$unit,'karconmes_cantidad_saldo_anterior'=>5,'karconmes_costo_saldo_anterior'=>50,'almitmdisfuefin_id'=>7000]);
  $p=['warehouse'=>$this->warehouse,'year'=>$prev->year,'month'=>$prev->month,'basis'=>'snapshot'];$r=$this->getJson('/api/reports/vencimientos-mensual?'.http_build_query($p));$r->assertOk();$matches=[];foreach($r->json('sections') as $s)foreach($s['rows'] as $row)if($row['codigo']===$this->product)$matches[]=$row;$this->assertNotEmpty($matches);$this->assertSame('EXPIRADO',$matches[0]['dias']);
  L::insert('resumencostoinventario',['rescosinv_id'=>L::uuid(),'rescosinv_fecha'=>today()->toDateString(),'almcataitmalm_id'=>$this->warehouse,'cataitm_id'=>$this->product,'almitmdisfuefin_id'=>7000,'rescosinv_costo_saldo_anterior'=>100,'rescosinv_costo_ingresos'=>20,'rescosinv_costo_salidas'=>-10,'rescosinv_costo_ajustes'=>2,'rescosinv_costo_traspasos'=>-5]);
  $r=$this->getJson('/api/reports/resumen-costos?'.http_build_query(['warehouse'=>$this->warehouse,'product'=>$this->product,'from'=>today()->toDateString(),'to'=>today()->toDateString()]));$r->assertOk()->assertJsonPath('sections.0.rows.0.costo_saldo',107);
 }
 public function test_excel_strings_cannot_be_formulas():void {
  $r=app(ReportData::class)->base('Prueba','TEST','Test');$r['sections'][]=app(ReportData::class)->section('Valores',[['key'=>'texto','label'=>'Texto','type'=>'text'],['key'=>'importe','label'=>'Importe','type'=>'money']],[['texto'=>'=HYPERLINK("x")','importe'=>12.5]]);$bytes=app(\App\Services\Reports\XlsxWriter::class)->write($r);$file=tempnam(sys_get_temp_dir(),'rpt-test');file_put_contents($file,$bytes);$z=new \ZipArchive;$z->open($file);$xml=$z->getFromName('xl/worksheets/sheet1.xml');$z->close();unlink($file);$this->assertStringContainsString('t="inlineStr"',$xml);$this->assertStringNotContainsString('<f>',$xml);$this->assertStringContainsString('<v>12.5</v>',$xml);
 }
 public function test_all_special_reports_and_asset_fiche_are_callable():void {
  $count=L::table('inventariofisico')->value('invfis_id');
  foreach([
   'saldo-mensual'=>['year'=>2026,'month'=>9,'warehouse'=>$this->warehouse,'basis'=>'snapshot'],
   'movimientos-periodo'=>['from'=>'2026-08-01','to'=>'2026-09-30','warehouse'=>$this->warehouse,'product'=>$this->product,'basis'=>'snapshot'],
   'vencimientos-mensual'=>['year'=>2026,'month'=>9,'warehouse'=>$this->warehouse,'basis'=>'snapshot'],
   'resumen-costos'=>['from'=>'2026-09-01','to'=>'2026-09-30','warehouse'=>$this->warehouse,'product'=>$this->product],
   'inventario-blanco'=>['count_id'=>$count,'count_source'=>'legacy'],
   'inventario-resultados'=>['count_id'=>$count,'count_source'=>'legacy'],
  ] as $report=>$params)$this->getJson('/api/reports/'.$report.'?'.http_build_query($params))->assertOk()->assertJsonStructure(['sections','metadata','row_count']);
  $office=L::table('almacen')->where('alm_id',$this->warehouse)->value('ofi_id');$cat=L::table('catalogoitem')->where('cataitm_id',$this->product)->value('catitm_id');
  $asset=$this->postJson('/api/assets',['code'=>'RPT-ASSET','description'=>'Activo para reporte','serial'=>'RPT-SERIAL','purchase_date'=>today()->toDateString(),'purchase_cost'=>100,'asset_cost'=>100,'supplier_id'=>9999,'category_id'=>$cat,'office_id'=>$office,'area'=>'Administración','conservation_id'=>9020,'depreciate'=>false]);$asset->assertOk();$id=$asset->json('id');$this->getJson("/api/assets/$id/print")->assertOk()->assertJsonPath('metadata.Código','RPT-ASSET');$this->get("/api/assets/$id/print?format=pdf")->assertOk()->assertHeader('Content-Type','application/pdf');
 }
 public function test_scoped_documents_reports_and_anonymous_downloads():void {
  $in=$this->receipt();$u=User::where('username','yanarteaga')->first();$u->role='viewer';$u->warehouses='[]';$this->actingAs($u);$this->getJson("/api/documents/ingresos/$in/print?format=pdf")->assertForbidden();$this->getJson('/api/reports/saldo-mensual?year=2026&month=10&warehouse='.$this->warehouse)->assertForbidden();$this->getJson('/api/reports/listado-usuarios')->assertNotFound();$this->getJson('/api/reports/listado-inventario')->assertOk()->assertJsonPath('row_count',0);$this->getJson('/api/reports/listado-emisiones')->assertOk();auth()->logout();$this->getJson('/api/reports/listado-productos?format=pdf')->assertUnauthorized();
 }
 public function test_live_opening_carries_prior_month_app_changes_and_crossyear_range():void {
  $now=today();$prev=$now->copy()->startOfMonth()->subMonth();L::table('logcierremesinventario')->where('logcieinv_anio',$prev->year)->where('logcieinv_mes',$prev->month)->update(['logcieinv_estado'=>'ABIERTO']);
  $r=$this->postJson('/api/documents/ingresos',['warehouse_id'=>$this->warehouse,'date'=>$prev->toDateString(),'type_id'=>1,'funding_id'=>7000,'recipient_type'=>'PROVEEDOR','supplier_id'=>9999,'notes'=>'Ingreso mes previo','lines'=>[['product_id'=>$this->product,'quantity'=>5,'cost'=>100,'tax'=>0,'lot'=>'PREV']]]);$r->assertOk();$this->approve('ingresos',$r->json('id'));
  $f=['year'=>$now->year,'month'=>$now->month,'warehouse'=>$this->warehouse,'product'=>$this->product];$this->getJson('/api/reports/saldo-mensual?'.http_build_query($f))->assertOk()->assertJsonPath('sections.0.rows.0.cantidad_anterior',5)->assertJsonPath('sections.0.rows.0.cantidad_saldo',5);
  $this->getJson('/api/reports/movimientos-periodo?from=2025-12-01&to=2026-01-31&warehouse='.$this->warehouse.'&product='.$this->product.'&basis=snapshot')->assertOk();
 }
}
