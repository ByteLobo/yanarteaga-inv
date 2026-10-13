<?php

use Illuminate\Database\Migrations\Migration;

use Illuminate\Database\Schema\Blueprint;

use Illuminate\Support\Facades\Schema;

use Illuminate\Support\Facades\DB;

return new class extends Migration {

 public function up():void {

  Schema::table('users',function(Blueprint $t){$t->string('username')->unique()->nullable();$t->string('role')->default('viewer');$t->json('warehouses')->nullable();});

  Schema::create('app_audit',function(Blueprint $t){$t->id();$t->string('actor');$t->string('action');$t->string('reference');$t->jsonb('detail');$t->timestamp('created_at');});

  Schema::create('app_sequences',function(Blueprint $t){$t->string('key')->primary();$t->unsignedBigInteger('value')->default(0);});

  Schema::create('app_count_sessions',function(Blueprint $t){$t->uuid('id')->primary();$t->integer('warehouse_id');$t->date('date');$t->string('actor');$t->string('status')->default('BORRADOR');$t->jsonb('lines');$t->text('notes');$t->timestamps();});

  Schema::create('app_purchase_plans',function(Blueprint $t){$t->uuid('id')->primary();$t->integer('warehouse_id');$t->integer('months');$t->jsonb('lines');$t->string('actor');$t->timestamps();});

  Schema::create('app_asset_assignments',function(Blueprint $t){$t->uuid('id')->primary();$t->string('asset_id',36);$t->integer('custodian_id');$t->integer('office_id');$t->string('actor');$t->text('notes');$t->timestamp('created_at');});

  DB::statement("CREATE UNIQUE INDEX app_pending_cancel_unique ON msib.autorizacionanulacion (autanu_transaccion_id) WHERE autanu_estado_id = 8000");

 }

 public function down():void {DB::statement('DROP INDEX IF EXISTS msib.app_pending_cancel_unique');foreach(['app_asset_assignments','app_purchase_plans','app_count_sessions','app_sequences','app_audit'] as $t)Schema::dropIfExists($t);Schema::table('users',fn(Blueprint $t)=>$t->dropColumn(['username','role','warehouses']));}

};

