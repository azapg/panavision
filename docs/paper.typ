#import "@preview/charged-ieee:0.1.4": ieee

#set math.equation(numbering: "(1)")

#show: ieee.with(
  title: [El Espacio Latente Panameño: Análisis Territorial mediante Embeddings Satelitales de AlphaEarth],
  abstract: [
    Los _satellite embeddings_ de DeepMind AlphaEarth representan una nueva frontera en la observación terrestre, codificando cada píxel del planeta como un vector denso de 64 dimensiones que integra información multisensorial y multitemporal. Este estudio explora el espacio latente del territorio panameño mediante tres aproximaciones analíticas: (1) visualización cromática del espacio de características, (2) búsqueda por similitud geométrica utilizando referencias estratégicas (mina Cobre Panamá, vertedero Cerro Patacón, y perfiles de agua del Canal), y (3) clustering no supervisado para identificar clases latentes de superficie. Los resultados revelan que el embedding captura gradientes ecológicos, zonas urbanas y patrones de uso del suelo con alta coherencia espacial. El clustering k-means ($k=8$) distingue claramente entre selva húmeda caribeña, tierras altas cordilleranas y el arco seco del Pacífico. La búsqueda por similitud identifica firmas de construcción industrial y suelo antropizado, aunque muestra limitaciones para discriminar vertederos consolidados. Los mapas de similitud de agua revelan diferencias espectrales entre el Canal y aguas costeras, correlacionadas con turbidez y uso antropogénico. Este trabajo demuestra el potencial de los embeddings satelitales para análisis territorial integrado, ofreciendo una representación geométrica navegable del territorio que facilita tareas de clasificación, monitoreo ambiental y planificación espacial sin necesidad de etiquetado supervisado.
  ],
  authors: (
    (
      name: "Allan Zapata",
      department: [Facultad de Informática, Electrónica y Comunicación],
      organization: [Universidad de Panamá],
      location: [Panamá],
      email: "allan.zapata@up.ac.pa",
    ),
  ),
  index-terms: (
    "Embeddings satelitales",
    "AlphaEarth",
    "análisis territorial",
    "aprendizaje no supervisado",
    "similitud coseno",
    "clustering geoespacial",
  ),
  figure-supplement: [Fig.],
)

= Introducción

La observación de la Tierra mediante sensores remotos ha experimentado una transformación radical en la última década, transitando desde el procesamiento de índices espectrales especializados hacia representaciones aprendidas de alto nivel. Los _satellite embeddings_ de Google DeepMind, introducidos en el marco del proyecto AlphaEarth @brown2025alphaearthfoundationsembeddingfield, materializan este cambio de paradigma: cada píxel terrestre se codifica como un vector unitario de 64 dimensiones ($bold(x) in bb(R)^64$, $norm(bold(x))_2 = 1$) obtenido mediante un encoder CNN-Transformer entrenado sobre series temporales multifuente. Esta arquitectura integra datos de Sentinel-2 (óptico multiespectral), Sentinel-1 (radar de apertura sintética), SRTM (topografía digital) y variables climáticas globales, capturando patrones fenológicos, estructura superficial y firmas espectrales de forma unificada @AIpowere81:online @AlphaEar70:online.

La normalización unitaria convierte el territorio en una geometría navegable donde la similitud entre superficies se mide mediante el producto punto: $s(bold(a), bold(b)) = bold(a)^top bold(b) = cos theta$. Zonas físicamente parecidas convergen hacia vecindades del espacio latente, mientras que áreas diferentes ocupan regiones separadas. Esta propiedad habilita operaciones geométricas directas: búsqueda por similitud, clustering, interpolación y composición de conceptos geográficos sin necesidad de etiquetado supervisado.

Panamá, con su singularidad geográfica (istmo transoceánico, Canal interoceánico, gradientes climáticos abruptos, heterogeneidad de uso del suelo), constituye un caso de estudio ideal para evaluar la capacidad descriptiva de estos embeddings. Este trabajo explora tres líneas analíticas sobre el territorio panameño:

