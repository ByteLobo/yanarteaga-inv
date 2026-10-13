<?php
namespace Tests\Feature;
use Tests\TestCase;
use Illuminate\Support\Facades\DB;
class ReadinessTest extends TestCase {
 public function test_ready_checks_database_without_requiring_login():void {
  DB::shouldReceive('select')->once()->with('select 1 from msib.almacen limit 1')->andReturn([]);
  DB::shouldReceive('select')->once()->with('select 1 from public.app_report_issues limit 1')->andReturn([]);
  $this->getJson('/ready')->assertOk()->assertExactJson(['status'=>'ready']);
 }
 public function test_missing_key_is_unavailable():void {
  config(['app.key'=>'']);
  $this->getJson('/ready')->assertStatus(503)->assertExactJson(['status'=>'unavailable']);
 }
 public function test_database_failure_does_not_expose_connection_details():void {
  DB::shouldReceive('select')->once()->andThrow(new \RuntimeException('private connection details'));
  $this->getJson('/ready')->assertStatus(503)->assertExactJson(['status'=>'unavailable']);
 }
}
