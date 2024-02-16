import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/archived_game.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'game_repository.dart';

part 'game_repository_providers.g.dart';

@riverpod
Future<ArchivedGame> archivedGame(ArchivedGameRef ref, {required GameId id}) {
  return ref.withAuthClient(
    (client) => GameRepository(client).getGame(id),
  );
}

@riverpod
Future<IList<LightArchivedGame>> userRecentGames(
  UserRecentGamesRef ref, {
  required UserId userId,
}) {
  return ref.withAuthClientCacheFor(
    (client) => GameRepository(client).getRecentGames(userId),
    const Duration(minutes: 5),
  );
}

@riverpod
Future<IList<LightArchivedGame>> gamesById(
  GamesByIdRef ref, {
  required ISet<GameId> ids,
}) {
  return ref.withAuthClientCacheFor(
    (client) => GameRepository(client).getGamesByIds(ids),
    const Duration(minutes: 5),
  );
}
