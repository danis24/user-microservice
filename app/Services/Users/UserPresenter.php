<?php

namespace App\Services\Users;

use Illuminate\Support\Collection;
use Uuid;
use Illuminate\Pagination\AbstractPaginator;

class UserPresenter {

    public function transform(User $user) {
        $transformed = $user->toArray();
        foreach ($user->getUuidAttributeNames() as $uuidAttributeName) {
            $value = $user->getAttribute($uuidAttributeName);
            $transformed[$uuidAttributeName] = Uuid::import($value)->string;
        }

        return $transformed;
    }

    public function transformCollection(Collection $users) {
        return $users->map(function($user) {
            return $this->transform($user);
        });
    }

    public function render(User $user, $statusCode = 200, $headers = []) {

        return response()->json($this->transform($user), $statusCode, $headers);
    }


    public function renderCollection(Collection $users, $statusCode = 200, $headers = []) {
        $users = $this->transformCollection($users);
        return response()->json($users);
    }

    public function renderPaginator(AbstractPaginator $paginator, $statusCode = 200, $headers = []) {
        $collection = $this->transformCollection($paginator->getCollection());
        $paginator->setCollection($collection);
        return response()->json($paginator);
    }
}
