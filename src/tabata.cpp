#include "tabata.h"



Tabata::Tabata(QObject *parent) :
    QObject(parent)
{
    setting=new QSettings("harbour-tabatimer","harbour-tabatimer");
    t_timer= new QTimer(this);
    connect(t_timer,SIGNAL(timeout()), this, SLOT(next()));

    mediaPlayer=new QMediaPlayer();
    playList=new QMediaPlaylist();
    playList->addMedia(SailfishApp::pathTo("qml/pages/ding.mp3"));
    mediaPlayer->setPlaylist(playList);

    t_timer->setInterval(1000);
    t_timer->stop();
    i_round=0;
    i_time=0;
    i_state=tabaStop;

    dbm_blankpause_start = QDBusMessage::createMethodCall("com.nokia.mce",
                                                          "/com/nokia/mce/request",
                                                          "com.nokia.mce.request",
                                                          "req_display_blanking_pause");

    dbm_blankpause_cancel = QDBusMessage::createMethodCall("com.nokia.mce",
                                                           "/com/nokia/mce/request",
                                                           "com.nokia.mce.request",
                                                           "req_display_cancel_blanking_pause");

    //ini default values, loading settings from file fails here-> do it later; reason ?
    for(int i=0;i<maxProfiles;i++){
        profiles[i].timeInt1.setHMS(0,0,0);
        profiles[i].timeInt1=profiles[i].timeInt1.addSecs(20);
        profiles[i].timeInt2.setHMS(0,0,0);
        profiles[i].timeInt2=profiles[i].timeInt2.addSecs(10);
        profiles[i].timeStart.setHMS(0,0,0);
        profiles[i].timeStart=profiles[i].timeStart.addSecs(5);

        profiles[i].mute=false;
        profiles[i].preventSleep=true;
        profiles[i].text="Tabata";
        profiles[i].intervals=8;
    }
    profileActive=0;
    profileDefault=0;

    QTimer::singleShot(50,this,SLOT(loadSettings()));
}

Tabata::~Tabata(){
    QDBusConnection::systemBus().send(dbm_blankpause_cancel);
}

//start timer
Q_INVOKABLE int Tabata::start(){
    if(t_timer->isActive()){
        this->stop();
        return 1;
    }

    this->i_round=0;
    this->i_time=0;
    this->i_state=tabaStartUp;
    this->t_timer->start();
    if(profiles[profileActive].preventSleep){
        QDBusConnection::systemBus().send(dbm_blankpause_start);
    }
    emit tabataChanged();
    return 0;
}

//stop timer
Q_INVOKABLE int Tabata::stop(){
    this->t_timer->stop();
    i_round=0;
    i_time=0;
    i_state=tabaStop;
    if(profiles[profileActive].preventSleep){
        QDBusConnection::systemBus().send(dbm_blankpause_cancel);
    }
    emit tabataChanged();
    return 0;
}

//next second
Q_INVOKABLE int Tabata::next(void){

    if(profiles[profileActive].preventSleep){
        QDBusConnection::systemBus().send(dbm_blankpause_start);
    }
    int i_end=getProfileAllSeconds(i_state,profileActive);
    i_time++;
    if(i_time>=(i_end-1)){
        emit tabataDing();
    }
    if(i_time>=i_end){
        i_time=0;

        switch(i_state){
        case tabaStartUp: i_state=tabaInt1; break;
        case tabaInt1: i_state=tabaInt2; break;
        case tabaInt2: {i_state=tabaInt1; i_round++;} break;
        default: break;
        }
    }

    if(i_round>=getProfileIntervals(profileActive)){
        stop();
        emit tabataDing();
    }

    emit tabataChanged();
    return 0;

}


//return current interval
Q_INVOKABLE int Tabata::getIntervalCurrent(){

    if(t_timer->isActive()==false)
        return 0;
    return i_round;
}

//return intervals left
Q_INVOKABLE int Tabata::getIntervalLeft(){

    if(t_timer->isActive()==false)
        return profiles[profileActive].intervals;
    return profiles[profileActive].intervals-i_round;
}

