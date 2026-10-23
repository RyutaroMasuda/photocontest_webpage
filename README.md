# みんなのフォトコンテスト

仲間うちで写真を投稿し、いいねで競う小さなフォトコンテストアプリです。
HTML 1 枚と Firebase (Hosting / Authentication / Cloud Firestore) だけで動きます。

## 主な機能

- **ゲスト閲覧**: ログインなしでオープンなフォトコンを閲覧できます
- **Google ログイン**と表示名の設定
- **フォトコングループ**の作成 (オープン / プライベート)
- **招待リンク・招待コード**でプライベートグループに参加
- **写真の投稿**、タイトル編集、削除
- **いいね投票**
- 管理者 (グループ作成者) 向けの設定
  - 締め切り日時
  - いいね数の公開 / 非公開
  - 1 人あたりの投票数の上限
  - 自分の写真へのいいねの可否
  - 投票の開始 / 停止
  - グループの削除
- 参加メンバー一覧
- 開発者ダッシュボード (全体の利用状況)
- スマホ対応、LINE などアプリ内ブラウザから外部ブラウザへの誘導

## 構成

```
.
├── code.html               # アプリ本体 (HTML / CSS / JS をこの 1 ファイルに集約)
├── firestore.rules         # Firestore セキュリティルール (アクセス制御はすべてここ)
├── firestore.indexes.json  # Firestore インデックス定義
├── firebase.json           # Firebase Hosting / Firestore の設定
├── .firebaserc             # デプロイ先の Firebase プロジェクト ID
└── deploy.sh               # デプロイ用スクリプト
```

`public/` は `deploy.sh` が `code.html` から生成するため、リポジトリには含めていません。


## セットアップ (自分の Firebase プロジェクトで動かす)

### 1. Firebase プロジェクトを用意する

1. [Firebase コンソール](https://console.firebase.google.com/) でプロジェクトを作成する
2. ウェブアプリを追加し、表示される `firebaseConfig` を控える
3. **Authentication** で「Google」プロバイダを有効にする
4. **Firestore Database** を作成する (リージョンは任意。例: `asia-northeast1`)

### 2. 設定を書き換える

- `.firebaserc` の `default` を自分のプロジェクト ID に変える
- `code.html` の次の値を自分のものに変える
  - `firebaseConfig` 一式
  - `authDomain` は Hosting のドメイン (`<project-id>.web.app`) にする
  - `GOOGLE_CLIENT_ID` (下記の OAuth クライアント ID)

### 3. Google OAuth クライアントの設定

スマホでは Google のログイン画面に直接ページ遷移する方式を使っています。
[Google Cloud Console の認証情報](https://console.cloud.google.com/apis/credentials) で、
「Web client (auto created by Google Service)」を開き、次を登録してください。

- 承認済みの JavaScript 生成元
  - `https://<project-id>.web.app`
- 承認済みのリダイレクト URI
  - `https://<project-id>.web.app/`
  - `https://<project-id>.web.app/__/auth/handler`

このクライアントの ID を `code.html` の `GOOGLE_CLIENT_ID` に設定します。

### 4. デプロイ

[Firebase CLI](https://firebase.google.com/docs/cli) をインストールしてログインしておきます。

```bash
npm install -g firebase-tools
firebase login

./deploy.sh          # 画面 (code.html) だけデプロイ
./deploy.sh rules    # 画面 + セキュリティルールをデプロイ
```

`deploy.sh` は `code.html` にビルド時刻を埋め込み、`public/index.html` として出力してからデプロイします。
画面下部に表示されるビルド時刻で、ブラウザが最新版を読み込んでいるか確認できます。

### 5. 開発者ダッシュボードを使う (任意)

自分のアカウントを開発者として登録すると、ヘッダーに「開発者」ボタンが表示され、
プライベートを含む全グループの利用状況を確認できます。

1. アプリに Google でログインする
2. Firebase コンソールの Authentication → ユーザー で自分の **ユーザー UID** をコピーする
3. Firestore Database で `admins` コレクションを作り、ドキュメント ID にその UID を指定して保存する (フィールドは空で構いません)
4. アプリを再読み込みする

`admins` コレクションはセキュリティルールでアプリからの読み書きをすべて禁止しているため、コンソールからしか変更できません。

## セキュリティについて

- **API キーが HTML に含まれるのは正常**です。Firebase のウェブ用 API キーはプロジェクトの識別子で、秘密情報ではありません。
- アクセス制御はすべて `firestore.rules` で行っています。画面上の制御は利便性のためで、保護にはなっていません。
- ルールで強制している主な制約
  - プライベートグループの写真はメンバーのみ閲覧可
  - 投稿・編集は本人のみ、削除は本人とグループ管理者のみ
  - 締め切り後の投稿・投票の禁止、投票開始前の投票の禁止
  - 自分の写真へのいいね禁止 (設定時)
- **画面側のみの制御** (ルールでは強制していないもの)
  - いいね数の非公開 (データ自体は閲覧権限のある人が読めます)
  - 1 人あたりの投票数の上限
- ログインすれば誰でもグループ作成や投稿ができます。広く公開する場合は [App Check](https://firebase.google.com/docs/app-check) の導入や投稿数の制限を検討してください。
- 画像は Firestore のドキュメントに直接保存しているため、無料枠 (1 GiB) を目安に運用してください。

## 既知の制約

- LINE・Instagram などのアプリ内ブラウザでは Google がログインを拒否します。アプリは外部ブラウザへの切り替えを案内します。
- Tailwind CSS は CDN 版を使っているため、コンソールに本番利用の警告が表示されます。
