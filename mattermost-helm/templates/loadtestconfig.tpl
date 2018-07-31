{{- define "loadtestconfig.tpl" -}}
{
    "ConnectionConfiguration": {
        "ServerURL": "http://{{ template "mattermost-enterprise-edition.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.mattermostApp.service.internalPort }}",
        "WebsocketURL": "ws://{{ template "mattermost-enterprise-edition.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.mattermostApp.service.internalPort }},
        "PProfUrl": "http://{{ template "mattermost-enterprise-edition.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.mattermostApp.service.metricsName }}/debug/pprof",
        "DriverName": "mysql",
        "DataSource": "{{ .Values.mysqlha.mysqlha.mysqlUser }}:{{ .Values.mysqlha.mysqlha.mysqlPassword }}@tcp({{ .Release.Name }}-mysqlha-0.{{ .Release.Name }}-mysqlha:3306)/{{  .Values.mysqlha.mysqlha.mysqlDatabase }}?charset=utf8mb4,utf8&readTimeout=240s&writeTimeout=240s",
        "LocalCommands": true,
        "SSHHostnamePort": "",
        "SSHUsername": "",
        "SSHPassword": "",
        "SSHKey": "",
        "MattermostInstallDir": "/mattermost",
        "ConfigFileLoc": "",
        "AdminEmail": "success+ltadmin@simulator.amazonses.com",
        "AdminPassword": "ltpassword",
        "SkipBulkload": {{ .Values.global.features.loadTest.skipBulkLoad }},
        "WaitForServerStart": true
    },
    "LoadtestEnviromentConfig": {
        "NumTeams": {{ .Values.global.features.loadTest.numTeams }},
        "NumChannelsPerTeam": {{ .Values.global.features.loadTest.numChannelsPerTeam }},
        "NumUsers": {{ .Values.global.features.loadTest.numUsers }},
        "NumPosts": {{.Values.global.features.loadTest.numPosts}},
        "NumEmoji": {{.Values.global.features.loadTest.numEmoji}},
        "PostTimeRange": 2600000,
        "ReplyChance": {{.Values.global.features.loadTest.replyChance}},
        "PercentHighVolumeTeams": 0.2,
        "PercentMidVolumeTeams": 0.5,
        "PercentLowVolumeTeams": 0.3,
        "PercentUsersHighVolumeTeams": 0.9,
        "PercentUsersMidVolumeTeams": 0.5,
        "PercentUsersLowVolumeTeams": 0.1,
        "PercentHighVolumeChannels": 0.2,
        "PercentMidVolumeChannels": 0.5,
        "PercentLowVolumeChannels": 0.3,
        "PercentUsersHighVolumeChannel": 0.1,
        "PercentUsersMidVolumeChannel": 0.003,
        "PercentUsersLowVolumeChannel": 0.0002,
        "HighVolumeTeamSelectionWeight": 3,
        "MidVolumeTeamSelectionWeight": 2,
        "LowVolumeTeamSelectionWeight": 1,
        "HighVolumeChannelSelectionWeight": 1,
        "MidVolumeChannelSelectionWeight": 3,
        "LowVolumeChannelSelectionWeight": 1
    },
    "UserEntitiesConfiguration": {
        "TestLengthMinutes": {{ .Values.global.features.loadTest.testLengthMinutes }},
        "NumActiveEntities": {{ .Values.global.features.loadTest.numActiveEntities }},
        "EntityStartNum": 0,
        "ActionRateMilliseconds": {{ .Values.global.features.loadTest.actionRateMilliseconds }},
        "ActionRateMaxVarianceMilliseconds": {{ .Values.global.features.loadTest.actionRateMaxVarianceMilliseconds }},
        "EnableRequestTiming": true,
        "UploadImageChance": 0.01,
        "LinkPreviewChance": {{ .Values.global.features.loadTest.linkPreviewChance }},
        "CustomEmojiChance": {{ .Values.global.features.loadTest.customEmojiChance }},
        "DoStatusPolling": true
    },
    "DisplayConfiguration": {
        "ShowUI": false,
        "LogToConsole": true
    },
    "ResultsConfiguration": {
        "CustomReportText": "Results for #{{ template "mattermost-enterprise-edition.jobserver.fullname" . }}",
        "SendReportToMMServer": {{ .Values.global.features.loadTest.sendReportToMMServer }},
        "ResultsServerURL": "{{ .Values.global.features.loadTest.resultsServerUrl }}",
        "ResultsChannelId": "{{ .Values.global.features.loadTest.resultsChannelId }}",
        "ResultsUsername": "{{ .Values.global.features.loadTest.resultsUsername }}",
        "ResultsPassword": "{{ .Values.global.features.loadTest.resultsPassword }}",
        "PProfDelayMinutes": {{ .Values.global.features.loadTest.pprofDelayMinutes }},
        "PProfLength": {{ .Values.global.features.loadTest.pprofLengthSeconds }}
    }
}
{{- end -}}
