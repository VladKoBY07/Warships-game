#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>

#include "autogen/environment.h"
#include "backend/gameboard.h"
#include "backend/ai_player.h"
#include "backend/gamecontroller.h"

int main(int argc, char *argv[])
{
    set_qt_environment();
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterUncreatableType<GameController>(
        "Warships", 1, 0,
        "GameController",
        "GameController is exposed as context property"
        );

    GameBoard gameBoard;
    ai_player ai;
    GameController gameController(&gameBoard, &ai);
    engine.rootContext()->setContextProperty("gameBoard", &gameBoard);
    engine.rootContext()->setContextProperty("gameController", &gameController);

    const QUrl url(mainQmlFile);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}