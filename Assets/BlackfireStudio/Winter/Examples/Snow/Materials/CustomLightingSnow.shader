Shader "Custom/URP/CustomLightingSnow"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _SnowStrength ("Snow Strength", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _SnowStrength;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varyings Vert(Attributes input)
            {
                Varyings output;
                float3 worldPos = TransformObjectToWorld(input.positionOS.xyz);

                output.positionHCS = TransformWorldToHClip(worldPos);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = input.uv;

                // View direction (world space)
                output.viewDirWS = GetCameraPositionWS() - worldPos;

                return output;
            }

            // Custom lighting model, similar to LightingSnow
            half3 CustomLighting(float3 normalWS, float3 lightDirWS, half3 lightColor, float snowStrength)
            {
                // Lambert diffuse term
                half NdotL = max(dot(normalWS, lightDirWS), 0.0);
                half3 diffuse = NdotL * lightColor;

                // Snow effect: Apply a brighter diffuse color for upward-facing normals
                float snowEffect = saturate(dot(normalWS, float3(0, 1, 0)));
                half3 snowColor = lerp(diffuse, float3(1.0, 1.0, 1.0), snowStrength * snowEffect);

                return snowColor;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                // Sample base color
                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _BaseColor;

                // Normalize directions
                half3 normalWS = normalize(input.normalWS);
                half3 viewDirWS = normalize(input.viewDirWS);

                // Accumulate lighting
                half3 lighting = 0.0;
                uint pixelLightCount;

                // Main directional light
                Light mainLight = GetMainLight();
                lighting += CustomLighting(normalWS, normalize(mainLight.direction), mainLight.color, _SnowStrength);

                // Additional lights
                #if _ADDITIONAL_LIGHTS
                Light light;
                for (pixelLightCount = 0; pixelLightCount < GetAdditionalLightsCount(); pixelLightCount++)
                {
                    light = GetAdditionalLight(pixelLightCount);
                    lighting += CustomLighting(normalWS, normalize(light.direction), light.color, _SnowStrength);
                }
                #endif

                return half4(baseColor.rgb * lighting, baseColor.a);
            }
            ENDHLSL
        }
    }
    // FallBack "Hidden/InternalErrorShader"
}
