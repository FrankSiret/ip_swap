#include "ip_change.h"

ip_change::ip_change(QObject *parent) : QObject(parent) { }

void ip_change::start() {
    get_interfaces();
    get_profiles();
}

void ip_change::validIp(QString &ip)
{
    if(ip.isEmpty())
        return;
    QStringList x = ip.split(".");

    bool b = x.size() == 4;
    for(int i=0; i<x.size(); i++) {
        bool ok;
        int num = QString(x[i]).toInt(&ok);
        b &= ok & (num <= 255);
    }

    if(!b) ip = "";
}

void ip_change::get_proxy()
{
    QString _proxy, _port, _proxy_except;
    QSettings set("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings", QSettings::NativeFormat);
    if(set.value("ProxyEnable", 0).toInt() == 1) {
        auto p = set.value("ProxyServer").toString();
        if(p.indexOf(":") != -1) {
            _proxy = p.section(":",0,-2);
            _port = p.section(":",-1);
        }
        _proxy_except = set.value("ProxyOverride").toString();
    }

    db << _proxy << _port << _proxy_except;

    emit getProxy(_proxy, _port, _proxy_except);
}

void ip_change::get_profiles()
{
    profiles.clear();
    QSettings set(qApp->applicationDirPath()+"/config_ipswap.ini", QSettings::IniFormat);
    QStringList groups = set.childGroups();
    QString currentProfile = set.value("current_profile", "").toString();
    for(QString s: groups) profiles << s;
    emit addProfiles(profiles, currentProfile);
}

void ip_change::delete_profile(const QString &profile)
{
    QSettings set(qApp->applicationDirPath()+"/config_ipswap.ini", QSettings::IniFormat);
    profiles.removeOne(profile);
    set.remove(profile);
    set.sync();
}

void ip_change::get_dnsservers(const QString &interface)
{
    QProcess *p = new QProcess(this);
    QString program;
    QStringList args;
    program = "netsh";

    args.clear();
    args << "interface" << "ipv4" << "show" << "dns" << interface;

    p->start(program, args, QProcess::ReadOnly);
    p->waitForFinished();
    p->waitForReadyRead();

    QStringList read = QString(p->readAll()).split("\r\n");

    if(read.size() <= 2) return;

    read.removeFirst();
    read.removeFirst();

    QString dns1, dns2;
    foreach (QString line, read) {
        line = line.trimmed();

        if(line.contains("dns",Qt::CaseInsensitive)) {
            dns1 = line.section(":",1).trimmed();
            if(dns1.contains(QRegularExpression("[a-z]+")))
                dns1.clear();
        }
        else if(!line.contains(':') && dns2.isEmpty()) {
            dns2 = line;
        }
    }

    emit getDns(dns1, dns2);
}

void ip_change::get_interfaces()
{
    emit cleanAdapters();
    emit cleanAdapterTab();

    /*
     * QProcess *p = new QProcess(this);
     * connect(p, SIGNAL(finished(int)), this, SLOT(readInterface()));
     * QString program, args;
     * program = "powershell";
     * args = "Get-NetAdapter";
     * p->start(program, args.split(" "), QProcess::ReadOnly);
     */

    adapters.clear();
    allAdapter.clear();
    QString b;

    struct E {
        int index;
        QString name;
        bool isUp;
        QString mac;
        E(int _index=0, QString _name="", bool _isUp=0, QString _mac="")
        { index = _index; name = _name; isUp = _isUp; mac = _mac; }
    };
    QMap<int,E> indexes;

    QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface interface, interfaces) {
        QNetworkInterface::InterfaceFlags flags = interface.flags();
        bool isUp = flags.testFlag(QNetworkInterface::IsUp) && flags.testFlag(QNetworkInterface::IsRunning);
        QString mac = interface.hardwareAddress();
        QString name = interface.humanReadableName();
        int index = interface.index();
        indexes[index] = {index,name,isUp,mac};
    }

    for (E it: indexes) {
        QMap<QString, QString> m;
        m["description"] = it.name;
        m["index"] = QString::number(it.index);
        m["status"] = it.isUp ? "Yes" : "No";
        m["mac"] = it.mac;
        allAdapter[it.name] = m;

        if(it.mac.size() == 6*2+5) {
            adapters << it.name;
            if(it.isUp && b.isEmpty()) {
                b = it.name;
            }
        }
    }

    if(b.isEmpty()) b = adapters.first();
    emit addAdapters(adapters, b);
    changeAdapter(b);
}

