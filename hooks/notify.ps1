param(
    [string]$Title = "Claude Code",
    [string]$Message = "Needs your attention"
)

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null

$iconPath = "$env:USERPROFILE\.claude\hooks\claude-icon.png"

$template = @"
<toast duration="short">
    <visual>
        <binding template="ToastGeneric">
            <image placement="appLogoOverride" hint-crop="circle" src="$iconPath"/>
            <text>$Title</text>
            <text>$Message</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.IM"/>
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)

$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$toast = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
$toast.Show([Windows.UI.Notifications.ToastNotification]::new($xml))
