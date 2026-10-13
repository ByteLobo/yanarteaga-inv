<?php
namespace App\Services\Reports;
use Dompdf\Dompdf;
use Dompdf\Options;
class ReportRenderer {
 public function html(array $report):string {return view('reports.document',['report'=>$report,'panels'=>$this->panels($report)])->render();}
 public function panels(array $report):array {
  $panels=[];foreach($report['sections'] as $section){$cols=$section['columns'];if(count($cols)<=(in_array($report['code'],['IT-A-0001','IT-A-0002','IT-A-0004','IT-A-0007','IT-A-0008'])?11:9)){$panels[]=$section;continue;}$anchorKeys=in_array($report['code'],['IT-A-0005','EX-A-0002'])&&isset($section['rows'][0]['almacen'])?['codigo','almacen']:array_column(array_slice($cols,0,2),'key');$anchors=array_values(array_filter($cols,fn($c)=>in_array($c['key'],$anchorKeys)));$rest=array_values(array_filter($cols,fn($c)=>!in_array($c['key'],$anchorKeys)));foreach(array_chunk($rest,7) as $i=>$chunk){$panel=$section;$panel['columns']=array_merge($anchors,$chunk);$panel['title']=$section['title'].' - bloque '.($i+1);$panel['continued']=$i>0;$panels[]=$panel;}}
  return $panels;
 }
 public function pdf(array $report):string {
  $directory=storage_path('app/private/report-temp');if(!is_dir($directory))mkdir($directory,0770,true);
  $options=new Options();$options->set('defaultMediaType','print');$options->set('isRemoteEnabled',false);$options->set('isPhpEnabled',false);$options->set('isJavascriptEnabled',false);$options->set('defaultFont','DejaVu Sans');$options->set('tempDir',$directory);$options->set('fontCache',$directory);$options->set('chroot',[base_path('vendor/dompdf'),storage_path('app/private')]);
  $pdf=new Dompdf($options);$pdf->setPaper('A4',$report['orientation']);$pdf->loadHtml($this->html($report),'UTF-8');$pdf->render();$canvas=$pdf->getCanvas();$font=$pdf->getFontMetrics()->getFont('Helvetica');$canvas->page_text($canvas->get_width()-76,$canvas->get_height()-25,'{PAGE_NUM} / {PAGE_COUNT}',$font,8,[.4,.45,.5]);return $pdf->output();
 }
}
