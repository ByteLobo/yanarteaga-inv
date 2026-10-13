<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>{{ $report['title'] }}</title>
<style>
@page { margin: 109px 30px 49px 30px; }
body{font-family:'DejaVu Sans',sans-serif;font-size:8px;color:#24324a;line-height:1.35;}
header{position:fixed;top:-89px;left:0;right:0;height:74px;border-bottom:2px solid #6653ca;}
.brand{font-size:15px;font-weight:bold;color:#6653ca;letter-spacing:-.5px;}
.brand-sub{font-size:6px;letter-spacing:1.4px;color:#8c95a7;margin-top:2px;}
h1{font-size:14px;margin:8px 0 0;line-height:1.3;color:#26314b;}
.header-table{width:100%;border-collapse:collapse;}.header-table td{padding:0;vertical-align:top;border:none;background:transparent;}
.emit{font-size:6.5px;text-align:right;width:190px;color:#6e7a90;line-height:1.6;}
.code{font-size:9px;font-weight:bold;color:#6653ca;}
.footer{position:fixed;bottom:-32px;left:0;right:90px;font-size:6px;color:#929dad;border-top:1px solid #dce2ec;padding-top:7px;}
.watermark{position:fixed;top:215px;left:20px;font-size:43px;font-weight:bold;color:#e9dfe4;transform:rotate(-22deg);z-index:-1000;}
.status{border:1px solid #d8c8b7;padding:5px 8px;color:#806f55;font-size:8px;margin-bottom:12px;background:#fbf8f3;}
.metadata{width:100%;border-collapse:collapse;margin:0 0 8px;table-layout:fixed;}
.metadata td{padding:4px 9px;border:1px solid #e2e6ef;vertical-align:top;background:#fbfcfe;}
.label{font-size:6px;text-transform:uppercase;color:#8994a8;letter-spacing:.4px;margin-bottom:3px;}.value{font-size:8px;overflow-wrap:break-word;}
h2{page-break-after:avoid;font-size:10px;color:#3b4861;margin:10px 0 6px;border-left:3px solid #9e8bda;padding-left:7px;}
.section{margin-bottom:6px;}.continued{margin-top:10px;}
table.data{width:100%;border-collapse:collapse;table-layout:fixed;}
table.data thead{display:table-header-group;}table.data th{background:#edf0f7;color:#67748b;border:1px solid #d9dfeb;padding:6px 5px;font-size:7px;text-align:left;font-weight:bold;}
table.data td{border:1px solid #e1e6ef;padding:5px 5px;vertical-align:top;font-size:7px;overflow-wrap:break-word;word-wrap:break-word;}table.data tr{page-break-inside:avoid;}table.data tr:nth-child(even){background:#fafbfe;}
.num{text-align:right;font-variant-numeric:tabular-nums;}table.data .total td{background:#eeeaf8;font-weight:bold;color:#6653a4;}
.empty{text-align:center;padding:16px;color:#8e99a9;}.notes{margin-top:10px;padding:8px;border:1px solid #e1e6ef;page-break-inside:avoid;font-size:7px;color:#6c7890;}.notes p{margin:4px 0;}
.signatures{width:100%;border-collapse:collapse;margin-top:14px;page-break-inside:avoid;}.signatures td{vertical-align:top;width:50%;padding:0 18px 8px;text-align:center;border:0;}.signature-line{height:20px;border-bottom:1px solid #9ba4b4;margin-bottom:5px;}.signature-title{font-weight:bold;font-size:8px;margin-bottom:4px;}.origin{font-size:6px;color:#9aa4b3;margin-top:5px;}
.signature-record{page-break-inside:avoid;margin-top:16px;}.signature-context{font-size:7px;color:#7d899c;padding:7px 10px;background:#f8f9fc;border:1px solid #e1e6ef;}.signature-record h2{margin-bottom:7px;}.signature-record .signatures{margin-top:9px;}.issue{font-size:6px;color:#9ca6b5;margin-top:12px;overflow-wrap:anywhere;}
@media screen{body{max-width:1100px;margin:30px auto;font-size:11px;padding:20px;background:white;}header,.footer{position:static;height:auto;padding-bottom:12px;margin-bottom:18px;}.watermark{position:fixed;opacity:.6;}h1{font-size:23px;}h2{font-size:16px;}table.data td,table.data th{font-size:11px;}.continued{page-break-before:auto;}.metadata .value{font-size:12px;}.emit,.label{font-size:10px;}}
</style></head><body>
<header><table class="header-table"><tr><td><div class="brand">yanarteaga</div><div class="brand-sub">GESTIÓN DE INVENTARIO</div><h1>{{ $report['title'] }}</h1></td><td class="emit"><div class="code">{{ $report['code'] }}</div>Emitido: {{ $report['emitted_at'] }}<br>Usuario emisor: {{ $report['actor'] }}<br>Importes en bolivianos (Bs)</td></tr></table></header>
<div class="footer">yanarteaga · {{ $report['code'] }} · {{ $report['reference'] ?? 'Reporte de consulta' }}</div>
@if($report['watermark'])<div class="watermark">{{ $report['watermark'] }}</div><div class="status">{{ $report['watermark'] }} · El estado corresponde al documento registrado.</div>@endif
@if($report['metadata'])<table class="metadata">@foreach(array_chunk($report['metadata'],2,true) as $pair)<tr>@foreach($pair as $label=>$value)<td><div class="label">{{ $label }}</div><div class="value">{{ $value ?? 'Sin dato' }}</div></td>@endforeach @if(count($pair)===1)<td></td>@endif</tr>@endforeach</table>@endif
@foreach($panels as $panel)
<div class="section {{ !empty($panel['continued'])?'continued':'' }}"><h2>{{ $panel['title'] }}</h2><table class="data"><thead><tr>@foreach($panel['columns'] as $column)<th>{{ $column['label'] }}</th>@endforeach</tr></thead><tbody>
@forelse($panel['rows'] as $row)<tr>@foreach($panel['columns'] as $column)@php($v=$row[$column['key']]??'')<td class="{{ $column['type']!=='text'?'num':'' }}">@if($v===''||$v===null)&nbsp;@elseif($column['type']==='money'){{ number_format((float)$v,2,',','.') }}@elseif($column['type']==='number'){{ is_numeric($v)?number_format((float)$v,0,',','.'):$v }}@else{{ is_scalar($v)?$v:json_encode($v,JSON_UNESCAPED_UNICODE) }}@endif</td>@endforeach</tr>
@empty<tr><td colspan="{{ max(1,count($panel['columns'])) }}" class="empty">Sin registros para los filtros seleccionados.</td></tr>@endforelse
@if($panel['totals'])<tr class="total">@foreach($panel['columns'] as $i=>$column)<td class="{{ $column['type']!=='text'?'num':'' }}">@if($i===0)TOTAL / SALDO FINAL @elseif(array_key_exists($column['key'],$panel['totals'])){{ number_format($panel['totals'][$column['key']],$column['type']==='money'?2:0,',','.') }}@endif</td>@endforeach</tr>@endif
</tbody></table></div>
@endforeach
@if(array_filter($report['notes'],fn($note)=>trim((string)$note)!==''))<div class="notes"><strong>Notas y criterios del documento</strong>@foreach($report['notes'] as $note)@if($note)<p>{!! nl2br(e($note)) !!}</p>@endif @endforeach</div>@endif
@if($report['signatures'])<div class="signature-record"><h2>Constancia de revisión y firmas</h2><div class="signature-context">Documento: {{ $report['metadata']['Nro. documento'] ?? $report['reference'] ?? $report['code'] }} · Almacén / oficina: {{ $report['metadata']['Almacén'] ?? $report['metadata']['Oficina'] ?? 'Según datos del documento' }} · Fecha: {{ $report['metadata']['Fecha de almacén'] ?? $report['metadata']['Fecha de inicio'] ?? $report['emitted_at'] }}</div><table class="signatures"><tr>@foreach($report['signatures'] as $signature)<td><div class="signature-line"></div><div class="signature-title">{{ $signature['statement'] }}</div>{{ $signature['name']?:'Nombre: ____________________' }}<br>{{ $signature['role']?:'Cargo: ____________________' }}<br>Fecha: {{ $signature['date']?:'____________________' }}<div class="origin">{{ $signature['origin'] }}</div></td>@endforeach</tr></table></div>@endif
@if(!empty($report['issue_id']))<div class="issue">Identificador de emisión: {{ $report['issue_id'] }} · Referencia para auditoría de esta descarga.</div>@endif
</body></html>
