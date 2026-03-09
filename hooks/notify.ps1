param(
    [string]$Title = "Claude Code",
    [string]$Message = "Needs your attention"
)

# --- Taskbar flash via FlashWindowEx P/Invoke ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32Flash {
    [StructLayout(LayoutKind.Sequential)]
    public struct FLASHWINFO {
        public uint cbSize;
        public IntPtr hwnd;
        public uint dwFlags;
        public uint uCount;
        public uint dwTimeout;
    }

    [DllImport("user32.dll")]
    public static extern bool FlashWindowEx(ref FLASHWINFO pwfi);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    // FLASHW_ALL | FLASHW_TIMERNOFG
    private const uint FLASHW_ALL = 3;
    private const uint FLASHW_TIMERNOFG = 12;

    public static void Flash() {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) return;

        FLASHWINFO fi = new FLASHWINFO();
        fi.cbSize = (uint)Marshal.SizeOf(fi);
        fi.hwnd = hwnd;
        fi.dwFlags = FLASHW_ALL | FLASHW_TIMERNOFG;
        fi.uCount = 0;
        fi.dwTimeout = 0;
        FlashWindowEx(ref fi);
    }
}
"@ -ErrorAction SilentlyContinue

# --- Persistent toast with reminder scenario ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null

$iconPath = "$env:USERPROFILE\.claude\hooks\claude-icon.png"

$template = @"
<toast scenario="reminder">
    <visual>
        <binding template="ToastGeneric">
            <image placement="appLogoOverride" hint-crop="circle" src="$iconPath"/>
            <text>$Title</text>
            <text>$Message</text>
            <progress value="indeterminate" title="Waiting for you..." status=""/>
        </binding>
    </visual>
    <actions>
        <action content="Dismiss" arguments="dismiss" activationType="system"/>
    </actions>
    <audio silent="true"/>
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)

$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$toast = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
$toast.Show([Windows.UI.Notifications.ToastNotification]::new($xml))

# Flash taskbar after showing toast
[Win32Flash]::Flash()
