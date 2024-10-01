# Utiliser Python 3.9 basé sur Debian (ou Slim pour une image plus légère)
FROM --platform=linux/amd64 python:3.9-slim-buster as build

# Mettre à jour les paquets et installer les dépendances nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libffi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail
WORKDIR /app

# Copier votre fichier requirements.txt dans l'image
COPY requirements.txt /app/requirements.txt

# Créer un lien symbolique pour que 'python' pointe vers 'python3.9'
RUN ln -s /usr/local/bin/python3.9 /usr/bin/python

# Installer les dépendances Python à partir du requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de votre application dans le conteneur
COPY . /app

# Installer pytest
RUN pip install pytest

# Démarrer l'application
CMD ["python", "app.py"]







