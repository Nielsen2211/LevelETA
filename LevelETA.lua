-- LevelETA: viser hvornaar du rammer dit naeste tiende level og level 60,
-- og hvilket level du er paa ved sengetid. Virker fra level 1 til 60.
local ADDON = "LevelETA"
local NAME = "LevelETA"
local MAXLVL = 60
local PATH = "Interface\\AddOns\\LevelETA\\"
local TEX = PATH .. "Textures\\"
local LOGO = TEX .. "Logo"
local F_SEMI = PATH .. "Fonts\\Inter-SemiBold.ttf"
local F_BOLD = PATH .. "Fonts\\Inter-Bold.ttf"

-- XP til naeste level i WoW Forever (samme kurve som Classic). Level 1 til 59.
local XPT = {400,900,1400,2100,2800,3600,4500,5400,6500,7600,8800,10100,11400,12900,14400,
  16000,17700,19400,21300,23200,25200,27300,29400,31700,34000,36400,38900,41400,44300,47400,
  50800,54500,58600,62800,67100,71600,76100,80800,85700,90700,95800,101000,106300,111800,117500,
  123200,129100,135100,141200,147500,153900,160400,167100,173900,180800,187900,195000,202300,209800}

local WINDOW = 7200  -- dit tempo lige nu maales over de sidste 2 timers spilletid
local GROWTH = 0.75  -- hvor meget XP pr. time vokser med level (backtestet paa rigtige data)
local DB

