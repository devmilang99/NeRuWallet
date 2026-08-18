allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

subprojects {
    val projectRoot = project.projectDir.toPath().root
    val buildRoot = newBuildDir.asFile.toPath().root

    // Only relocate build directory if project and build dir are on the same drive
    if (projectRoot == buildRoot) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Force SDK versions to 37 to support modern plugins while targeting SDK 35
subprojects {
    val applySdkFix = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android")
            try {
                // Set compileSdk
                android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    .invoke(android, 37)

                // Set targetSdk in defaultConfig
                val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                defaultConfig.javaClass.getMethod("setTargetSdk", Int::class.javaPrimitiveType)
                    .invoke(defaultConfig, 35)
            } catch (e: Exception) {
                // If setCompileSdk/setTargetSdk doesn't exist (older AGP), try older methods
                try {
                    android.javaClass.getMethod(
                        "setCompileSdkVersion",
                        Int::class.javaPrimitiveType
                    )
                        .invoke(android, 37)
                } catch (e2: Exception) {
                }
            }
        }
    }
    if (project.state.executed) {
        applySdkFix()
    } else {
        project.afterEvaluate { applySdkFix() }
    }
}

// Fix for plugins missing 'namespace' in AGP 8.0+
subprojects {
    val applyNamespaceFix = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android")
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    val fallbackNamespace = when (project.name) {
                        "flutter_jailbreak_detection" -> "appmire.be.flutterjailbreakdetection"
                        "safe_device" -> "com.xamdesign.safe_device"
                        "http_certificate_pinning" -> "diefferson.http_certificate_pinning"
                        else -> "com.example.neruwallet.autons." + project.name.replace("-", "_")
                    }
                    setNamespace.invoke(android, fallbackNamespace)
                }
            } catch (e: Exception) {
                // Fallback for older AGP or unexpected structures
            }
        }
    }
    if (project.state.executed) {
        applyNamespaceFix()
    } else {
        project.afterEvaluate { applyNamespaceFix() }
    }
}

// Fix for "different roots" error by disabling unit tests for plugins
subprojects {
    tasks.configureEach {
        if (name.contains("UnitTest")) {
            enabled = false
        }
    }
}

// Force consistent JVM target across all subprojects
subprojects {
    val applyJvmFix = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android")
            try {
                // Java compilation target
                val compileOptions =
                    android.javaClass.getMethod("getCompileOptions").invoke(android)
                compileOptions.javaClass.getMethod(
                    "setSourceCompatibility",
                    JavaVersion::class.java
                ).invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass.getMethod(
                    "setTargetCompatibility",
                    JavaVersion::class.java
                ).invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (e: Exception) {
            }
        }

        // Kotlin compilation target
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }

    if (project.state.executed) {
        applyJvmFix()
    } else {
        project.afterEvaluate { applyJvmFix() }
    }

    configurations.all {
        resolutionStrategy.dependencySubstitution {
            substitute(module("com.github.scottyab:rootbeer")).using(module("com.scottyab:rootbeer-lib:0.1.1"))
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
