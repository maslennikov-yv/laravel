```sh
cp .env.example .env
```

Install PHP dependencies:

```sh
docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd):/var/www/html" -w /var/www/html laravelsail/php84-composer:latest composer install --ignore-platform-reqs
```

Up containers:

```sh
vendor/bin/sail up -d
```

Generate application key:

```sh
vendor/bin/sail php artisan key:generate
```

Run database migrations:

```sh
vendor/bin/sail php artisan migrate
```

Run database seeder:

```sh
vendor/bin/sail php artisan db:seed
```
Shell:

```sh
vendor/bin/sail shell
```

Stop containers:

```sh
vendor/bin/sail stop
```
