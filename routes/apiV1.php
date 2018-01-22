<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->get('/users', [
    'as' => 'users', 'uses' => 'UserController@browse'
]);

$router->get('/users/{id}', [
    'as' => 'users', 'uses' => 'UserController@read'
]);
$router->patch('/users/{id}', [
    'as' => 'users', 'uses' => 'UserController@edit'
]);
$router->post('/users', [
    'as' => 'users', 'uses' => 'UserController@add'
]);
$router->delete('/users/{id}', [
    'as' => 'users', 'uses' => 'UserController@delete'
]);
$router->post('/register', [
    'as' => 'users', 'uses' => 'UserController@register'
]);