Q_INVOKABLE int Tabata::getAllSecondsLeft(){

    if(t_timer->isActive()==false){
        return getProfileAllSeconds(tabaStartUp, profileActive);
    }

    return getProfileAllSeconds(i_state,profileActive)-i_time;
}

//saves settings to ram and file if requested
Q_INVOKABLE int Tabata::setSettings(int defaultProfile, bool warnSleepPower){

    if(checkProfileID(defaultProfile))
        profileDefault=defaultProfile;
    warnSleep=warnSleepPower;

    setting->setValue("warnSleep",warnSleep);
    setting->setValue("profileDefault",profileDefault);
    setting->sync();
    emit tabataChanged();
    return 0;
}

Q_INVOKABLE int Tabata::setProfile(int time1, int time2,int timeStart, int rounds, bool mute, bool preventSleep, QString text,bool save, int profileId){

    checkProfileID(profileId,true);

    if(time1==0)
        time1++;
    if(time2==0)
        time2++;
    if(timeStart==0)
        timeStart++;

    profiles[profileId].intervals=rounds;
    profiles[profileId].mute=mute;
    profiles[profileId].preventSleep=preventSleep;
    profiles[profileId].text=text;

    profiles[profileId].timeInt1.setHMS(0,0,0);
    profiles[profileId].timeInt1=profiles[profileId].timeInt1.addSecs(time1);
    profiles[profileId].timeInt2.setHMS(0,0,0);
    profiles[profileId].timeInt2=profiles[profileId].timeInt2.addSecs(time2);
    profiles[profileId].timeStart.setHMS(0,0,0);
    profiles[profileId].timeStart=profiles[profileId].timeStart.addSecs(timeStart);

    if(save){
        setting->beginGroup("Profile"+QString::number(profileId));
        setting->setValue("mute",profiles[profileId].mute);
        setting->setValue("intervals",profiles[profileId].intervals);
        setting->setValue("preventSleep",profiles[profileId].preventSleep);
        setting->setValue("text",profiles[profileId].text);

        int itemp=calcSeconds(&(profiles[profileId].timeInt1));
        setting->setValue("timeInt1",itemp);
        itemp=calcSeconds(&(profiles[profileId].timeInt2));
        setting->setValue("timeInt2",itemp);
        itemp=calcSeconds(&(profiles[profileId].timeStart));
        setting->setValue("timeStart",itemp);

        setting->endGroup();
        setting->sync();

    }
    emit tabataChanged();
    return 0;
}

Q_INVOKABLE bool Tabata::getProfileMute(int profileid){ //returns mutesetting
    checkProfileID(profileid,true);
    return profiles[profileid].mute;
}

Q_INVOKABLE bool Tabata::getProfilePreventSleep(int profileid){ //returns setting Prevent Sleepmode?
    checkProfileID(profileid,true);
    return profiles[profileid].preventSleep;
}


Q_INVOKABLE Tabata::TabaStates Tabata::getState(void){ //return 0 on stopped, 1 on first timerinterval active, 2 on second, 3 on startup
    if (t_timer->isActive()){
        return i_state;
    }
    else{
        return tabaStop;
    }
}

