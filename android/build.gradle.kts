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

// Fix for "different roots" error by disabling unit tests for plugins
subprojects {
    tasks.configureEach {
        if (name.contains("UnitTest")) {
            enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
