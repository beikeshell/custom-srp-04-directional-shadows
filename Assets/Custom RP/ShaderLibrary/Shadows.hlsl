﻿#ifndef CUSTOM_SHADOWS_INCLUDED
#define CUSTOM_SHADOWS_INCLUDED

#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
#define MAX_CASCADE_COUNT 4


TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);

CBUFFER_START(_CustomShadows)
	int _CascadeCount;
	float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
	float4 _CascadeData[MAX_CASCADE_COUNT];
	float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];
	// float _ShadowDistance;
	float4 _ShadowDistanceFade;
CBUFFER_END

struct DirectionalShadowData {
	float strength;
	int tileIndex;
	float normalBias;
};

struct ShadowData {
	int cascadeIndex;
	float strength;
};

float FadedShadowStrength (float distance, float scale, float fade) {
	return saturate((1.0 - distance * scale) * fade);
}

ShadowData GetShadowData (Surface surfaceWS) {
	ShadowData data;
	data.strength =  FadedShadowStrength(
		surfaceWS.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y
	);
	int i;
	for (i = 0; i < _CascadeCount; i++) {
		float4 sphere = _CascadeCullingSpheres[i];
		float distanceSqr = DistanceSquared(surfaceWS.position, sphere.xyz);
		if (distanceSqr < sphere.w) {
			if (i == _CascadeCount - 1) {
				data.strength *= FadedShadowStrength(
					distanceSqr, _CascadeData[i].x, _ShadowDistanceFade.z
				);
			}
			break;
		}
	}
	if (i == _CascadeCount) {
		data.strength = 0.0;
	}
	data.cascadeIndex = i;
	return data;
}

float SampleDirectionalShadowAtlas (float3 positionSTS) {
	return SAMPLE_TEXTURE2D_SHADOW(
		_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS
	);
}

float GetDirectionalShadowAttenuation (DirectionalShadowData directional, ShadowData global, Surface surfaceWS) {
	if (directional.strength <= 0.0) {
		return 1.0;
	}
	float3 normalBias = surfaceWS.normal * (directional.normalBias * _CascadeData[global.cascadeIndex].y);
	float3 positionSTS = mul(
		_DirectionalShadowMatrices[directional.tileIndex],
		float4(surfaceWS.position + normalBias, 1.0)
	).xyz;
	float shadow = SampleDirectionalShadowAtlas(positionSTS);
	return lerp(1.0, shadow, directional.strength);
}

#endif