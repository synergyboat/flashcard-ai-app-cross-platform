// plugins/benchmark-native.plugin.cjs
// CommonJS plugin; Expo loads via require()
const {
  withPlugins,
  withMainApplication,
  withAppBuildGradle,
} = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

/* =========================
 * ANDROID: MainApplication
 * =========================
 * - No extra package/namespace.
 * - Works for Java OR Kotlin MainApplication.
 * - Uses config.android.package if present, else fallback.
 */
function withAndroidMainApplication(config) {
  const appId = (config.android && config.android.package) || 'com.anonymous.flashcardaiapp';

  return withMainApplication(config, (mod) => {
    let src = mod.modResults.contents || '';
    const filePath = mod.modResults.filePath || '';

    const isKotlin =
      /\.kt$/.test(filePath) || /class\s+MainApplication\s*:\s*Application\b/.test(src);

    const importLine = isKotlin
      ? `import ${appId}.BenchmarkPackage`
      : `import ${appId}.BenchmarkPackage;`;

    const addLine = isKotlin
      ? `packages.add(BenchmarkPackage())`
      : `packages.add(new BenchmarkPackage());`;

    // Insert import after the package declaration
    if (!src.includes(importLine)) {
      src = src.replace(/^package[^\n]*\n/, (m) => m + importLine + '\n');
    }

    // Insert registration (Java or Kotlin patterns)
    if (!src.includes(addLine)) {
      let replaced = false;

      // Java: new PackageList(this).getPackages();
      const javaPattern = /new\s+PackageList\(this\)\.getPackages\(\)\s*;/;
      if (javaPattern.test(src)) {
        src = src.replace(javaPattern, (m) => `${m}\n    ${addLine}`);
        replaced = true;
      }

      // Kotlin: PackageList(this).packages
      if (!replaced) {
        const ktAssignPattern = /PackageList\(this\)\.packages[^\n]*\n/;
        if (ktAssignPattern.test(src)) {
          src = src.replace(ktAssignPattern, (m) => `${m}    ${addLine}\n`);
          replaced = true;
        }
      }

      // Fallback: before "return packages"
      if (!replaced) {
        const returnPackages = /\breturn\s+packages\s*;/;
        if (returnPackages.test(src)) {
          src = src.replace(returnPackages, `${addLine};\n    return packages;`);
        }
      }
    }

    mod.modResults.contents = src;
    return mod;
  });
}

/* =========================================
 * ANDROID (optional): keep rules for release
 * ========================================= */
function withAndroidKeepRules(config) {
  const appId = (config.android && config.android.package) || 'com.anonymous.flashcardaiapp';
  return withAppBuildGradle(config, (mod) => {
    try {
      const proguardPath = path.join(
        mod.modRequest.platformProjectRoot,
        'app',
        'proguard-rules.pro'
      );
      const keep = `\n-keep class ${appId}.** { *; }\n`;
      if (fs.existsSync(proguardPath)) {
        const cur = fs.readFileSync(proguardPath, 'utf8');
        if (!cur.includes(`${appId}.`)) {
          fs.writeFileSync(proguardPath, cur + keep);
        }
      }
    } catch {
      // best-effort; ignore
    }
    return mod;
  });
}

/* ======================
 * Combined export
 * ====================== */
function withBenchmarkNative(config) {
  return withPlugins(config, [withAndroidMainApplication, withAndroidKeepRules]);
}

module.exports = withBenchmarkNative;