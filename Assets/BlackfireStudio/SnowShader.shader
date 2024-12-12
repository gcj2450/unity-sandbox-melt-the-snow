//改自WinterPackage内的snowshader
Shader "Custom/URP/SnowShader"
{
    Properties
    {
        _Ramp ("Shade (RGB)", 2D) = "white" {}
        _RampPower ("Shade Intensity", Range(0.0, 1.0)) = 1.0
        _MainTex ("Base Color (RGB)", 2D) = "white" {}
        _GlitterTex ("Specular Map (RGB)", 2D) = "black" {}
        _Specular("Specular Intensity", Range (0.0, 5.0))	= 1.0
        _Shininess("Shininess", Range (0.01, 1.0))			= 0.08
		_Aniso("Anisotropic Mask", Range (0.0, 1.0))		= 0.0
		_Glitter("Anisotropic Intensity", Range (0.0, 15.0))= 0.5
		_BumpTex("Normal (RGB)", 2D)						= "bump" {}
		_DepthTex("Depth (R)", 2D)							= "white" {}
		_Depth("Translucency", Range(-2.0, 1.0))			= 1.0
		_Coverage("Coverage", Range (-0.01, 1.001))			= 0.5
		_SubNormal("SubNormal (RGB)", 2D)						= "bump" {}
		_Spread("Spread", Range (0.0, 1.0))				= 1.0
		_Smooth("Smooth", Range (0.01, 5.0))				= 0.5
		_Transition("Transition", Range (-1.0, 1.0))			= 0.5
		_TransitionSmooth	("Transition Smoothness", Range (0.0, 2.0))	= 0.5
		_Direction("Direction", Vector)						= (0, 1, 0)
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        LOD 300
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            Offset 0, -1
		    ZWrite Off

            HLSLPROGRAM

            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            // Properties
            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_BumpTex);
            SAMPLER(sampler_BumpTex);

            TEXTURE2D(_DepthTex);
            SAMPLER(sampler_DepthTex);

            TEXTURE2D(_SubNormal);
            SAMPLER(sampler_SubNormal);

            TEXTURE2D(_GlitterTex);
            SAMPLER(sampler_GlitterTex);


            float _RampPower;
            float _Glitter;
            half _Aniso;
            float _Shininess;
            half _Specular;
	        float _Depth;
            float4 _Direction;
            float _Coverage;
            half _Spread;
			half _Smooth;
            float _Transition;
            float _TransitionSmooth;

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


            half4 frag(Varyings input) : SV_Target
            {
                return half4(1,1,1, 1.0);
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}
