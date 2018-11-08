<?php

namespace App\Http\Api\V1\Controllers;

use App\Services\Users\UserService;
use Laravel\Lumen\Routing\Controller;
use Illuminate\Http\Request;
use App\Presenters\JsonApiPresenter;

class UserController extends Controller
{
    private $service;

    /**
     * Constructor
     * @param \App\Services\Users\UserService user service
     * @return UserController
     */
    public function __construct(UserService $service)
    {
        $this->service = $service;
        $this->presenter = new JsonApiPresenter;
    }

    /**
     * Browse Users
     * @return \Illuminate\Http\JsonResponse
     */
    public function browse()
    {
        $users = $this->service->browse();
        return $this->presenter->renderPaginator($users, 200);
    }

    /**
     * Read user by id
     * @return \Illuminate\Http\JsonResponse
     */
    public function read($id)
    {
        $user = $this->service->read($id);
        if ($user) {
            return $this->presenter->render($user, 200);
        }
        return $this->notFountSetValue();
    }

    /**
     * Edit user by id
     * @return \Illuminate\Http\JsonResßponse
     * @param \Illuminate\Http\Request $request
     */
    public function edit($id, Request $request)
    {
        $user = $this->service->edit($id, $request);
        if ($user) {
            $headers = [
                'Content-Type' => 'application/vnd.api+json',
                'Accept' => 'application/vnd.api+json'
            ];
            return $this->presenter->render($user, 201, $headers);
        }
        return $this->notFountSetValue();
    }

    /**
     * Add user
     * @param \Illuminate\Http\Request $request
     */
    public function add(Request $request)
    {
        $this->validate($request, [
            "first_name" => "required",
            "last_name" => "required",
            "email" => "required|unique:users,email",
            "password" => "required",
        ]);

        $user = $this->service->add($request);
        $headers = [
            'Content-Type' => 'application/vnd.api+json',
            'Accept' => 'application/vnd.api+json'
        ];
        return $this->presenter->render($user, 201, $headers);
    }

    /**
     * Delete User by id
     */
    public function delete($id)
    {
        $deleted = $this->service->delete($id);
        if ($deleted) {
            return response()->json([
                'meta' => [
                    'deleted_count' => $deleted,
                ]
            ], 204);
        }
        return $this->notFountSetValue();
    }

    public function register(Request $request)
    {
        $data = [
             'first_name' => $request->first_name,
             'last_name' => $request->last_name,
             'email' => $request->email,
             'password' => app('hash')->make($request->password),
             'phone' => $request->phone,
             'country' => $request->country
         ];
        $user = $this->service->register($data);
        $headers = [
            'Content-Type' => 'application/vnd.api+json',
            'Accept' => 'application/vnd.api+json'
         ];
        return $this->presenter->render($user, 200, $headers);
    }

    private function notFountSetValue()
    {
        return response()->json([
            'meta' => [
                'status' => "Not Found",
            ]
        ], 404);
    }
}
