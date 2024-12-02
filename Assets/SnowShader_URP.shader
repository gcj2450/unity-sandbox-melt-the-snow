Shader "xuhonghua/SnowShader_URP"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}      // ԭʼ����
        _Bump ("Normal Map", 2D) = "bump" {}           // ������ͼ
        _Snow ("Snow Level", Range(0,1)) = 0           // ѩ���ǳ̶�
        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)// ѩ��ɫ
        _SnowDirection ("Snow Direction", Vector) = (0, 1, 0) // ѩ����
        _SnowDepth ("Snow Depth", Range(0, 0.3)) = 0.1 // ѩ���
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForwardOnly" "RenderType" = "Opaque" }
            
            HLSLPROGRAM

            // ���� URP �����ļ�
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // �������������
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
                float4 positionOS : POSITION;    // ����ռ�λ��
                float3 normalOS : NORMAL;       // ����ռ䷨��
                float2 uv : TEXCOORD0;          // UV ����
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION; // �ü��ռ�λ��
                float3 worldPosition : TEXCOORD0; // ����ռ�λ��
                float3 worldNormal : TEXCOORD1;   // ����ռ䷨��
                float2 uv : TEXCOORD2;            // UV ����
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                // ת�����㵽�ü��ռ�
                o.positionCS = TransformObjectToHClip(v.positionOS);
                // ����ռ䷨��
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);
                // ����ռ�λ��
                o.worldPosition = TransformObjectToWorld(v.positionOS);
                // UV ����
                o.uv = v.uv;

                // ѩƫ���߼�
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
                // ��������
                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half3 normalMap = UnpackNormal(SAMPLE_TEXTURE2D(_Bump, sampler_Bump, i.uv));

                // ѩ�����߼�
                float snowAmount = dot(i.worldNormal, normalize(_SnowDirection.xyz));
                half3 finalColor = baseColor.rgb;
                if (snowAmount > lerp(1, -1, _Snow))
                {
                    finalColor = _SnowColor.rgb;
                }

                // ����Դ����
                Light mainLight = GetMainLight(); // ��ȡ����Դ��Ϣ
                float3 lightDir = normalize(mainLight.direction);
                float lightIntensity = max(0.0, dot(i.worldNormal, lightDir));
                lightIntensity = lightIntensity * 0.5 + 0.5; // ������������

                half3 lighting = finalColor * mainLight.color * lightIntensity;

                return half4(lighting, baseColor.a);
            }

            ENDHLSL
        }
    }
}
