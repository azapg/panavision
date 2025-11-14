#import "@preview/poster-syndrome:0.1.0": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/subpar:0.2.2"
#set text(lang: "es")
#set math.equation(numbering: "(1)")


#let (container, frames) = figma-layout(json("layout_modern.json"))
#let (poster, frame) = poster-syndrome-setup(container: container, frames: frames)


#show: poster.with(
  // cover-image: image("../assets/map.png"),
  cover-image: [#figure(
    image("image-1.png"),
    caption: [Representación RGB del espacio latente de la ciudad de Panamá y sus alrededores.],
  ) <fig:cover>],
  title: align(center + horizon, text([EL ESPACIO LATENTE PANAMEÑO], tracking: -4pt, size: 92pt)),
  subtitle: [
    #align(center + horizon, text(
      size: 42pt,
      fill: green.darken(15%),
      tracking: 10pt,
    )[EMBEDDINGS SATELITALES $dot$ GEOESPACIO $dot$ EE])
  ],
)



#frame(tag: "details")[
  #align(horizon, box(
    stroke: (left: (4pt + green.darken(15%))),
    inset: (left: 15pt, y: 12pt),
    grid(
      columns: (2fr, 5fr),
      [
        #set text(size: 26pt)
        #v(-7pt)
        #grid(
          columns: 2,
          column-gutter: 25pt,
          [
            #grid(
              row-gutter: 18pt,
              [Allan Zapata$#none^*$],
              [Eliezer Quijada$#none^*$],
              [Rodrigo Donadío$#none^*$],
              [Yelitza Downer$#none^*$],
            )
          ],
          [
            #v(-6pt)
            #qr-code("https://panavision.alam.systems", width: 4.75cm)
          ],
        )

        #set text(size: 18pt)
        #v(-8pt)
        _$#none^*$Universidad de Panamá $dot$ FIEC $dot$ Ciencia de \ Datos $dot$ Grupo Panavisión_
      ],
      [
        #v(-10pt)
        #set text(size: 25pt)
        Recientemente, DeepMind en colaboración con la organización AlphaEarth Foundations, lanzó un dataset de embeddings satelitales que representan la superficie terrestre en un espacio vectorial de 64 dimensiones. Estos embeddings integran múltiples fuentes de datos, incluyendo reflectancia espectral, retrodispersión de radar, clima y topografía, proporcionando una representación lista para análisis del planeta. En este póster, exploramos el uso de estos embeddings para analizar el espacio latente de Panamá, mediante técnicas como búsqueda por similitud y clustering.
      ],
    ),
  ))

]

#frame(tag: "bg")[
  #box(fill: red.lighten(85%), width: 40in / 2, height: 30in)
]

#frame(tag: "introduction")[
  #columns(2)[
    = Introducción
    Los _satellite embeddings_ de DeepMind y AlphaEarth representan cada píxel terrestre como un vector unitario de 64 dimensiones ($bold(x) in bb(R)^64$), obtenido mediante un encoder CNN-Transformer entrenado sobre series temporales multifuente: Sentinel-2 (óptico), Sentinel-1 (radar), SRTM (topografía) y variables climáticas @brown2025alphaearthfoundationsembeddingfield. Esta representación densa y sensor-agnóstica captura patrones fenológicos, estructura superficial y firmas espectrales integradas.

    La normalización unitaria ($norm(bold(x))_2 = 1$) convierte el territorio en una geometría navegable donde la similitud entre superficies se mide mediante el producto punto:
    $ s(bold(a), bold(b)) = bold(a)^top bold(b) = cos theta $
    Zonas físicamente parecidas convergen hacia vecindades del espacio latente, mientras que áreas diferentes ocupan regiones separadas.

    En este estudio exploramos tres líneas sobre el territorio panameño: (1) visualización cromática del espacio latente, como la imagen presentada en la @fig:cover, (2) búsqueda por similitud geométrica tomando como referencia sitios estratégicos (mina Cobre Panamá, vertedero Cerro Patacón, perfiles de agua del Canal), y (3) clustering no supervisado para identificar clases latentes de superficie.

    = Metodología
    Para el análisis del espacio latente, primero debemos adquirir los datos
    #text(size: 18pt)[
      $ I_(2024) = "mosaic"({e in E: t(e) in [2024-01-01, 2025-01-01)}) $
    ]
    donde $E$ es la colección `GOOGLE/SATELLITE_EMBEDDING/V1/ANNUAL` y $t(e)$ la fecha. Cada píxel $p in Omega_("PA")$ tiene embedding $bold(x)_p in bb(R)^64$ con $norm(bold(x)_p)_2 = 1$.

    === Visualización RGB.
    Proyección lineal sobre bandas ${A_1, A_16, A_9}$ con normalización de percentiles:
    $ "RGB"(p) = "normalize"_{[0,255]}([I_(2024)(p)]_(A_1, A_16, A_9)) $

    === Similitud coseno.
    Para semilla $bold(v)$ (ej. punto minero muestreado a escala 20m), el mapa de similitud es:
    $ S(p; bold(v)) = (bold(x)_p^top bold(v))/(norm(bold(x)_p)_2 norm(bold(v))_2) = bold(x)_p^top bold(v) $
    dado que ambos vectores son unitarios. Para un conjunto de puntos ${p_1, dots, p_m}$ (ej. muestras de agua), la semilla es el centroide:
    $ bold(v)_("mean") = (sum_(i=1)^m bold(x)_(p_i))/m, quad S(p) = bold(x)_p^top bold(v)_("mean") $

    === Clustering k-means.
    Muestreo estratificado de $N=5000$ píxeles a escala 50m:
    $ D = {bold(x)_(p_i)}_(i=1)^N $
    Optimización k-means ($k=8$):
    $ min_(C_1, dots, C_k, bold(mu)_1, dots, bold(mu)_k) sum_(j=1)^k sum_(bold(x) in C_j) norm(bold(x) - bold(mu)_j)^2 $
    con asignación de etiqueta por cluster más cercano:
    $ ell(p) = op("argmin", limits: #true)_(j in {1, dots, k}) norm(bold(x)_p - bold(mu)_j)_2 $
  ]
]

