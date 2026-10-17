; Billing Baba Windows installer (Inno Setup 6)
;
; CI compiles with defines:
;   /DAppVersion="1.0.0"
;   /DReleaseDir="C:\path\to\Release"
;   /DOutputDir="C:\path\to\output"
;   /DVCRedistPath="C:\path\to\vc_redist.x64.exe"
;   /DSetupIcon="C:\path\to\app_icon.ico"
;
; Future: code signing — add SignTool directive and SignedUninstaller once a
; Windows Authenticode certificate is available (see docs/deployment/windows-release.md).

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#ifndef ReleaseDir
  #define ReleaseDir "..\apps\client\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "..\dist"
#endif

#ifndef VCRedistPath
  #define VCRedistPath "deps\vc_redist.x64.exe"
#endif

#ifndef SetupIcon
  #define SetupIcon "..\apps\client\windows\runner\resources\app_icon.ico"
#endif

#define AppName "Billing Baba"
#define AppPublisher "Billing Baba"
#define AppExeName "billing_baba.exe"
; Double braces so Inno Setup treats the GUID as a literal, not a constant.
#define AppId "{{A3F8C2E1-9B4D-4F6A-8C1E-2D5E7F9A0B3C}}"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=BillingBabaSetup-v{#AppVersion}
SetupIconFile={#SetupIcon}
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
CloseApplications=yes
DisableDirPage=auto
RestartApplications=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Enable when an Authenticode certificate is available:
; SignTool=signtool /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /a $f

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchapp"; Description: "Launch {#AppName} after installation"; GroupDescription: "Post-install:"; Flags: checkedonce

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#VCRedistPath}"; DestDir: "{tmp}"; DestName: "vc_redist.x64.exe"; Flags: deleteafterinstall; Check: VCRedistNeedsInstall

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ Redistributable..."; Flags: waituntilterminated; Check: VCRedistNeedsInstall
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent runasoriginaluser; Tasks: launchapp
Filename: "{app}\{#AppExeName}"; Flags: nowait skipifsilent runasoriginaluser; Check: WizardSilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) then
  begin
    Result := False;
    Exit;
  end;

  if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
end;