Q_INVOKABLE int Tabata::loadSettings(void){ //load Settings from file
    int retval=0;
    if(!setting->contains("version")){
        setting->clear();
        setting->setValue("version","1.3");
    }
    else
    {
        warnSleep=setting->value("warnSleep",true).toBool();
        profileDefault=setting->value("profileDefault",0).toInt();
        profileActive=profileDefault;

        profileFav1=setting->value("profileFav1",0).toInt();
        profileFav2=setting->value("profileFav2",0).toInt();

        for(int i=0; i<maxProfiles; i++){
            setting->beginGroup("Profile"+QString::number(i));
            profiles[i].mute=setting->value("mute",false).toBool();
            profiles[i].preventSleep=setting->value("preventSleep",true).toBool();
            profiles[i].intervals=setting->value("intervals",8).toInt();
            profiles[i].text=setting->value("text","Tabata").toString();
            profiles[i].timeStart.setHMS(0,0,0);
            profiles[i].timeStart=profiles[i].timeStart.addSecs(setting->value("timeStart",5).toInt());
            profiles[i].timeInt1.setHMS(0,0,0);
            profiles[i].timeInt1=profiles[i].timeInt1.addSecs(setting->value("timeInt1",20).toInt());
            profiles[i].timeInt2.setHMS(0,0,0);
            profiles[i].timeInt2=profiles[i].timeInt2.addSecs(setting->value("timeInt2",10).toInt());
            setting->endGroup();
        }
    }
    emit tabataChanged();
    emit tabataLoaded();
    return retval;
}

Q_INVOKABLE float Tabata::getRoundPercent(void){

    if(getState())
        return ((float(i_round))/profiles[profileActive].intervals);
    return 0;
}

Q_INVOKABLE float Tabata::getTimePercent(void){
    if(getState()==tabaInt1){
        return ((float(i_time)+1.0)/calcSeconds(&(profiles[profileActive].timeInt1)));    //a_time1);
    }
    if(getState()==tabaInt2){
        return ((float(i_time)+1.0)/calcSeconds(&(profiles[profileActive].timeInt2)));    //a_time2);
    }
    if(getState()==tabaStartUp){
        return ((float(i_time)+1.0)/calcSeconds(&(profiles[profileActive].timeStart)));    //a_starttime);
    }
    return 0;
}

bool Tabata::checkProfileID(int &profileid, bool overwrite){
    if((profileid>=0) && (profileid < maxProfiles)){
        return true;
    }
    else{
        if(overwrite)
            profileid=profileActive;
        return false;
    }
}

bool Tabata::checkState(TabaStates state){
    bool retval=false;
    switch(state){
    case tabaInt1: retval= true; break;
    case tabaInt2: retval= true; break;
    case tabaStartUp: retval= true; break;
    case tabaStop: retval= true; break;
    default: retval= false; break;
    }
    return retval;
}

bool Tabata::checkState(TabaStates &state,bool overwrite){
    if(overwrite){
        if(checkState(state)){
            return true;
        }
        else{
            state=i_state;
            return false;
        }
    }
    return checkState(state);

}

void Tabata::tabataDing(void){
    mediaPlayer->play();
}

int Tabata::calcSeconds(int secs, int mins, int hours){
    return hours*3600+mins*60+secs;
}

int Tabata::calcSeconds(QTime *timeObj){
    return calcSeconds(timeObj->second(),timeObj->minute(),timeObj->hour());
}


Q_INVOKABLE int Tabata::getSecondsLeft(void){
    QTime temp;
    temp.setHMS(0,0,0);
    temp=temp.addSecs(getProfileAllSeconds(i_state,profileActive)-i_time);
    return temp.second();
}

Q_INVOKABLE int Tabata::getMinutesLeft(void){
    QTime temp;
    temp.setHMS(0,0,0);
    temp=temp.addSecs(getProfileAllSeconds(i_state,profileActive)-i_time);
    return temp.minute();
}

Q_INVOKABLE int Tabata::getHoursLeft(void){
    QTime temp;
    temp.setHMS(0,0,0);
    temp=temp.addSecs(getProfileAllSeconds(i_state,profileActive)-i_time);
    return temp.hour();
}


Q_INVOKABLE int Tabata::getProfileSeconds(TabaStates timerid, int profileid){
    checkState(timerid,true);
    checkProfileID(profileid,true);
    int retval=0;
    switch (timerid){
    case tabaInt1: retval=profiles[profileid].timeInt1.second(); break;
    case tabaInt2: retval=profiles[profileid].timeInt2.second(); break;
    case tabaStartUp: retval=profiles[profileid].timeStart.second(); break;
    case tabaStop: retval=profiles[profileid].timeStart.second(); break;
    default: retval=profiles[profileid].timeStart.second(); break;
    }
    return retval;
}

