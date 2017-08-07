/*
Copyright 2017 Richard Kopelow

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphericalDestruction : MonoBehaviour
{
    [Range(0, 1)]
    public float Expansion;
    
    Transform trans;
    Material[] mats;
    Vector4[] orbs = new Vector4[] {
                new Vector4(0,0.6f,0,0),
                new Vector4(1f,0.4f,0,0),
                new Vector4(-1f,0.4f,0,0),
                new Vector4(0,-0.9f,0,0)
            };

    void Start()
    {
        trans = GetComponent<Transform>();
        mats = GetComponent<Renderer>().materials;
        foreach (Material mat in mats)
        {
            mat.SetInt("_OrbsLength", 4);
            mat.SetVectorArray("_Orbs", orbs);
        }
    }

    private void Update()
    {
        foreach (Material mat in mats)
        {
            mat.SetFloat("_Expansion", Expansion);
            mat.SetVectorArray("_Orbs", orbs);
            mat.SetVector("_Position", trans.position);
        }
    }
}
