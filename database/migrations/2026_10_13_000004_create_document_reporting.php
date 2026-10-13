<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up():void {
  Schema::create('app_document_signatures',function(Blueprint $t){
   $t->id();$t->string('document_id',36);$t->integer('state');$t->foreignId('user_id')->constrained('users');$t->string('username');$t->string('name');$t->string('role');$t->string('statement');$t->timestamp('signed_at');$t->unique(['document_id','state']);
  });
  Schema::create('app_report_issues',function(Blueprint $t){
   $t->uuid('id')->primary();$t->string('report');$t->string('reference')->nullable();$t->string('actor');$t->string('format');$t->jsonb('filters');$t->string('sha256',64);$t->integer('row_count');$t->timestamp('created_at');
  });
 }
 public function down():void {Schema::dropIfExists('app_report_issues');Schema::dropIfExists('app_document_signatures');}
};
