using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombustionOperator : MonoBehaviour {
public CustomRenderTexture Texture;

	void Start () {
		Texture.Initialize();
	}
	
	void Update () {
		Texture.Update(5);
	}
}
