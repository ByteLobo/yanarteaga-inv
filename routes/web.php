<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\WorkspaceController;
use App\Http\Controllers\ReportController;

Route::get('/', fn()=>view('app'))->name('login');

Route::get('/api/session',[WorkspaceController::class,'session']);

Route::post('/api/login',[WorkspaceController::class,'login'])->middleware('throttle:5,1');

Route::middleware('auth')->group(function(){

 Route::get('/api/reports/catalog',[ReportController::class,'catalog']);
 Route::get('/api/reports/{id}',[ReportController::class,'generate']);
 Route::get('/api/documents/{kind}/{id}/print',[ReportController::class,'document']);
 Route::get('/api/assets/{id}/print',[ReportController::class,'asset']);
 Route::post('/api/logout',[WorkspaceController::class,'logout']);

 Route::get('/api/bootstrap',[WorkspaceController::class,'bootstrap']);

 Route::get('/api/records/{module}',[WorkspaceController::class,'records']);

 Route::get('/api/documents/{kind}/{id}',[WorkspaceController::class,'detail']);

 Route::post('/api/documents/{kind}',[WorkspaceController::class,'saveDocument']);

 Route::post('/api/documents/{kind}/{id}/{action}',[WorkspaceController::class,'action']);

 Route::post('/api/catalogs/{module}',[WorkspaceController::class,'saveCatalog']);

 Route::post('/api/periods',[WorkspaceController::class,'period']);

 Route::post('/api/counts',[WorkspaceController::class,'countInventory']);

 Route::post('/api/assets/{id}/assign',[WorkspaceController::class,'assignAsset']);

 Route::post('/api/planning',[WorkspaceController::class,'planning']);

 Route::post('/api/configuration',[WorkspaceController::class,'saveConfiguration']);
 Route::post('/api/assets',[WorkspaceController::class,'saveAsset']);
 Route::post('/api/users',[WorkspaceController::class,'saveUser']);

});

