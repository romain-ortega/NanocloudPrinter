; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Nanocloud Printer"
!define PRODUCT_PUBLISHER "Nanocloud"
!define PRODUCT_WEB_SITE "https://www.nanocloud.com/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\photon.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "Library.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Nanocloud Printer"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME}"
OutFile "install_printer.exe"
InstallDir "$PROGRAMFILES\NanocloudPrinter"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  
  IfSilent 0 +2
  SetSilent silent
  
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "cc2.db3"
  File "gsdll32.dll"
  File "printer.exe"
  File "installDll.dll"
NoExcel:
  SetOutPath "$INSTDIR\DriverFiles"
  SetOverwrite try
  File "DriverFiles\*.*"
  SetOutPath "$INSTDIR\DriverFiles64bit"
  SetOverwrite try
  File "DriverFiles64bit\*.*"
  SetOutPath "$INSTDIR\urwfonts"
  File "urwfonts\*.*"
  SetOutPath "$INSTDIR\Images"
  File "Images\*.*"
  SetOutPath "$INSTDIR\lib"
  File "lib\*.*"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END

; Install the printer by calling the .dll
  DetailPrint "Registring the Nanocloud printer... please wait"
  
  System::Call '$TEMP\installDll::InstallPrinter(i, *i, t) i($HWNDPARENT, ., d).r2'
  Delete "$TEMP\installDll.dll"
  SetOutPath $tmp
  IntCmp $2 0 isok
  
; Failed: do something! ####
isok:

SectionEnd

Section -AdditionalIcons
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\printer.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\printer.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  IfSilent +2 0
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  IfSilent +3 0
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Function .onInit
  Var /GLOBAL the_temp

  StrCpy $the_temp $INSTDIR
  SetOutPath $TEMP
  SetOverwrite on
  File "installDll.dll"
  Copyfiles "$INSTDIR\installDll.dll" "$TEMP\installDll.dll"
  
  IntFmt $2 "%u" 2
  System::Call '$TEMP\installDll::IsInstalled(i, *i, t) i($HWNDPARENT, ., .).r2 ? u'
  
  StrCmp $2 "error" OnInitErr OnInitCont

OnInitErr:
  IfSilent +2 0

OnInitCont:
  
NotInstalled:

FunctionEnd
  
Function .onInstSuccess
  ;ExecShell "open" "http://www.cogniview.com/cc-pdf-converter-installed"
FunctionEnd

Section Uninstall
  IfSilent 0 +2
  SetSilent silent
  
; Remove the printer before deleting the files
  DetailPrint "Unregistering the Nanocloud printer... please wait"
  
  Copyfiles "$INSTDIR\installDll.dll" "$TEMP\installDll.dll"
  IntFmt $2 "%u" 2
  System::Call '$TEMP\installDll::RemovePrinter(i, *i, t) i($HWNDPARENT, ., .).r2 ? u'
  Delete "$TEMP\installDll.dll"
  
  IntCmp $2 0 RemoveOK

; Remove failed; we'll stop the uninstall
  Abort "Cannot uninstall"
RemoveOK:

  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP

  Delete "$INSTDIR\uninst.exe"
  RmDir /r "$INSTDIR\lib"
  RmDir /r "$INSTDIR\Images"
  RmDir /r "$INSTDIR\urwfonts"
  RmDir /r "$INSTDIR\DriverFiles"
  RmDir /r "$INSTDIR\DriverFiles64bit"
  Delete "$INSTDIR\printer.exe"
  Delete "$INSTDIR\gsdll32.dll"
  Delete "$INSTDIR\cc2.db3"
  Delete "$INSTDIR\installDll.dll"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
