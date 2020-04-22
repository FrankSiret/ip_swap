#ifndef IP_CHANGE_H
#define IP_CHANGE_H

#include <QProcess>
#include <QSettings>
#include <QStringList>
#include <QNetworkInterface>
#include <QGuiApplication>

#include <QDebug>
#define db qDebug()

class ip_change : public QObject
{
    Q_OBJECT
public:
    explicit ip_change(QObject *parent = 0);
    Q_INVOKABLE void start();
    Q_INVOKABLE void get_interfaces();
    Q_INVOKABLE void get_profiles();
    Q_INVOKABLE void delete_profile(const QString &profile);

    Q_INVOKABLE void changeAdapter(const QString &interface);
    Q_INVOKABLE void get_ipaddresses(const QString &interface);
    Q_INVOKABLE void get_dnsservers(const QString &interface);

    Q_INVOKABLE void update_profile(const QString &profile);

    Q_INVOKABLE void set_addresses(bool ipDHCP, QString IP, QString MASK, QString GATEWAY, QString DNS1, QString DNS2, QString interface);
    Q_INVOKABLE void save_profile(bool ipDHCP, QString IP, QString MASK, QString GATEWAY, QString DNS1, QString DNS2, QString profile);

    Q_INVOKABLE void validIp(QString &ip);
//    Q_INVOKABLE void set_proxy();
    ~ip_change() { }

//public slots:
//    void readInterface();

signals:
    void cleanAdapters();
    void cleanAdapterTab();
    void addProfile(QString _profile);
    void addProfiles(QList<QString> _profiles, QString _current);
    void addAdapters(QList<QString> _adapters, QString _current);
    void setConnected(bool _isConnected);
    void setDescription(QString _description, QString _mac);

    void getIp(bool _dhcp, QString _ip, QString _mask, QString _gateway);
    void setIp(bool _dhcp, QString _ip, QString _mask, QString _gateway);
    void getDns(QString _dns1, QString _dns2);
    void setDns(QString _dns1, QString _dns2);

private:
    QList<QString> profiles;
    QList<QString> adapters;
    QMap<QString, QMap<QString,QString>> allAdapter;
    bool checkIp;
    bool checkMask;
    bool checkGateway;
    bool checkDns1;
    bool checkDns2;
};

#endif // IP_CHANGE_H
