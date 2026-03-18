FROM python:3.9-slim

# Installer l'outil "ab" (apache bench) via le paquet apache2-utils
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apache2-utils \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les fichiers nécessaires dans l'image
COPY make-data.py generate-votes.sh ./

# Générer les fichiers posta et postb au build, corriger les fins de ligne Windows
# éventuelles sur le script shell, et le rendre exécutable
RUN python make-data.py \
	&& sed -i 's/\r$//' generate-votes.sh \
	&& chmod +x generate-votes.sh

# Au démarrage du conteneur, envoyer les votes puis s'arrêter
CMD ["./generate-votes.sh"]

