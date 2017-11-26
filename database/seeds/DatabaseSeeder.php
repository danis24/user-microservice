<?php

use Illuminate\Database\Seeder;


class DatabaseSeeder extends Seeder
{
    /**
    * Run the database seeds.
    *
    * @return void
    */
    public function run()
    {
        factory(\App\Services\Users\User::class, 5)->create(
            [
                'password' => app('hash')->make('4n1qm4user!@#'),
            ]
        );
    }
}
