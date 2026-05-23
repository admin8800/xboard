### xboard-docker


```
docker compose up -d
```
```
docker exec -it xboard php artisan xboard:install
```
```
docker restart xboard
```
```
docker cp xboard:/www/.env ./.env
```

---

迁移需要在新机器里将`.env`映射进去