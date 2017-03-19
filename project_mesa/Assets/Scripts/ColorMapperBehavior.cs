﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class ColorMapperBehavior : MonoBehaviour {
    public Shader shader;
    
    private Material material;
    private float elapsedSeconds;

    public void Awake() {
        SpriteRenderer renderer = GetComponent<SpriteRenderer>();
        material = renderer.material;
    }

    public void OnDestroy() {
        Destroy(material);
    }

    public void Update() {
        AssignCommonShaderVariables();
        elapsedSeconds += Time.deltaTime;
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (GetComponent<Camera>() != null) {
            material.SetTexture("_MainTexture", source);
            AssignCommonShaderVariables();
            Graphics.Blit(source, destination, material);
        }
    }

    public Material GetMaterial() {
        return material;
    }

    private void AssignCommonShaderVariables() {
        material.SetFloat("_Elapsed", System.DateTime.Now.Millisecond);
    }
}