1. *Visualización cromática del espacio latente*: proyección de las 64 dimensiones a RGB para inspección cualitativa de la estructura del embedding.

2. *Búsqueda por similitud geométrica*: identificación de regiones análogas a referencias estratégicas (mina Cobre Panamá, vertedero Cerro Patacón, perfiles de agua del Canal de Panamá).

3. *Clustering no supervisado*: partición del territorio en clases latentes mediante k-means para revelar gradientes ecológicos y patrones de uso del suelo.

Los resultados demuestran que el embedding captura estructura territorial coherente con conocimiento geográfico previo, ofreciendo una representación compacta y sensor-agnóstica del geoespacio panameño.

= Metodología

== Adquisición de Datos

El conjunto de datos corresponde a la colección `GOOGLE/SATELLITE_EMBEDDING/V1/ANNUAL` disponible en Google Earth Engine, que provee mosaicos anuales de embeddings a escala global con resolución espacial de 10 metros. Para el territorio panameño ($Omega_("PA")$), se extrajo la imagen correspondiente al año 2024, representada por la ecuación @eq:data-acquisition. El procesamiento se realizó mediante la API de Python de Earth Engine, con autenticación OAuth y proyecto configurado.

== Visualización RGB del Espacio Latente

Para inspeccionar visualmente la estructura del embedding, se proyectaron tres bandas específicas del vector de 64 dimensiones a los canales RGB. Las bandas seleccionadas fueron ${A_1, A_16, A_9}$, elegidas empíricamente por maximizar el contraste visual entre clases de cobertura conocidas (selva, agua, urbano). La transformación aplicada fue:

$ "RGB"(p) = "normalize"_(p_0.02, p_0.98) ([I_(2024)(p)]_(A_1, A_16, A_9)) $

donde la normalización emplea percentiles 2% y 98% para recorte de valores extremos antes del escalado a $[0, 255]$. Esta representación cromática permite identificar regiones con firmas latentes similares sin recurrir a clasificación supervisada @brown2025alphaearthfoundationsembeddingfield.

== Búsqueda por Similitud Coseno

La métrica de similitud coseno cuantifica la alineación direccional entre embeddings, ideal para vectores unitarios. Para una semilla $bold(v)$ (ej. punto minero muestreado a escala 20m), el mapa de similitud es:

$ S(p; bold(v)) = (bold(x)_p^top bold(v))/(norm(bold(x)_p)_2 norm(bold(v))_2) = bold(x)_p^top bold(v) $

dado que ambos vectores son unitarios. Para un conjunto de puntos ${p_1, dots, p_m}$ (ej. muestras de agua del Canal), la semilla es el centroide normalizado:

$ bold(v)_("mean") = (sum_(i=1)^m bold(x)_(p_i))/m, quad S(p) = bold(x)_p^top bold(v)_("mean") $

Se definieron tres casos de estudio:

1. *Mina Cobre Panamá*: coordenadas (8.85197°N, 80.64478°W), muestreada a 20m.
2. *Cerro Patacón*: coordenadas (9.05305°N, 79.56512°W), vertedero urbano consolidado.
3. *Perfiles de agua*:
  - Punto Gatún: muestra individual del lago Gatún.
  - Canal (mean): promedio de 15 puntos de agua del Canal ($"canal" = "true"$).
  - No canal (mean): promedio de 8 puntos de aguas costeras ($"canal" = "false"$).

Los mapas de similitud se visualizaron usando la paleta Viridis con rango $[0, 1]$.

== Clustering No Supervisado

Para revelar clases latentes de superficie sin etiquetado previo, se aplicó clustering k-means en el espacio de embeddings de 64 dimensiones. El procedimiento fue:

1. *Muestreo estratificado*: extracción de $N=5000$ píxeles a escala 50m sobre $Omega_("PA")$ con semilla fija ($"seed"=42$):

