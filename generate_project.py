from pathlib import Path
import hashlib
root=Path(__file__).parent
uid=lambda x:hashlib.sha1(x.encode()).hexdigest()[:24].upper()
objects=[]
audio_files=sorted((root/'MeowPaw/Audio').glob('cat-*.wav'))
def add(name,body):
 objects.append(uid(name)+' = { '+body+' };')
def arr(values):return '('+','.join(uid(x) for x in values)+')'
add('assets','isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>";')
add('assetsbuild','isa = PBXBuildFile; fileRef = '+uid('assets')+';')
targets=['MeowPaw','MeowPawTests','MeowPawUITests']
files={'MeowPaw':['MeowPawApp.swift','PlaybackController.swift','ContentView.swift'],'MeowPawTests':['PlaybackTests.swift'],'MeowPawUITests':['InterfaceTests.swift']}
for p in audio_files:
 add('audio/'+p.name,'isa = PBXFileReference; lastKnownFileType = audio.wav; path = '+p.name+'; sourceTree = "<group>";')
 add('audio/'+p.name+'build','isa = PBXBuildFile; fileRef = '+uid('audio/'+p.name)+';')
add('AudioGroup','isa = PBXGroup; path = Audio; sourceTree = "<group>"; children = '+arr('audio/'+p.name for p in audio_files)+';')
for t in targets:
 for f in files[t]:
  key=t+'/'+f
  add(key,'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = '+f+'; sourceTree = "<group>";')
  add(key+'build','isa = PBXBuildFile; fileRef = '+uid(key)+';')
 add(t+'group','isa = PBXGroup; path = '+t+'; sourceTree = "<group>"; children = '+arr([t+'/'+f for f in files[t]]+(['AudioGroup','assets'] if t=='MeowPaw' else []))+';')
 isapp=t=='MeowPaw'; ext='app' if isapp else 'xctest'; typ='application' if isapp else ('bundle.unit-test' if t=='MeowPawTests' else 'bundle.ui-testing')
 add(t+'product','isa = PBXFileReference; explicitFileType = wrapper.'+('application' if isapp else 'cfbundle')+'; path = '+t+'.'+ext+'; sourceTree = BUILT_PRODUCTS_DIR;')
 add(t+'sources','isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = '+arr(t+'/'+f+'build' for f in files[t])+'; runOnlyForDeploymentPostprocessing = 0;')
 add(t+'frameworks','isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
 add(t+'resources','isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = '+arr((['audio/'+p.name+'build' for p in audio_files]+['assetsbuild']) if t=='MeowPaw' else [])+'; runOnlyForDeploymentPostprocessing = 0;')
 deps=[]
 if not isapp:
  add(t+'proxy','isa = PBXContainerItemProxy; containerPortal = '+uid('project')+'; proxyType = 1; remoteGlobalIDString = '+uid('MeowPawtarget')+'; remoteInfo = MeowPaw;')
  add(t+'dependency','isa = PBXTargetDependency; target = '+uid('MeowPawtarget')+'; targetProxy = '+uid(t+'proxy')+';')
  deps=[t+'dependency']
 add(t+'target','isa = PBXNativeTarget; buildConfigurationList = '+uid(t+'configs')+'; buildPhases = '+arr(t+v for v in ['sources','frameworks','resources'])+'; buildRules = (); dependencies = '+arr(deps)+'; name = '+t+'; productName = '+t+'; productReference = '+uid(t+'product')+'; productType = "com.apple.product-type.'+typ+'";')
 for mode in ['Debug','Release']:
  extra=''
  if isapp: extra='ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; INFOPLIST_KEY_CFBundleDisplayName = "喵喵喵"; INFOPLIST_KEY_UILaunchScreen_Generation = YES; INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES; INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";'
  elif t=='MeowPawTests':extra='BUNDLE_LOADER = "$(TEST_HOST)"; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MeowPaw.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MeowPaw";'
  else:extra='TEST_TARGET_NAME = MeowPaw;'
  add(t+mode,'isa = XCBuildConfiguration; name = '+mode+'; buildSettings = { CODE_SIGNING_ALLOWED = NO; GENERATE_INFOPLIST_FILE = YES; PRODUCT_BUNDLE_IDENTIFIER = "com.tinyworm.meowpaw'+('' if isapp else '.'+t)+'"; PRODUCT_NAME = "$(TARGET_NAME)"; TARGETED_DEVICE_FAMILY = 1; IPHONEOS_DEPLOYMENT_TARGET = 17.0; SWIFT_VERSION = 5.0; SWIFT_EMIT_LOC_STRINGS = YES; '+extra+' };')
 add(t+'configs','isa = XCConfigurationList; buildConfigurations = '+arr(t+m for m in ['Debug','Release'])+'; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
for mode in ['Debug','Release']:
 add('project'+mode,'isa = XCBuildConfiguration; name = '+mode+'; buildSettings = { SDKROOT = iphoneos; CLANG_ENABLE_MODULES = YES; SWIFT_OPTIMIZATION_LEVEL = "'+('-Onone' if mode=='Debug' else '-O')+'"; DEBUG_INFORMATION_FORMAT = dwarf; ENABLE_TESTABILITY = YES; };')
add('projectconfigs','isa = XCConfigurationList; buildConfigurations = '+arr('project'+m for m in ['Debug','Release'])+'; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
add('products','isa = PBXGroup; name = Products; sourceTree = "<group>"; children = '+arr(t+'product' for t in targets)+';')
add('root','isa = PBXGroup; sourceTree = "<group>"; children = '+arr([t+'group' for t in targets]+['products'])+';')
attrs=' '.join(uid(t+'target')+' = { CreatedOnToolsVersion = 27.0; '+('TestTargetID = '+uid('MeowPawtarget')+';' if t!='MeowPaw' else '')+' };' for t in targets)
add('project','isa = PBXProject; attributes = { BuildIndependentTargetsInParallel = YES; LastUpgradeCheck = 2700; TargetAttributes = {'+attrs+'}; }; buildConfigurationList = '+uid('projectconfigs')+'; compatibilityVersion = "Xcode 14.0"; developmentRegion = zh-Hans; knownRegions = ("zh-Hans",en,Base); mainGroup = '+uid('root')+'; productRefGroup = '+uid('products')+'; projectDirPath = ""; projectRoot = ""; targets = '+arr(t+'target' for t in targets)+';')
(root/'MeowPaw.xcodeproj/project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(objects)+'\n}; rootObject = '+uid('project')+'; }\n')
ref=lambda t:'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="'+uid(t+'target')+'" BuildableName="'+t+('.app' if t=='MeowPaw' else '.xctest')+'" BlueprintName="'+t+'" ReferencedContainer="container:MeowPaw.xcodeproj"/>'
scheme='<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="2700" version="1.3"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">'+ref('MeowPaw')+'</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" shouldUseLaunchSchemeArgsEnv="YES"><Testables>'+''.join('<TestableReference skipped="NO" parallelizable="NO">'+ref(t)+'</TestableReference>' for t in targets[1:])+'</Testables></TestAction><LaunchAction buildConfiguration="Debug" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">'+ref('MeowPaw')+'</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES"><BuildableProductRunnable runnableDebuggingMode="0">'+ref('MeowPaw')+'</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>'
(root/'MeowPaw.xcodeproj/xcshareddata/xcschemes/MeowPaw.xcscheme').write_text(scheme)
