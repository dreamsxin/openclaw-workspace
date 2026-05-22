const ART = "../../reverse-output/gacha-static/sample-export/b61d633c6f7beec5301d9f48ffb87909/by_container/Assets/Game/RawAssets/Spine/Hero/hero_003Dh/hero_003Dh.png";

const HEROES = [
  { id: 240055, name: "天狐妲己", rarity: 4, spine: "hero_016", assets: "zhero_016 / bhero_016 / hero_016" },
  { id: 240065, name: "莉莉絲", rarity: 3, spine: "hero_003", assets: "zhero_003 / bhero_003 / hero_003", art: ART },
  { id: 240069, name: "女帝", rarity: 3, spine: "hero_017", assets: "zhero_017 / bhero_017 / hero_017" },
  { id: 240068, name: "哪吒", rarity: 3, spine: "hero_001", assets: "zhero_001 / bhero_001 / hero_001" },
  { id: 240045, name: "蔡文姬", rarity: 3, spine: "hero_005", assets: "zhero_005 / bhero_005 / hero_005" },
  { id: 240082, name: "阿布羅狄忒", rarity: 3, spine: "hero_018", assets: "待補導出" },
  { id: 240037, name: "阿修羅", rarity: 2, spine: "hero_037", assets: "待補導出" },
  { id: 240062, name: "大喬", rarity: 2, spine: "hero_062", assets: "待補導出" }
];

const POOLS = [
  { id: "normal", name: "普通喚靈", cost: 1, pityLimit: 2000, featured: [240065, 240069, 240068, 240045] },
  { id: "advanced", name: "高級喚靈", cost: 1, pityLimit: 60, featured: [240055, 240065, 240069, 240082] },
  { id: "epic", name: "進階喚靈", cost: 1, pityLimit: 60, featured: [240055, 240069, 240068, 240045] },
  { id: "prayer", name: "源神祈願", cost: 1, pityLimit: 20, featured: [240055] }
];

const DEFAULT_SAVE = {
  tickets: 120,
  gems: 16800,
  owned: {},
  pity: { normal: 0, advanced: 0, epic: 0, prayer: 0 },
  history: [],
  selectedHeroId: 240065,
  activePool: "advanced"
};

let save = loadSave();

function loadSave() {
  const raw = localStorage.getItem("shaonv-single-player-save");
  if (!raw) return structuredClone(DEFAULT_SAVE);
  try {
    return { ...structuredClone(DEFAULT_SAVE), ...JSON.parse(raw) };
  } catch {
    return structuredClone(DEFAULT_SAVE);
  }
}

function persist() {
  localStorage.setItem("shaonv-single-player-save", JSON.stringify(save));
}

function byId(id) {
  return HEROES.find((hero) => hero.id === Number(id)) || HEROES[0];
}

function currentPool() {
  return POOLS.find((pool) => pool.id === save.activePool) || POOLS[1];
}

function switchView(viewId) {
  document.querySelectorAll(".view").forEach((view) => view.classList.toggle("active", view.id === viewId));
  document.querySelectorAll(".nav-button").forEach((button) => button.classList.toggle("active", button.dataset.view === viewId));
  document.getElementById("view-title").textContent = { home: "主界面", gacha: "抽卡", gallery: "圖鑑", history: "記錄" }[viewId];
}

function drawOne(pool) {
  save.pity[pool.id] += 1;
  const forced = save.pity[pool.id] >= pool.pityLimit;
  const roll = Math.random();
  let rarity = 2;
  if (forced || roll < 0.02) rarity = 4;
  else if (roll < 0.14) rarity = 3;

  const candidates = HEROES.filter((hero) => {
    if (rarity === 4) return hero.rarity === 4 || pool.featured.includes(hero.id);
    if (rarity === 3) return hero.rarity === 3;
    return hero.rarity <= 2;
  });
  const featured = candidates.filter((hero) => pool.featured.includes(hero.id));
  const list = rarity >= 3 && featured.length && Math.random() < 0.55 ? featured : candidates;
  const hero = list[Math.floor(Math.random() * list.length)] || HEROES[0];

  if (rarity === 4) save.pity[pool.id] = 0;
  const first = !save.owned[hero.id];
  save.owned[hero.id] = (save.owned[hero.id] || 0) + 1;
  return { ...hero, first, rolledRarity: Math.max(rarity, hero.rarity) };
}

