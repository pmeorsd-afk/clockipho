// Generate standard PBXProject for ShabbatAlarm iOS App
const fs = require('fs');
const path = require('path');

const files = [
  { name: 'ShabbatAlarmApp.swift', path: 'ShabbatAlarm/ShabbatAlarmApp.swift', isSource: true },
  { name: 'AlarmItem.swift', path: 'ShabbatAlarm/Models/AlarmItem.swift', isSource: true },
  { name: 'AlarmStore.swift', path: 'ShabbatAlarm/Models/AlarmStore.swift', isSource: true },
  { name: 'SoundPlayerService.swift', path: 'ShabbatAlarm/Services/SoundPlayerService.swift', isSource: true },
  { name: 'AlarmScheduler.swift', path: 'ShabbatAlarm/Services/AlarmScheduler.swift', isSource: true },
  { name: 'AlarmListView.swift', path: 'ShabbatAlarm/Views/AlarmListView.swift', isSource: true },
  { name: 'AlarmEditView.swift', path: 'ShabbatAlarm/Views/AlarmEditView.swift', isSource: true },
  { name: 'ShabbatNightstandView.swift', path: 'ShabbatAlarm/Views/ShabbatNightstandView.swift', isSource: true },
  { name: 'SettingsView.swift', path: 'ShabbatAlarm/Views/SettingsView.swift', isSource: true },
  { name: 'Info.plist', path: 'ShabbatAlarm/Resources/Info.plist', isSource: false, isPlist: true }
];

function makeId(prefix, index) {
  return `${prefix}${index.toString(16).padStart(4, '0')}000000000000`.toUpperCase().slice(0, 24);
}

const projId = '000000010000000000000001';
const targetId = '000000020000000000000002';
const mainGroupId = '000000030000000000000003';
const sourcesBuildPhaseId = '000000040000000000000004';
const frameworksBuildPhaseId = '000000050000000000000005';
const resourcesBuildPhaseId = '000000060000000000000006';
const productFileRefId = '000000070000000000000007';
const projConfigListId = '000000080000000000000008';
const targetConfigListId = '000000090000000000000009';
const projDebugConfigId = '0000000A000000000000000A';
const projReleaseConfigId = '0000000B000000000000000B';
const targetDebugConfigId = '0000000C000000000000000C';
const targetReleaseConfigId = '0000000D000000000000000D';

files.forEach((f, idx) => {
  f.fileRefId = makeId('1000', idx);
  f.buildFileId = makeId('2000', idx);
});

let pbx = `// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
`;

files.filter(f => f.isSource).forEach(f => {
  pbx += `\t\t${f.buildFileId} /* ${f.name} in Sources */ = {isa = PBXBuildFile; fileRef = ${f.fileRefId} /* ${f.name} */; };\n`;
});

pbx += `/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\t\t${productFileRefId} /* ShabbatAlarm.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ShabbatAlarm.app; sourceTree = BUILT_PRODUCTS_DIR; };
`;

files.forEach(f => {
  const type = f.name.endsWith('.swift') ? 'sourcecode.swift' : 'text.plist.xml';
  pbx += `\t\t${f.fileRefId} /* ${f.name} */ = {isa = PBXFileReference; lastKnownFileType = ${type}; path = "${f.path}"; sourceTree = "<group>"; };\n`;
});

pbx += `/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t${frameworksBuildPhaseId} /* Frameworks */ = {
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t${mainGroupId} = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
`;

files.forEach(f => {
  pbx += `\t\t\t\t${f.fileRefId} /* ${f.name} */,\n`;
});

pbx += `\t\t\t\t${productFileRefId} /* ShabbatAlarm.app */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t${targetId} /* ShabbatAlarm */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = ${targetConfigListId} /* Build configuration list for PBXNativeTarget "ShabbatAlarm" */;
\t\t\tbuildPhases = (
\t\t\t\t${sourcesBuildPhaseId} /* Sources */,
\t\t\t\t${frameworksBuildPhaseId} /* Frameworks */,
\t\t\t\t${resourcesBuildPhaseId} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = ShabbatAlarm;
\t\t\tproductName = ShabbatAlarm;
\t\t\tproductReference = ${productFileRefId} /* ShabbatAlarm.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t${projId} /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tattributes = {
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {
\t\t\t\t\t${targetId} = {
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t};
\t\t\t\t};
\t\t\t};
\t\t\tbuildConfigurationList = ${projConfigListId} /* Build configuration list for PBXProject "ShabbatAlarm" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = he;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\the,
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = ${mainGroupId};
\t\t\tproductRefGroup = ${mainGroupId};
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t${targetId} /* ShabbatAlarm */,
\t\t\t);
\t\t};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t${resourcesBuildPhaseId} /* Resources */ = {
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t${sourcesBuildPhaseId} /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
`;

files.filter(f => f.isSource).forEach(f => {
  pbx += `\t\t\t\t${f.buildFileId} /* ${f.name} in Sources */,\n`;
});

pbx += `\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t${projDebugConfigId} /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t${projReleaseConfigId} /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\t${targetDebugConfigId} /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = ShabbatAlarm/Resources/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.orellugasi.shabbatalarm;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t${targetReleaseConfigId} /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = ShabbatAlarm/Resources/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.orellugasi.shabbatalarm;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t};
\t\t\tname = Release;
\t\t};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t${projConfigListId} /* Build configuration list for PBXProject "ShabbatAlarm" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t${projDebugConfigId} /* Debug */,
\t\t\t\t${projReleaseConfigId} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
\t\t${targetConfigListId} /* Build configuration list for PBXNativeTarget "ShabbatAlarm" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t${targetDebugConfigId} /* Debug */,
\t\t\t\t${targetReleaseConfigId} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
/* End XCConfigurationList section */

\t};
\trootObject = ${projId} /* Project object */;
}
`;

const outputPath = path.join(__dirname, 'ShabbatAlarm.xcodeproj', 'project.pbxproj');
fs.writeFileSync(outputPath, pbx, 'utf8');
console.log('Successfully wrote project.pbxproj to ' + outputPath);
