<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

use Illuminate\Support\Str;

class Legacy {

 public static function table(string $table){return DB::table('msib.'.$table);}

 // Explicit overrides always win. Required legacy technical fields receive neutral values.

 public static function insert(string $table,array $data):void {

  $columns=DB::select("select column_name,data_type,is_nullable from information_schema.columns where table_schema='msib' and table_name=?",[$table]);

  $row=[];foreach($columns as $c){$n=$c->column_name;if(array_key_exists($n,$data)){$row[$n]=$data[$n];continue;}if($c->is_nullable==='YES'){$row[$n]=null;continue;}

   $row[$n]=match($c->data_type){'smallint','integer','bigint','numeric'=>0,'boolean'=>false,'date'=>'0001-01-01','timestamp without time zone'=>now()->toDateTimeString(),default=>''};

   if(str_ends_with($n,'user'))$row[$n]=auth()->user()?->username??'yanarteaga';

   if(str_ends_with($n,'date'))$row[$n]=now()->toDateTimeString();

  }self::table($table)->insert($row);

 }

 public static function audit(string $action,string $ref,array $data=[]):void {DB::table('app_audit')->insert(['actor'=>auth()->user()?->username??'yanarteaga','action'=>$action,'reference'=>$ref,'detail'=>json_encode($data),'created_at'=>now()]);}

 public static function uuid():string{return (string)Str::uuid();}

}

