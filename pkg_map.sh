#!/system/bin/sh

# 夹名 → 包名映射表
# 格式：夹名=包名
PKG_MAP="
MSA=com.miui.systemAdSolution
SecurityOnetrackService=com.xiaomi.security.onetrack
AnalyticsCore=com.miui.analytics
MiGameCenterSDKService=com.xiaomi.gamecenter.sdk.service
MiniGameService=com.xiaomi.minigame
MIUIGameCenter=com.xiaomi.gamecenter
MiGameService_8550=com.xiaomi.migameservice
MIUICloudService=com.miui.cloudservice
MIUIMiCloudSync=com.miui.micloudsync
MIUICloudBackup=com.miui.cloudbackup
MirrorOS3=com.xiaomi.mirror
CarWith=com.miui.carlink
MIS=com.xiaomi.mis
MiLinkOS3Cn=com.milink.service
MiConnectService=com.xiaomi.mi_connect_service
XiaoaiRecommendation=com.xiaomi.aireco
VoiceAssistAndroidT=com.miui.voiceassist
VoiceTrigger=com.miui.voicetrigger
AiasstVision=com.xiaomi.aiasst.vision
MIUIAiasstService=com.xiaomi.aiasst.service
MIUIAICR=com.xiaomi.aicr
MIUIPersonalAssistantPhoneOS3=com.miui.personalassistant
MiuiBarrage=com.xiaomi.barrage
MIUIContentExtension=com.miui.contentextension
DownloadProviderUi=com.android.providers.downloads.ui
MiuiScanner=com.xiaomi.scanner
BuiltInPrintService=com.android.bips
MiuiPrintSpooler=com.android.printspooler
ManagedProvisioning=com.android.managedprovisioning
WMService=com.miui.wmsvc
MIUIReporter=com.miui.uireporter
AutoRegistration=com.xiaomi.registration
RegService=com.miui.dmregservice
MiSightService=com.miui.misightservice
MiuiDaemon=com.miui.daemon
VsimCore=com.miui.vsimcore
EmergencyInfo=com.android.emergency
PowerInsight=com.miui.powerinsight
com.qualcomm.qti.services.systemhelper=com.qualcomm.qti.services.systemhelper
SystemHelper=com.mobiletools.systemhelper
MetokNLP=com.xiaomi.metoknlp
MIUIQuickSearchBox=com.android.quicksearchbox
SwitchAccess=com.google.android.accessibility.switchaccess
com.xiaomi.macro=com.xiaomi.macro
com.xiaomi.ugd=com.xiaomi.ugd
NQNfcNci=com.android.nfc
MIUIGuardProvider=com.miui.guardprovider
SogouIME=com.sohu.inputmethod.sogou.xiaomi
iFlytekIME=com.iflytek.inputmethod.miui
CellBroadcastServiceModulePlatform=com.android.cellbroadcastservice
MINextpay=com.miui.nextpay
MITSMClient=com.miui.tsmclient
PaymentService=com.xiaomi.payment
MIUISuperMarket_M2_M3=com.xiaomi.market
MIShare=com.miui.mishare.connectivity
ContentCatcherOS3_1=com.miui.contentcatcher
MIUIYellowPage=com.miui.yellowpage
MIGalleryLockscreen=
MIUIMiDrive=
MIUIMusicT=
MiBugReportOS3=com.miui.bugreport
hybrid=
greenguard=
RideModeAudio=com.qualcomm.qti.ridemodeaudio
ThirdAppAssistant=com.miui.thirdappassistant
digitalkey=com.xiaomi.digitalkey
MIUITouchAssistant=com.miui.touchassistant
Stk=com.android.stk
CarrierDefaultApp=com.android.carrierdefaultapp
CallLogBackup=com.android.calllogbackup
ConfigUpdater=
CatchLog=com.bsp.catchlog
TouchService=com.xiaomi.touchservice
"

# 根据 REPLACE 路径获取包名
get_pkg_name() {
  local folder=$(basename "$1")
  local line
  for line in $PKG_MAP; do
    case "$line" in
      "$folder="*) echo "${line#*=}" ; return ;;
    esac
  done
  echo ""
}
