#include "playersmodel.h"

PlayersModel::PlayersModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int PlayersModel::rowCount(
    const QModelIndex &parent
    ) const
{
    if (parent.isValid())
        return 0;

    return m_players.size();
}

QVariant PlayersModel::data(
    const QModelIndex &index,
    int role
    ) const
{
    if (!index.isValid())
        return {};

    if (index.row() < 0 ||
        index.row() >= m_players.size()) {
        return {};
    }

    const Player &player = m_players.at(index.row());

    switch (role) {
    case PlayerNameRole:
        return player.name;

    case PlayerIdRole:
        return player.id;

    case AddressRole:
        return player.address.toString();

    case PortRole:
        return player.port;

    case Qt::DisplayRole:
        return player.name;

    default:
        return {};
    }
}

QHash<int, QByteArray> PlayersModel::roleNames() const
{
    return {
        { PlayerNameRole, "playerName" },
        { PlayerIdRole, "playerId" },
        { AddressRole, "address" },
        { PortRole, "port" }
    };
}

void PlayersModel::addOrUpdatePlayer(
    const QString &id,
    const QString &name,
    const QHostAddress &address,
    quint16 port
    )
{
    if (id.isEmpty() || name.isEmpty())
        return;

    for (int i = 0; i < m_players.size(); ++i) {
        if (m_players[i].id == id) {
            m_players[i].name = name;
            m_players[i].address = address;
            m_players[i].port = port;

            const QModelIndex modelIndex =
                index(i, 0);

            emit dataChanged(
                modelIndex,
                modelIndex,
                {
                    PlayerNameRole,
                    AddressRole,
                    PortRole
                }
                );

            return;
        }
    }

    const int newRow = m_players.size();

    beginInsertRows(
        QModelIndex(),
        newRow,
        newRow
        );

    Player player;
    player.id = id;
    player.name = name;
    player.address = address;
    player.port = port;

    m_players.append(player);

    endInsertRows();
}

void PlayersModel::removePlayer(
    const QString &id
    )
{
    for (int i = 0; i < m_players.size(); ++i) {
        if (m_players.at(i).id == id) {
            beginRemoveRows(
                QModelIndex(),
                i,
                i
                );

            m_players.removeAt(i);

            endRemoveRows();
            return;
        }
    }
}

void PlayersModel::removePlayerByAddress(
    const QHostAddress &address
    )
{
    for (int i = m_players.size() - 1; i >= 0; --i) {
        if (m_players.at(i).address == address) {
            beginRemoveRows(
                QModelIndex(),
                i,
                i
                );

            m_players.removeAt(i);

            endRemoveRows();
        }
    }
}

void PlayersModel::clear()
{
    if (m_players.isEmpty())
        return;

    beginResetModel();
    m_players.clear();
    endResetModel();
}

QHostAddress PlayersModel::addressAt(
    int index
    ) const
{
    if (index < 0 || index >= m_players.size())
        return {};

    return m_players.at(index).address;
}

quint16 PlayersModel::portAt(
    int index
    ) const
{
    if (index < 0 || index >= m_players.size())
        return 0;

    return m_players.at(index).port;
}

QString PlayersModel::idAt(
    int index
    ) const
{
    if (index < 0 || index >= m_players.size())
        return {};

    return m_players.at(index).id;
}

QString PlayersModel::nameAt(
    int index
    ) const
{
    if (index < 0 || index >= m_players.size())
        return {};

    return m_players.at(index).name;
}
