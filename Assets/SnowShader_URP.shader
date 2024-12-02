Shader "xuhonghua/SnowShader_URP"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}      // 原始纹理
        _Bump ("Normal Map", 2D) = "bump" {}           // 法线贴图
        _Snow ("Snow Level", Range(0,1)) = 0           // 雪覆盖程度
        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)// 雪颜色
        _SnowDirection ("Snow Direction", Vector) = (0, 1, 0) // 雪方向
        _SnowDepth ("Snow Depth", Range(0, 0.3)) = 0.1 // 雪深度
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForwardOnly" "RenderType" = "Opaque" }
            
            HLSLPROGRAM

            // 引入 URP 核心文件
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 声明纹理和属性
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_Bump);
            SAMPLER(sampler_Bump);

            float _Snow;
            float4 _SnowColor;
            float4 _SnowDirection;
            float _SnowDepth;

            struct Attributes
            {
                float4 positionOS : POSITION;    // 对象空间位置
                float3 normalOS : NORMAL;       // 对象空间法线
                float2 uv : TEXCOORD0;          // UV 坐标
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION; // 裁剪空间位置
                float3 worldPosition : TEXCOORD0; // 世界空间位置
                float3 worldNormal : TEXCOORD1;   // 世界空间法线
                float2 uv : TEXCOORD2;            // UV 坐标
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                // 转换顶点到裁剪空间
                o.positionCS = TransformObjectToHClip(v.positionOS);
                // 世界空间法线
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);
                // 世界空间位置
                o.worldPosition = TransformObjectToWorld(v.positionOS);
                // UV 坐标
                o.uv = v.uv;

                // 雪偏移逻辑
                float3 snowDirectionWS = normalize(_SnowDirection.xyz);
                float snowFactor = dot(v.normalOS, snowDirectionWS);
                if (snowFactor >= lerp(1, -1, (_Snow * 2) / 3))
                {
                    float3 offset = (snowDirectionWS + v.normalOS) * _SnowDepth * _Snow;
                    o.worldPosition += offset;
                }

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                // 采样纹理
                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half3 normalMap = UnpackNormal(SAMPLE_TEXTURE2D(_Bump, sampler_Bump, i.uv));

                // 雪覆盖逻辑
                float snowAmount = dot(i.worldNormal, normalize(_SnowDirection.xyz));
                half3 finalColor = baseColor.rgb;
                if (snowAmount > lerp(1, -1, _Snow))
                {
                    finalColor = _SnowColor.rgb;
                }

                // 主光源处理
                Light mainLight = GetMainLight(); // 获取主光源信息
                float3 lightDir = normalize(mainLight.direction);
                float lightIntensity = max(0.0, dot(i.worldNormal, lightDir));
                lightIntensity = lightIntensity * 0.5 + 0.5; // 调整暗部光照

                half3 lighting = finalColor * mainLight.color * lightIntensity;

                return half4(lighting, baseColor.a);
            }

            ENDHLSL
        }
    }
}
