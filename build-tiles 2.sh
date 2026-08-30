#!/bin/bash
set -e
PLANETILER_VERSION="0.10.1"
PLANETILER_SHA256_EXPECTED="5e5e7d8c4fc89b4573cc9109d0a543c3c2c798b2bcde7c3dcd2214031ee59c29"
JAR="planetiler-${PLANETILER_VERSION}.jar"
curl -sL -o "$JAR" "https://github.com/onthegomap/planetiler/releases/download/v${PLANETILER_VERSION}/planetiler.jar"
JAR_SHA=$(sha256sum "$JAR" | cut -d' ' -f1)
if [ "$JAR_SHA" != "$PLANETILER_SHA256_EXPECTED" ]; then
  echo "[REPROVADO] Checksum nao confere."; exit 1
fi
echo ">> Planetiler verificado. Gerando mapa..."
mkdir -p public/tiles
OSM_RETRIEVED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
INICIO=$(date +%s)
java -Xmx4g -jar "$JAR" --area=nordeste --download --bounds=-41.6,-9.6,-34.7,-7.2 --output=public/tiles/barros-map-pe.pmtiles
FIM=$(date +%s)
TAM=$(stat -c%s public/tiles/barros-map-pe.pmtiles)
SHA=$(sha256sum public/tiles/barros-map-pe.pmtiles | cut -d' ' -f1)
cat > public/tiles/barros-map-pe.version.json << FIMJSON
{
  "mapVersion": "pe-$(date -u +%Y%m%d)",
  "appVersion": "prova1-1.2.1",
  "region": "Nordeste (recorte Pernambuco)",
  "buildDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "osmExtractDate": null,
  "osmSourceRetrievedAt": "${OSM_RETRIEVED_AT}",
  "planetilerVersion": "${PLANETILER_VERSION}",
  "planetilerSha256": "${JAR_SHA}",
  "buildSeconds": $((FIM-INICIO)),
  "pmtilesSize": ${TAM},
  "pmtilesSha256": "${SHA}"
}
FIMJSON
cp mapa-corrida-1-7-2.html public/index.html
echo ">> Mapa gerado: $((TAM/1048576)) MB"
