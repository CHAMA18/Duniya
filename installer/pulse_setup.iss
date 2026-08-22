; =====================================================================
; Pulse — Windows Installer (Inno Setup 6)
; =====================================================================
; Used by the GitHub Actions desktop release workflow
; (see .github/workflows/build-desktop.yml) and by build_windows.sh.
; Output: installer/Output/Pulse-Setup.exe
; =====================================================================

#define MyAppName "Pulse"
#define MyAppVersion "1.8.0"
#define MyAppPublisher "Pulse Healthcare"
#define MyAppURL "https://ivm.duniyahealthcare.com"
#define MyAppExeName "duniya.exe"

[Setup]
AppId={{7D2C1A3E-5B4A-4C9F-9E6A-D8B1F2C4E6A8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#SourcePath}Output
OutputBaseFilename={#MyAppName}-Setup
SetupIconFile=..\assets\images\app_launcher_icon.png
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

