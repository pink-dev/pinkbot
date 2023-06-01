import dimscord, dimscmd, config, asyncdispatch, yaml/serialization, streams, std/logging, cnsl

var botConfig: Bot

var logger = newConsoleLogger(fmtStr="$time".green & " -> ".red & "$levelname" & " -> ".red)
var s = newFileStream("Pink.yml")
load(s, botConfig)

let discord = newDiscordClient(botConfig.token)
var cmd = discord.newHandler()
s.close()

proc messageCreate (s: Shard, msg: Message) {.event(discord).} =
  discard await cmd.handleMessage(".", s, msg)

proc onReady (s: Shard, r: Ready) {.event(discord).} =
  logger.log(lvlInfo, "Ready as " & $r.user)
  await cmd.registerCommands()

proc interactionCreate (s: Shard, i: Interaction) {.event(discord).} =
  discard await cmd.handleInteraction(s, i)


waitFor discord.startSession()
