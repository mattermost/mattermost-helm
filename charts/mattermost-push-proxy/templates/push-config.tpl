{{- define "push-config.tpl" -}}
{
    "ListenAddress":":8066",
    "ThrottlePerSec":300,
    "ThrottleMemoryStoreSize":50000,
    "ThrottleVaryByHeader":"X-Forwarded-For",
    "EnableMetrics": {{ .Values.enableMetrics }},
    "SendTimeoutSec": {{ .Values.sendTimeoutSec }},
    "RetryTimeoutSec": {{ .Values.retryTimeoutSec }},
    "ApplePushSettings":[
        {
            "Type":"apple",
            "ApplePushUseDevelopment":false,
	    {{- if eq .Values.applePushSettings.apple.privateCert "" }}
            "ApplePushCertPrivate":"",
            {{- else }}
            "ApplePushCertPrivate": "/certs/apple-push-cert.pem",
	    {{- end }}
        {{- if and (eq .Values.applePushSettings.authKey "") (eq .Values.externalSecrets.enabled false) }}
            "AppleAuthKeyFile":"",
            "AppleAuthKeyID":"",
            "AppleTeamID":"",
        {{- else }}
            "AppleAuthKeyFile": "{{ .Values.applePushSettings.authKeyFile }}",
            "AppleAuthKeyID": "{{ .Values.applePushSettings.authKeyID }}",
            "AppleTeamID": "{{ .Values.applePushSettings.teamID }}",
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
        {{- if and (eq .Values.applePushSettings.authKey "") (eq .Values.externalSecrets.enabled false) }}
            "AppleAuthKeyFile":"",
            "AppleAuthKeyID":"",
            "AppleTeamID":"",
        {{- else }}
            "AppleAuthKeyFile": "{{ .Values.applePushSettings.authKeyFile }}",
            "AppleAuthKeyID": "{{ .Values.applePushSettings.authKeyID }}",
            "AppleTeamID": "{{ .Values.applePushSettings.teamID }}",
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
        {{- if and (eq .Values.applePushSettings.authKey "") (eq .Values.externalSecrets.enabled false) }}
            "AppleAuthKeyFile":"",
            "AppleAuthKeyID":"",
            "AppleTeamID":"",
        {{- else }}
            "AppleAuthKeyFile": "{{ .Values.applePushSettings.authKeyFile }}",
            "AppleAuthKeyID": "{{ .Values.applePushSettings.authKeyID }}",
            "AppleTeamID": "{{ .Values.applePushSettings.teamID }}",
        {{- end }}
            "ApplePushCertPassword":"{{ .Values.applePushSettings.apple_rnbeta.privateCertPassword }}",
            "ApplePushTopic":"{{ .Values.applePushSettings.apple_rnbeta.pushTopic }}"
        }
    ],
    "AndroidPushSettings":[
        {
            "Type":"android",
             {{- if eq .Values.androidPushSettings.android.serviceFileLocation "" }}
            "ServiceFileLocation":""
             {{- else }}
            "ServiceFileLocation":"{{ .Values.androidPushSettings.android.serviceFileLocation }}"
             {{- end }}
        },
        {
            "Type":"android_rn",
            {{- if eq .Values.androidPushSettings.android_rn.serviceFileLocation "" }}
            "ServiceFileLocation":""
             {{- else }}
            "ServiceFileLocation":"{{ .Values.androidPushSettings.android_rn.serviceFileLocation }}"
             {{- end }}
        }
    ]
}
{{- end -}}
