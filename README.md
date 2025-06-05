# docker-demo-sites

これはTraefik + Apache + PHPの**マルチサイト開発環境テンプレート**です。  
**hostsファイルの編集なしで** http://site1.localhost や http://site2.localhost にアクセスできます。

---

## 概要

- **Traefik**がリバースプロキシとして各サブドメインを自動ルーティング
- **Apache(PHP)**がバーチャルホストで各サイトを公開
- **sites/** ディレクトリに各サイトのドキュメントルートを配置
- **BrowserSync**によるライブリロード対応

---

## 使い方

### 1. 必要なファイル・ディレクトリ

```
docker-demo-sites/
├── Dockerfile
├── docker-compose.yml
├── traefik/
│   └── traefik.yml
├── apache/
│   └── vhosts.conf
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

---

## サイト追加方法

1. **新しいディレクトリとファイルを作成**  
   例: `sites/yournewsite/index.php`
   ```php
   <?php
   echo "This is YOUR NEW SITE";
   ```
2. **apache/vhosts.conf にVirtualHostを追加**  
   例:
   ```apache
   <VirtualHost *:80>
       ServerName yournewsite.localhost
       DocumentRoot /var/www/html/yournewsite
       <Directory "/var/www/html/yournewsite">
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```
3. **docker-compose.yml のphp-webサービスのlabelsにルーター定義を追加**  
   例:
   ```yaml
   - "traefik.http.routers.yournewsite.rule=Host(`yournewsite.localhost`)"
   - "traefik.http.routers.yournewsite.entrypoints=web"
   ```
4. **ビルドと起動をやり直す**
   ```sh
   docker-compose build
   docker-compose up -d
   ```
5. **ブラウザでアクセス**
   - http://yournewsite.localhost

---

## BrowserSyncによるライブリロード

このテンプレートは**BrowserSyncによる自動リロード（ライブリロード）**にも対応しています。  
開発中にファイルを保存すると、ブラウザが自動でリロードされます。

### 使い方

1. `docker-compose.yml` の `browsersync` サービスを有効にしてください。
    ```yaml
    browsersync:
      image: node:20
      container_name: browsersync-docker-demo-sites
      working_dir: /app
      volumes:
        - ./sites:/app
      command: >
        sh -c "npm config set strict-ssl false &&
              npm install -g browser-sync &&
              browser-sync start --proxy 'php-web:80' --files '/app/**/*' --host '0.0.0.0' --port 3001 --no-open --no-ui"
      ports:
        - "3001:3001"
    ```
2. サービスを起動
    ```sh
    docker-compose up -d
    ```
3. ブラウザで [http://localhost:3001/](http://localhost:3001/) にアクセス  
   → `sites/site1/index.php` の内容がライブリロード付きで表示されます。

---

### BrowserSyncで表示するサイトの切り替え方法

- **browsersyncで http://localhost:3001/ に表示されるサイトは、`apache/vhosts.conf` の一番上のVirtualHost（デフォルトバーチャルホスト）で決まります。**
- 例：`site1`を表示したい場合は、`vhosts.conf`の一番上に`DocumentRoot /var/www/html/site1`のVirtualHostを記述してください。
- サイトを切り替えたい場合は、`vhosts.conf`の順番を入れ替えて`docker-compose restart`してください。

---

> ※複数サイトでBrowserSyncを使いたい場合は、サービスをサイトごとに追加し、`--proxy`や`--port`を変更してください。

---

## Traefikダッシュボード

- [http://localhost:8088](http://localhost:8088)
- ルーティング状況やサービス状態の確認に便利です

---

## トラブルシューティング

- **404 Not Found**  
  → docker-compose.ymlのlabels設定、VirtualHost記述、ファイル配置を再確認。`docker-compose build`と`docker-compose up -d`をやり直し。
- **設定変更が反映されない**  
  → 必ず `docker-compose build` の後に `docker-compose up -d` を行ってください。
- **BrowserSyncで自動リロードしない**  
  → `--files` オプションのパスや、HTMLに`<body>`タグがあるかを確認してください。証明書エラーが出る場合は `npm config set strict-ssl false` を追加してください。

---

## ライセンス

MIT（ご自由にご利用ください）