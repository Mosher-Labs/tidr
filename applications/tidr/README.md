# README

## Testing

We currently use [RSpec](https://github.com/rspec/rspec-rails) as
our test engine. We typically run those inside of the docker
container that is created in docker-compose.

```bash
docker exec -e "RAILS_ENV=test" tidr-app-1 bundle exec rspec
```

To generate a new spec file, you can run something similiar to this:

```bash
docker exec -e "RAILS_ENV=test" tidr-app-1 bundle exec rails g rspec:model user
```

```bash
docker-compose run --rm app bin/rails credentials:edit
docker-compose run --rm app bin/rails db:migrate
```
