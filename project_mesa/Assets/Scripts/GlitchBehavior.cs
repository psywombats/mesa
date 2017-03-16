using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlitchBehavior : MonoBehaviour {
    public Shader shader;
    
    private Material material;
    private float elapsedSeconds;

    public void Awake() {
        material = new Material(shader);
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
        float elapsed = elapsedSeconds;
    }
}
