# Fakebook - Outil de Demonstration de Phishing

> Avertissement legal : Cet outil a ete cree exclusivement dans un cadre pedagogique et educatif dans le domaine de la cybersecurite. L'utilisation de cet outil contre des cibles sans leur consentement prealable et explicite est illégale. L'auteur decline toute responsabilite quant a l'usage qui pourrait en etre fait.

## A propos du projet

Fakebook est une application legere concue pour demontrer le fonctionnement technique d'une attaque de phishing basee sur l'usurpation d'une interface d'authentification. L'objectif principal est d'illustrer les vecteurs de menace pour mieux sensibiliser aux bonnes pratiques de securite informatique.

## Fonctionnalites

* **Interface visuelle simulee :** Reproduction de la page de connexion pour analyser l'impact visuel sur un utilisateur.
* **Automatisation du deploiement :** Le script Bash integre la mise en place d'un serveur web local via PHP et l'exposition via un tunnel securise Cloudflare.
* **Capture et journalisation :** Recuperation des donnees saisies via les methodes HTTP POST et stockage immediat dans un fichier journal local.
* **Redirection de dissimulation :** Redirection automatique de la victime vers la plateforme legitime afin de retarder la prise de conscience de l'attaque.

## Structure du projet

```text
fakebook/
├── facebook-logo.png    # Element graphique de l'interface
├── fakebook.sh          # Script d'automatisation (PHP et Cloudflare)
├── index.html           # Formulaire de capture d'identifiants
├── login.php            # Traitement backend et stockage des donnees
├── logins.txt           # Fichiers de stockage des logs d'authentification
└── style.css            # Feuille de style de l'interface
```

## Prerequis techniques

Pour executer cet outil de demonstration, les elements suivants sont necessaires :
* Un environnement compatible Bash (Linux, WSL sous Windows, ou macOS).
* PHP installe sur la machine.
* L'utilitaire CLI Cloudflare (`cloudflared`) pour la generation du tunnel reseau.

Installation des dependances sur un systeme Debian / Ubuntu :
```bash
sudo apt update
sudo apt install php cloudflared
```

## Guide d'utilisation

1. Cloner le depot distant ou acceder au repertoire local :
   ```bash
   git clone https://github.com/Fanantenana-RAKOTO/fakebook.git
   cd fakebook
   ```
2. Attribuer les droits d'execution au script de lancement :
   ```bash
   chmod +x fakebook.sh
   ```
3. Executer le script :
   ```bash
   ./fakebook.sh
   ```
4. Recuperer l'URL publique generee par le tunnel pour effectuer la demonstration.

## Mesures de prevention et de defense
* **Verification des URL :** S'assurer systematiquement de la conformite des noms de domaine dans la barre d'adresse.
* **Authentification multifacteur (MFA) :** Generaliser l'utilisation de cles de securite ou de methodes d'authentification fortes resistantes au phishing.