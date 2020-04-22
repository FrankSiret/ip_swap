#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ip_change.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<ip_change>("ip_swap", 1, 0, "IpSwap");
    //engine.rootContext()->setContextProperty("openOption", e);
    //engine.rootContext()->setContextProperty("programToAppend", p);
    engine.load(QUrl(QStringLiteral("qrc:/app.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