$ D = {bold(x)_(p_i)}_(i=1)^N $

2. *Optimización k-means*: con $k=8$ clusters, se minimiza la varianza intra-cluster:

$ min_(C_1, dots, C_k, bold(mu)_1, dots, bold(mu)_k) sum_(j=1)^k sum_(bold(x) in C_j) norm(bold(x) - bold(mu)_j)_2^2 $

donde $C_j$ son particiones de $D$ y $bold(mu)_j$ centroides.

3. *Asignación de etiquetas*: cada píxel $p in Omega_("PA")$ se clasifica según el centroide más cercano:

$ ell(p) = op("argmin", limits: #true)_(j in {1, dots, k}) norm(bold(x)_p - bold(mu)_j)_2 $

El resultado es una imagen categórica $ell : Omega_("PA") -> {0, dots, 7}$ que segmenta el territorio en 8 clases latentes. Se visualizó usando una paleta de 8 colores distintivos.

== Análisis Temporal: Serie de la Mina Cobre Panamá

Para evaluar la capacidad del embedding de capturar cambios temporales, se extrajo una serie anual (2017-2024) de la región minera ($Omega_("mina")$), recortando cada año al polígono de la concesión minera. Se exportaron thumbnails RGB para inspección visual de la evolución de la firma latente durante el período de operación y cierre de la mina.

= Resultados

== Visualización del Espacio Latente

La @fig:cover muestra la proyección RGB del espacio latente panameño (bandas A01, A16, A09). La imagen revela estructura territorial nítida sin clasificación supervisada. Las zonas urbanas (Ciudad de Panamá, Colón, David, Santiago) aparecen en tonos morados distintivos, mientras que la cobertura boscosa caribeña se codifica en azules y verdes. Los bosques montanos presenta tonalidades amarillo-naranja, y las aguas del Canal y costas se distinguen claramente en marrón. Esta coherencia cromática confirma que el embedding captura firmas espectrales y fenológicas interpretables.

#figure(
  image("../assets/image-1.png", width: 100%),
  caption: [Representación RGB del espacio latente de Panamá (2024). Proyección de bandas A01, A16, A09 normalizada por percentiles. Se muestra en verde las aguas poco profundas adyacentes a las costas.],
) <fig:cover>

== Clustering No Supervisado

El clustering k-means ($k=8$) del territorio panameño revela una estructura latente coherente con gradientes ecológicos y patrones de uso del suelo (@fig:clusters). Cada color representa una clase latente distinta, correspondiente a firmas espectrales, fenológicas y topográficas integradas.

#figure(
  image("../assets/8clusters.png", width: 100%),
  caption: [Clustering k-means ($k=8$) del espacio latente panameño. Cada color representa una clase latente de superficie. Nótese la separación clara entre selva húmeda caribeña (azul oscuro), tierras altas (verde) y zonas urbanas (rojo-amarillo).],
) <fig:clusters>

Los resultados muestran coherencia geográfica notable:

- *Cluster azul oscuro*: domina las zonas costeras caribeñas y la cuenca del Canal, correspondiente a selva húmeda tropical de baja altitud con alta precipitación anual.

- *Clusters verdes*: concentrados en las tierras altas occidentales (Cordillera Central), capturando bosque nuboso y zonas de montaña con diferentes grados de intervención.

- *Clusters rojo-amarillo-naranja*: fragmentados en la vertiente del Pacífico, asociados al arco seco (sabanas, agricultura extensiva, ganadería) y el corredor urbano metropolitano (Ciudad de Panamá-Arraiján-La Chorrera).

- *Cluster urbano*: distinguible en las principales ciudades (Panamá, Colón, David, Santiago), confirmando que la firma urbana es separable sin índices especializados.

La mina Cobre Panamá y Cerro Patacón no forman clusters exclusivos, sugiriendo que sus firmas latentes comparten características con otras superficies antropizadas. Sin embargo, sus vecindades locales muestran consistencia interna, habilitando búsqueda por similitud dirigida.