function doDraw(count) {
  const pool = currentPool();
  if (save.tickets < count * pool.cost) return;
  save.tickets -= count * pool.cost;
  const results = Array.from({ length: count }, () => drawOne(pool));
  save.history.unshift({
    time: new Date().toLocaleString("zh-Hant"),
    pool: pool.name,
    results: results.map((hero) => `${hero.name}${hero.first ? "(NEW)" : ""}`)
  });
  save.history = save.history.slice(0, 30);
  persist();
  renderResults(results);
  renderAll();
}

function renderResults(results) {
  const box = document.getElementById("draw-results");
  box.innerHTML = results.map((hero) => `
    <article class="result-card r${hero.rolledRarity}">
      <strong>${hero.name}</strong>
      <small>${"★".repeat(hero.rolledRarity)} / ${hero.spine}</small>
      <div>${hero.first ? "首次獲得" : "轉化碎片"}</div>
    </article>
  `).join("");
}

function renderHome() {
  const hero = byId(save.selectedHeroId);
  document.getElementById("ticket-count").textContent = save.tickets;
  document.getElementById("gem-count").textContent = save.gems;
  document.getElementById("owned-count").textContent = Object.keys(save.owned).length;
  document.getElementById("pity-count").textContent = `${save.pity.advanced || 0}/60`;
  document.getElementById("last-result").textContent = save.history[0]?.results?.[0] || "無";
  document.getElementById("home-hero-name").textContent = hero.name;
  document.getElementById("home-hero-meta").textContent = `${"★".repeat(hero.rarity)} / ${hero.spine}`;
  const art = document.getElementById("home-hero-art");
  art.src = hero.art || ART;
  art.style.opacity = hero.art ? "1" : "0.42";
}

function renderPools() {
  const tabs = document.getElementById("pool-tabs");
  tabs.innerHTML = POOLS.map((pool) => `
    <button class="pool-tab ${pool.id === save.activePool ? "active" : ""}" data-pool="${pool.id}" type="button">${pool.name}</button>
  `).join("");
  const pool = currentPool();
  document.getElementById("pool-type").textContent = pool.name;
  document.getElementById("pool-name").textContent = pool.name;
  document.getElementById("pool-heroes").textContent = pool.featured.map((id) => byId(id).name).join(" / ");
}

function renderGallery() {
  const grid = document.getElementById("gallery-grid");
  grid.innerHTML = HEROES.map((hero) => `
    <button class="hero-card ${save.owned[hero.id] ? "owned" : ""}" data-hero="${hero.id}" type="button">
      <strong>${save.owned[hero.id] ? hero.name : "未獲得"}</strong>
      <small>${"★".repeat(hero.rarity)} / ${hero.spine}</small>
      <div>${save.owned[hero.id] ? `持有 ${save.owned[hero.id]}` : "待抽取"}</div>
    </button>
  `).join("");
  renderDetail(byId(save.selectedHeroId));
}

function renderDetail(hero) {
  save.selectedHeroId = hero.id;
  const art = document.getElementById("detail-art");
  art.src = hero.art || ART;
  art.style.opacity = hero.art ? "1" : "0.38";
  document.getElementById("detail-rarity").textContent = "★".repeat(hero.rarity);
  document.getElementById("detail-name").textContent = hero.name;
  document.getElementById("detail-assets").textContent = hero.assets;
}

function renderHistory() {
  const list = document.getElementById("history-list");
  list.innerHTML = save.history.length
    ? save.history.map((row) => `
      <div class="history-row">
        <strong>${row.pool}<br><small>${row.time}</small></strong>
        <span>${row.results.join("、")}</span>
      </div>
    `).join("")
    : "<p>暫無抽卡記錄</p>";
}

function renderAll() {
  renderHome();
  renderPools();
  renderGallery();
  renderHistory();
}

document.addEventListener("click", (event) => {
  const target = event.target.closest("button");
  if (!target) return;
  if (target.dataset.view) switchView(target.dataset.view);
  if (target.dataset.pool) {
    save.activePool = target.dataset.pool;
    persist();
    renderPools();
  }
  if (target.dataset.draw) doDraw(Number(target.dataset.draw));
  if (target.dataset.hero) {
    renderDetail(byId(target.dataset.hero));
    persist();
  }
  if (target.dataset.action === "open-gacha") switchView("gacha");
  if (target.dataset.action === "open-gallery") switchView("gallery");
  if (target.dataset.action === "set-home") {
    persist();
    renderHome();
    switchView("home");
  }
  if (target.dataset.action === "reset-save") {
    save = structuredClone(DEFAULT_SAVE);
    persist();
    renderAll();
  }
});

renderAll();
