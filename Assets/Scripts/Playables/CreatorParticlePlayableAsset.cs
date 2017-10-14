using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

[System.Serializable]
public class CreatorParticlePlayableAsset : PlayableAsset
{
	// Factory method that generates a playable based on this asset
	public override Playable CreatePlayable(PlayableGraph graph, GameObject go) {
		CreatorParticles particlePlay = new CreatorParticles();
		particlePlay.system = go.GetComponent<Transform>().GetComponentInChildren<ParticleSystem>();
		return ScriptPlayable<CreatorParticles>.Create(graph, particlePlay);
	}
}