-- ---------- sprog ----------
local LOC = {
  en = {
    level = "Level", today = "Today at %s", tomorrow = "Tomorrow at %s",
    daysFull = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
    months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"},
    todayW = "Today", tomorrowW = "Tomorrow", at = "%s %02d:%02d",
    done = "Level 60. Well done!", settings = "Settings",
    rhythm = "Play time", useRhythm = "Use my play times", bed = "Play until", wake = "Play from",
    breakAt = "Break starts", breakLen = "Break length", none = "none", min = "min",
    display = "Display", showWin = "Show window", lock = "Lock window", size = "Size",
    questSec = "Quests and rested", qBuf = "Quest buffer", inn = "Rested XP while logged out",
    reset = "Reset pace", close = "Done", language = "Language: English",
    tipLeft = "Left click: show or hide", tipRight = "Right click: settings", nextLvl = "Next level",
    standalone = "Works on its own. Uses ForeverXP Bar data too, when it is installed.",
    fxbFound = "ForeverXP Bar: found, its level history is used", fxbMissing = "ForeverXP Bar: not installed, using LevelETA's own data",
    showTimes = "Show level times", timesHead = "Level times", now = "now", noTimes = "No level times yet",
    avg = "Average per level", hm = "%dh %02dm", timesCount = "Levels in the list",
    foodTip = "Food buff, +5% XP from kills", bagTip = "Sleeping bag, +%d%% XP",
    barHead = "XP bar", showBar = "Show XP bar", hideBlizz = "Hide Blizzard's XP bar", barSize = "Bar size",
    xph = "XP per hour", nextLevel = "Next level", questsReady = "Quests ready", rested = "Rested",
    xpLeft = "XP left", killsTo = "Kills to level", questsTo = "Quests to level", session = "This session",
    sessTime = "Time", sessXP = "XP", sessKills = "Kills", sessQuests = "Quests", sessLevels = "Levels",
    buffsHead = "XP buffs",
    showAct = "Show activity bar", actHead = "Activity", actLast = "Active, last 10 min", thisLevel = "This level",
    thisSession = "This session", catActive = "Fighting and questing", catTravel = "Travelling", catFlight = "Flying",
    catTown = "In town", catIdle = "AFK", catDead = "Dead", deaths = "Deaths", activeShare = "Active",
    goalHead = "Goal", useGoal = "Use goal", goalLevel = "Level", goalDay = "Day", goalTime = "Time",
    needAct = "You need to be active", atPace = "At your pace now", ahead = "Ahead by", behind = "Behind by",
    impossible = "Not reachable at your pace", goalDone = "Goal reached!", clickGoal = "Click: set goal",
    goalBtn = "Goal", dh = "%dd %dh",
    tabWindow = "Window", tabBar = "XP bar", tabTime = "Play time", winSec = "Window", rowsSec = "Show in the window",
    showToday = "Level when I stop today", showNext = "Next tenth level", show60 = "Level 60", showBuffsWin = "XP buffs",
    showMinimap = "Minimap button", onBar = "On the bar", showStats = "Numbers under the bar",
    showBuffsBar = "XP buffs on the bar", setGoal = "Set goal",
  },
  da = {
    level = "Level", today = "I dag kl. %s", tomorrow = "I morgen kl. %s",
    daysFull = {"Søndag","Mandag","Tirsdag","Onsdag","Torsdag","Fredag","Lørdag"},
    months = {"jan","feb","mar","apr","maj","jun","jul","aug","sep","okt","nov","dec"},
    todayW = "I dag", tomorrowW = "I morgen", at = "%s kl. %02d:%02d",
    done = "Level 60. Godt gået!", settings = "Indstillinger",
    rhythm = "Spilletid", useRhythm = "Brug mine spilletider", bed = "Spiller til", wake = "Spiller fra",
    breakAt = "Pause starter", breakLen = "Pausens længde", none = "ingen", min = "min",
    display = "Visning", showWin = "Vis vinduet", lock = "Lås vinduet", size = "Størrelse",
    questSec = "Quests og rested", qBuf = "Quest-buffer", inn = "Rested XP når jeg er logget ud",
    reset = "Nulstil tempo", close = "Færdig", language = "Sprog: Dansk",
    tipLeft = "Venstreklik: vis eller skjul", tipRight = "Højreklik: indstillinger", nextLvl = "Næste level",
    standalone = "Virker helt alene. Bruger også data fra ForeverXP Bar, hvis den er installeret.",
    fxbFound = "ForeverXP Bar: fundet, dens levelhistorik bruges", fxbMissing = "ForeverXP Bar: ikke installeret, bruger LevelETA's egne data",
    showTimes = "Vis level-tider", timesHead = "Level-tider", now = "nu", noTimes = "Ingen level-tider endnu",
    avg = "Snit pr. level", hm = "%dt %02dm", timesCount = "Levels på listen",
    foodTip = "Food buff, +5% XP fra kills", bagTip = "Sovepose, +%d%% XP",
    barHead = "XP-bar", showBar = "Vis XP-bar", hideBlizz = "Skjul Blizzards XP-bar", barSize = "Barens størrelse",
    xph = "XP pr. time", nextLevel = "Næste level", questsReady = "Quests klar", rested = "Rested",
    xpLeft = "XP tilbage", killsTo = "Kills til level", questsTo = "Quests til level", session = "Denne session",
    sessTime = "Tid", sessXP = "XP", sessKills = "Kills", sessQuests = "Quests", sessLevels = "Levels",
    buffsHead = "XP-buffs",
    showAct = "Vis aktivitets-bjælke", actHead = "Aktivitet", actLast = "Aktiv, sidste 10 min", thisLevel = "Dette level",
    thisSession = "Denne session", catActive = "Kamp og quests", catTravel = "Rejser", catFlight = "Flyver",
    catTown = "I byen", catIdle = "AFK", catDead = "Død", deaths = "Dødsfald", activeShare = "Aktiv",
    goalHead = "Mål", useGoal = "Brug mål", goalLevel = "Level", goalDay = "Dag", goalTime = "Klokken",
    needAct = "Du skal være aktiv", atPace = "Med dit tempo nu", ahead = "Foran med", behind = "Bagud med",
    impossible = "Kan ikke nås med dit tempo", goalDone = "Mål nået!", clickGoal = "Klik: sæt mål",
    goalBtn = "Mål", dh = "%dd %dt",
    tabWindow = "Vindue", tabBar = "XP-bar", tabTime = "Spilletid", winSec = "Vinduet", rowsSec = "Vis i vinduet",
    showToday = "Level når jeg stopper i dag", showNext = "Næste tiende level", show60 = "Level 60", showBuffsWin = "XP-buffs",
    showMinimap = "Minimap-knap", onBar = "På baren", showStats = "Tal under baren",
    showBuffsBar = "XP-buffs på baren", setGoal = "Sæt mål",
  },
}
local function T(k) return (LOC[(DB and DB.lang) or "en"] or LOC.en)[k] end
local labels = {}  -- tekster der skal skifte sprog
local function label(f, key) labels[#labels + 1] = {f, key}; f:SetText(T(key)) end
local function updateLabels() for _, x in ipairs(labels) do x[1]:SetText(T(x[2])) end end

local defaults = {
  play = 0, samples = {}, times = {}, ptimes = {}, fxbTimes = {},
  schedule = true, sleepStart = 23 * 60, sleepEnd = 7 * 60, breakStart = 12 * 60, breakLen = 0,
  questBuffer = 25, inn = true, scale = 1, lang = "en", locked = false, hidden = false, mmAngle = 200,
  showTimes = false, timesCount = 10,
  showBar = true, hideBlizz = true, barScale = 1, questRewards = {},
  showAct = true, act = {}, goalOn = false, goalLevel = 60,
  showToday = true, showNext = true, show60 = true, showBuffsWin = true, showMinimap = true,
  showStats = true, showBuffsBar = true, tab = 1,
}

-- ---------- tid og datoer ----------
local function hhmm(m) return string.format("%02d:%02d", math.floor(m / 60) % 24, m % 60) end

local function midnight(t)
  local d = date("*t", math.floor(t)); d.hour, d.min, d.sec = 0, 0, 0
  return time(d)
end

-- naturlig dato: "I morgen kl. 07:04", "Mandag kl. 18:30", "21. nov kl. 16:15"
local function nice(t, roundMin)
  if roundMin then
    local step = roundMin * 60
    t = math.floor((t + step / 2) / step) * step
  end
  t = math.floor(t)
  local d = date("*t", t)
  local diff = math.floor((midnight(t) - midnight(time())) / 86400 + 0.5)
  local day
  if diff <= 0 then day = T("todayW")
  elseif diff == 1 then day = T("tomorrowW")
  elseif diff < 7 then day = T("daysFull")[d.wday]
  elseif DB.lang == "da" then day = string.format("%d. %s", d.day, T("months")[d.month])
  else day = string.format("%s %d", T("months")[d.month], d.day) end
  return string.format(T("at"), day, d.hour, d.min)
end

-- ---------- XP ----------
local function mobxp(l) return (45 + 5 * l) ^ GROWTH end

local function scale(level)  -- hvis spillet skulle afvige fra tabellen
  local tbl, mx = XPT[level], UnitXPMax("player")
  if tbl and mx and mx > 0 then return mx / tbl end
  return 1
end

-- spilletid (sek) til et level. head = XP du allerede har i haanden (quests og rested)
local function timeTo(target, r, head)
  local lvl = UnitLevel("player")
  if lvl >= target then return 0 end
  local s, k0, h, t = scale(lvl), mobxp(lvl), head or 0, 0
  for l = lvl, target - 1 do
    local need = (l == lvl) and (UnitXPMax("player") - UnitXP("player")) or (XPT[l] or 0) * s
    local take = math.min(h, need)
    need, h = need - take, h - take
    t = t + need / (r * mobxp(l) / k0)
  end
  return t
end

-- hvilket level (med decimaler) du er paa efter sec sekunders spil
local function levelAfter(sec, r, head)
  local lvl = UnitLevel("player")
  local s, k0, h = scale(lvl), mobxp(lvl), head or 0
  for l = lvl, MAXLVL - 1 do
    local size = (l == lvl) and UnitXPMax("player") or (XPT[l] or 0) * s
    local base = (l == lvl) and UnitXP("player") or 0
    local take = math.min(h, size - base)
    base, h = base + take, h - take
    local rl = r * mobxp(l) / k0
    local tl = (size - base) / rl
    if sec < tl then return l + (base + sec * rl) / size end
    sec = sec - tl
  end
  return MAXLVL
end

-- XP fra faerdige quests, der endnu ikke er afleveret
local questCache, questDirty = 0, true
local function questXP()
  if not questDirty then return questCache end
  questDirty = false
  local ok, total = pcall(function()
    local sum = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
      for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and info.questID and C_QuestLog.IsComplete and C_QuestLog.IsComplete(info.questID) then
          sum = sum + ((GetQuestLogRewardXP and GetQuestLogRewardXP(info.questID)) or 0)
        end
      end
    end
    return sum
  end)
  questCache = ok and total or 0
  return questCache
end

local function restedXP() return (GetXPExhaustion and GetXPExhaustion()) or 0 end

-- ---------- XP-buffs ----------
-- Food (Well Fed): +5 % XP fra kills (ikke quests) saa laenge buffen varer, normalt 15 min.
--   Forsvinder naar man doer.
-- Cozy Sleeping Bag (Well-Rested): +1 % al XP pr. stak, op til 3 stakke. Overlever doed.
-- Camp Tent ved et campfire fylder rested XP op til 5 % af et level. Det er almindelig
--   rested XP, saa det er allerede med via GetXPExhaustion.
-- Tiden der er tilbage laeses fra selve buffen, saa talenter der forlaenger den regnes med.
local FOOD_BONUS = 0.05
local BAG_ID = 429959
local buffs, buffsDirty = {}, true
local lastQuestAt = -100

local function clock() return (GetTime and GetTime()) or 0 end
local function num(v)  -- i kamp kan spillet skjule vaerdier
  if type(v) ~= "number" then return nil end
  if issecretvalue then
    local ok, secret = pcall(issecretvalue, v)
    if not ok or secret then return nil end
  end
  return v
end

local function scanBuffs()
  if InCombatLockdown and InCombatLockdown() then return end  -- buffs kan kun laeses uden for kamp
  local fed, bag, stacks, fedIcon, bagIcon
  local ok = pcall(function()
    for i = 1, 80 do
      local name, id, exp, count, icon
      if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not a then break end
        name, id, exp, count, icon = a.name, a.spellId, a.expirationTime, a.applications, a.icon
      elseif UnitBuff then
        local n, ic, c, _, _, e, _, _, _, sid = UnitBuff("player", i)
        if not n then break end
        name, id, exp, count, icon = n, sid, e, c, ic
      else
        break
      end
      exp = num(exp)
      if exp and exp > 0 then
        local n = type(name) == "string" and name:lower() or ""
        if n:find("well fed", 1, true) then
          if not fed or exp > fed then fed, fedIcon = exp, icon end
        elseif num(id) == BAG_ID or n:find("well-rested", 1, true) or n:find("well rested", 1, true) then
          bag, stacks, bagIcon = exp, num(count), icon
        end
      end
    end
  end)
  if not ok then return end
  buffs.fedUntil, buffs.bagUntil = fed, bag
  buffs.fedIcon, buffs.bagIcon = fedIcon, bagIcon
  buffs.bagStacks = bag and math.max(1, math.min(3, (stacks and stacks > 0) and stacks or 1)) or nil
  buffsDirty = false
end

local function fedLeft() local t = buffs.fedUntil and (buffs.fedUntil - clock()) or 0; return t > 0 and t or 0 end
local function bagLeft() local t = buffs.bagUntil and (buffs.bagUntil - clock()) or 0; return t > 0 and t or 0 end

-- hvor stor en del af din XP kommer fra kills (resten er quests). Maales paa de sidste timer.
local function killShare()
  local k, t = 0, 0
  for _, x in ipairs(DB.samples) do
    local c = x.xp - (x.b or 0) - (x.e or 0)
    t = t + c
    if not x.q then k = k + c end
  end
  if t < 5000 then return 0.6 end  -- for lidt data endnu: antag 60 % fra kills
  return math.max(0, math.min(1, k / t))
end

-- ekstra XP du faar fra dine buffs i den tid, de har tilbage
local function buffXP(r)
  if not r or r <= 0 then return 0 end
  local x = fedLeft() * r * killShare() * FOOD_BONUS
  x = x + bagLeft() * r * (buffs.bagStacks or 0) / 100
  return x
end

local function headStart(r) return questXP() * (100 - DB.questBuffer) / 100 + restedXP() + buffXP(r) end

-- ---------- historik ----------
local INFO = {}

local function fxbRecord()  -- ForeverXP Bar gemmer spilletid ved hvert level
  local db = _G.ForeverXPBarDB
  if type(db) ~= "table" or type(db.records) ~= "table" or type(db.records.chars) ~= "table" then return nil end
  local key = (UnitName("player") or "") .. "-" .. ((GetRealmName and GetRealmName()) or "")
  local rec = db.records.chars[key]
  if type(rec) ~= "table" or type(rec.times) ~= "table" then return nil end
  return rec
end

local function durations(times)  -- {L = sekunder paa level L}
  local d = {}
  if type(times) ~= "table" then return d end
  for L = 1, MAXLVL - 1 do
    local a, b = times[L], times[L + 1]
    if type(a) == "number" and type(b) == "number" and b > a then d[L] = b - a end
  end
  return d
end

-- Tre kilder pr. level, i prioriteret raekkefoelge:
--  1. /played (ptimes): spillets egen tid, helt praecis
--  2. ForeverXP Bar (kopieres ind i fxbTimes, saa den bliver, selv hvis addonen fjernes)
--  3. vores egen maaling ved hvert ding (times)
-- Er to kilder enige (under 25 % forskel), bruges gennemsnittet, ellers den hoejeste prioritet.
local function mergedHistory(rec)
  if rec then
    for L = 1, MAXLVL do
      if type(rec.times[L]) == "number" then DB.fxbTimes[L] = rec.times[L] end
    end
  end
  local src = {durations(DB.ptimes), durations(DB.fxbTimes), durations(DB.times)}
  local used = {false, false, false}
  local h = {}
  for L = 1, MAXLVL - 1 do
    local best, bi
    for i = 1, 3 do
      local v = src[i][L]
      if v then
        if not best then best, bi = v, i
        elseif math.abs(best - v) / math.max(best, v) < 0.25 then best = (best + v) / 2; used[i] = true end
      end
    end
    if best then h[#h + 1] = {L = L, d = best}; used[bi] = true end
  end
  local names = {}
  if used[1] or used[3] then names[#names + 1] = NAME end
  if used[2] then names[#names + 1] = "ForeverXP Bar" end
  INFO.source = #names > 0 and table.concat(names, " + ") or nil
  return h
end

-- Effektivitet = XP pr. sekund delt med hvad levelet giver. Naesten konstant for en spiller.
-- De sidste 12 levels bruges, nye vejer mest (halveringstid 6 levels), og afvigere smides ud.
local function histEfficiency(hist, lvl, s)
  local es = {}
  for i = math.max(1, #hist - 11), #hist do
    local x = hist[i]
    if x.d >= 300 and XPT[x.L] then es[#es + 1] = {L = x.L, e = XPT[x.L] * s / (x.d * mobxp(x.L))} end
  end
  if #es == 0 then return nil end
  local sorted = {}
  for i, x in ipairs(es) do sorted[i] = x.e end
  table.sort(sorted)
  local med = sorted[math.ceil(#sorted / 2)]
  local sw, se = 0, 0
  for _, x in ipairs(es) do
    if x.e > med / 2.5 and x.e < med * 2.5 then
      local w = 0.5 ^ ((lvl - 1 - x.L) / 6)
      sw, se = sw + w, se + w * x.e
    end
  end
  if sw == 0 then return nil end
  return se / sw, #es
end

-- ---------- tempo ----------
local playedLevelTime, playedAt  -- fra /played: tid paa nuvaerende level, og hvornaar vi fik den

local function rate()  -- XP pr. sekund paa dit nuvaerende level, og om det er et skoen
  local lvl = UnitLevel("player")
  local k0, s = mobxp(lvl), scale(lvl)
  INFO.eh, INFO.liveE = nil, nil

  -- 1) dit tempo lige nu: XP og tid fra samme vindue
  local liveR, liveSpan
  local winStart = math.max(DB.play - WINDOW, DB.sessionStart or DB.play)
  local span, gained = DB.play - winStart, 0
  for i = #DB.samples, 1, -1 do
    local x = DB.samples[i]
    if x.p < winStart then break end
    gained = gained + x.xp - (x.b or 0) - (x.e or 0)  -- rested- og buff-bonus taeller ikke som tempo
  end
  if span >= 600 and gained > 0 then liveR, liveSpan = gained / span, span end

  -- uden egne maalinger endnu: brug tiden paa dette level fra /played eller ForeverXP Bar
  local rec = fxbRecord()
  if not liveR then
    local el
    if playedLevelTime then el = playedLevelTime + (time() - playedAt)
    elseif rec and type(rec.times[lvl]) == "number" and type(rec.elapsed) == "number" then el = rec.elapsed - rec.times[lvl] end
    local cur = UnitXP("player")
    if el and el >= 900 and cur > 0 then liveR, liveSpan = cur / el, math.min(el, 3600) end
  end

  -- 2) historik
  local eh = histEfficiency(mergedHistory(rec), lvl, s)
  INFO.eh = eh
  INFO.liveE = liveR and liveR / k0 or nil

  local e
  if eh and liveR then
    local w = math.min(0.4, liveSpan / 10800)  -- dit tempo nu vejer op til 40 % efter 3 timer
    e = w * (liveR / k0) + (1 - w) * eh
  elseif eh then e = eh
  elseif liveR then e = liveR / k0
  else
    local minutes = 10 + lvl * 4.5  -- skoen: ca. 15 min ved level 1, ca. 4,5 timer ved level 59
    return math.max(1, UnitXPMax("player") or 1) / (minutes * 60), true
  end
  return e * k0, false
end

-- kort sigt (i dag): glattet over ca. 15 min, hopper direkte hvis den er langt fra
local lastShort
local function shortRate()
  local r, est = rate()
  local lvl = UnitLevel("player")
  if est then return r, true end
  local e = r / mobxp(lvl)
  local dt = math.max(0, DB.play - (lastShort or DB.play)); lastShort = DB.play
  if not DB.eS or math.abs(e - DB.eS) / e > 0.25 then DB.eS = e
  else DB.eS = DB.eS + (e - DB.eS) * math.min(1, dt / 900) end
  return DB.eS * mobxp(lvl), false
end

-- lang sigt (level 50 og 60): 90 % historik, 10 % dit tempo nu, glattet over ca. 2 timer
local lastLong
local function longRate()
  local r, est = shortRate()
  if est or not INFO.eh then return r, est end
  local lvl = UnitLevel("player")
  local e = 0.9 * INFO.eh + 0.1 * (INFO.liveE or INFO.eh)
  local dt = math.max(0, DB.play - (lastLong or DB.play)); lastLong = DB.play
  if not DB.eL or math.abs(e - DB.eL) / e > 0.4 then DB.eL = e
  else DB.eL = DB.eL + (e - DB.eL) * math.min(1, dt / 7200) end
  return DB.eL * mobxp(lvl), false
end

-- ---------- spilletid (sleepEnd = spiller fra, sleepStart = spiller til) ----------
local function inRange(m, a, b)
  if a == b then return false end
  if a < b then return m >= a and m < b end
  return m >= a or m < b
end

local function playing(m)
  if inRange(m, DB.sleepStart, DB.sleepEnd) then return false end
  if DB.breakLen > 0 and inRange(m, DB.breakStart, (DB.breakStart + DB.breakLen) % 1440) then return false end
  return true
end

local function points() return {DB.sleepStart, DB.sleepEnd, DB.breakStart, (DB.breakStart + DB.breakLen) % 1440} end

-- gaa gennem kalenderen i bidder mellem sengetid, opvaagning og pause
local function walk(t, fn)
  local pts = points()
  for _ = 1, 3000 do
    local d = date("*t", math.floor(t))
    local m = d.hour * 60 + d.min
    local delta = 1440
    for _, p in ipairs(pts) do
      local x = (p - m) % 1440
      if x > 0 and x < delta then delta = x end
    end
    local chunk = delta * 60 - d.sec
    if fn(t, m, chunk) then return end
    t = t + chunk
  end
end

-- klokkeslaet hvor du har spillet playSec, med soevn og rested XP i en inn regnet med
local function eta(playSec, r)
  local t0, need = time(), math.floor(playSec)
  if not DB.schedule then return t0 + need end
  local mx = UnitXPMax("player") or 0
  local restLeft = math.max(0, mx * 1.5 - restedXP())
  local result = t0 + need
  walk(t0, function(t, m, chunk)
    if playing(m) then
      if chunk >= need then result = t + need; return true end
      need = need - chunk
    elseif DB.inn and r and r > 0 and inRange(m, DB.sleepStart, DB.sleepEnd) then
      local gain = math.min(restLeft, mx * 0.05 * chunk / 28800)  -- 5 % af et level pr. 8 timer
      restLeft = restLeft - gain
      need = math.max(0, need - gain / r)
    end
  end)
  return result
end

local function playableUntil(t1)
  local t0 = time()
  if t1 <= t0 then return 0 end
  if not DB.schedule then return t1 - t0 end
  local total = 0
  walk(t0, function(t, m, chunk)
    chunk = math.min(chunk, t1 - t)
    if playing(m) then total = total + chunk end
    return t + chunk >= t1
  end)
  return total
end

-- ---------- byggeklodser ----------
local function fs(parent, font, size)
  local t = parent:CreateFontString(nil, "OVERLAY")
  t:SetFont(font, size, "")
  t:SetShadowOffset(0, 0)
  if t.SetWordWrap then t:SetWordWrap(false) end
  if t.SetMaxLines then t:SetMaxLines(1) end
  return t
end

-- panel af tre skiver (top, midte, bund), saa hjoernerne ikke forvraenges
local function skin(frame, prefix, texW, canvasW)
  local top = frame:CreateTexture(nil, "BACKGROUND")
  top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(20)
  top:SetTexture(TEX .. prefix .. "Top"); top:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
  local bot = frame:CreateTexture(nil, "BACKGROUND")
  bot:SetPoint("BOTTOMLEFT"); bot:SetPoint("BOTTOMRIGHT"); bot:SetHeight(20)
  bot:SetTexture(TEX .. prefix .. "Bottom"); bot:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
  local mid = frame:CreateTexture(nil, "BACKGROUND")
  mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT"); mid:SetPoint("BOTTOMRIGHT", bot, "TOPRIGHT")
  mid:SetTexture(TEX .. prefix .. "Mid"); mid:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
end

-- logo, navn og guldstreg oeverst
local function header(frame, titleText)
  local logo = frame:CreateTexture(nil, "ARTWORK")
  logo:SetSize(22, 22); logo:SetPoint("TOPLEFT", 12, -9); logo:SetTexture(LOGO)
  local title = fs(frame, F_BOLD, 15)
  title:SetPoint("LEFT", logo, "RIGHT", 7, 0)
  if titleText then title:SetText(titleText) end
  local line = frame:CreateTexture(nil, "ARTWORK")
  line:SetSize(22, 2); line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
  line:SetColorTexture(1, 0.8, 0.35, 0.9)
  return title
end

local function movable(frame, canMove)
  frame:SetMovable(true); frame:EnableMouse(true); frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) if canMove() then self:StartMoving() end end)
end

-- ---------- hovedvindue ----------
local W = 260
local f = CreateFrame("Frame", "LevelETAFrame", UIParent)
f:SetSize(W, 120)
skin(f, "Panel", 520, 1024)
movable(f, function() return not DB.locked end)
f:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local p, _, rp, x, y = self:GetPoint()
  DB.point = {p, rp, x, y}
end)
header(f, "|cffffffffLevel|r|cffffd24aETA|r")

-- raekke: label til venstre, vaerdi til hoejre, tynd streg eller bjaelke under
local function newRow()
  local c = CreateFrame("Frame", nil, f)
  c.line = c:CreateTexture(nil, "ARTWORK")
  c.line:SetPoint("BOTTOMLEFT"); c.line:SetPoint("BOTTOMRIGHT"); c.line:SetHeight(1)
  c.line:SetColorTexture(1, 1, 1, 0.06)
  c.track = c:CreateTexture(nil, "ARTWORK")
  c.track:SetPoint("BOTTOMLEFT", 0, 1); c.track:SetPoint("BOTTOMRIGHT", 0, 1); c.track:SetHeight(3)
  c.track:SetColorTexture(1, 1, 1, 0.08)
  c.fill = c:CreateTexture(nil, "OVERLAY")
  c.fill:SetPoint("BOTTOMLEFT", c.track, "BOTTOMLEFT"); c.fill:SetHeight(3)
  c.fill:SetColorTexture(0.62, 0.82, 1, 0.9)
  c.value = fs(c, F_BOLD, 13); c.value:SetPoint("RIGHT"); c.value:SetJustifyH("RIGHT")
  c.title = fs(c, F_SEMI, 12); c.title:SetPoint("LEFT"); c.title:SetPoint("RIGHT", c.value, "LEFT", -8, 0)
  c.title:SetJustifyH("LEFT"); c.title:SetTextColor(0.55, 0.58, 0.64)
  return c
end
local rows = {newRow(), newRow(), newRow()}

local function setRow(c, y, title, value, progress, last)
  c.title:SetText(title); c.value:SetText(value)
  local bar = type(progress) == "number"
  c.track:SetShown(bar); c.fill:SetShown(bar)
  if bar then c.fill:SetWidth((W - 28) * math.max(0.02, math.min(1, progress))) end
  c.line:SetShown(not last and not bar)
  local h = bar and 28 or 24
  c:SetHeight(h); c:ClearAllPoints()
  c:SetPoint("TOPLEFT", 14, y); c:SetPoint("TOPRIGHT", -14, y); c:Show()
  return y - h
end

-- ---------- level-tider (valgfri liste) ----------
local TX, TR = 84, 68             -- bjaelken starter efter label og slutter foer tiden
local TW = W - 28 - TX - TR

local function dur(sec)
  sec = math.floor(sec + 0.5)
  if sec < 60 then return "<1m" end
  local m = math.floor(sec / 60)
  if m < 60 then return m .. "m" end
  return string.format(T("hm"), math.floor(m / 60), m % 60)
end

-- tid brugt paa det level du er paa nu
local function levelElapsed(rec)
  local lvl = UnitLevel("player")
  if playedLevelTime then return playedLevelTime + (time() - playedAt) end
  if type(DB.times[lvl]) == "number" then return DB.play - DB.times[lvl] end
  if rec and type(rec.times[lvl]) == "number" and type(rec.elapsed) == "number" then return rec.elapsed - rec.times[lvl] end
end

local tSep = f:CreateTexture(nil, "ARTWORK"); tSep:SetHeight(1); tSep:SetColorTexture(1, 1, 1, 0.06)
local tHead = fs(f, F_BOLD, 11); tHead:SetTextColor(1, 0.82, 0.4); label(tHead, "timesHead")
local tAvgLine = f:CreateTexture(nil, "ARTWORK"); tAvgLine:SetHeight(1); tAvgLine:SetColorTexture(1, 1, 1, 0.06)
local tRows = {}

local function timeRow(i)
  if tRows[i] then return tRows[i] end
  local c = CreateFrame("Frame", nil, f)
  c:SetHeight(17)
  c.title = fs(c, F_SEMI, 11); c.title:SetPoint("LEFT"); c.title:SetJustifyH("LEFT")
  c.value = fs(c, F_BOLD, 12); c.value:SetPoint("RIGHT"); c.value:SetJustifyH("RIGHT")
  c.track = c:CreateTexture(nil, "ARTWORK"); c.track:SetHeight(4)
  c.track:SetPoint("LEFT", TX, 0); c.track:SetPoint("RIGHT", -TR, 0)
  c.track:SetColorTexture(1, 1, 1, 0.06)
  c.fill = c:CreateTexture(nil, "OVERLAY"); c.fill:SetHeight(4); c.fill:SetPoint("LEFT", c.track, "LEFT")
  tRows[i] = c
  return c
end

local function hideTimes()
  tSep:Hide(); tHead:Hide(); tAvgLine:Hide()
  for _, c in ipairs(tRows) do c:Hide() end
end

-- det level du er paa nu vises stoerre, de faerdige levels i lille skrift
local function placeTime(i, y, title, value, frac, now)
  local c = timeRow(i)
  local h, bh = 17, 4
  if now then
    h, bh = 30, 6
    c.title:SetFont(F_BOLD, 14); c.value:SetFont(F_BOLD, 16)
    c.title:SetTextColor(0.62, 0.82, 1); c.value:SetTextColor(0.62, 0.82, 1); c.fill:SetColorTexture(0.62, 0.82, 1, 0.9)
  else
    c.title:SetFont(F_SEMI, 11); c.value:SetFont(F_BOLD, 12)
    c.title:SetTextColor(0.55, 0.58, 0.64); c.value:SetTextColor(0.91, 0.92, 0.94); c.fill:SetColorTexture(0.62, 0.82, 1, 0.35)
  end
  c.title:SetText(title); c.value:SetText(value or "")
  c:SetHeight(h); c.track:SetHeight(bh); c.fill:SetHeight(bh)
  local bar = type(frac) == "number"
  c.track:SetShown(bar); c.fill:SetShown(bar)
  if bar then c.fill:SetWidth(math.max(1, TW * math.min(1, frac))) end
  c:ClearAllPoints(); c:SetPoint("TOPLEFT", 14, y); c:SetPoint("TOPRIGHT", -14, y); c:Show()
  return y - h
end

local function drawTimes(y)
  y = y - 6
  tSep:ClearAllPoints(); tSep:SetPoint("TOPLEFT", 14, y); tSep:SetPoint("TOPRIGHT", -14, y); tSep:Show()
  y = y - 10
  tHead:ClearAllPoints(); tHead:SetPoint("TOPLEFT", 14, y); tHead:Show()
  y = y - 20

  local lvl = UnitLevel("player")
  local rec = fxbRecord()
  local hist = mergedHistory(rec)
  local list = {}
  if lvl < MAXLVL then
    local el = levelElapsed(rec)
    if el and el > 0 then list[1] = {L = lvl, d = el, now = true} end
  end
  local sum, n = 0, 0
  for i = #hist, 1, -1 do
    local x = hist[i]
    if x.L < lvl then
      list[#list + 1] = x; sum = sum + x.d; n = n + 1
      if n >= DB.timesCount then break end
    end
  end

  for _, c in ipairs(tRows) do c:Hide() end
  tAvgLine:Hide()
  if #list == 0 then return placeTime(1, y, T("noTimes")) end

  local mx = 0
  for _, x in ipairs(list) do mx = math.max(mx, x.d) end
  for i, x in ipairs(list) do
    y = placeTime(i, y, T("level") .. " " .. x.L, dur(x.d), x.d / mx, x.now)
  end
  if n >= 2 then
    y = y - 4
    tAvgLine:ClearAllPoints(); tAvgLine:SetPoint("TOPLEFT", 14, y); tAvgLine:SetPoint("TOPRIGHT", -14, y); tAvgLine:Show()
    y = placeTime(#list + 1, y - 4, T("avg"), "|cffffd24a" .. dur(sum / n) .. "|r")
  end
  return y
end

-- ---------- aktive XP-buffs som smaa "chips": ikon, procent, tid tilbage ----------
local FOOD_ICON = "Interface\\Icons\\Spell_Misc_Food"
local BAG_ICON = "Interface\\Icons\\INV_Drink_15"

local function activeBuffs()
  local list = {}
  if fedLeft() > 0 then list[#list + 1] = {icon = buffs.fedIcon or FOOD_ICON, pct = "+5%", left = fedLeft()} end
  if bagLeft() > 0 then list[#list + 1] = {icon = buffs.bagIcon or BAG_ICON, pct = "+" .. (buffs.bagStacks or 1) .. "%", left = bagLeft()} end
  return list
end

local function placeChips(parent, store, list, x, y)
  for i, b in ipairs(list) do
    local c = store[i]
    if not c then
      c = CreateFrame("Frame", nil, parent); c:SetHeight(16)
      c.icon = c:CreateTexture(nil, "ARTWORK"); c.icon:SetSize(14, 14); c.icon:SetPoint("LEFT")
      c.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      c.pct = fs(c, F_BOLD, 11); c.pct:SetPoint("LEFT", c.icon, "RIGHT", 5, 0); c.pct:SetTextColor(0.62, 0.82, 1)
      c.time = fs(c, F_SEMI, 11); c.time:SetPoint("LEFT", c.pct, "RIGHT", 4, 0); c.time:SetTextColor(0.55, 0.58, 0.64)
      store[i] = c
    end
    c.icon:SetTexture(b.icon); c.pct:SetText(b.pct); c.time:SetText(dur(b.left))
    local w = 14 + 5 + (c.pct:GetStringWidth() or 0) + 4 + (c.time:GetStringWidth() or 0)
    c:SetWidth(w); c:ClearAllPoints(); c:SetPoint("LEFT", parent, "TOPLEFT", x, y); c:Show()
    x = x + w + 14
  end
  for i = #list + 1, #store do store[i]:Hide() end
end
local winChips = {}

-- ---------- XP-bar ----------
local BW = 460
local bar = CreateFrame("Frame", "LevelETABar", UIParent)
bar:SetSize(BW, 96); bar:Hide()
skin(bar, "Bar", 920, 1024)
movable(bar, function() return not DB.locked end)
bar:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local p, _, rp, x, y = self:GetPoint()
  DB.barPoint = {p, rp, x, y}
end)

local bLogo = bar:CreateTexture(nil, "ARTWORK"); bLogo:SetSize(18, 18); bLogo:SetPoint("LEFT", bar, "TOPLEFT", 14, -18); bLogo:SetTexture(LOGO)
local bLevel = fs(bar, F_BOLD, 14); bLevel:SetPoint("LEFT", bLogo, "RIGHT", 6, 0)
local bPct = fs(bar, F_BOLD, 14); bPct:SetPoint("RIGHT", bar, "TOPRIGHT", -14, -18); bPct:SetTextColor(0.62, 0.82, 1)
local bXP = fs(bar, F_SEMI, 11); bXP:SetPoint("RIGHT", bPct, "LEFT", -10, 0); bXP:SetTextColor(0.36, 0.38, 0.44)
local barChips = {}

-- bjaelken: baggrund, nuvaerende XP (blaa), quests klar (guld), rested (lyseblaa), afrundet med en maske
local track = CreateFrame("Frame", nil, bar)
track:SetPoint("TOPLEFT", 14, -30); track:SetPoint("TOPRIGHT", -14, -30); track:SetHeight(16)
local TRW = BW - 28
local mask
if track.CreateMaskTexture then
  mask = track:CreateMaskTexture()
  if mask then
    mask:SetTexture(TEX .. "BarMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(track)
  end
end
local function barTex(layer, sub, r, g, b, a)
  local t = track:CreateTexture(nil, layer, nil, sub)
  t:SetColorTexture(r, g, b, a)
  t:SetPoint("TOP"); t:SetPoint("BOTTOM")
  if mask and t.AddMaskTexture then t:AddMaskTexture(mask) end
  return t
end
local segBg = barTex("BACKGROUND", 0, 1, 1, 1, 0.06); segBg:SetPoint("LEFT"); segBg:SetPoint("RIGHT")
local segCur = barTex("ARTWORK", 3, 0.62, 0.82, 1, 0.92)
local segQuest = barTex("ARTWORK", 2, 1, 0.82, 0.29, 0.8)
local segRest = barTex("ARTWORK", 1, 0.62, 0.82, 1, 0.43)
for i = 1, 9 do
  local t = track:CreateTexture(nil, "OVERLAY")
  t:SetColorTexture(0, 0, 0, 0.18); t:SetSize(1, 10)
  t:SetPoint("CENTER", track, "LEFT", TRW * i / 10, 0)
end
local function setSeg(t, from, to)
  from, to = math.max(0, math.min(1, from)), math.max(0, math.min(1, to))
  if to - from < 0.002 then t:Hide(); return end
  t:ClearAllPoints(); t:SetPoint("TOP"); t:SetPoint("BOTTOM")
  t:SetPoint("LEFT", track, "LEFT", TRW * from, 0); t:SetWidth(TRW * (to - from)); t:Show()
end

-- fire tal under bjaelken
local cols = {}
local CW = (BW - 28) / 4
for i = 1, 4 do
  local x = 14 + CW * (i - 1)
  local c = {}
  c.dot = bar:CreateTexture(nil, "ARTWORK"); c.dot:SetSize(6, 6); c.dot:SetTexture(TEX .. "Dot")
  c.dot:SetPoint("LEFT", bar, "TOPLEFT", x, -60)
  c.label = fs(bar, F_SEMI, 9.5); c.label:SetTextColor(0.55, 0.58, 0.64)
  c.value = fs(bar, F_BOLD, 13); c.value:SetPoint("LEFT", bar, "TOPLEFT", x, -77)
  c.x = x
  if i > 1 then
    local sep = bar:CreateTexture(nil, "ARTWORK"); sep:SetColorTexture(1, 1, 1, 0.06)
    sep:SetSize(1, 30); sep:SetPoint("TOPLEFT", x - 10, -54)
    c.sep = sep
  end
  cols[i] = c
end
local function setCol(i, labelKey, value, r, g, b, dot)
  local c = cols[i]
  c.label:SetText(T(labelKey)); c.value:SetText(value); c.value:SetTextColor(r, g, b)
  c.label:ClearAllPoints()
  if dot then
    c.dot:SetVertexColor(dot[1], dot[2], dot[3]); c.dot:Show()
    c.label:SetPoint("LEFT", bar, "TOPLEFT", c.x + 10, -60)
  else
    c.dot:Hide(); c.label:SetPoint("LEFT", bar, "TOPLEFT", c.x, -60)
  end
end

local function kfmt(n)
  n = math.floor(n + 0.5)
  if n >= 1000 then return string.format("%.1fk", n / 1000) end
  return tostring(n)
end
local function commas(n)
  local s = tostring(math.floor(n + 0.5))
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- XP du rent faktisk har faaet pr. time de sidste 30 min (med rested og buffs), som ForeverXP Bar viser
local function liveXPh()
  local winStart = DB.play - 1800
  local sum, first = 0, nil
  for i = #DB.samples, 1, -1 do
    local x = DB.samples[i]
    if x.p < winStart then break end
    sum = sum + x.xp; first = x.p
  end
  local span = math.min(1800, DB.play - (DB.sessionStart or 0))
  if span >= 120 and sum > 0 then return sum / span * 3600 end
  return nil
end

local function restedPct(mx)
  local p = mx > 0 and restedXP() / mx * 100 or 0
  if p >= 10 then return string.format("%d%%", math.floor(p + 0.5)) end
  return string.format("%.1f%%", p)
end

local barH = 96
local function updateBar(r, head)
  if not DB.showBar or UnitLevel("player") >= MAXLVL then bar:Hide(); return end
  bar:SetScale(DB.barScale); bar:Show()
  barH = DB.showStats and 96 or 56
  bar:SetHeight(barH)
  for _, c in ipairs(cols) do
    c.label:SetShown(DB.showStats); c.value:SetShown(DB.showStats)
    if not DB.showStats then c.dot:Hide() end
    if c.sep then c.sep:SetShown(DB.showStats) end
  end
  local lvl, xp, mx = UnitLevel("player"), UnitXP("player"), UnitXPMax("player")
  if not mx or mx <= 0 then return end
  bLevel:SetText(T("level") .. " " .. lvl)
  bPct:SetText(math.floor(xp / mx * 100) .. "%")
  bXP:SetText(kfmt(xp) .. " / " .. kfmt(mx) .. " XP")
  local q = math.min(questXP(), mx - xp)
  local rs = math.min(restedXP(), math.max(0, mx - xp - q))
  setSeg(segCur, 0, xp / mx); setSeg(segQuest, xp / mx, (xp + q) / mx); setSeg(segRest, (xp + q) / mx, (xp + q + rs) / mx)
  placeChips(bar, barChips, DB.showBuffsBar and activeBuffs() or {}, 14 + 18 + 6 + (bLevel:GetStringWidth() or 60) + 14, -18)
  if not DB.showStats then return end

  local xph = liveXPh() or (r * 3600)
  setCol(1, "xph", kfmt(xph), 0.91, 0.92, 0.94)
  setCol(2, "nextLevel", dur(timeTo(lvl + 1, r, head)), 0.62, 0.82, 1)
  setCol(3, "questsReady", "+" .. kfmt(questXP()), 1, 0.82, 0.29, {1, 0.82, 0.29})
  setCol(4, "rested", restedPct(mx), 0.75, 0.88, 1, {0.62, 0.82, 1})
end

-- session: nulstilles ved ny login, ikke ved /reload
local function sess()
  DB.sess = DB.sess or {start = time(), xp = 0, kills = 0, quests = 0, levels = 0}
  return DB.sess
end

bar:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:AddLine(NAME, 1, 0.82, 0.3)
  local xp, mx = UnitXP("player"), UnitXPMax("player")
  local left = math.max(0, mx - xp)
  GameTooltip:AddDoubleLine(T("xpLeft"), commas(left), 0.85, 0.85, 0.85, 1, 1, 1)
  if DB.lastKill and DB.lastKill > 0 then
    GameTooltip:AddDoubleLine(T("killsTo"), "~" .. math.max(1, math.ceil(left / DB.lastKill)), 0.85, 0.85, 0.85, 1, 0.6, 0.55)
  end
  local qr = DB.questRewards
  if #qr > 0 then
    local sum = 0
    for _, v in ipairs(qr) do sum = sum + v end
    GameTooltip:AddDoubleLine(T("questsTo"), "~" .. math.max(1, math.ceil(left / (sum / #qr))), 0.85, 0.85, 0.85, 1, 0.82, 0.29)
  end
  local s = sess()
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(T("session"), 1, 0.82, 0.3)
  GameTooltip:AddDoubleLine(T("sessTime"), dur(time() - s.start), 0.85, 0.85, 0.85, 1, 1, 1)
  GameTooltip:AddDoubleLine(T("sessXP"), "+" .. commas(s.xp), 0.85, 0.85, 0.85, 1, 1, 1)
  GameTooltip:AddDoubleLine(T("sessKills"), tostring(s.kills), 0.85, 0.85, 0.85, 1, 1, 1)
  GameTooltip:AddDoubleLine(T("sessQuests"), tostring(s.quests), 0.85, 0.85, 0.85, 1, 1, 1)
  if s.levels > 0 then GameTooltip:AddDoubleLine(T("sessLevels"), "+" .. s.levels, 0.85, 0.85, 0.85, 1, 1, 1) end
  local list = activeBuffs()
  if #list > 0 then
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(T("buffsHead"), 1, 0.82, 0.3)
    if fedLeft() > 0 then GameTooltip:AddDoubleLine(T("foodTip"), dur(fedLeft()), 0.85, 0.85, 0.85, 0.62, 0.82, 1) end
    if bagLeft() > 0 then
      GameTooltip:AddDoubleLine(string.format(T("bagTip"), buffs.bagStacks or 1), dur(bagLeft()), 0.85, 0.85, 0.85, 0.62, 0.82, 1)
    end
  end
  GameTooltip:Show()
end)
bar:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Blizzards egen XP-bar (samme rammer som ForeverXP Bar skjuler)
local BLIZZ_BARS = {"StatusTrackingBarManager", "MainStatusTrackingBarContainer", "MainMenuBarXPBar",
  "MainMenuExpBar", "MainMenuBarExpBar", "MainMenuBarMaxLevelBar", "ReputationWatchBar"}
local function applyBlizz()
  for _, name in ipairs(BLIZZ_BARS) do
    local fr = _G[name]
    if fr and type(fr.Hide) == "function" and type(fr.Show) == "function" then
      pcall(function()
        if not fr.levelETAHooked and hooksecurefunc then
          fr.levelETAHooked = true
          hooksecurefunc(fr, "Show", function(self) if DB and DB.hideBlizz then self:Hide() end end)
        end
        if DB.hideBlizz then fr:Hide() elseif fr.levelETAHid then fr:Show() end
        fr.levelETAHid = DB.hideBlizz
      end)
    end
  end
end

-- ---------- aktivitet: hvad bruger du tiden paa, et sekund ad gangen ----------
-- aktiv = i kamp, eller XP / quest inden for de sidste 25 sek (samme regel som ForeverXP Bar)
local ACT_CATS = {"active", "travel", "flight", "town", "idle", "dead"}
local CAT_KEY = {active = "catActive", travel = "catTravel", flight = "catFlight", town = "catTown", idle = "catIdle", dead = "catDead"}
local ACTIVE_GRACE = 25
local lastActiveAt = -1000
local TOWN_FRAMES = {"MerchantFrame", "MailFrame", "AuctionFrame", "AuctionHouseFrame", "BankFrame", "TradeFrame",
  "GuildBankFrame", "ClassTrainerFrame"}

local function flag(fn, ...)
  if not fn then return false end
  local ok, v = pcall(fn, ...)
  if not ok then return false end
  if issecretvalue then
    local o2, secret = pcall(issecretvalue, v)
    if not o2 or secret then return false end
  end
  return v and true or false
end

local function classify()
  if flag(UnitIsDeadOrGhost, "player") then return "dead" end
  if flag(UnitOnTaxi, "player") then return "flight" end
  if (InCombatLockdown and InCombatLockdown()) or clock() - lastActiveAt < ACTIVE_GRACE then return "active" end
  for _, n in ipairs(TOWN_FRAMES) do
    local fr = _G[n]
    if fr and fr.IsShown and flag(fr.IsShown, fr) then return "town" end
  end
  if flag(IsResting) then return "town" end
  if flag(UnitIsAFK, "player") then return "idle" end
  local sp
  if GetUnitSpeed then
    local ok, v = pcall(GetUnitSpeed, "player")
    sp = ok and num(v)
  end
  if sp and sp > 0 then return "travel" end
  return "idle"
end

local function actTable(t)
  t.total = t.total or 0
  return t
end
local function levelAct(lvl)
  lvl = lvl or UnitLevel("player")
  DB.act[lvl] = DB.act[lvl] or {total = 0}
  return DB.act[lvl]
end

local function sampleActivity(dt)
  local cat = classify()
  local a = actTable(levelAct())
  a[cat] = (a[cat] or 0) + dt; a.total = a.total + dt
  local s = sess(); s.act = actTable(s.act or {})
  s.act[cat] = (s.act[cat] or 0) + dt; s.act.total = s.act.total + dt
  local on = (cat == "active") and 1 or 0
  if not DB.actEma then DB.actEma = (a.total > 60 and (a.active or 0) / a.total) or 0.6 end
  if not DB.actLong then DB.actLong = DB.actEma end
  DB.actEma = DB.actEma + (on - DB.actEma) * math.min(1, dt / 600)    -- de sidste ca. 10 min
  DB.actLong = DB.actLong + (on - DB.actLong) * math.min(1, dt / 7200) -- dit normale niveau, ca. 2 timer
end

-- ---------- maal: et level inden en bestemt tid ----------
local function goalDay()
  if not DB.goalAt then return 3 end
  return math.max(0, math.floor((midnight(DB.goalAt) - midnight(time())) / 86400 + 0.5))
end
local function goalMin()
  if not DB.goalAt then return 22 * 60 end
  local d = date("*t", DB.goalAt)
  return d.hour * 60 + d.min
end
local function setGoal(day, m)
  local d = date("*t")
  d.day, d.hour, d.min, d.sec = d.day + day, math.floor(m / 60), m % 60, 0
  DB.goalAt = time(d)
end

-- hvor aktiv du skal vaere for at naa maalet: dit normale aktivitetsniveau gange hvor meget
-- hurtigere end dit tempo nu du skal gaa (spilletid du skal bruge / spilletid du har)
local function goalInfo(rL, head)
  if not DB.goalOn or not DB.goalAt then return nil end
  local g = {level = DB.goalLevel, at = DB.goalAt}
  if UnitLevel("player") >= g.level then g.done = true; return g end
  local need = timeTo(g.level, rL, head)
  g.finish = eta(need, rL)
  g.diff = g.at - g.finish
  local avail = playableUntil(g.at)
  g.req = avail > 0 and (DB.actLong or 0.6) * need / avail or 9
  return g
end

-- lange tider (over et doegn) i dage og timer
local function longDur(sec)
  if sec < 86400 then return dur(sec) end
  return string.format(T("dh"), math.floor(sec / 86400), math.floor(sec % 86400 / 3600))
end

-- ---------- den lille boks ved siden af XP-baren ----------
local VH = 56
local box = CreateFrame("Button", "LevelETAActivity", bar)
box:SetSize(40, 96); box:SetPoint("TOPLEFT", bar, "TOPRIGHT", 6, 0)
skin(box, "Side", 80, 128)
box:RegisterForClicks("LeftButtonUp")
box:RegisterForDrag("LeftButton")
box:SetScript("OnDragStart", function() if not DB.locked then bar:StartMoving() end end)
box:SetScript("OnDragStop", function() local fn = bar:GetScript("OnDragStop"); if fn then fn(bar) end end)
local vt = CreateFrame("Frame", nil, box)
vt:SetSize(8, VH); vt:SetPoint("TOP", box, "TOP", 0, -14)
local vmask
if vt.CreateMaskTexture then
  vmask = vt:CreateMaskTexture()
  if vmask then
    vmask:SetTexture(TEX .. "VMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    vmask:SetAllPoints(vt)
  end
end
local vbg = vt:CreateTexture(nil, "BACKGROUND"); vbg:SetAllPoints(); vbg:SetColorTexture(1, 1, 1, 0.08)
local vfill = vt:CreateTexture(nil, "ARTWORK"); vfill:SetPoint("BOTTOMLEFT"); vfill:SetPoint("BOTTOMRIGHT"); vfill:SetHeight(1)
if vmask then
  if vbg.AddMaskTexture then vbg:AddMaskTexture(vmask) end
  if vfill.AddMaskTexture then vfill:AddMaskTexture(vmask) end
end
local vmark = box:CreateTexture(nil, "OVERLAY"); vmark:SetSize(14, 2); vmark:SetColorTexture(1, 1, 1, 0.92)
local vtext = fs(box, F_BOLD, 10); vtext:SetPoint("CENTER", box, "TOP", 0, -83)

local GREEN, YELLOW, RED = {0.47, 0.86, 0.59}, {1, 0.82, 0.29}, {1, 0.42, 0.42}
local lastGoal

local function updateActivity(rL, head)
  if not DB.showAct then box:Hide(); return end
  box:Show()
  box:SetHeight(barH)
  if barH >= 90 then VH = 56; vt:SetPoint("TOP", box, "TOP", 0, -14); vtext:Show()
  else VH = barH - 22; vt:SetPoint("TOP", box, "TOP", 0, -11); vtext:Hide() end
  vt:SetHeight(VH)
  local v = DB.actEma or 0.6
  local g = goalInfo(rL, head)
  lastGoal = g
  local col
  if g and not g.done then
    col = (g.req <= 1 and v >= g.req) and GREEN or RED
    vmark:ClearAllPoints(); vmark:SetPoint("CENTER", vt, "BOTTOM", 0, VH * math.min(1, g.req)); vmark:Show()
  else
    col = (g and g.done) and GREEN or (v >= 0.75 and GREEN) or (v >= 0.5 and YELLOW) or RED
    vmark:Hide()
  end
  vfill:SetHeight(math.max(1, VH * math.max(0, math.min(1, v))))
  vfill:SetColorTexture(col[1], col[2], col[3], 0.92)
  vtext:SetText(math.floor(v * 100 + 0.5) .. "%"); vtext:SetTextColor(col[1], col[2], col[3])
end

local function addShares(t, title)
  if not t or (t.total or 0) < 60 then return end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(title, 1, 0.82, 0.3)
  for _, k in ipairs(ACT_CATS) do
    local secs = t[k] or 0
    if secs >= 1 then
      GameTooltip:AddDoubleLine(T(CAT_KEY[k]), string.format("%d%%  %s", math.floor(secs / t.total * 100 + 0.5), dur(secs)),
        0.85, 0.85, 0.85, 1, 1, 1)
    end
  end
  if (t.deaths or 0) > 0 then GameTooltip:AddDoubleLine(T("deaths"), tostring(t.deaths), 0.85, 0.85, 0.85, 1, 0.42, 0.42) end
end

box:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:AddLine(T("actHead"), 1, 0.82, 0.3)
  GameTooltip:AddDoubleLine(T("actLast"), math.floor((DB.actEma or 0.6) * 100 + 0.5) .. "%", 0.85, 0.85, 0.85, 1, 1, 1)
  addShares(levelAct(), T("thisLevel"))
  addShares(sess().act, T("thisSession"))
  local g = lastGoal
  GameTooltip:AddLine(" ")
  if g then
    GameTooltip:AddLine(T("goalHead"), 1, 0.82, 0.3)
    GameTooltip:AddLine(T("level") .. " " .. g.level .. ", " .. nice(g.at), 0.85, 0.85, 0.85)
    if g.done then
      GameTooltip:AddLine(T("goalDone"), GREEN[1], GREEN[2], GREEN[3])
    elseif g.req > 1 then
      GameTooltip:AddLine(T("impossible"), RED[1], RED[2], RED[3])
      GameTooltip:AddDoubleLine(T("atPace"), nice(g.finish, 15), 0.85, 0.85, 0.85, 1, 1, 1)
    else
      GameTooltip:AddDoubleLine(T("needAct"), math.floor(g.req * 100 + 0.5) .. "%", 0.85, 0.85, 0.85, 1, 1, 1)
      GameTooltip:AddDoubleLine(T("atPace"), nice(g.finish, 15), 0.85, 0.85, 0.85, 1, 1, 1)
      if g.diff >= 0 then
        GameTooltip:AddDoubleLine(T("ahead"), longDur(g.diff), 0.85, 0.85, 0.85, GREEN[1], GREEN[2], GREEN[3])
      else
        GameTooltip:AddDoubleLine(T("behind"), longDur(-g.diff), 0.85, 0.85, 0.85, RED[1], RED[2], RED[3])
      end
    end
  end
  GameTooltip:AddLine(T("clickGoal"), 0.6, 0.6, 0.6)
  GameTooltip:Show()
end)
box:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- de tre faste raekker
local function mainRows(y)
  local lvl = UnitLevel("player")
  if lvl >= MAXLVL then
    if DB.showToday or DB.showNext or DB.show60 then return setRow(rows[1], y, T("done"), "", nil, true) end
    return y
  end

  local r = shortRate()
  local rL = longRate()
  local head = headStart(r)
  local list = {}

  -- level ved sengetid, med bjaelke for hvor langt inde i levelet
  if DB.showToday and DB.schedule and DB.sleepStart ~= DB.sleepEnd then
    local d = date("*t")
    local nowMin = d.hour * 60 + d.min
    d.hour, d.min, d.sec = math.floor(DB.sleepStart / 60), DB.sleepStart % 60, 0
    local bt, key = time(d), "today"
    if nowMin >= DB.sleepStart then bt, key = bt + 86400, "tomorrow" end
    local at = levelAfter(playableUntil(bt), r, head)
    if at >= MAXLVL then
      list[#list + 1] = {string.format(T(key), hhmm(DB.sleepStart)), "|cff9fd0ff" .. T("level") .. " 60|r"}
    else
      local p = at % 1
      list[#list + 1] = {string.format(T(key), hhmm(DB.sleepStart)),
        string.format("|cff9fd0ff%s %d|r  |cff5c6270%d%%|r", T("level"), math.floor(at), math.floor(p * 100)), p}
    end
  end
  -- naeste tiende level og level 60
  local mile = (math.floor(lvl / 10) + 1) * 10
  if DB.showNext and mile < MAXLVL then
    list[#list + 1] = {T("level") .. " " .. mile, "|cffe8eaf0" .. nice(eta(timeTo(mile, rL, head), rL), 15) .. "|r"}
  end
  if DB.show60 then
    list[#list + 1] = {T("level") .. " 60", "|cffffd24a" .. nice(eta(timeTo(MAXLVL, rL, head), rL), 30) .. "|r"}
  end

  for i, it in ipairs(list) do y = setRow(rows[i], y, it[1], it[2], it[3], i == #list) end
  return y, r, head, rL
end

local function refresh()
  if not DB then return end
  if buffsDirty then scanBuffs() end
  f:SetScale(DB.scale)
  updateLabels()
  for _, c in ipairs(rows) do c:Hide() end
  local y, r, head, rL = mainRows(-44)
  local list = DB.showBuffsWin and activeBuffs() or {}
  if #list > 0 then
    placeChips(f, winChips, list, 14, y - 12); y = y - 22
  else
    placeChips(f, winChips, list, 0, 0)
  end
  if DB.showTimes then y = drawTimes(y) else hideTimes() end
  f:SetHeight(-y + 10)
  f:SetShown(not DB.hidden and y < -44)  -- intet at vise: skjul vinduet helt
  if LevelETAMinimapButton then LevelETAMinimapButton:SetShown(DB.showMinimap) end
  r = r or shortRate()
  head = head or headStart(r)
  updateBar(r, head)
  if bar:IsShown() then updateActivity(rL or longRate(), head) end
end

-- indstillinger og maal-vindue i egen blok (Lua tillader kun 200 lokale variabler i filen)
local S, controls, toggleSettings, toggleWindow, toggleGoal
do
-- ---------- indstillinger ----------
local SW, COL = 520, 260
S = CreateFrame("Frame", "LevelETASettings", UIParent)
S:SetSize(SW, 446); S:SetPoint("CENTER"); S:SetFrameStrata("DIALOG"); S:Hide()
skin(S, "Wide", 1040, 2048)
movable(S, function() return true end)
S:SetScript("OnDragStop", S.StopMovingOrSizing)
tinsert(UISpecialFrames, "LevelETASettings")  -- Esc lukker
local sTitle = header(S)
label(sTitle, "settings")

local closeX = CreateFrame("Button", nil, S)
closeX:SetSize(20, 20); closeX:SetPoint("TOPRIGHT", -10, -10)
local closeT = fs(closeX, F_BOLD, 16); closeT:SetPoint("CENTER"); closeT:SetText("×"); closeT:SetTextColor(0.55, 0.58, 0.64)
closeX:SetScript("OnEnter", function() closeT:SetTextColor(1, 1, 1) end)
closeX:SetScript("OnLeave", function() closeT:SetTextColor(0.55, 0.58, 0.64) end)
closeX:SetScript("OnClick", function() S:Hide() end)

controls = {}
local colX = 0
local host, hostControls = S, controls  -- hvilket vindue byggeklodserne tegner paa

local function section(y, key)
  local t = fs(host, F_BOLD, 11); t:SetPoint("TOPLEFT", colX + 18, y); t:SetTextColor(1, 0.82, 0.4)
  label(t, key)
end

local function toggle(y, lkey, get, set)
  local c = CreateFrame("CheckButton", nil, host)
  c:SetSize(32, 18); c:SetPoint("TOPRIGHT", host, "TOPLEFT", colX + COL - 18, y)
  local off = c:CreateTexture(nil, "ARTWORK"); off:SetAllPoints(); off:SetTexture(TEX .. "ToggleOff"); off:SetTexCoord(0, 1, 0, 36 / 64)
  local on = c:CreateTexture(nil, "ARTWORK"); on:SetAllPoints(); on:SetTexture(TEX .. "ToggleOn"); on:SetTexCoord(0, 1, 0, 36 / 64)
  local t = fs(host, F_SEMI, 12); t:SetPoint("TOPLEFT", colX + 18, y - 2); t:SetTextColor(0.85, 0.87, 0.92)
  label(t, lkey)
  local function show() local v = get(); on:SetShown(v); off:SetShown(not v) end
  c:SetScript("OnClick", function() set(not get()); show(); refresh() end)
  c.load = show
  hostControls[#hostControls + 1] = c
end

local function slider(y, lkey, minV, maxV, step, get, set, fmt)
  local t = fs(host, F_SEMI, 12); t:SetPoint("TOPLEFT", colX + 18, y); t:SetTextColor(0.85, 0.87, 0.92)
  label(t, lkey)
  local val = fs(host, F_BOLD, 12); val:SetPoint("TOPRIGHT", host, "TOPLEFT", colX + COL - 18, y); val:SetTextColor(1, 0.82, 0.4)
  local tw = COL - 36
  local s = CreateFrame("Slider", nil, host)
  s:SetOrientation("HORIZONTAL")
  s:SetSize(tw, 16); s:SetPoint("TOPLEFT", colX + 18, y - 18)
  local track = s:CreateTexture(nil, "BACKGROUND")
  track:SetPoint("LEFT"); track:SetPoint("RIGHT"); track:SetHeight(3); track:SetColorTexture(1, 1, 1, 0.12)
  local fill = s:CreateTexture(nil, "ARTWORK")
  fill:SetPoint("LEFT"); fill:SetHeight(3); fill:SetColorTexture(1, 0.8, 0.35, 0.9)
  s:SetThumbTexture(TEX .. "Thumb")
  local thumb = s:GetThumbTexture(); if thumb then thumb:SetSize(16, 16) end
  s:SetMinMaxValues(minV, maxV); s:SetValueStep(step)
  if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
  s:EnableMouseWheel(true)
  s:SetScript("OnMouseWheel", function(self, d)
    self:SetValue(math.max(minV, math.min(maxV, self:GetValue() + d * step)))
  end)
  local function paint(v)
    val:SetText(fmt(v))
    fill:SetWidth(math.max(1, tw * (v - minV) / (maxV - minV)))
  end
  s:SetScript("OnValueChanged", function(self, v)
    v = math.floor(v / step + 0.5) * step
    paint(v)
    if self.loading then return end
    set(v); refresh()
  end)
  s.load = function() s.loading = true; s:SetValue(get()); paint(get()); s.loading = false end
  hostControls[#hostControls + 1] = s
end

local function pill(text, w)
  local b = CreateFrame("Button", nil, host)
  b:SetSize(w, 24)
  local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture(TEX .. "Pill"); bg:SetTexCoord(0, 240 / 256, 0, 48 / 64)
  b.bg = bg
  b.text = fs(b, F_SEMI, 12); b.text:SetPoint("CENTER"); b.text:SetTextColor(0.85, 0.87, 0.92)
  b:SetScript("OnEnter", function() b.text:SetTextColor(1, 0.82, 0.4) end)
  b:SetScript("OnLeave", function() b.text:SetTextColor(0.85, 0.87, 0.92) end)
  return b
end

local clockFmt = function(v) return hhmm(v) end

-- faner: Vindue, XP-bar, Spilletid
local TABS = {"tabWindow", "tabBar", "tabTime"}
local pages, tabBtns = {}, {}
local function paintTabs()
  for k, b in ipairs(tabBtns) do
    local on = k == (DB and DB.tab or 1)
    b.text:SetTextColor(on and 1 or 0.55, on and 0.82 or 0.58, on and 0.4 or 0.64)
    b.bg:SetAlpha(on and 1 or 0.45)
  end
end
local function showTab(i)
  DB.tab = i
  for k, p in ipairs(pages) do p:SetShown(k == i) end
  paintTabs()
end
local TBW = (SW - 36 - 16) / 3
for i, key in ipairs(TABS) do
  local b = pill("", TBW); b:SetPoint("TOPLEFT", 18 + (i - 1) * (TBW + 8), -48); label(b.text, key)
  b:SetScript("OnClick", function() showTab(i) end)
  b:SetScript("OnLeave", paintTabs)
  tabBtns[i] = b
  local pg = CreateFrame("Frame", nil, S); pg:SetAllPoints(S); pg:Hide()
  pages[i] = pg
end
local pctFmt = function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end

-- fane 1: vinduet
host = pages[1]
colX = 0
section(-92, "winSec")
toggle(-114, "showWin", function() return not DB.hidden end, function(v) DB.hidden = not v; f:SetShown(v) end)
toggle(-142, "lock", function() return DB.locked end, function(v) DB.locked = v end)
toggle(-170, "showMinimap", function() return DB.showMinimap end, function(v) DB.showMinimap = v end)
slider(-202, "size", 0.6, 2.0, 0.05, function() return DB.scale end, function(v) DB.scale = v end, pctFmt)
colX = COL
section(-92, "rowsSec")
toggle(-114, "showToday", function() return DB.showToday end, function(v) DB.showToday = v end)
toggle(-142, "showNext", function() return DB.showNext end, function(v) DB.showNext = v end)
toggle(-170, "show60", function() return DB.show60 end, function(v) DB.show60 = v end)
toggle(-198, "showBuffsWin", function() return DB.showBuffsWin end, function(v) DB.showBuffsWin = v end)
section(-236, "timesHead")
toggle(-258, "showTimes", function() return DB.showTimes end, function(v) DB.showTimes = v end)
slider(-290, "timesCount", 3, 30, 1, function() return DB.timesCount end, function(v) DB.timesCount = v end,
  function(v) return tostring(v) end)

-- fane 2: XP-bar
host = pages[2]
colX = 0
section(-92, "barHead")
toggle(-114, "showBar", function() return DB.showBar end, function(v) DB.showBar = v end)
toggle(-142, "hideBlizz", function() return DB.hideBlizz end, function(v) DB.hideBlizz = v; applyBlizz() end)
slider(-174, "barSize", 0.6, 2.0, 0.05, function() return DB.barScale end, function(v) DB.barScale = v end, pctFmt)
colX = COL
section(-92, "onBar")
toggle(-114, "showStats", function() return DB.showStats end, function(v) DB.showStats = v end)
toggle(-142, "showBuffsBar", function() return DB.showBuffsBar end, function(v) DB.showBuffsBar = v end)
toggle(-170, "showAct", function() return DB.showAct end, function(v) DB.showAct = v end)
local goalBtn = pill("", 120); goalBtn:SetPoint("TOPLEFT", COL + 18, -206); label(goalBtn.text, "setGoal")

-- fane 3: spilletid, quests og rested
host = pages[3]
colX = 0
section(-92, "rhythm")
toggle(-114, "useRhythm", function() return DB.schedule end, function(v) DB.schedule = v end)
slider(-146, "wake", 0, 1410, 30, function() return DB.sleepEnd end, function(v) DB.sleepEnd = v end, clockFmt)
slider(-192, "bed", 0, 1410, 30, function() return DB.sleepStart end, function(v) DB.sleepStart = v end, clockFmt)
slider(-238, "breakAt", 0, 1410, 30, function() return DB.breakStart end, function(v) DB.breakStart = v end, clockFmt)
slider(-284, "breakLen", 0, 180, 15, function() return DB.breakLen end, function(v) DB.breakLen = v end,
  function(v) return v == 0 and T("none") or (v .. " " .. T("min")) end)
colX = COL
section(-92, "questSec")
slider(-116, "qBuf", 0, 100, 5, function() return DB.questBuffer end, function(v) DB.questBuffer = v end,
  function(v) return string.format("-%d%%", v) end)
toggle(-162, "inn", function() return DB.inn end, function(v) DB.inn = v end)
host = S

-- info: virker alene og sammen med ForeverXP Bar
local infoLine = S:CreateTexture(nil, "ARTWORK")
infoLine:SetPoint("TOPLEFT", 18, -342); infoLine:SetPoint("TOPRIGHT", -18, -342); infoLine:SetHeight(1)
infoLine:SetColorTexture(1, 1, 1, 0.06)
local infoText = fs(S, F_SEMI, 11); infoText:SetPoint("TOPLEFT", 18, -354); infoText:SetTextColor(0.55, 0.58, 0.64)
label(infoText, "standalone")
local fxbDot = S:CreateTexture(nil, "ARTWORK")
fxbDot:SetSize(7, 7); fxbDot:SetPoint("TOPLEFT", 19, -374); fxbDot:SetTexture(TEX .. "Dot")
local fxbText = fs(S, F_SEMI, 11); fxbText:SetPoint("TOPLEFT", 32, -372)

-- knapper i bunden
local langBtn = pill("", 140); langBtn:SetPoint("BOTTOMLEFT", 18, 16); label(langBtn.text, "language")
langBtn:SetScript("OnClick", function()
  DB.lang = (DB.lang == "da") and "en" or "da"
  updateLabels(); refresh()
  for _, c in ipairs(controls) do c.load() end
end)
local resetBtn = pill("", 130); resetBtn:SetPoint("LEFT", langBtn, "RIGHT", 10, 0); label(resetBtn.text, "reset")
resetBtn:SetScript("OnClick", function()
  DB.samples = {}; DB.sessionStart = DB.play; DB.eS = nil; DB.eL = nil; refresh()
end)
local doneBtn = pill("", 100); doneBtn:SetPoint("BOTTOMRIGHT", -18, 16); label(doneBtn.text, "close")
doneBtn:SetScript("OnClick", function() S:Hide() end)

-- maal-vinduet (aabnes fra aktivitets-boksen, knappen her eller /lp goal)
local G = CreateFrame("Frame", "LevelETAGoal", UIParent)
G:SetSize(260, 290); G:SetPoint("CENTER", 0, 40); G:SetFrameStrata("DIALOG"); G:Hide()
skin(G, "Panel", 520, 1024)
movable(G, function() return true end)
G:SetScript("OnDragStop", G.StopMovingOrSizing)
tinsert(UISpecialFrames, "LevelETAGoal")
label(header(G), "goalHead")
local gX = CreateFrame("Button", nil, G)
gX:SetSize(20, 20); gX:SetPoint("TOPRIGHT", -10, -10)
local gXT = fs(gX, F_BOLD, 16); gXT:SetPoint("CENTER"); gXT:SetText("×"); gXT:SetTextColor(0.55, 0.58, 0.64)
gX:SetScript("OnClick", function() G:Hide() end)

local goalControls = {}
host, hostControls, colX = G, goalControls, 0
toggle(-52, "useGoal", function() return DB.goalOn end, function(v)
  DB.goalOn = v
  if v and not DB.goalAt then setGoal(goalDay(), goalMin()) end
end)
slider(-84, "goalLevel", 2, MAXLVL, 1, function() return DB.goalLevel end, function(v) DB.goalLevel = v end,
  function(v) return tostring(v) end)
slider(-130, "goalDay", 0, 14, 1, goalDay, function(v) setGoal(v, goalMin()) end, function(v)
  if v == 0 then return T("todayW") elseif v == 1 then return T("tomorrowW") end
  local d = date("*t", time() + v * 86400)
  if v < 7 then return T("daysFull")[d.wday] end
  return DB.lang == "da" and string.format("%d. %s", d.day, T("months")[d.month]) or string.format("%s %d", T("months")[d.month], d.day)
end)
slider(-176, "goalTime", 0, 1410, 30, goalMin, function(v) setGoal(goalDay(), v) end, clockFmt)
local gSum = fs(G, F_BOLD, 12); gSum:SetPoint("TOPLEFT", 18, -226); gSum:SetTextColor(1, 0.82, 0.4)
local gDone = pill("", 100); gDone:SetPoint("BOTTOMRIGHT", -18, 16); label(gDone.text, "close")
gDone:SetScript("OnClick", function() G:Hide() end)
host, hostControls = S, controls

local function paintGoalSummary()
  if DB.goalOn and DB.goalAt then
    gSum:SetText(T("level") .. " " .. DB.goalLevel .. ", " .. nice(DB.goalAt))
  else
    gSum:SetText("")
  end
end
G:SetScript("OnShow", function()
  updateLabels()
  for _, c in ipairs(goalControls) do c.load() end
  paintGoalSummary()
end)
local gAcc = 0
G:SetScript("OnUpdate", function(_, el)
  gAcc = gAcc + el
  if gAcc > 0.2 then gAcc = 0; paintGoalSummary() end
end)
toggleGoal = function() G:SetShown(not G:IsShown()) end
box:SetScript("OnClick", toggleGoal)

goalBtn:SetScript("OnClick", toggleGoal)

S:SetScript("OnShow", function()
  updateLabels()
  if fxbRecord() then
    fxbDot:SetVertexColor(0.36, 1, 0.48); fxbText:SetText(T("fxbFound")); fxbText:SetTextColor(0.85, 0.87, 0.92)
  else
    fxbDot:SetVertexColor(0.54, 0.56, 0.6); fxbText:SetText(T("fxbMissing")); fxbText:SetTextColor(0.55, 0.58, 0.64)
  end
  for _, c in ipairs(controls) do c.load() end
  showTab(DB.tab or 1)
end)

toggleSettings = function() S:SetShown(not S:IsShown()) end
toggleWindow = function()
  DB.hidden = f:IsShown()
  f:SetShown(not DB.hidden)
  if S:IsShown() then for _, c in ipairs(controls) do c.load() end end
end
end

-- ---------- minimap-knap ----------
local mmb = CreateFrame("Button", "LevelETAMinimapButton", Minimap)
mmb:SetSize(31, 31); mmb:SetFrameStrata("MEDIUM"); mmb:SetFrameLevel(8)
mmb:RegisterForClicks("LeftButtonUp", "RightButtonUp"); mmb:RegisterForDrag("LeftButton")
mmb:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local mmBg = mmb:CreateTexture(nil, "BACKGROUND")
mmBg:SetSize(20, 20); mmBg:SetPoint("TOPLEFT", 7, -5); mmBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
local mmIcon = mmb:CreateTexture(nil, "ARTWORK")
mmIcon:SetSize(21, 21); mmIcon:SetPoint("TOPLEFT", 5, -5); mmIcon:SetTexture(LOGO)
local mmBorder = mmb:CreateTexture(nil, "OVERLAY")
mmBorder:SetSize(53, 53); mmBorder:SetPoint("TOPLEFT"); mmBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local function placeButton()
  local a = math.rad(DB.mmAngle)
  local rad = (Minimap:GetWidth() / 2) + 5
  mmb:ClearAllPoints()
  mmb:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * rad, math.sin(a) * rad)
end
mmb:SetScript("OnDragStart", function(self)
  self:SetScript("OnUpdate", function()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local sc = Minimap:GetEffectiveScale()
    DB.mmAngle = math.deg(atan2(py / sc - my, px / sc - mx))
    placeButton()
  end)
end)
mmb:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mmb:SetScript("OnClick", function(_, btn) if btn == "RightButton" then toggleSettings() else toggleWindow() end end)
mmb:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine(NAME, 1, 0.82, 0.3)
  if UnitLevel("player") < MAXLVL then
    local rL = longRate()
    local head = headStart(rL)
    GameTooltip:AddDoubleLine(T("level") .. " 60", nice(eta(timeTo(MAXLVL, rL, head), rL), 30), 0.85, 0.85, 0.85, 1, 0.82, 0)
  end
  if fedLeft() > 0 then GameTooltip:AddDoubleLine(T("foodTip"), dur(fedLeft()), 0.85, 0.85, 0.85, 0.62, 0.82, 1) end
  if bagLeft() > 0 then
    GameTooltip:AddDoubleLine(string.format(T("bagTip"), buffs.bagStacks or 1), dur(bagLeft()), 0.85, 0.85, 0.85, 0.62, 0.82, 1)
  end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(T("tipLeft"), 0.6, 0.6, 0.6)
  GameTooltip:AddLine(T("tipRight"), 0.6, 0.6, 0.6)
  GameTooltip:Show()
end)
mmb:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ---------- /played (skjult i chatten) ----------
local wantPlayed = false
local function requestPlayed()
  if not RequestTimePlayed then return end
  wantPlayed = true
  RequestTimePlayed()
end
if ChatFrame_DisplayTimePlayed then
  local orig = ChatFrame_DisplayTimePlayed
  ChatFrame_DisplayTimePlayed = function(...)
    if wantPlayed then return end  -- vores egen forespoergsel: ingen besked i chatten
    return orig(...)
  end
end

-- ---------- events ----------
local lastXP, lastMax, lastLevel, lastEx
local acc = 0

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:RegisterEvent("TIME_PLAYED_MSG")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
-- XP fra et kill staar i chatten: "<mob> dies, you gain N experience." (bygget af spillets egen tekst)
local killPattern
local function killXP(msg)
  if type(msg) ~= "string" then return nil end
  if issecretvalue then
    local ok, secret = pcall(issecretvalue, msg)
    if not ok or secret then return nil end
  end
  if killPattern == nil then
    killPattern = false
    local g = _G.COMBATLOG_XPGAIN_FIRSTPERSON
    if type(g) == "string" and g:find("%%d") then
      local p = g:gsub("%%s", "\1"):gsub("%%d", "\2")
      p = p:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      p = p:gsub("\1", ".-"):gsub("\2", "(%%d+)")
      killPattern = "^" .. p
    end
  end
  local ok, n = pcall(function() return killPattern and msg:match(killPattern) end)
  return ok and tonumber(n) or nil
end

f:SetScript("OnEvent", function(self, event, a1, a2)
  if event == "ADDON_LOADED" and a1 == ADDON then
    LevelETADB = LevelETADB or {}
    DB = LevelETADB
    for k, v in pairs(defaults) do if DB[k] == nil then DB[k] = v end end
    if not DB.sessionStart then DB.sessionStart = DB.play end
    if DB.calcVer ~= 7 then DB.eS, DB.eL, DB.calcVer = nil, nil, 7 end  -- smid gamle udglattede tempi ud
    if (DB.defVer or 0) < 2 then DB.showBar, DB.hideBlizz, DB.defVer = true, true, 2 end  -- XP-baren er nu slaaet til som standard
    self:ClearAllPoints()
    if DB.point then self:SetPoint(DB.point[1], UIParent, DB.point[2], DB.point[3], DB.point[4])
    else self:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -200) end
    if DB.hidden then self:Hide() end
    if LevelETAMinimapButton then LevelETAMinimapButton:SetShown(DB.showMinimap) end
    bar:ClearAllPoints()
    if DB.barPoint then bar:SetPoint(DB.barPoint[1], UIParent, DB.barPoint[2], DB.barPoint[3], DB.barPoint[4])
    else bar:SetPoint("TOP", UIParent, "TOP", -23, -14) end  -- standard: oeverst paa skaermen, midt for (bar + aktivitets-boks)
    placeButton()
  elseif event == "PLAYER_ENTERING_WORLD" then
    if a1 or not DB.sess then DB.sess = {start = time(), xp = 0, kills = 0, quests = 0, levels = 0} end  -- ny login
    applyBlizz()
    lastXP, lastMax, lastLevel, lastEx = UnitXP("player"), UnitXPMax("player"), UnitLevel("player"), restedXP()
    questDirty = true
    if C_Timer and C_Timer.After then C_Timer.After(3, requestPlayed) end
    refresh()
  elseif event == "TIME_PLAYED_MSG" then
    -- chatvinduet faar beskeden foer os; slip spaerringen lidt efter
    if C_Timer and C_Timer.After then C_Timer.After(1, function() wantPlayed = false end) else wantPlayed = false end
    local total, atLevel = a1, a2
    if type(total) == "number" and type(atLevel) == "number" then
      playedLevelTime, playedAt = atLevel, time()
      DB.ptimes[UnitLevel("player")] = total - atLevel  -- praecis start paa dette level
    end
  elseif event == "PLAYER_LEVEL_UP" then
    if C_Timer and C_Timer.After then C_Timer.After(2, requestPlayed) end
  elseif event == "QUEST_LOG_UPDATE" then
    questDirty = true
  elseif event == "UNIT_AURA" then
    if a1 == "player" then buffsDirty = true end
  elseif event == "PLAYER_REGEN_ENABLED" then
    buffsDirty = true
  elseif event == "PLAYER_DEAD" then
    buffs.fedUntil = nil  -- food buff forsvinder ved doed, soveposen bliver
    buffsDirty = true
    local a = levelAct(); a.deaths = (a.deaths or 0) + 1
    local s = sess(); s.act = actTable(s.act or {}); s.act.deaths = (s.act.deaths or 0) + 1
  elseif event == "PLAYER_REGEN_DISABLED" then
    lastActiveAt = clock()
  elseif event == "QUEST_TURNED_IN" then
    lastQuestAt = clock()
    lastActiveAt = clock()
    sess().quests = sess().quests + 1
    if type(a2) == "number" and a2 > 0 then
      table.insert(DB.questRewards, a2)
      while #DB.questRewards > 10 do table.remove(DB.questRewards, 1) end
    end
  elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
    local n = killXP(a1)
    if n and n > 0 then DB.lastKill = n; sess().kills = sess().kills + 1 end
  elseif event == "UPDATE_EXHAUSTION" then
    local ex = restedXP()
    if lastEx and ex > lastEx then lastEx = ex end  -- rested steg (inn), ikke bonus
  elseif event == "PLAYER_XP_UPDATE" then
    local xp, mx, lvl = UnitXP("player"), UnitXPMax("player"), UnitLevel("player")
    local gain
    if lastLevel and lvl > lastLevel then
      gain = (lastMax - lastXP) + xp
      DB.times[lvl] = DB.play
      sess().levels = sess().levels + 1
      playedLevelTime, playedAt = 0, time()
    else
      gain = xp - (lastXP or xp)
    end
    local ex = restedXP()
    local bonus = math.max(0, math.min(gain, (lastEx or ex) - ex))  -- brugt rested = bonus-XP
    if gain > 0 then
      sess().xp = sess().xp + gain
      lastActiveAt = clock()
      -- quest-XP eller kill-XP, og hvor meget af det dine buffs gav (taeller ikke som tempo)
      local q = clock() - lastQuestAt < 2
      local mult = 1 + ((not q and fedLeft() > 0) and FOOD_BONUS or 0) + ((bagLeft() > 0) and (buffs.bagStacks or 0) / 100 or 0)
      local extra = (gain - bonus) * (1 - 1 / mult)
      DB.samples[#DB.samples + 1] = {p = DB.play, xp = gain, b = bonus, e = extra > 0 and extra or nil, q = q or nil}
    end
    local cut = DB.play - WINDOW * 2
    while DB.samples[1] and DB.samples[1].p < cut do table.remove(DB.samples, 1) end
    lastXP, lastMax, lastLevel, lastEx = xp, mx, lvl, ex
    refresh()
  end
end)

local actAcc = 0
f:SetScript("OnUpdate", function(_, el)
  if not DB then return end
  DB.play = DB.play + el
  actAcc = actAcc + el
  if actAcc >= 1 then
    if actAcc <= 5 then sampleActivity(actAcc) end  -- lange pauser (loadskaerm) taeller ikke
    actAcc = 0
  end
  acc = acc + el
  if acc >= 5 then acc = 0; refresh() end
end)

-- ---------- kommandoer ----------
SLASH_LEVELETA1 = "/leveleta"
SLASH_LEVELETA2 = "/lp"
SlashCmdList.LEVELETA = function(msg)
  msg = (msg or ""):lower()
  if msg == "vis" or msg == "show" then toggleWindow()
  elseif msg == "goal" or msg == "mål" or msg == "maal" then toggleGoal()
  else toggleSettings() end
end
