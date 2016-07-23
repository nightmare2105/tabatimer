# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-tabatimer

CONFIG += sailfishapp
QT += dbus
QT += multimedia

SOURCES += src/harbour-tabatimer.cpp \
    src/tabata.cpp

OTHER_FILES += qml/harbour-tabatimer.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-tabatimer.spec \
    rpm/harbour-tabatimer.yaml \
    harbour-tabatimer.desktop \
    qml/pages/Settings.qml \
    qml/pages/TimePickerSeconds.qml \
    qml/pages/TimePickerSeconds.png \
    qml/pages/TimeDialog.qml \
    qml/pages/Ding.wav \
    qml/pages/Profiles.qml \
    qml/pages/ProfileSettings.qml

HEADERS += \
    src/tabata.h

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
