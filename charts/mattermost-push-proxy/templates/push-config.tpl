{{- define "push-config.tpl" -}}
{
    "ListenAddress":":8066",
    "ThrottlePerSec":300,
    "ThrottleMemoryStoreSize":50000,
    "ThrottleVaryByHeader":"X-Forwarded-For",
    "EnableMetrics": false,
    "ApplePushSettings":[
        {
            "Type":"apple",
            "ApplePushUseDevelopment":false,
	    {{- if eq .Values.applePushSettings.apple.privateCert "" }}
            "ApplePushCertPrivate":"",
            {{- else }}
            "ApplePushCertPrivate": "/certs/apple-push-cert.pem",
	    {{- end }}
            "ApplePushCertPassword":"{{ .Values.applePushSettings.apple.privateCertPassword }}",
            "ApplePushTopic":"{{ .Values.applePushSettings.apple.pushTopic }}"
        },
        {
            "Type":"apple_rn",
            "ApplePushUseDevelopment":false,
	    {{- if eq .Values.applePushSettings.apple_rn.privateCert "" }}
            "ApplePushCertPrivate":"",
        {{- else }}
            "ApplePushCertPrivate": "/certs/apple-rn-push-cert.pem",
        {{- end }}
            "ApplePushCertPassword":"{{ .Values.applePushSettings.apple_rn.privateCertPassword }}",
            "ApplePushTopic":"{{ .Values.applePushSettings.apple_rn.pushTopic }}"
        },
        {
            "Type":"apple_rnbeta",
            "ApplePushUseDevelopment":false,
        {{- if eq .Values.applePushSettings.apple_rnbeta.privateCert "" }}
            "ApplePushCertPrivate":"",
        {{- else }}
            "ApplePushCertPrivate": "/certs/apple-rnbeta-push-cert.pem",
        {{- end }}
            "ApplePushCertPassword":"{{ .Values.applePushSettings.apple_rnbeta.privateCertPassword }}",
            "ApplePushTopic":"{{ .Values.applePushSettings.apple_rnbeta.pushTopic }}"
        }
    ],
    "AndroidPushSettings":[
        {
            "Type":"android",
            "AndroidApiKey":"{{ .Values.androidPushSettings.android.apiKey }}"
        },
        {
            "Type":"android_rn",
            "AndroidApiKey":"{{ .Values.androidPushSettings.android_rn.apiKey }}"
        }
    ]
}
{{- end -}}