Q_INVOKABLE int Tabata::getProfileMinutes(TabaStates timerid, int profileid){
    checkState(timerid,true);
    checkProfileID(profileid,true);
    int retval=0;
    switch (timerid){
    case tabaInt1: retval=profiles[profileid].timeInt1.minute(); break;
    case tabaInt2: retval=profiles[profileid].timeInt2.minute(); break;
    case tabaStartUp: retval=profiles[profileid].timeStart.minute(); break;
    case tabaStop: retval=profiles[profileid].timeStart.minute(); break;
    default: retval=profiles[profileid].timeStart.minute(); break;
    }
    return retval;
}

Q_INVOKABLE int Tabata::getProfileHours(TabaStates timerid, int profileid){
    checkState(timerid,true);
    checkProfileID(profileid,true);
    int retval=0;
    switch (timerid){
    case tabaInt1: retval=profiles[profileid].timeInt1.hour(); break;
    case tabaInt2: retval=profiles[profileid].timeInt2.hour(); break;
    case tabaStartUp: retval=profiles[profileid].timeStart.hour(); break;
    case tabaStop: retval=profiles[profileid].timeStart.hour(); break;
    default: retval=profiles[profileid].timeStart.hour(); break;
    }
    return retval;
}

Q_INVOKABLE int Tabata::getProfileAllSeconds(TabaStates timerid, int profileid){
    checkState(timerid,true);
    checkProfileID(profileid,true);
    //    int retval=0;
    switch (timerid){
    case tabaInt1: return calcSeconds(&(profiles[profileid].timeInt1)); break;
    case tabaInt2: return calcSeconds(&(profiles[profileid].timeInt2)); break;
    case tabaStartUp: return calcSeconds(&(profiles[profileid].timeStart)); break;
    case tabaStop: return calcSeconds(&(profiles[profileid].timeStart)); break;
    default: return -2;//retval=calcSeconds(&(profiles[profileid].timeStart)); break;
    }
    return -3;
}

Q_INVOKABLE int Tabata::getProfileIntervals(int profileid){
    checkProfileID(profileid,true);
    return profiles[profileid].intervals;
}

Q_INVOKABLE QString Tabata::getProfileText(int profileid){
    checkProfileID(profileid,true);
    return profiles[profileid].text;
}

Q_INVOKABLE int Tabata::getActiveProfile(void){
    return profileActive;
}

Q_INVOKABLE int Tabata::getDefaultProfile(void){
    return profileDefault;
}

Q_INVOKABLE int Tabata::valStateInt1(){
    return (int)tabaInt1;
}

Q_INVOKABLE int Tabata::valStateInt2(){
    return (int)tabaInt2;
}
Q_INVOKABLE int Tabata::valStateStartUp(){
    return (int)tabaStartUp;
}
Q_INVOKABLE int Tabata::valStateStop(){
    return (int)tabaStop;
}

Q_INVOKABLE int Tabata::setActiveProfile(int profile){
    if(getState()!=tabaStop)
        return 1;
    checkProfileID(profile,true);
    profileActive=profile;
    emit tabataChanged();
    return 0;
}

Q_INVOKABLE int Tabata::getProfileNumber(void){
    return maxProfiles;
}

Q_INVOKABLE bool Tabata::getWarnSleepPower(void){
    return warnSleep;
}

Q_INVOKABLE int Tabata::setFavProfile(int number,int profile){
    if(!checkProfileID(profile))
        return 1;
    switch (number){
    case 1: profileFav1=profile; break;
    case 2: profileFav2=profile; break;
    default: return 1;
    }
    setting->setValue("profileFav1",profileFav1);
    setting->setValue("profileFav2",profileFav2);
    setting->sync();
    emit tabataChanged();
    return 0;
}
Q_INVOKABLE int Tabata::getFavProfile(int number){
    switch (number){
    case 1: return profileFav1;
    case 2: return profileFav2;
    default: return 1;
    }
}
