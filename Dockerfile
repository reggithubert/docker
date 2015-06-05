FROM jenkins
# deploy a jenkins to build android sample https://github.com/googlesamples/android-TextLinkify
MAINTAINER regly

# update to be able to run aapt under jenkins
USER root
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y lib32z1 libstdc++6:i386

# install necessary plugins under jenkins
RUN mkdir -p /usr/share/jenkins/ref/plugins
ADD https://updates.jenkins-ci.org/download/plugins/scm-api/latest/scm-api.hpi /usr/share/jenkins/ref/plugins/scm-api.hpi
ADD https://updates.jenkins-ci.org/download/plugins/git-client/latest/git-client.hpi /usr/share/jenkins/ref/plugins/git-client.hpi
ADD https://updates.jenkins-ci.org/download/plugins/git/latest/git.hpi /usr/share/jenkins/ref/plugins/git.hpi
ADD https://updates.jenkins-ci.org/download/plugins/credentials/latest/credentials.hpi /usr/share/jenkins/ref/plugins/credentials.hpi
ADD https://updates.jenkins-ci.org/download/plugins/ssh-credentials/latest/ssh-credentials.hpi /usr/share/jenkins/ref/plugins/ssh-credentials.hpi
ADD https://updates.jenkins-ci.org/download/plugins/gradle/latest/gradle.hpi /usr/share/jenkins/ref/plugins/gradle.hpi
ADD https://updates.jenkins-ci.org/download/plugins/windows-azure-storage/latest/windows-azure-storage.hpi /usr/share/jenkins/ref/plugins/windows-azure-storage.hpi

RUN mkdir -p /usr/share/jenkins/android
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/android

USER jenkins
# Install Android SDK
RUN cd /usr/share/jenkins/android && wget -nv -O - http://dl.google.com/android/android-sdk_r24.1.2-linux.tgz | tar --no-same-permissions --no-same-owner -xvzf - && chmod -R a+rX android-sdk-linux

ENV ANDROID_HOME /usr/share/jenkins/android/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Install Android SDK components
ENV ANDROID_SDK_COMPONENTS platform-tools,build-tools-22.0.1,android-22,extra-android-m2repository,extra-google-m2repository
RUN echo y | /usr/share/jenkins/android/android-sdk-linux/tools/android update sdk --no-ui --all --filter "${ANDROID_SDK_COMPONENTS}"

USER root
RUN chown -R jenkins /usr/share/jenkins/ref/plugins
