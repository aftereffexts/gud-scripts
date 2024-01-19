#!/bin/bash

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Dieses Skript muss mit Root-Rechten ausgeführt werden."
  exit 1
fi

# MongoDB-Paketquelle hinzufügen
echo "Hinzufügen der MongoDB-Paketquelle"
apt install -y gnupg curl
curl -fsSL https://pgp.mongodb.com/server-4.4.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg \
   --dearmor

# Paketliste aktualisieren
echo "Aktualisieren der Paketliste"
apt update

# MongoDB installieren
echo "Installation von MongoDB"
apt install -y  mongodb-org

# MongoDB-Dienst starten und aktivieren
echo "Starten und Aktivieren des MongoDB-Dienstes"
systemctl start mongod
systemctl enable mongod

# Ausgabe des Installationsstatus
echo "MongoDB wurde erfolgreich installiert."
echo "MongoDB-Status:"
systemctl status mongod
