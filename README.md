# Panavisión — El Espacio Latente Panameño

Proyecto para CIIECOM 2025. Este repositorio contiene notebooks de análisis en Google Earth Engine y un sitio estático en `website/` para publicar el resumen del póster y servir el PDF en alta calidad.

# Variables de entorno
```properties
# Regístrate en https://console.cloud.google.com/earth-engine
GEE_PROJECT=PROYECTO_DE_EARTH_ENGINE
# Esto es opcional, por si quieres usar leafmap. https://www.maptiler.com/ 
MAPTILER_KEY=TU_KEY_DE_MAPTILER
```
## Estructura

- `website/` — sitio web estático listo para GitHub Pages.
	- `index.html`, `styles.css`, `CNAME`
	- `poster/panavision_poster.pdf` (agrega aquí el PDF final del póster)
- `docs/` — fuentes del póster (Typst), imágenes y bibliografía.
- Notebooks: `clustering.ipynb`, `similarity.ipynb`, `mina_years.ipynb`

## Compilar el póster (Typst)

Requiere `typst` instalado.

```bash
typst compile docs/poster_modern.typ website/poster/panavision_poster.pdf
```

## Previsualización local

No se requiere build. Abre directamente `website/index.html` en tu navegador o sirve la carpeta `website/` con un servidor estático si prefieres:

```bash
python -m http.server --directory website 8000
# luego navega a http://localhost:8000
```

## Créditos

Proyecto del Grupo Panavisión — Universidad de Panamá (FIEC, Ciencia de Datos). Basado en embeddings satelitales públicos (AlphaEarth/Google) y herramientas de `geemap`/Earth Engine.

