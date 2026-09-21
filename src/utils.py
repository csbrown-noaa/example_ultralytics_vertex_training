def resolve_fuse_path(uri: str) -> str:
    """
    Converts a GCS URI into a local Vertex AI FUSE path.
    """
    if uri.startswith("gs://"):
        return uri.replace("gs://", "/gcs/")
    return uri
