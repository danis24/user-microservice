<?php

namespace App\Services\Users;

use Illuminate\Contracts\Support\Arrayable;
use Uuid;

class UserService
{

    /**
     * newUser
     * @return UUid
     */
    private function newUser()
    {
        return new User;
    }

    /**
     * browse User
     */
    public function browse()
    {
        return $this->newUser()->paginate();
    }

    /**
     * read user by id
     */
    public function read($id)
    {
        return $this->newUser()->findByUuid($id);
    }

    /**
     * Edit user by id
     * @param Illuminate\Contracts\Support\Arrayable $payload
     */
    public function edit($id, Arrayable $payload)
    {
        $user = $this->read($id);
        if ($user) {
            foreach ($payload->toArray() as $key => $value) {
                $user->setAttribute($key, $value);
            }
            $user->save();
            return $user;
        }
        return null;
    }

    /**
     * Add user in json
     * @param Illuminate\Contracts\Support\Arrayable $payload
     */
    public function add(Arrayable $payload)
    {
        return $this->newUser()->create($payload->toArray());
    }

    /**
     * delete User by id
     */
    public function delete($id)
    {
        return $this->newUser()->destroyByUuid($id);
    }

    public function register($payload)
    {
        return $this->newUser()->create($payload);
    }
}
