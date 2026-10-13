<?php
namespace App\Http\Controllers;
use App\Services\Reports\{ReportRegistry,ReportData,ReportRenderer,XlsxWriter};
use App\Support\Legacy as L;
use App\Services\InventoryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
class ReportController extends Controller {
 public function __construct(private ReportRegistry $registry,private ReportData $data,private ReportRenderer $renderer,private XlsxWriter $xlsx){}
 public function catalog(){
  return ['reports'=>$this->registry->all(),'families'=>L::table('familiaitem')->get(['famitm_id as id','famitm_nombre as name']),'groups'=>L::table('grupoitem')->get(['gruitm_id as id','gruitm_nombre as name','famitm_id as family']),'categories'=>L::table('categoriaitem')->get(['catitm_id as id','catitm_nombre as name','gruitm_id as group']),'ranges'=>L::table('rangodiaexpiracion')->get(['ranexp_id as id','ranexp_descripcion as name','ranexp_valor_dia as days']),'channels'=>L::table('tablabasedata')->whereIn('tabbasdat_id',L::table('oficinas')->pluck('ofican_id'))->get(['tabbasdat_id as id','tabbasdat_descripcion as name']),'cost_groups'=>L::table('tablabasedata')->whereIn('tabbasdat_id',L::table('centrocosto')->pluck('ccosgru_id'))->get(['tabbasdat_id as id','tabbasdat_descripcion as name'])];
 }
 private function filters(Request $r,string $id):array {
  $definition=$this->registry->get($id);$f=$r->validate(['warehouse'=>'nullable|integer|exists:pgsql.msib.almacen,alm_id','product'=>'nullable|string|max:20|exists:pgsql.msib.catalogoitem,cataitm_id','funding'=>'nullable|integer|exists:pgsql.msib.tablabasedata,tabbasdat_id','family'=>'nullable|integer','group'=>'nullable|integer','category'=>'nullable|integer','year'=>'nullable|integer|between:2000,2100','month'=>'nullable|integer|between:1,12','from'=>'nullable|date_format:Y-m-d','to'=>'nullable|date_format:Y-m-d|after_or_equal:from','range'=>'nullable|integer|exists:pgsql.msib.rangodiaexpiracion,ranexp_id','channel'=>'nullable|integer','cost_group'=>'nullable|integer','search'=>'nullable|string|max:100','state'=>'nullable|integer','basis'=>'nullable|in:auto,snapshot','count_id'=>'nullable|uuid','count_source'=>'nullable|in:legacy,new','format'=>'nullable|in:json,pdf,xlsx,html']);
  $req=match($id){'kardex-valorado'=>['warehouse','product','from','to'],'saldo-mensual','vencimientos-mensual'=>['year','month'],'movimientos-periodo','resumen-costos'=>['from','to'],'inventario-blanco','inventario-resultados'=>['count_id'],default=>[]};foreach($req as $key)if(empty($f[$key]))InventoryService::fail('Complete el filtro requerido: '.$key.'.');
  if($id==='movimientos-periodo'&&Carbon::parse($f['from'])->diffInMonths(Carbon::parse($f['to']))>24)InventoryService::fail('Seleccione hasta 24 meses por reporte.');unset($f['format']);return array_intersect_key($f,array_flip($definition['filters']));
 }
 public function generate(Request $r,string $id){$f=$this->filters($r,$id);return $this->deliver($this->snapshot(fn()=>$this->data->build($id,$f)),$r,$id,$f);}
 public function document(Request $r,string $kind,string $id){$r->validate(['format'=>'nullable|in:pdf,xlsx,html,json']);return $this->deliver($this->snapshot(fn()=>$this->data->document($kind,$id)),$r,'document-'.$kind,[]);}
 public function asset(Request $r,string $id){$r->validate(['format'=>'nullable|in:pdf,xlsx,html,json']);return $this->deliver($this->snapshot(fn()=>$this->data->asset($id)),$r,'asset',[]);}
 private function snapshot(callable $reader):array {
  if(DB::connection()->transactionLevel()>0)return $reader();
  return DB::transaction(function()use($reader){DB::statement('SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY');return $reader();});
 }
 private function deliver(array $report,Request $r,string $name,array $filters){
  $format=$r->input('format','json');if($format==='json')return $report;
  $pdfRows=array_sum(array_map(fn($p)=>count($p['rows']),$this->renderer->panels($report)));if($format==='pdf'&&$pdfRows>1500)InventoryService::fail('El PDF supera 1.500 filas de impresión. Acote los filtros o descargue Excel, que admite hasta 10.000 filas.');
  $report['issue_id']=L::uuid();$dir=storage_path('app/private/report-temp');if(!is_dir($dir))mkdir($dir,0770,true);
  $bytes=match($format){'pdf'=>$this->renderer->pdf($report),'xlsx'=>$this->xlsx->write($report),'html'=>$this->renderer->html($report)};
  DB::table('app_report_issues')->insert(['id'=>$report['issue_id'],'report'=>$name,'reference'=>$report['reference']??null,'actor'=>auth()->user()->username,'format'=>$format,'filters'=>json_encode($filters),'sha256'=>hash('sha256',$bytes),'row_count'=>$report['row_count'],'created_at'=>now()]);
  $filename=$report['code'].'-'.now()->format('Ymd-His').'.'.$format;$mime=match($format){'pdf'=>'application/pdf','xlsx'=>'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','html'=>'text/html; charset=UTF-8'};
  return response($bytes,200,['Content-Type'=>$mime,'Content-Disposition'=>($format==='xlsx'?'attachment':'inline').'; filename="'.$filename.'"','Cache-Control'=>'private, no-store','X-Content-Type-Options'=>'nosniff','X-Report-Issue'=>$report['issue_id']]);
 }
}
