# docker-demo-sites

これはTraefik + Apache + PHPの**マルチサイト開発環境テンプレート**です。  
**hostsファイルの編集なしで** http://site1.localhost や http://site2.localhost にアクセスできます。

---

## 構成

- **Traefik**: リバースプロキシとして、`site1.localhost` や `site2.localhost` などのリクエストを自動でルーティング
- **Apache(PHP)**: 各サブドメインに対応したVirtualHostでサイトを公開
- **sites/**: 各サイトのドキュメントルート

---

## 使い方

### 1. 必要なファイル・ディレクトリ

```
docker-demo-sites/
├── Dockerfile
├── docker-compose.yml
├── traefik/
│   └── traefik.yml
└── sites/
    ├── site1/
    │   └── index.php
    └── site2/
        └── index.php
```

### 2. サイトファイルの作成

例:  
`sites/site1/index.php`
```php
<?php
echo "This is SITE 1";
```

`sites/site2/index.php`
```php
<?php
echo "This is SITE 2";
```

### 3. docker-compose.yml で labels を設定

`php-web` サービスの定義例：

```yaml
  php-web:
    build: .
    volumes:
      - ./sites:/var/www/html
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.site1.rule=Host(`site1.localhost`)"
      - "traefik.http.routers.site1.entrypoints=web"
      - "traefik.http.routers.site2.rule=Host(`site2.localhost`)"
      - "traefik.http.routers.site2.entrypoints=web"
```

これにより、Traefikがリクエストの`Host`ヘッダ（site1.localhostやsite2.localhost）で自動的にルーティングします。

### 4. ビルドと起動

```sh
docker-compose build
docker-compose up -d
```

### 5. アクセス

- [http://site1.localhost](http://site1.localhost)
- [http://site2.localhost](http://site2.localhost)

**hostsファイルの編集は一切不要**です。  
（`.localhost`ドメインはローカルループバックへ自動で割り当てられるため、追加設定なしでアクセスできます）

---

## Traefikダッシュボード

- [http://localhost:8088](http://localhost:8088)
- ルーティング状況やサービス状態の確認に便利です

---

## サイト追加方法

1. `sites/yournewsite/index.php` を作成
2. Dockerfileの `<VirtualHost>` セクションに新しいサイト用の設定を追記
3. **docker-compose.ymlのlabelsにルーター定義を追加**  
   例:
   ```yaml
   - "traefik.http.routers.yournewsite.rule=Host(`yournewsite.localhost`)"
   - "traefik.http.routers.yournewsite.entrypoints=web"
   ```
4. `docker-compose build` し直す
5. `http://yournewsite.localhost` でアクセス

---

## トラブルシューティング

- **404 Not Found**  
  → docker-compose.ymlのlabels設定、DockerfileのVirtualHost記述を再確認。`docker-compose build`と`docker-compose up -d`をやり直し。
- **設定変更が反映されない**  
  → 必ず `docker-compose build` の後に `docker-compose up -d` を行ってください。

---

## ライセンス

MIT（ご自由にご利用ください）
