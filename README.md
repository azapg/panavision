# Panavisión — El Espacio Latente Panameño

**Análisis Territorial mediante Embeddings Satelitales de AlphaEarth**

Proyecto de investigación presentado en CIIECOM 2025. Este repositorio contiene notebooks de análisis en Google Earth Engine, un paper académico completo en formato IEEE, un póster científico, y un sitio web estático para difusión pública.

## Publicaciones

- 📄 **Paper académico**: _El Espacio Latente Panameño: Análisis Territorial mediante Embeddings Satelitales de AlphaEarth_ (IEEE format)
- 🎨 **Póster científico**: Presentación visual del proyecto para CIIECOM 2025
- 🌐 **Sitio web**: [panavision.up.ac.pa](https://panavision.up.ac.pa) - Resumen ejecutivo y acceso a publicaciones

## Resumen

Este trabajo explora el espacio latente del territorio panameño mediante **satellite embeddings** de Google DeepMind/AlphaEarth. Cada píxel se representa como un vector unitario de 64 dimensiones que integra información multisensorial (Sentinel-2, Sentinel-1, SRTM, clima). Implementamos tres aproximaciones analíticas:

1. **Visualización cromática** del espacio latente (proyección RGB)
2. **Búsqueda por similitud coseno** usando referencias estratégicas (mina Cobre Panamá, vertedero Cerro Patacón, perfiles de agua del Canal)
3. **Clustering no supervisado** (k-means, k=8) para identificar clases latentes de superficie

Los resultados revelan que el embedding captura gradientes ecológicos, zonas urbanas y patrones de uso del suelo con alta coherencia espacial, sin necesidad de clasificación supervisada.

# Variables de entorno
```properties
# Regístrate en https://console.cloud.google.com/earth-engine
GEE_PROJECT=PROYECTO_DE_EARTH_ENGINE
# Esto es opcional, por si quieres usar leafmap. https://www.maptiler.com/ 
MAPTILER_KEY=TU_KEY_DE_MAPTILER
```
## Estructura del Repositorio

```
panavision/
├── website/              # Sitio web estático (GitHub Pages)
│   ├── index.html       # Página principal
│   ├── styles.css       # Estilos personalizados
│   ├── poster/          # Póster en PDF alta calidad
│   └── paper/           # Paper académico en PDF
├── docs/                # Fuentes de publicaciones
│   ├── paper.typ        # Paper IEEE (Typst)
│   ├── poster_modern.typ # Póster científico (Typst)
│   ├── sources.bib      # Referencias bibliográficas
│   └── *.png            # Imágenes y figuras
├── assets/              # Datos y recursos
│   ├── geo/             # Archivos GeoJSON (geometrías)
│   └── *.png            # Imágenes exportadas de Earth Engine
├── clustering.ipynb     # Análisis de clustering k-means
├── similarity.ipynb     # Mapas de similitud coseno
├── mina_years.ipynb     # Serie temporal mina Cobre Panamá
├── ee.ipynb            # Experimentos exploratorios
└── utils.py            # Funciones auxiliares Earth Engine
```

## Compilar Publicaciones (Typst)

Requiere [`typst`](https://typst.app/) instalado.

### Compilar paper académico

```bash
typst compile docs/paper.typ website/paper/panavision_paper.pdf
```

### Compilar póster científico

```bash
typst compile docs/poster_modern.typ website/poster/panavision_poster.pdf
```

### Compilar ambos

```bash
typst compile docs/paper.typ website/paper/panavision_paper.pdf && \
typst compile docs/poster_modern.typ website/poster/panavision_poster.pdf
```

## Previsualización local

No se requiere build. Abre directamente `website/index.html` en tu navegador o sirve la carpeta `website/` con un servidor estático si prefieres:

```bash
python -m http.server --directory website 8000
# luego navega a http://localhost:8000
```

## Notebooks de Análisis

### `clustering.ipynb`
Clustering no supervisado del territorio panameño mediante k-means en el espacio de embeddings de 64 dimensiones. Entrena sobre 5,000 píxeles muestreados a 50m y genera mapa de 8 clases latentes.

### `similarity.ipynb`
Mapas de similitud coseno para referencias estratégicas:
- Mina Cobre Panamá (superficie minera a cielo abierto)
- Cerro Patacón (vertedero urbano)
- Perfiles de agua: punto Gatún, promedio Canal, promedio aguas costeras

### `mina_years.ipynb`
Serie temporal 2017-2024 de la región de la mina Cobre Panamá, capturando fases de construcción, operación y cierre.

### `ee.ipynb`
Notebook exploratorio con experimentos iniciales de visualización y procesamiento.

### `utils.py`
Funciones auxiliares para autenticación Earth Engine, carga de geometrías, visualización, clustering, y cálculo de similitud coseno.

## Datos y Referencias

- **Satellite Embeddings**: `GOOGLE/SATELLITE_EMBEDDING/V1/ANNUAL` (Earth Engine)
- **Geometrías**: Polígonos de Panamá, mina Cobre Panamá, muestras de agua (`assets/geo/`)
- **Referencias bibliográficas**: Brown et al. 2025 (AlphaEarth), DeepMind blog, Google Earth Medium

## Resultados Principales

- ✅ Clustering k-means distingue claramente selva húmeda caribeña, tierras altas, arco seco del Pacífico y zonas urbanas
- ✅ Similitud con mina identifica infraestructura industrial, puertos y esclusas del Canal
- ✅ Similitud con agua separa lago Gatún/Canal de aguas costeras (diferencias en turbidez)
- ✅ Serie temporal de la mina muestra transición cobertura boscosa → suelo expuesto (2017-2024)

## Créditos y Autoría

**Grupo Panavisión** — Universidad de Panamá (FIEC, Ciencia de Datos)

- Allan Zapata
- Eliezer Quijada
- Rodrigo Donadío
- Yelitza Downer

Proyecto basado en embeddings satelitales públicos (AlphaEarth/Google DeepMind) y herramientas de `geemap`/Earth Engine.

## Licencia

Los notebooks y código fuente están disponibles bajo licencia MIT. Las figuras y publicaciones están sujetas a derechos de autor de los autores.