void ip_change::update_profile(const QString &profile)
{
    QSettings set(qApp->applicationDirPath()+"/config_ipswap.ini", QSettings::IniFormat);
    set.beginGroup(profile);
    bool dhcp = set.value("dhcp", true).toBool();
    QString ip = set.value("ip", "").toString();
    QString mask = set.value("mask", "").toString();
    QString gateway = set.value("gateway", "").toString();
    QString dns1 = set.value("dns1", "").toString();
    QString dns2 = set.value("dns2", "").toString();
    QString proxy = set.value("proxy", "").toString();
    QString port = set.value("port", "").toString();
    QString proxy_except = set.value("proxy_except", "").toString();
    set.endGroup();

    validIp(ip);
    validIp(mask);
    validIp(gateway);
    validIp(dns1);
    validIp(dns2);

    emit setIp(dhcp, ip, mask, gateway);
    emit setDns(dns1, dns2);
    emit setProxy(proxy, port, proxy_except);
}

void ip_change::save_profile(bool ipDHCP, QString IP, QString MASK, QString GATEWAY, QString DNS1, QString DNS2, QString PROXY, QString PORT, QString PROXY_EXCEPT, QString profile)
{
    if(ipDHCP) IP = MASK = GATEWAY = DNS1 = DNS2 = "";
    QSettings set(qApp->applicationDirPath()+"/config_ipswap.ini", QSettings::IniFormat);
    set.beginGroup(profile);
    set.setValue("dhcp", ipDHCP);
    set.setValue("ip", IP);
    set.setValue("mask", MASK);
    set.setValue("gateway", GATEWAY);
    set.setValue("dns1", DNS1);
    set.setValue("dns2", DNS2);
    set.setValue("proxy", PROXY);
    set.setValue("port", PORT);
    set.setValue("proxy_except", PROXY_EXCEPT);
    set.endGroup();
    set.setValue("current_profile", profile);
    if (!profiles.contains(profile)) {
        profiles << profile;
        emit addProfile(profile);
    }
}

void ip_change::get_ipaddresses(const QString &interface)
{
    QProcess *p = new QProcess(this);
    QString program;
    QStringList args;
    program = "netsh";

    args.clear();
    args << "interface" << "ipv4" << "show" << "address" << interface;

    p->start(program, args, QProcess::ReadOnly);
    p->waitForFinished();
    p->waitForReadyRead();

    QStringList read = QString(p->readAll()).split("\r\n");

    if(read.size() <= 2) return;

    read.removeFirst();
    read.removeFirst();

    bool dhcp;
    QString ip, mask, gateway;

    foreach(QString line, read) {
        line = line.trimmed();
        if(line.contains("dhcp",Qt::CaseInsensitive)) {
            QString dhcpline = line.section(":",1).trimmed();
            dhcp = dhcpline[0] != 'N';
        }
        else if(line.contains("ip",Qt::CaseInsensitive)) {
            ip = line.section(":",1).trimmed();
        }
        else if(line.contains("subred",Qt::CaseInsensitive) || line.contains("mask",Qt::CaseInsensitive)) {
            QString maskline = line.section(":",1).trimmed();
            mask = maskline.section(" ",-1).section(")",0,0);
        }
        else if(gateway.isEmpty() && (line.contains("enlace",Qt::CaseInsensitive) || line.contains("gateway",Qt::CaseInsensitive))) {
            gateway = line.section(":",1).trimmed();
            if(gateway.contains(QRegularExpression("[a-z]+")))
                gateway.clear();
        }
    }

    emit getIp(dhcp, ip, mask, gateway);
}

void ip_change::set_addresses(bool ipDHCP, QString IP, QString MASK, QString GATEWAY, QString DNS1, QString DNS2, QString PROXY, QString PORT, QString PROXY_EXCEPT, QString interface)
{
    QProcess *p = new QProcess(this);
    QString program;
    QStringList args;
    program = "netsh";

    args.clear();
    args << "interface" << "ipv4" << "set" << "address" << interface;

    if(ipDHCP) {
        args << "dhcp";
    }
    else {
        args << "static" << IP << MASK;
        if(!GATEWAY.isEmpty()) args << GATEWAY;
    }

    db << program << args;

    p->start(program, args, QProcess::ReadOnly);
    p->waitForFinished();
    p->waitForReadyRead();

    bool b;
    QString error;

    error = p->readAll();
    b = !error.contains(QRegularExpression("[a-z]+"));
    qDebug() << error;

    if(ipDHCP) {
        args.clear();
        args << "interface" << "ipv4" << "set" << "dns" << interface << "dhcp";
        p->start(program, args, QProcess::ReadOnly);
        p->waitForFinished();
        p->waitForReadyRead();
        error = p->readAll();
        b &= !error.contains(QRegularExpression("[a-z]+"));
        qDebug() << error;
    }
    else {
        if(DNS1.isEmpty() && !DNS2.isEmpty())
            qSwap(DNS1, DNS2);
        if(!DNS1.isEmpty()) {
            args.clear();
            args << "interface" << "ipv4" << "set" << "dns" << interface << "static";
            if(!DNS1.isEmpty()) args << DNS1;
            args << "primary" << "validate=no";
            p->start(program, args, QProcess::ReadOnly);
            p->waitForFinished();
            p->waitForReadyRead();
            error = p->readAll();
            b &= !error.contains(QRegularExpression("[a-z]+"));
            qDebug() << error;
        }
        if(!DNS2.isEmpty()) {
            args.clear();
            args << "interface" << "ipv4" << "add" << "dns" << interface << DNS2 << "validate=no" << "index=2";
            p->start(program, args, QProcess::ReadOnly);
            p->waitForFinished();
            p->waitForReadyRead();
            error = p->readAll();
            b &= !error.contains(QRegularExpression("[a-z]+"));
            qDebug() << error;
        }
    }

    set_proxy(PROXY, PORT, PROXY_EXCEPT);

    if(b) {
        QSettings set(qApp->applicationDirPath()+"/config_ipswap.ini", QSettings::IniFormat);
        set.setValue("CurrentAdapter", interface);
    }

    changeAdapter(interface);
}

