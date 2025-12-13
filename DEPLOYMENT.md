# Déploiement (Production) — BTP Assistant

Ce document décrit la procédure de déploiement en production via **Kamal**, ainsi que la configuration requise (Stripe / Unipile / OpenAI), les webhooks, la base de données SQLite et l’exécution des jobs via **SolidQueue**.

## 1) Pré-requis

### Accès serveur
- Accès SSH au serveur de production : `ubuntu@141.94.197.228`
- Domaine : `btp-assistant.5000.dev`
- SSL géré via le proxy Kamal (Let’s Encrypt)

### Outils locaux
- Ruby / Bundler (pour lancer `bin/kamal`)
- Docker (build/push image)
- Accès au registry Docker Hub : `loicboutet/btp_assistant`

## 2) Configuration Kamal

Fichier : `config/deploy.yml`

Points importants :
- Service : `btp_assistant`
- Image : `loicboutet/btp_assistant`
- Proxy SSL :
  - `ssl: true`
  - `host: btp-assistant.5000.dev`
- Volume persistant : `base_rails_app_storage:/rails/storage`
  - contient **SQLite** (`storage/*.sqlite3`) + **ActiveStorage** (`storage/*`)
- Jobs : `SOLID_QUEUE_IN_PUMA: true`
  - Les jobs ActiveJob tournent dans le process Puma (OK pour 1 serveur)

## 3) Secrets / Variables d’environnement

### Secrets Kamal (obligatoires)
Kamal lit les secrets via `.kamal/secrets`.

Variables attendues :
- `KAMAL_REGISTRY_PASSWORD` : token docker hub
- `RAILS_MASTER_KEY` : clé de déchiffrement des credentials Rails

> Ne jamais committer de secrets dans le repo.

### Credentials Rails (recommandé)
Le code supporte l’utilisation des **Rails credentials** (ex SMTP) et/ou de `AppSetting` (DB).

Commandes :
```bash
EDITOR=nano bin/rails credentials:edit
```

### AppSetting (dans la DB)
L’application stocke les paramètres applicatifs dans `AppSetting.instance` (singleton). En prod, ces valeurs se configurent depuis l’interface admin :
- Unipile : DSN, API key, account_id
- Stripe : secret key, webhook secret, price_id
- OpenAI : API key, model

⚠️ Il faut donc :
1) déployer,
2) se connecter à l’admin,
3) renseigner ces paramètres,
4) configurer les webhooks côté Stripe/Unipile.

## 4) Base de données (SQLite multi-DB)

Fichier : `config/database.yml`

En production :
- `primary` : `storage/btp_assistant_production.sqlite3`
- `cache` : `storage/btp_assistant_production_cache.sqlite3`
- `queue` : `storage/btp_assistant_production_queue.sqlite3` (SolidQueue)
- `cable` : `storage/btp_assistant_production_cable.sqlite3`

Ces fichiers sont dans `storage/` et doivent être **persistés** (volume Kamal).

### Migrations
Après un déploiement, vérifier que les migrations ont bien tourné.

Depuis la machine locale :
```bash
bin/kamal app exec "bin/rails db:migrate"
```

## 5) ActionMailer (IMPORTANT)

Dans `config/environments/production.rb`, le host est actuellement :
```ruby
config.action_mailer.default_url_options = { host: "example.com" }
```

➡️ À remplacer par le vrai domaine :
- `btp-assistant.5000.dev`

Et configurer SMTP (via credentials) si on envoie des emails en prod.

## 6) Webhooks (Stripe / Unipile)

### Stripe
Endpoint :
- `POST https://btp-assistant.5000.dev/webhooks/stripe`

À configurer dans Stripe Dashboard :
- Signing secret à copier dans `AppSetting.stripe_webhook_secret`
- Events minimum :
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.paid`
  - `invoice.payment_failed`

### Unipile
Endpoint :
- `POST https://btp-assistant.5000.dev/webhooks/unipile/messages`

Paramètres requis dans `AppSetting` :
- `unipile_dsn`
- `unipile_api_key`
- `unipile_account_id` (sert à authentifier les webhooks)

## 7) Commandes de déploiement Kamal

### Premier déploiement
```bash
bin/kamal setup
```

### Déploiement normal
```bash
bin/kamal deploy
```

### Logs
```bash
bin/kamal logs
```

### Console / shell
```bash
bin/kamal console
bin/kamal shell
```

## 8) Checks post-déploiement

1) **Healthcheck**
- `GET https://btp-assistant.5000.dev/up`

2) **Admin**
- Login admin : `https://btp-assistant.5000.dev/admin/login`
- Vérifier pages : dashboard, users, subscriptions, settings

3) **Settings**
- Renseigner Unipile / Stripe / OpenAI dans l’admin

4) **Webhooks**
- Déclencher un event Stripe (mode test) et vérifier l’arrivée dans `SystemLog`
- Envoyer un message WhatsApp test et vérifier création `WhatsappMessage`

5) **Jobs**
- Vérifier qu’un message entrant déclenche `ProcessWhatsappMessageJob`

## 9) Rollback

Kamal permet de revenir à la version précédente :
```bash
bin/kamal rollback
```

## 10) Monitoring minimal recommandé

- Utiliser `SystemLog` (admin) pour :
  - erreurs webhooks
  - erreurs jobs
  - activités admin

Optionnel (fortement recommandé) : ajouter Sentry/Honeybadger pour exceptions en prod.
