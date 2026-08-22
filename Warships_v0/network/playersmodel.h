#ifndef PLAYERSMODEL_H
#define PLAYERSMODEL_H

#include <QAbstractListModel>
#include <QHostAddress>
#include <QVector>

class PlayersModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        PlayerNameRole = Qt::UserRole + 1,
        PlayerIdRole,
        AddressRole,
        PortRole
    };

    explicit PlayersModel(QObject *parent = nullptr);

    int rowCount(
        const QModelIndex &parent = QModelIndex()
        ) const override;

    QVariant data(
        const QModelIndex &index,
        int role = Qt::DisplayRole
        ) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addOrUpdatePlayer(
        const QString &id,
        const QString &name,
        const QHostAddress &address,
        quint16 port
        );

    void removePlayer(const QString &id);

    void removePlayerByAddress(
        const QHostAddress &address
        );

    void clear();

    QHostAddress addressAt(int index) const;
    quint16 portAt(int index) const;
    QString idAt(int index) const;
    QString nameAt(int index) const;

private:
    struct Player {
        QString id;
        QString name;
        QHostAddress address;
        quint16 port = 0;
    };

    QVector<Player> m_players;
};

#endif // PLAYERSMODEL_H
