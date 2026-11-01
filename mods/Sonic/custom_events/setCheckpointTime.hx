function onCreatePost() {
    game.songMisses = PlayState.campaignMisses;
    game.setOnScripts('misses', game.songMisses);
    return;
}

function onEvent(e, v1, v2) {
    if (e == "setCheckpointTime") {
        PlayState.checkpointTime = Conductor.songPosition;
        PlayState.campaignMisses = game.songMisses;
    }
    return;
}

function onDestroy() {}