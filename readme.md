# users-microservice

Is an API Services that used for maintain user.

User microservices.

This is a collection of API Services that used for maintain user.
This api has features:
- Browse users:
`GET /users`
- Read User by id:
`GET /users/{id}`
- Edit User by id:
`PATCH /users/{id}`
- Add User:
`POST /users`
- Delete User by ID
`DELETE /users/{id}`
- Delete Mulitple User
`DELETE /users`


Framework using latest production lumen version.
- Use Service Layer for Domain Business Logic


User microservice has entities:

- User
    - id (uuid.v4)
    - username
    - password
    - last_name
    - first_name
    - email
    - created_at
    - updated_at
    - deleted_at

- LoginHistory
    - user_id (uuid.v4)
    - login_date


for example user danis has a preference:
    person_filter: {"visible_columns": ["username", "password"], "entity": "users", "sorts": "-id,-created_at"}
    - preference_attributes:
        id: 1, name: person_filter
    - preference_entities:
        id: 2, name: "users", entity_id: user_id
    - preference_attribute_values:
        id: 3, attribute_id: 1, entity_id: 2, value: {"visible_columns": ["username", "password"], "entity": "users", "sorts": "-id,-created_at"}



- Preference (EAV Model)
    - preference_attributes
        - id (uuid.v4)
        - name

    - preference_entities
        - id (uuid.v4)
        - name
        - entity_id

    - preference_attrbute_values
        - id (uuid.v4)
        - attribute_id
        - entity_id
        - data_type (string)

        - string_value
        - json_value
        - boolean_value
        - numeric_value
        - decimal_value
