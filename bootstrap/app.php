<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        if (env('TRUST_PROXY', false)) {
            $middleware->trustProxies(at: '*');
        }
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (\Illuminate\Database\QueryException $e, \Illuminate\Http\Request $r) {
            if ($r->expectsJson() && in_array($e->errorInfo[0] ?? '', ['23503','23505','23514','22001'], true)) {
                return response()->json(['message'=>'No se pudo guardar: revise los códigos relacionados, valores duplicados y límites de los campos.'],422);
            }
        });
    })->create();
