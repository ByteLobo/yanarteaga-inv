<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

use App\Models\User;

use Illuminate\Support\Facades\Hash;

class CreateManager extends Command {

 protected $signature='app:create-manager {--username=yanarteaga} {--password=} {--email=yanarteaga@localhost}';

 protected $description='Crea el gestionador inicial con una contraseña elegida';

 public function handle():int {$password=$this->option('password')?:$this->secret('Contraseña (mínimo 12 caracteres)');if(strlen($password??'')<12){$this->error('Mínimo 12 caracteres');return 1;}if(User::where('username',$this->option('username'))->exists()){$this->error('El usuario ya existe.');return 1;}$u=new User;$u->name=$this->option('username');$u->username=$this->option('username');$u->email=$this->option('email');$u->password=Hash::make($password);$u->role='admin';$u->warehouses='[]';$u->save();$this->info('Gestionador creado: '.$u->username);return 0;}

}