#frame(tag: "description")[

  = Resultados

  El clustering no supervisado del territorio panameño mediante k-means en el espacio de embeddings de 64 dimensiones ($k=8$) revela una estructura latente coherente con gradientes ecológicos, zonas urbanas, provincias y patrones de uso del suelo. La @fig-clusters muestra la distribución espacial de clusters obtenida tras entrenar sobre 5,000 píxeles muestreados a escala de 50m. Cada color representa una clase latente distinta, correspondiente a firmas espectrales, fenológicas y topográficas integradas.

  #figure(
    image("../assets/8clusters.png", width: 15cm),
    caption: [_Clustering k-means ($k=8$) del espacio latente panameño basado en embeddings_],
  ) <fig-clusters>

  Los clústeres presentan una coherencia geográfica notable. El clúster azul oscuro, dominante en las zonas costeras (especialmente el Caribe), parece capturar la selva húmeda de baja altitud, mientras que las tierras altas occidentales (Cordillera Central) se definen claramente por los tonos verdes.

  En contraste, la vertiente del Pacífico y el "Arco Seco" (tonos rojo, naranja y amarillo) exhiben mayor fragmentación, asociados a zonas de sabana, agricultura o el corredor urbano metropolitano. Esto confirma que la firma urbana es separable sin necesidad de índices especializados. Aunque regiones de alta intervención antrópica (como Cobre Panamá o Cerro Patacón) no forman clústeres exclusivos, sus vecindades locales consistentes sugieren firmas latentes distintivas, permitiendo una búsqueda por similitud dirigida.

  == Búsqueda por similitud geométrica

  La métrica de similitud coseno permite identificar regiones del territorio con firmas latentes análogas a referencias estratégicas. Se definieron tres casos de estudio: (1) mina Cobre Panamá como superficie minera a cielo abierto, (2) Cerro Patacón como vertedero urbano consolidado, y (3) perfiles de agua del Canal de Panamá diferenciados por turbidez y uso.
]

