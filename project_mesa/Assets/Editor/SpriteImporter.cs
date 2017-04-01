using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

internal sealed class SpriteImporter : AssetPostprocessor {

    private void OnPreprocessTexture() {
        //TextureImporter importer = (TextureImporter) assetImporter;
        //importer.textureType = TextureImporterType.Sprite;
        //importer.filterMode = FilterMode.Point;
        //importer.textureCompression = TextureImporterCompression.Uncompressed;
        //importer.spritePixelsPerUnit = 1;
    }
}