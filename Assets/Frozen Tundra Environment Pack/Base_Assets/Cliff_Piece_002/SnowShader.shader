//改自WinterPackage内的snowshader
Shader "Custom/URP/SnowShader"
{
    Properties
    {
        _MainTex ("Base Color (RGB)", 2D) = "white" {}
        _SnowTex ("Snow Texture", 2D) = "white" {}
        _Ramp ("Shade (RGB)", 2D) = "white" {}
        _RampPower ("Shade Intensity", Range(0.0, 1.0)) = 1.0
        _GlitterTex ("Specular Map (RGB)", 2D) = "black" {}
        _Shininess ("Shininess", Range(0.01, 1.0)) = 0.08
        _Coverage ("Snow Coverage", Range(0.0, 1.0)) = 0.5
        _Transition ("Transition", Range(-1.0, 1.0)) = 0.5
        _TransitionSmooth ("Transition Smoothness", Range(0.0, 2.0)) = 0.5
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Range(1.0, 10.0)) = 5.0
        _Direction ("Direction", Vector) = (0, 1, 0)
    }

    SubShader
    {
        Tags {"RenderPipeline"="UniversalRenderPipeline" "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "IgnoreProjector"="True"}
        Cull Back
        HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
        Pass
        {
            Name "Forward"
            Tags { "LightMode"="UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            Offset 0, -1
		    ZWrite Off
		    LOD 400

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            // Properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_SnowTex);
            SAMPLER(sampler_SnowTex);
            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);
            TEXTURE2D(_GlitterTex);
            SAMPLER(sampler_GlitterTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            float _RampPower;
            float _Shininess;
            float _Coverage;
            float _Transition;
            float _TransitionSmooth;
            float _NoiseScale;
            float4 _Direction;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionHCS = TransformWorldToHClip(positionWS);
                output.uv = input.uv;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionWS = positionWS.xyz;
                output.shadowCoord=TransformWorldToShadowCoord( positionWS );
                return output;
            }

            half3 ApplyRamp(float3 normalWS, float3 viewDirWS, float NdotL)
            {
                float NdotV = saturate(dot(normalWS, viewDirWS));
                float rampUV = _RampPower * NdotV;
                float3 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, float2(rampUV, NdotL)).rgb;
                return ramp;
            }

            float ComputeSnowBlend(float3 worldNormal, float2 uv, float2 noiseUV)
            {
                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
                float NdotD = dot(worldNormal, normalize(_Direction.xyz));
                float coverage = saturate(NdotD - lerp(1.0, -1.0, _Coverage));
                float blend = saturate(coverage + noise / _TransitionSmooth);
                return blend;
            }

            float3 ApplySpecular(float3 normalWS, float3 lightDirWS, float3 viewDirWS, float3 specularColor)
            {
                float3 halfVector = normalize(lightDirWS + viewDirWS);
                float specular = pow(saturate(dot(normalWS, halfVector)), _Shininess * 128.0);
                return specularColor * specular;
            }

            half4 frag(Varyings input) : SV_Target
            {
                Light mainLight = GetMainLight(input.shadowCoord);

                float3 normalWS = normalize(input.normalWS);
                float3 viewDirWS = normalize(_WorldSpaceCameraPos - input.positionWS);
                float3 lightDirWS = normalize(mainLight.direction);

                // Base color and snow blend
                float3 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
                float3 snowColor = SAMPLE_TEXTURE2D(_SnowTex, sampler_SnowTex, input.uv).rgb;
                float snowBlend = ComputeSnowBlend(normalWS, input.uv, input.uv * _NoiseScale);

                // Apply ramp and blend
                float NdotL = saturate(dot(normalWS, lightDirWS));
                float3 ramp = ApplyRamp(normalWS, viewDirWS, NdotL);
                float3 color = lerp(baseColor, snowColor, snowBlend);
                color = color * ramp;

                // Add specular
                float3 specularColor = SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, input.uv).rgb;
                float3 specular = ApplySpecular(normalWS, lightDirWS, viewDirWS, specularColor);

                return half4(color + specular, 1.0);
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}
