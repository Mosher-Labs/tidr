# README

## Testing

We currently use [RSpec](https://github.com/rspec/rspec-rails) as
our test engine. We typically run those inside of the docker
container that is created in docker-compose.

```bash
docker exec -e "RAULS_ENV=test" tidr-app-1 bundle exec rspec
```