== Búsqueda por Similitud: Superficies Terrestres

La @fig:similarity-land presenta los mapas de similitud para la mina Cobre Panamá y Cerro Patacón. Los resultados revelan patrones espaciales diferenciados:

#figure(
  scope: "parent",
  placement: bottom,
  grid(
    columns: 2,
    gutter: 10pt,
    image("../assets/similarity-mina.png"), image("../assets/similarity-patacon.png"),
  ),
  caption: [Mapas de similitud coseno (2024). Izquierda: similitud con mina Cobre Panamá. Derecha: similitud con vertedero Cerro Patacón. Paleta Viridis de 0 (baja similitud, morado) a 1 (alta similitud, blanco).],
) <fig:similarity-land>

*Similitud con Mina Cobre Panamá* (@fig:similarity-land, izquierda): El mapa identifica principalmente:
- Zonas urbanas consolidadas (Ciudad de Panamá, Colón, David, Santiago)
- Infraestructura portuaria de Punta Rincón (operada por Minera Panamá)
- Esclusas y estructuras del Canal de Panamá
- Carreteras y superficies pavimentadas de alta reflectancia

Notablemente, las aguas del lago Gatún muestran baja similitud con la mina, confirmando que el embedding discrimina entre agua y suelo antropizado. Las áreas de alta similitud corresponden a construcción industrial, concreto expuesto y roca desnuda, coherente con la firma espectral de la operación minera a cielo abierto.

*Similitud con Cerro Patacón* (@fig:similarity-land, derecha): El mapa muestra alta uniformidad a lo largo del territorio, con valores concentrados en el rango medio-alto ($0.6-0.8$) sin concentraciones espaciales claras. Esto sugiere que el embedding no captura características distintivas del vertedero y lo reconoce como una superficie plana genérica, posiblemente clasificada como suelo desnudo o área urbana degradada. La ausencia de firmas especializadas para vertederos indica una limitación del embedding para discriminar esta clase sin entrenamiento supervisado adicional.

== Búsqueda por Similitud: Perfiles de Agua

La @fig:similarity-water presenta los mapas de similitud para tres perfiles de agua: punto Gatún (lago Gatún), promedio de aguas del Canal, y promedio de aguas costeras no canalizadas.

#figure(
  scope: "parent",
  placement: auto,
  grid(
    columns: 3,
    gutter: 8pt,
    image("../assets/similarity_gatun.png"),
    image("../assets/similarity_canal_mean.png"),
    image("../assets/similarity_non_canal_mean.png"),
  ),
  caption: [Mapas de similitud coseno para perfiles de agua (2024). Izquierda: punto Gatún. Centro: promedio de aguas del Canal. Derecha: promedio de aguas costeras. Paleta Viridis.],
) <fig:similarity-water>

*Punto Gatún* (@fig:similarity-water, izquierda): Identifica con alta precisión el lago Gatún y cuerpos de agua dulce interiores (lagos Alajuela, Bayano), mostrando baja similitud con aguas costeras. Esto confirma que el embedding captura diferencias en turbidez, contenido de sedimentos y firma espectral del agua dulce lacustre.

*Promedio Canal* (@fig:similarity-water, centro): Resalta el sistema lacustre del Canal (Gatún, Alajuela) y algunos embalses menores, con similitud moderada en ríos principales. Las aguas costeras muestran baja similitud, sugiriendo que la firma del Canal se asocia principalmente a agua dulce represada con baja turbidez.

*Promedio No Canal* (@fig:similarity-water, derecha): Identifica aguas costeras del Pacífico y Caribe, con alta similitud en estuarios, manglares y zonas de mezcla salina. También resalta ríos turbulentos con alta carga de sedimentos. La baja similitud con el sistema del Canal confirma la separación espectral entre agua dulce lacustre y agua costera/salobre.

