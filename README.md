# QuotaFor — CRM Promotore Finanziario

## Descrizione

QuotaFor è un'applicazione CRM Rails pensata per promotori finanziari.
Consente di gestire clienti, appuntamenti, attività ricorrenti, note di timeline e notifiche.
Include un feed ICS per sincronizzare gli appuntamenti con Google Calendar / Apple Calendar e un sistema di reminder via email e notifiche in-app.

## Requisiti

- Ruby 3.2.2
- Rails 8.1
- PostgreSQL
- Node.js + Yarn (per la pipeline CSS con Bootstrap)

## Setup sviluppo

```bash
bundle install
yarn install
rails db:create db:migrate db:seed
bin/dev          # avvia web server + watcher CSS (Procfile.dev)
```

`Procfile.dev` avvia:
- `web` — Rails server con debug aperto (`RUBY_DEBUG_OPEN=true`)
- `css` — `yarn watch:css` per compilazione Bootstrap in tempo reale

## Variabili d'ambiente

Crea un file `.env` nella root del progetto (ignorato da git):

| Variabile        | Descrizione                        | Esempio                  |
|------------------|------------------------------------|--------------------------|
| `HOST`           | Host pubblico dell'app             | `app.example.com`        |
| `SMTP_ADDRESS`   | Host SMTP                          | `smtp.gmail.com`         |
| `SMTP_PORT`      | Porta SMTP                         | `587`                    |
| `SMTP_USERNAME`  | Username SMTP                      | `user@example.com`       |
| `SMTP_PASSWORD`  | Password SMTP                      | `secret`                 |
| `SECRET_KEY_BASE`| Chiave segreta Rails               | *(output di `rails secret`)* |
| `SOLID_QUEUE_IN_PUMA` | Avvia solid_queue inline in Puma | `true`              |
| `SENTRY_DSN`     | DSN Sentry per error tracking      | `https://...@sentry.io/` |

## Feed ICS (Calendario)

- **URL feed**: `GET /calendar/feed/:token.ics`
- **Rigenera token**: `POST /calendar/regenerate_token` *(richiede autenticazione)*

Per aggiungere il feed a un calendario esterno:
1. Accedi all'app e copia l'URL del tuo feed personale
2. In Google Calendar: *+ Aggiungi calendario → Da URL*
3. In Apple Calendar: *File → Nuovo abbonamento calendario*

## Worker / Job Queue

I reminder email e le notifiche in-app vengono inviati tramite ActiveJob con **solid_queue** (default Rails 8.1).

| Job | Descrizione |
|-----|-------------|
| `AppointmentDayBeforeReminderJob` | Invia reminder per un singolo appuntamento (con token antiduplicato) |
| `DayBeforeAppointmentReminderJob` | Scansiona tutti gli appuntamenti di domani e invia reminder |

### Avvio worker in produzione

**Opzione A — inline in Puma** (semplice, server singolo):
```bash
SOLID_QUEUE_IN_PUMA=true bundle exec puma
```

**Opzione B — processo separato** (raccomandato):
```bash
bundle exec rake solid_queue:start
```

> ⚠️ Non usare l'adapter `:async` in produzione: non persiste i job tra i restart del server.

## Notifiche

- **Email reminder**: inviata il giorno prima dell'appuntamento (se l'utente ha `email_notifications?` abilitato)
- **In-app**: badge con conteggio notifiche non lette nella navbar
- **Mark as read**: `PATCH /in_app_notifications/:id/mark_as_read`

## Deploy

Il progetto include configurazione per deploy via **Kamal** (`config/deploy.yml`) e immagine **Docker** (`Dockerfile`).

```bash
# Prima deploy
kamal setup

# Deploy successivi
kamal deploy
```

### Health check
`GET /up` — restituisce 200 se l'app è avviata correttamente (usabile da load balancer / uptime monitor).

