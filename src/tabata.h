#ifndef TABATA_H
#define TABATA_H

#include <QObject>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QTime>
#include <QTimer>
#include <QQmlEngine>
#include <QSettings>
#include <QString>
#include <QtMultimedia/QMediaPlayer>
#include <QtMultimedia/QMediaPlaylist>
#include <QtMultimedia/QSoundEffect>

#include <sailfishapp.h>

#include <QtQml>


class Tabata : public QObject
{
    Q_OBJECT
    Q_ENUMS(TabaStates)
public:
    enum TabaStates {tabaStop=0,tabaStartUp=1,tabaInt1=2,tabaInt2=3};
private:
    QTimer *t_timer;
    int i_round;
    int i_time;

    TabaStates i_state;

    QSettings *setting;
    QDBusMessage dbm_blankpause_start;
    QDBusMessage dbm_blankpause_cancel;
    
    QSoundEffect soundeffect;

    const static int maxProfiles=10;
    bool warnSleep;
    int profileActive;
    int profileDefault;
    int profileFav1;
    int profileFav2;
    struct TabaProfile {
        QTime timeStart;
        QTime timeInt1;
        QTime timeInt2;
        int intervals;
        bool mute;
        bool preventSleep;
        QString text;
    } profiles[10];

     bool checkProfileID(int &profileid,bool overwrite=false);
     bool checkState(TabaStates state);
     bool checkState(TabaStates &state,bool overwrite);

    void tabataDing(void);
    int calcSeconds(int secs, int mins, int hours=0);
    int calcSeconds(QTime *timeObj);
public:
    explicit Tabata(QObject *parent = 0);
    ~Tabata();
    static void declareQML() {
        qmlRegisterType<Tabata>("harbour.tabatimer.tabata", 1, 0, "Tabata");
    }

    Q_INVOKABLE int getSecondsLeft(void);
    Q_INVOKABLE int getMinutesLeft(void);
    Q_INVOKABLE int getHoursLeft(void);
    Q_INVOKABLE int getAllSecondsLeft(void);
    Q_INVOKABLE int getIntervalCurrent(void);
    Q_INVOKABLE int getIntervalLeft(void);

    Q_INVOKABLE int start();
    Q_INVOKABLE int stop(void);
    Q_INVOKABLE TabaStates getState(void);

    Q_INVOKABLE int setSettings(int defaultProfile, bool warnSleepPower);
    Q_INVOKABLE int setProfile(int time1, int time2,int timeStart, int rounds, bool mute, bool preventSleep, QString text,bool save=false, int profileId=-1);

    Q_INVOKABLE bool getProfileMute(int profileid=-1);
    Q_INVOKABLE bool getProfilePreventSleep(int profileid=-1);
    Q_INVOKABLE int getProfileSeconds(TabaStates timerid, int profileid=-1);
    Q_INVOKABLE int getProfileMinutes(TabaStates timerid, int profileid=-1);
    Q_INVOKABLE int getProfileHours(TabaStates timerid, int profileid=-1);
    Q_INVOKABLE int getProfileAllSeconds(TabaStates timerid, int profileid=-1);
    Q_INVOKABLE int getProfileIntervals(int profileid=-1);
    Q_INVOKABLE QString getProfileText(int profileid=-1);
    Q_INVOKABLE int getActiveProfile(void);
    Q_INVOKABLE int setActiveProfile(int profile);
    Q_INVOKABLE int setFavProfile(int number,int profile);
    Q_INVOKABLE int getFavProfile(int number);
    Q_INVOKABLE int getDefaultProfile(void);
    Q_INVOKABLE int getProfileNumber(void);
    Q_INVOKABLE bool getWarnSleepPower(void);

    Q_INVOKABLE float getTimePercent(void);
    Q_INVOKABLE float getRoundPercent(void);

    Q_INVOKABLE int valStateInt1();
    Q_INVOKABLE int valStateInt2();
    Q_INVOKABLE int valStateStartUp();
    Q_INVOKABLE int valStateStop();

signals:
    void tabataChanged(void);
    void tabataLoaded(void);
public slots:
    int next(void);
    int loadSettings(void);
};


//static QObject *tabata_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
//{
//    Q_UNUSED(engine)
//    Q_UNUSED(scriptEngine)

//    Tabata *tabata = new Tabata();
//    return tabata;
//}


#endif // TABATA_H
