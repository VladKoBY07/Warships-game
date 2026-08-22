#ifndef NETWORKPROTOCOL_H
#define NETWORKPROTOCOL_H

#include <QtGlobal>

namespace NetworkProtocol
{
constexpr int Version = 1;

constexpr quint16 UdpPort = 45455;
constexpr quint16 TcpPort = 45454;

constexpr const char *GameName = "WarShips";

constexpr const char *PlayerAnnounce =
    "PLAYER_ANNOUNCE";

constexpr const char *ConnectionRequest =
    "CONNECTION_REQUEST";

constexpr const char *ConnectionAccepted =
    "CONNECTION_ACCEPTED";

constexpr const char *ConnectionRejected =
    "CONNECTION_REJECTED";

constexpr const char *GameAction =
    "GAME_ACTION";
}

#endif // NETWORKPROTOCOL_H