Estos resultados demuestran que el embedding captura firmas de agua diferenciadas por propiedades físico-químicas (turbidez, salinidad, contenido de clorofila), sin necesidad de índices especializados como NDWI o turbidez derivada de Secchi.

== Serie Temporal: Mina Cobre Panamá (2017-2024)

La @fig:mina-series presenta la evolución del espacio latente de la mina Cobre Panamá durante el período 2017-2024, capturando las fases de construcción, operación y cierre.

#figure(
  scope: "parent",
  placement: auto,
  grid(
    columns: 4,
    rows: 2,
    gutter: 8pt,
    image("../assets/mina2017.png"),
    image("../assets/mina2020.png"),
    image("../assets/mina2022.png"),
    image("../assets/mina2024.png"),
  ),
  caption: [Evolución del espacio latente de la mina Cobre Panamá (2017, 2020, 2022, 2024). Proyección RGB de bandas A01, A16, A09. Nótese la transición de cobertura boscosa (verde-azul) a suelo expuesto (rosa-gris) durante la fase de construcción, y la estabilización de la firma latente durante la operación.],
) <fig:mina-series>

La serie revela tres fases claramente diferenciadas:

1. *2017-2019*: Transición de cobertura boscosa (verde-azul) a suelo expuesto (rosa-gris). La firma latente muestra alta variabilidad temporal, asociada a deforestación, movimiento de tierras y construcción de infraestructura.

2. *2020-2023*: Estabilización de la firma latente en tonos rosa-gris uniformes, correspondiente a operación minera a cielo abierto consolidada. La pit principal, pilas de lixiviación y planta de procesamiento son distinguibles por diferencias sutiles de textura.

3. *2024*: Tras el cierre de operaciones (noviembre 2023), la firma latente muestra cambios incipientes en zonas de rehabilitación, aunque la señal dominante permanece como suelo industrial expuesto.

Esta serie demuestra la capacidad del embedding de capturar cambios temporales en uso del suelo sin etiquetado supervisado, habilitando monitoreo de proyectos de infraestructura de gran escala.

= Discusión

== Capacidad Descriptiva del Embedding

Los resultados confirman que el embedding satelital de AlphaEarth captura estructura territorial coherente con conocimiento geográfico previo. El clustering no supervisado reproduce gradientes ecológicos conocidos (selva húmeda caribeña vs. arco seco del Pacífico), distingue zonas urbanas de forma automática, y segmenta tierras altas sin información topográfica explícita. Esto sugiere que el encoder CNN-Transformer ha aprendido representaciones latentes que integran información espectral, fenológica y topográfica de forma efectiva.

La búsqueda por similitud coseno demuestra utilidad práctica para identificar superficies análogas a referencias estratégicas. El caso de la mina Cobre Panamá muestra que el embedding captura firmas de construcción industrial, concreto y roca expuesta, permitiendo localizar infraestructura similar (puertos, esclusas, zonas urbanas densas). Sin embargo, el caso de Cerro Patacón revela una limitación: los vertederos consolidados no tienen firma distintiva en el espacio latente, probablemente porque su señal espectral es genérica (suelo desnudo, vegetación dispersa) y no se diferencia de áreas degradadas o superficies planas sin cobertura.

== Perfiles de Agua y Capacidad Discriminativa

Los mapas de similitud de agua revelan que el embedding captura diferencias espectrales entre agua dulce lacustre (Gatún, Alajuela) y agua costera/salobre. Esta separación es relevante para monitoreo de calidad del agua, ya que la turbidez y el contenido de sedimentos son indicadores de eutrofización y contaminación. La alta similitud entre el punto Gatún y el promedio del Canal confirma homogeneidad espectral del sistema lacustre, mientras que la baja similitud con aguas costeras sugiere que el embedding codifica propiedades físico-químicas diferenciales.

No obstante, la interpretación de estas firmas requiere validación con datos in situ (turbidez, clorofila, materia orgánica disuelta), ya que el embedding es una representación aprendida sin garantía de correspondencia directa con parámetros físicos medibles.

