using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

// A behaviour that is attached to a playable
public class CreatorParticles : PlayableBehaviour
{
	public float Duration;
	public ParticleSystem system;

	private float time;
	private bool up = true;
	private float rate;

	// Called when the owning graph starts playing
	public override void OnGraphStart(Playable playable) {

	}

	// Called when the owning graph stops playing
	public override void OnGraphStop(Playable playable) {
		
	}

	// Called when the state of the playable is set to Play
	public override void OnBehaviourPlay(Playable playable, FrameData info) {
		time = 0;
		Duration = (float)playable.GetDuration();
	}

	// Called when the state of the playable is set to Paused
	public override void OnBehaviourPause(Playable playable, FrameData info) {
		
	}

	// Called each frame while the state is set to Play
	public override void PrepareFrame(Playable playable, FrameData info) {
		if (up)
		{
			time += info.deltaTime;
			if (time >= Duration/2)
			{
				up = false;
			}
		}
		else
		{
			time -= Time.deltaTime;
			if (time <= 0)
			{
				time = 0;
				up = true;
			}
		}
		var em = system.emission;
        em.rateOverTimeMultiplier = Mathf.Lerp(0, 1, time * 2 / Duration) * 40;
	}
}
