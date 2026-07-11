allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

/*subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val androidExt = extensions.getByName("android")
            try {
                androidExt::class.java.getMethod("setCompileSdkVersion", Int::class.java).invoke(androidExt, 36)
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
}*/
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
