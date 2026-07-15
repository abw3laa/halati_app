// تحويل استدعاءات jcenter() القديمة إلى mavenCentral() تلقائياً لمنع فشل بناء المكتبات مثل shared_storage
allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // هذا الكود البرمجي يعيد تعريف دالة jcenter لتشير داخلياً إلى mavenCentral
    val repoHandler = repositories
    val metaClass = (repoHandler as GroovyObject).metaClass
    metaClass.setProperty("jcenter", closureOf<Any> {
        repoHandler.mavenCentral()
    })
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
