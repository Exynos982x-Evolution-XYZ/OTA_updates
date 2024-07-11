#!/bin/bash

# Définir le dossier contenant les fichiers JSON
BUILD_DIR="builds"

# Vérifier si le dossier existe
if [ ! -d "$BUILD_DIR" ]; then
  echo "Le dossier $BUILD_DIR n'existe pas."
  exit 1
fi

# Parcourir chaque fichier JSON dans le dossier
for json_file in "$BUILD_DIR"/*.json; do
  # Vérifier si des fichiers JSON existent dans le dossier
  if [ ! -e "$json_file" ]; then
    echo "Aucun fichier JSON trouvé dans $BUILD_DIR."
    exit 1
  fi

  # Lire l'URL du fichier ZIP à partir du fichier JSON
  zip_url=$(jq -r '.response[0].download' "$json_file")

  # Vérifier si l'URL est valide
  if [ -z "$zip_url" ]; then
    echo "L'URL du fichier ZIP est manquante dans $json_file."
    continue
  fi

  # Télécharger le fichier ZIP
  zip_file="${json_file%.json}.zip"
  curl -L -o "$zip_file" "$zip_url"

  # Vérifier si le téléchargement a réussi
  if [ ! -f "$zip_file" ]; then
    echo "Le téléchargement de $zip_url a échoué."
    continue
  fi

  # Extraire le fichier boot.img
  unzip -j "$zip_file" "boot.img" -d ./

  # Vérifier si l'extraction a réussi
  if [ ! -f "$BUILD_DIR/boot.img" ]; then
    echo "L'extraction de boot.img a échoué pour $zip_file."
    rm -f "$zip_file"
    continue
  fi

  # Renommer le fichier boot.img
  mv "$BUILD_DIR/boot.img" "${json_file%.json}-boot.img"

  # Supprimer le fichier ZIP téléchargé
  rm -f "$zip_file"

  echo "Traitement terminé pour $json_file."
done

echo "Tous les fichiers ont été traités."
