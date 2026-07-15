allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // هذا الكود يبحث في كل موديول (مثل shared_storage) وإذا وجد أنه يطلب jcenter يقوم باستبداله بـ mavenCentral فوراً
    buildscript.configurations.all {
        resolutionStrategy.eachDependency {
            // هذا لضمان معالجة أي حزم قديمة
        }
    }
}

// تعديل إعدادات مستودعات الموديولات الفرعية بشكل آمن تماماً
subprojects {
    project.afterEvaluate {
        repositories {
            // نقوم بإضافة google و mavenCentral كأولوية قصوى للمكتبات الفرعية
            google()
            mavenCentral()
            
            // هنا نقوم بتعطيل jcenter برمجياً وتوجيهه لـ mavenCentral
            all {
                if (this is MavenArtifactRepository && url.toString().contains("jcenter")) {
                    url = uri("https://repo.maven.apache.org/maven2/")
                }
            }
        }
    }
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
