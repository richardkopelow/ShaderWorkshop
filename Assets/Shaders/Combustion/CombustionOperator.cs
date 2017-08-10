using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombustionOperator : MonoBehaviour
{
    public CustomRenderTexture Texture;
    public bool SimulateOffScreen;

    private bool onScreen;

    void Start()
    {
        Texture.Initialize();
    }

    void Update()
    {
        if (onScreen || SimulateOffScreen)
        {
            Texture.Update(1);
        }
    }

    void OnBecameVisible()
    {
		onScreen = true;
    }

	void OnBecameInvisible()
	{
		onScreen = false;
	}
}