#frame(tag: "methods")[
  #columns(1, gutter: 24pt)[

    #subpar.grid(
      columns: 2,
      figure(
        image("../assets/similarity-mina.png"),
        caption: [Similitud respecto a mina Cobre Panamá.],
      ),
      <fig:similarity-mina>,

      figure(
        image("../assets/similarity-patacon.png"),
        caption: [Similitud respecto a vertedero Cerro Patacón.],
      ),
      <fig:similarity-patacon>,

      caption: [Mapas de similitud coseno para mina Cobre Panamá y vertedero Cerro Patacón. \ Menor similitud #box(height: 10pt, width: 100pt, baseline: -20%, fill: gradient.linear(..color.map.viridis)) Mayor similitud],
      label: <fig:similarity-land>,
    )

    La @fig:similarity-land revela patrones espaciales reveladores. El mapa de similitud minera (@fig:similarity-mina) identifica principalmente zonas urbanas consolidadas (Ciudad de Panamá, Santiago, Colón, David), la infraestructura portuaria de Punta Rincón (operada por la mina), y las esclusas del Canal. Notablemente, las aguas del lago Gatún muestran baja similitud con la mina, lo que confirma que el embedding captura firmas de construcción industrial y suelo antropizado más que agua. La similitud con Cerro Patacón (@fig:similarity-patacon) muestra alta uniformidad a lo largo del territorio nacional, sugiriendo que el embedding no discrimina características distintivas del vertedero y lo reconoce como una superficie plana genérica, capturando principalmente topografía sin mezcla espectral especializada.

    Para el análisis de cuerpos de agua, se contrastaron dos estrategias: (1) similitud con un punto individual del lago Gatún, y (2) similitud con el centroide (vector promedio) de muestras clasificadas por calidad. El lago Gatún actúa como firma de referencia de agua limpia y profunda. El centroide de muestras del canal (`canal=true`) integra variabilidad de turbidez y vegetación acuática, mientras que el centroide de aguas no canalizadas (`canal=false`) captura ríos costeros y cuerpos menores con mayor carga sedimentaria.

    #subpar.grid(
      caption: [Mapas de similitud coseno para perfiles de agua del Canal de Panamá. \ Menor similitud #box(height: 10pt, width: 100pt, baseline: -20%, fill: gradient.linear(..color.map.viridis)) Mayor similitud],
      label: <fig:similarity-water>,
      columns: 3,
      figure(
        image("../assets/similarity_gatun.png"),
        caption: [Gatún],
      ),
      <fig:similarity-gatun>,
      figure(
        image("../assets/similarity_canal_mean.png"),
        caption: [Promedio canal],
      ),

      <fig:similarity-canal>,
      figure(
        image("../assets/similarity_non_canal_mean.png"),
        caption: [Promedio no-canal],
      ),
      <fig:similarity-non-canal>,
    )

    La @fig:similarity-water muestra que la gran mayoría del territorio terrestre es muy diferente a todos los perfiles de agua, independientemente del origen (canal o no-canal). Los tres mapas evidencian alta similitud exclusivamente sobre cuerpos de agua, confirmando que todos los embeddings acuáticos son latentemente parecidos.

  ]
]

#frame(tag: "illustration")[
  #set align(horizon)
  #box(
    fill: red.lighten(90%),
    width: 100%,
    height: 100%,
    radius: 20pt,
    inset: 15pt,
  )[
    #subpar.grid(
      columns: 4,
      label: <fig:illustrations>,
      caption: [Evolución de la mina Cobre Panamá (2017-2024) en imágenes RGB generadas a partir de embeddings satelitales.],
      figure(
        image("../assets/mina2017.png", width: 8cm),
        caption: [Mina 2017],
      ),
      <fig:illustration-a>,
      figure(
        image("../assets/mina2020.png", width: 8cm),
        caption: [Mina 2020],
      ),
      <fig:illustration-b>,

      figure(
        image("../assets/mina2022.png", width: 8cm),
        caption: [Mina 2022],
      ),
      <fig:illustration-c>,
      figure(
        image("../assets/mina2024.png", width: 8cm),
        caption: [Mina 2024],
      ),
      <fig:illustration-e>,
    )
  ]
]

#frame(tag: "outlook")[
  #set par(justify: true)

  #columns(2)[
    = Conclusión
    Los embeddings satelitales de AlphaEarth constituyen una representación geométrica robusta del territorio panameño, revelando gradientes ecológicos, transiciones urbano-rurales y firmas espectrales integradas sin requerir índices especializados ni supervisión manual.

    La búsqueda por similitud coseno demuestra que el espacio latente distingue eficazmente superficies antrópicas (minería, urbanización) de ecosistemas naturales (agua, vegetación). No obstante, presenta limitaciones para discriminar subtipos dentro de categorías genéricas (vertederos vs. suelo desnudo). Los perfiles acuáticos, independientemente de su origen (canal vs. no-canal), convergen hacia una región común del espacio latente, indicando que la firma espectral del agua predomina sobre variaciones secundarias de turbidez o vegetación acuática.

    Adicionalmente, estos embeddings permiten analizar cambios temporales en superficies específicas. Si bien este trabajo no profundizó en análisis de series temporales, la imágenes de la @fig:illustrations ilustran la evolución de la mina Cobre Panamá entre 2017 y 2024, demostrando el potencial de los embeddings para monitorear transformaciones antrópicas a lo largo del tiempo.
    #colbreak()
    #bibliography("sources.bib", full: true, title: "Referencias")
  ]
]

// #show: _page-foreground(frames: frames)