void ip_change::set_proxy(QString PROXY, QString PORT, QString PROXY_EXCEPT)
{
    QSettings set("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings", QSettings::NativeFormat);
    if(PROXY.isEmpty()) {
        set.setValue("ProxyEnable", 0);
    }
    else {
        set.setValue("ProxyEnable", 1);
        set.setValue("ProxyServer", QString("%1:%2").arg(PROXY, PORT));
        //"internet.uo.edu.cu:3128"
        set.setValue("ProxyOverride", PROXY_EXCEPT);
        // "127.0.0.1;localhost;*.uo.edu.cu;10.30.*;10.31.*;<local>"
    }
}

void ip_change::changeAdapter(const QString &interface)
{
    QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface it, interfaces) {
        QNetworkInterface::InterfaceFlags flags = it.flags();
        bool isUp = flags.testFlag(QNetworkInterface::IsUp) && flags.testFlag(QNetworkInterface::IsRunning);
        QString name = it.humanReadableName();
        if(name == interface)
            allAdapter[interface]["status"] = isUp ? "Yes" : "No";
    }
    emit setConnected(allAdapter[interface]["status"] == "Yes");
    emit setDescription(allAdapter[interface]["description"], allAdapter[interface]["mac"]);
    emit cleanAdapterTab();
    get_ipaddresses(interface);
    get_proxy();
    get_dnsservers(interface);
}

/*void ip_change::readInterface()
{
    QProcess *p = qobject_cast<QProcess *>(sender());

    QByteArray allRead = p->readAllStandardOutput();
    QStringList read = QString(allRead).split("\r\n");

    if( read.size() < 4 ) return;

    read.removeFirst();
    QString first = read.first();
    read.removeFirst();
    read.removeFirst();

    int idxName=0;
    int idxIntDesc = first.indexOf("InterfaceDescription")+1;
    int idxifIndex = first.indexOf("ifIndex")+1;
    int idxStatus = first.indexOf("Status")+1;

    adapters.clear();
    allAdapter.clear();
    QString b;

    struct tri {
        QString name;
        bool isUp;
        QString mac;
        tri(QString _name="", bool _isUp=0, QString _mac="")
        { name = _name; isUp = _isUp; mac = _mac; }
    };
    QMap<int,tri> indexes;

    QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface interface, interfaces) {
        QNetworkInterface::InterfaceFlags flags = interface.flags();
        bool isUp = flags.testFlag(QNetworkInterface::IsUp) && flags.testFlag(QNetworkInterface::IsRunning);
        QString mac = interface.hardwareAddress();
        QString name = interface.humanReadableName();
        int index = interface.index();
        indexes[index] = {name,isUp,mac};
    }

    foreach (QString line, read) {
        QString l = line.trimmed();
        if (l.isEmpty()) continue;
        QString iDesc = l.section("",idxName,idxIntDesc-1).trimmed();
        QMap<QString, QString> m;
        m["description"] = l.section("",idxIntDesc,idxifIndex-1).trimmed();
        m["index"] = l.section("",idxifIndex,idxStatus-1).trimmed();
        int index = m["index"].toInt();
        adapters << indexes[index].name;
        m["status"] = indexes[index].isUp ? "Yes" : "No";
        m["mac"] = indexes[index].mac;
        allAdapter[indexes[index].name] = m;
        if(indexes[index].isUp && b.isEmpty()) {
            b = indexes[index].name;
        }
    }

    if(b.isEmpty()) b = adapters.first();
    emit addAdapters(adapters, b);
    changeAdapter(b);
}*/