== Limitaciones y Trabajo Futuro

Este estudio presenta tres limitaciones principales:

1. *Ausencia de validación cuantitativa*: Los resultados son cualitativos y se basan en inspección visual y conocimiento geográfico previo. Validación con datos de cobertura del suelo etiquetados (ej. ESA WorldCover, mapas nacionales de uso del suelo) permitiría cuantificar precisión de clasificación y coherencia temática.

2. *Resolución temporal gruesa*: Los mosaicos anuales ocultan variabilidad estacional y eventos episódicos (incendios, inundaciones, agricultura de ciclo corto). Acceso a embeddings mensuales o trimestrales mejoraría capacidad de monitoreo.

3. *Interpretabilidad limitada*: Las 64 dimensiones del embedding son representaciones latentes sin semántica explícita. Técnicas de explicabilidad (ej. análisis de componentes principales, visualización t-SNE/UMAP) podrían revelar qué dimensiones codifican vegetación, agua, urbanización, etc.

Trabajo futuro incluye: (a) validación cuantitativa con datasets de referencia, (b) exploración de embeddings temporales para monitoreo dinámico, (c) integración con clasificadores supervisados para tareas específicas (deforestación, expansión urbana, degradación), y (d) análisis de interpretabilidad para entender qué información codifica cada dimensión del embedding.

= Conclusiones

Este estudio demuestra que los _satellite embeddings_ de AlphaEarth proveen una representación geométrica navegable del territorio panameño que captura gradientes ecológicos, zonas urbanas y patrones de uso del suelo sin necesidad de etiquetado supervisado. Las tres aproximaciones analíticas exploradas (visualización cromática, búsqueda por similitud, clustering) revelan estructura territorial coherente con conocimiento geográfico previo.

El clustering k-means ($k=8$) distingue claramente entre selva húmeda caribeña, tierras altas cordilleranas y arco seco del Pacífico, reproduciendo divisiones biogeográficas conocidas. La búsqueda por similitud identifica firmas de construcción industrial y suelo antropizado (caso mina Cobre Panamá), aunque muestra limitaciones para discriminar vertederos consolidados (caso Cerro Patacón). Los mapas de similitud de agua revelan diferencias espectrales entre el Canal y aguas costeras, correlacionadas con turbidez y uso antropogénico.

La serie temporal de la mina Cobre Panamá (2017-2024) demuestra que el embedding captura cambios de uso del suelo asociados a deforestación, construcción y operación minera, habilitando monitoreo de proyectos de infraestructura sin etiquetado manual.

En conjunto, este trabajo establece que los embeddings satelitales son una herramienta viable para análisis territorial integrado en contextos de recursos limitados, ofreciendo una alternativa sensor-agnóstica y temporalmente consistente a métodos tradicionales basados en índices espectrales. Su adopción en planificación espacial, monitoreo ambiental y respuesta a desastres podría democratizar capacidades de observación de la Tierra previamente restringidas a instituciones con infraestructura de clasificación supervisada.

#bibliography("sources.bib", full: true, title: "Referencias"),


#let appendix(body) = {
  set page(columns: 1)
  set heading(numbering: "A", supplement: [Apéndice])
  counter(heading).update(0)
  body
}

#show: appendix

= Ecuaciones
A continuación se presentan las ecuaciones clave utilizadas en el análisis del espacio latente panameño mediante embeddings satelitales de AlphaEarth.

Ecuación de adquisición de datos:
$
  I_(2024) \= "mosaic"({e in E : t(e) in [2024-01-01, 2025-01-01) and e inter Omega_("PA") != emptyset})
$ <eq:data-acquisition>
donde $E$ es la colección de embeddings y $t(e)$ la fecha asociada. Cada píxel $p in Omega_("PA")$ tiene un embedding $bold(x)_p in bb(R)^64$ con norma unitaria $norm(bold(x)_p)_2 = 1$.
