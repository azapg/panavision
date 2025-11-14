"""
Utility functions for Google Earth Engine satellite embedding analysis.
Provides common functionality for authentication, data loading, and visualization.
"""

import os
import json
from typing import Dict, Any, Optional
import ee
import geemap


def authenticate_and_initialize(project: Optional[str] = None) -> None:
    """
    Authenticate and initialize Google Earth Engine.
    
    Args:
        project: GEE project ID. If None, reads from GEE_PROJECT environment variable.
    """
    ee.Authenticate()
    project_id = project or os.getenv('GEE_PROJECT')
    if not project_id:
        raise ValueError("No GEE project specified. Set GEE_PROJECT env var or pass project argument.")
    ee.Initialize(project=project_id)


def load_geojson(filepath: str) -> Dict[str, Any]:
    """
    Load a GeoJSON file from disk.
    
    Args:
        filepath: Path to the GeoJSON file.
        
    Returns:
        Dictionary containing the GeoJSON data.
    """
    with open(filepath, 'r') as f:
        return json.load(f)


def load_panama_geometry(geojson_path: str = './assets/geo/pa.geometry.geojson') -> ee.Geometry:
    """
    Load Panama border geometry from GeoJSON file.
    
    Args:
        geojson_path: Path to the Panama geometry GeoJSON file.
        
    Returns:
        Earth Engine Geometry object.
    """
    pa_geojson = load_geojson(geojson_path)
    return ee.Geometry(pa_geojson)


def get_embeddings_collection(bounds: ee.Geometry) -> ee.ImageCollection:
    """
    Get the Google Satellite Embedding collection filtered by bounds.
    
    Args:
        bounds: Geometry to filter the collection.
        
    Returns:
        Filtered ImageCollection.
    """
    return ee.ImageCollection("GOOGLE/SATELLITE_EMBEDDING/V1/ANNUAL").filterBounds(bounds)


def get_year_embedding(
    year: int,
    embeddings_collection: Optional[ee.ImageCollection] = None,
    bounds: Optional[ee.Geometry] = None
) -> ee.Image:
    """
    Get satellite embedding mosaic for a specific year.
    
    Args:
        year: Year to retrieve embeddings for.
        embeddings_collection: Pre-filtered ImageCollection. If None, must provide bounds.
        bounds: Geometry bounds for filtering. Only used if embeddings_collection is None.
        
    Returns:
        Mosaicked Image for the specified year.
    """
    if embeddings_collection is None:
        if bounds is None:
            raise ValueError("Must provide either embeddings_collection or bounds")
        embeddings_collection = get_embeddings_collection(bounds)
    
    start = ee.Date.fromYMD(year, 1, 1)
    end = start.advance(1, 'year')
    return (embeddings_collection
            .filter(ee.Filter.date(start, end))
            .mosaic())


def export_thumbnail(
    img: ee.Image,
    geometry: ee.Geometry,
    fname: str,
    vis_params: Dict[str, Any],
    dimensions: int = 4096,
    format: str = 'png',
    print_url: bool = True
) -> str:
    """
    Generate and optionally print a thumbnail URL for an Earth Engine image.
    
    Args:
        img: Image to export.
        geometry: Region to clip and export.
        fname: Filename/label for the export (for printing).
        vis_params: Visualization parameters (bands, min, max, palette, etc.).
        dimensions: Output dimensions in pixels.
        format: Output format ('png', 'jpg', etc.).
        print_url: Whether to print the URL to console.
        
    Returns:
        The thumbnail URL string.
    """
    url = img.clip(geometry).getThumbUrl({
        'region': geometry,
        'dimensions': dimensions,
        'format': format,
        **vis_params,
    })
    
    if print_url:
        print(f"{fname}: {url}")
    
    return url


def sample_embeddings(
    image: ee.Image,
    region: ee.Geometry,
    scale: int = 10,
    num_pixels: int = 100,
    seed: Optional[int] = None,
    geometries: bool = True
) -> ee.FeatureCollection:
    """
    Sample embeddings from an image within a region.
    
    Args:
        image: Image to sample from.
        region: Region to sample within.
        scale: Sampling scale in meters.
        num_pixels: Number of pixels to sample.
        seed: Random seed for reproducibility.
        geometries: Whether to include geometries in the output.
        
    Returns:
        FeatureCollection of sampled points.
    """
    kwargs = {
        'region': region,
        'scale': scale,
        'numPixels': num_pixels,
        'geometries': geometries,
    }
    if seed is not None:
        kwargs['seed'] = seed
    
    return image.sample(**kwargs)


