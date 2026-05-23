### xboard-docker
```
services:
  xboard:
    image: ghcr.io/admin8800/xboard
    container_name: xboard
    restart: always
    ports:
      - "7001:80"
    volumes:
      - ./sqlite-data:/www/sqlite-data
      - ./theme:/www/storage/theme
      - ./plugins:/www/plugins
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:5.7
    container_name: xboard-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: xboard
      MYSQL_USER: xboard
      MYSQL_PASSWORD: xboard
    volumes:
      - ./mysql:/var/lib/mysql

  redis:
    image: redis:7-alpine
    container_name: xboard-redis
    restart: always
    command: redis-server --appendonly yes
    volumes:
      - ./redis:/data
```
- 启动容器
```
docker compose up -d
```
- 导入数据库
```
docker exec -it xboard php artisan xboard:install
```
- 重启xboard
```
docker restart xboard
```
- 将持久化配置复制出来
```
docker cp xboard:/www/.env ./.env
```

---

迁移需要在新机器里将`.env`映射进去
```
- ./.env:/www/.env
```
