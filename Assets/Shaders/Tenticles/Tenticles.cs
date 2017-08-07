using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tenticles : MonoBehaviour {
Transform trans;
Material mat;

	void Start () {
		trans = GetComponent<Transform>();
		mat = GetComponent<MeshRenderer>().material;
	}
	
	
	void Update () {
		mat.SetVector("_Position",trans.position);
	}
}