def train_kmeans_clusterer(
    training_data: ee.FeatureCollection,
    n_clusters: int = 6
) -> ee.Clusterer:
    """
    Train a K-Means clusterer on training data.
    
    Args:
        training_data: FeatureCollection with training samples.
        n_clusters: Number of clusters.
        
    Returns:
        Trained clusterer.
    """
    return ee.Clusterer.wekaKMeans(n_clusters).train(training_data)


def create_cluster_image(
    image: ee.Image,
    clusterer: ee.Clusterer,
    clip_geometry: Optional[ee.Geometry] = None
) -> ee.Image:
    """
    Apply clustering to an image.
    
    Args:
        image: Image to cluster.
        clusterer: Trained clusterer.
        clip_geometry: Optional geometry to clip the result.
        
    Returns:
        Clustered image.
    """
    clusters = image.cluster(clusterer)
    if clip_geometry is not None:
        clusters = clusters.clip(clip_geometry)
    return clusters


def cosine_similarity(image: ee.Image, vector: ee.Array) -> ee.Image:
    """
    Compute cosine similarity between each pixel in an image and a reference vector.
    
    Args:
        image: Multi-band image to compare.
        vector: Reference vector (as ee.Array).
        
    Returns:
        Single-band image with cosine similarity values.
    """
    # Convert the image to an array image
    image_array = image.toArray()
    
    # Dot product: element-wise multiplication then sum
    dot = image_array.multiply(vector).arrayReduce(ee.Reducer.sum(), [0])
    
    # Compute norms
    image_norm = image_array.pow(2).arrayReduce(ee.Reducer.sum(), [0]).sqrt()
    vector_norm = vector.pow(2).reduce(ee.Reducer.sum(), [0]).sqrt()
    
    # Cosine similarity = dot / (norm1 * norm2)
    return dot.divide(image_norm.multiply(vector_norm)).arrayGet(0)


def compute_mean_embedding(
    samples: ee.FeatureCollection,
    band_names: ee.List
) -> ee.Array:
    """
    Compute the mean embedding vector from a collection of samples.
    
    Args:
        samples: FeatureCollection of sampled embeddings.
        band_names: List of band names to use.
        
    Returns:
        Mean embedding as ee.Array.
    """
    mean_dict = samples.reduceColumns(
        reducer=ee.Reducer.mean().repeat(band_names.size()),
        selectors=band_names
    ).get('mean')
    return ee.Array(mean_dict)


def create_geemap(
    center_geometry: Optional[ee.Geometry] = None,
    zoom: int = 8,
    clear_default_layers: bool = True
) -> geemap.Map:
    """
    Create a geemap Map object with optional centering and layer clearing.
    
    Args:
        center_geometry: Geometry to center the map on.
        zoom: Initial zoom level.
        clear_default_layers: Whether to remove default basemap layers.
        
    Returns:
        Configured geemap.Map instance.
    """
    Map = geemap.Map()
    
    if clear_default_layers:
        try:
            Map.layers = Map.layers[1:]
        except Exception:
            pass
    
    if center_geometry is not None:
        Map.centerObject(center_geometry, zoom)
    
    return Map


# Common visualization parameters
VIS_RGB_DEFAULT = {
    "bands": ["A01", "A16", "A09"],
    "min": -0.3,
    "max": 0.3,
}

VIS_RGB_ALT = {
    "bands": ["A21", "A10", "A09"],
    "min": -0.3,
    "max": 0.3,
}

VIS_SIMILARITY_VIRIDIS = {
    'min': 0,
    'max': 1,
    'palette': ['000004', '2C105C', '711F81', 'B63679', 'EE605E', 'FDAE78', 'FCFDBF', 'FFFFFF']
}

VIS_CLUSTER_8 = {
    "min": 0,
    "max": 7,
    "palette": [
        "440154", "3b528b", "21918c", "5ec962",
        "fde725", "ff7f00", "e31a1c", "6a3d9a",
    ],
}
