default:
  @just --list

run *args:
  gradle run {{args}}

test *args:
  gradle test {{args}}

lock:
  gradle2nix

init:
  #!/usr/bin/env bash
  set -euo pipefail
  read -ep "Project name: " name
  read -ep "Package: " package

  sed -i "s/CS2020-java-template/$name/" settings.gradle.kts flake.nix
  package_dir=$(echo $package | tr . /)
  mkdir -p src/{main,test}/java/$package_dir
  mv src/main/java/{net/soroos/ben/template,$package_dir}/App.java
  mv src/test/java/{net/soroos/ben/template,$package_dir}/AppTest.java

  find src/ -name '*.java' | xargs sed -i "s/net\.soroos\.ben\.template/$package/"

  mkdir -p .settings
  # For proper LSP support - jdtls doesn't pick up the right JDK for some reason
  # If only java.home is set, the file is overwritten
  # Since JAVA_HOME varies platform-to-platform, we don't want to commit this
  cat > .settings/org.eclipse.buildship.core.prefs <<EOF
  arguments=
  auto.sync=false
  build.scans.enabled=false
  connection.gradle.distribution=GRADLE_DISTRIBUTION(WRAPPER)
  connection.project.dir=
  eclipse.preferences.version=1
  gradle.user.home=
  java.home=$JAVA_HOME
  jvm.arguments=
  offline.mode=false
  override.workspace.settings=true
  show.console.view=true
  show.executions.view=true
  EOF
