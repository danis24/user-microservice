<?php

namespace App\Services\Users;

use Illuminate\Auth\Authenticatable;
use Laravel\Lumen\Auth\Authorizable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Contracts\Auth\Access\Authorizable as AuthorizableContract;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Services\UUIDEntity;
use App\Presenters\JsonApiPresenterable as Presenterable;
use Uuid;

class User extends Model implements AuthenticatableContract, AuthorizableContract, Presenterable
{
    use Authenticatable, Authorizable, SoftDeletes, UUIDEntity;

    /**
     * Indicates if the IDs are auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'first_name', 'last_name', 'username', 'password', 'email'
    ];

    /**
     * The attributes excluded from the model's JSON form.
     *
     * @var array
     */
    protected $hidden = [
        'password',
    ];

    protected $casts = [
        "id" => "uuid",
    ];

    /**
     * transform Uuid
     * @param Uuid $user
     * @return Uuid
     */
    public function transform() {
        $transformed = $this->toArray();
        foreach ($this->getUuidAttributeNames() as $uuidAttributeName) {
            $value = $this->getAttribute($uuidAttributeName);
            $transformed[$uuidAttributeName] = Uuid::import($value)->string;
        }
        return $transformed;
    }

}
