using System.Collections.Generic;
using System.Linq;
using Shaonv.Data;
using Shaonv.Gacha;
using UnityEngine;
using UnityEngine.UI;

namespace Shaonv.UI
{
    public sealed class MainUiController : MonoBehaviour
    {
        private GameDatabase database;
        private SaveData save;
        private GachaService gacha;

        private Canvas canvas;
        private RectTransform content;
        private Text titleText;
        private Text walletText;
        private Image heroImage;
        private Text heroNameText;
        private Text infoText;

        public void Initialize(GameDatabase database, SaveData save, GachaService gacha)
        {
            this.database = database;
            this.save = save;
            this.gacha = gacha;
            BuildRoot();
            ShowHome();
        }

        private void BuildRoot()
        {
            var eventSystem = new GameObject("EventSystem");
            eventSystem.AddComponent<UnityEngine.EventSystems.EventSystem>();
            eventSystem.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();

            canvas = new GameObject("Canvas").AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.gameObject.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvas.gameObject.AddComponent<GraphicRaycaster>();

            var root = Panel(canvas.transform, "Root", new Color(0.08f, 0.075f, 0.07f));
            root.anchorMin = Vector2.zero;
            root.anchorMax = Vector2.one;
            root.offsetMin = Vector2.zero;
            root.offsetMax = Vector2.zero;

            var nav = Panel(root, "Nav", new Color(0.13f, 0.12f, 0.11f));
            Anchor(nav, 0, 0, 0, 1, 0, 0, 210, 0);
            Button(nav, "主界面", new Vector2(18, -72), ShowHome);
            Button(nav, "抽卡", new Vector2(18, -126), ShowGacha);
            Button(nav, "圖鑑", new Vector2(18, -180), ShowGallery);
            Button(nav, "記錄", new Vector2(18, -234), ShowHistory);

            titleText = Label(root, "主界面", 30, TextAnchor.MiddleLeft);
            Anchor(titleText.rectTransform, 0, 1, 1, 1, 236, -78, -360, -20);
            walletText = Label(root, "", 18, TextAnchor.MiddleRight);
            Anchor(walletText.rectTransform, 1, 1, 1, 1, -340, -68, -24, -24);

            content = Panel(root, "Content", new Color(0, 0, 0, 0));
            Anchor(content, 0, 0, 1, 1, 236, 24, -24, -92);
        }

        private void ShowHome()
        {
            ClearContent("主界面");
            var hero = database.HeroById(save.selectedHeroId);
            if (hero == null)
            {
                return;
            }
            DrawHeroStage(hero);
            infoText.text = $"已收集 {save.ownedHeroes.Count}  |  高級保底 {save.GetPity("advanced")}/60";
            Button(content, "前往喚靈", new Vector2(24, 32), ShowGacha);
            Button(content, "查看圖鑑", new Vector2(176, 32), ShowGallery);
            RefreshWallet();
        }

        private void ShowGacha()
        {
            ClearContent("抽卡");
            var x = 24f;
            foreach (var pool in database.Pools)
            {
                var captured = pool;
                Button(content, pool.name, new Vector2(x, -24), () =>
                {
                    save.activePoolId = captured.id;
                    save.Persist();
                    ShowGacha();
                }, 132);
                x += 142;
            }

            var activePool = database.PoolById(save.activePoolId);
            if (activePool == null)
            {
                return;
            }
            LabelAt(content, activePool.name, 34, new Vector2(24, -120), new Vector2(500, 48));
            var heroNames = string.Join(" / ", activePool.featuredHeroIds.Select(id => database.HeroById(id).name));
            LabelAt(content, $"UP: {heroNames}\n保底: {save.GetPity(activePool.id)}/{activePool.pityLimit}", 18, new Vector2(24, -188), new Vector2(860, 72));
            Button(content, "喚靈 1 次", new Vector2(24, -286), () => DrawAndShow(1));
            Button(content, "喚靈 10 次", new Vector2(176, -286), () => DrawAndShow(10));
            RefreshWallet();
        }

        private void DrawAndShow(int count)
        {
            var results = gacha.Draw(save.activePoolId, count);
            ClearContent("結果");
            if (results.Count == 0)
            {
                LabelAt(content, "喚靈券不足", 28, new Vector2(24, -48), new Vector2(420, 48));
                Button(content, "返回", new Vector2(24, -120), ShowGacha);
                return;
            }

            var first = results[0].hero;
            if (first == null)
            {
                return;
            }
            DrawHeroStage(first);
            infoText.text = string.Join("\n", results.Select(result => $"{Stars(result.rolledRarity)} {result.hero.name} {(result.isNew ? "NEW" : "碎片")}"));
            Button(content, "再抽一次", new Vector2(24, 32), () => DrawAndShow(count));
            Button(content, "返回卡池", new Vector2(176, 32), ShowGacha);
            RefreshWallet();
        }

        private void ShowGallery()
        {
            ClearContent("圖鑑");
            var x = 24f;
            var y = -24f;
            foreach (var hero in database.Heroes)
            {
                var captured = hero;
                var owned = save.CopiesOf(hero.id) > 0;
                Button(content, owned ? $"{hero.name}\n{Stars(hero.rarity)} x{save.CopiesOf(hero.id)}" : $"未獲得\n{Stars(hero.rarity)}", new Vector2(x, y), () =>
                {
                    save.selectedHeroId = captured.id;
                    save.Persist();
                    ShowHome();
                }, 150, 84);
                x += 164;
                if (x > 760)
                {
                    x = 24;
                    y -= 96;
                }
            }
            RefreshWallet();
        }

        private void ShowHistory()
        {
            ClearContent("記錄");
            var text = save.history.Count == 0 ? "暫無抽卡記錄" : string.Join("\n\n", save.history.Select(row => $"{row.time} {row.poolName}\n{row.resultText}"));
            LabelAt(content, text, 18, new Vector2(24, -24), new Vector2(900, 620), TextAnchor.UpperLeft);
            Button(content, "重置存檔", new Vector2(24, 24), () =>
            {
                PlayerPrefs.DeleteKey("shaonv-unity-mvp-save");
                save.tickets = 120;
                save.gems = 16800;
                save.ownedHeroes.Clear();
                save.history.Clear();
                save.pity.Clear();
                save.Persist();
                ShowHome();
            });
            RefreshWallet();
        }

        private void DrawHeroStage(HeroRecord hero)
        {
            heroNameText = LabelAt(content, hero.name, 42, new Vector2(24, -36), new Vector2(420, 60));
            infoText = LabelAt(content, $"{Stars(hero.rarity)} / {hero.spine}", 20, new Vector2(24, -102), new Vector2(620, 96), TextAnchor.UpperLeft);
            heroImage = new GameObject("HeroImage").AddComponent<Image>();
            heroImage.transform.SetParent(content, false);
            heroImage.sprite = database.LoadHeroSprite(hero);
            heroImage.preserveAspect = true;
            Anchor(heroImage.rectTransform, 0.44f, 0.04f, 1, 0.96f, 0, 0, -24, 0);
        }

        private void ClearContent(string title)
        {
            titleText.text = title;
            foreach (Transform child in content)
            {
                Destroy(child.gameObject);
            }
        }

        private void RefreshWallet()
        {
            walletText.text = $"喚靈券 {save.tickets}   源石 {save.gems}";
        }

        private static RectTransform Panel(Transform parent, string name, Color color)
        {
            var image = new GameObject(name).AddComponent<Image>();
            image.transform.SetParent(parent, false);
            image.color = color;
            return image.rectTransform;
        }

        private static Text Label(Transform parent, string text, int size, TextAnchor align)
        {
            var label = new GameObject("Text").AddComponent<Text>();
            label.transform.SetParent(parent, false);
            label.text = text;
            label.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            label.fontSize = size;
            label.alignment = align;
            label.color = new Color(0.96f, 0.91f, 0.84f);
            label.horizontalOverflow = HorizontalWrapMode.Wrap;
            label.verticalOverflow = VerticalWrapMode.Overflow;
            return label;
        }

        private static Text LabelAt(Transform parent, string text, int size, Vector2 anchored, Vector2 sizeDelta, TextAnchor align = TextAnchor.MiddleLeft)
        {
            var label = Label(parent, text, size, align);
            label.rectTransform.anchorMin = new Vector2(0, 1);
            label.rectTransform.anchorMax = new Vector2(0, 1);
            label.rectTransform.pivot = new Vector2(0, 1);
            label.rectTransform.anchoredPosition = anchored;
            label.rectTransform.sizeDelta = sizeDelta;
            return label;
        }

        private static Button Button(Transform parent, string label, Vector2 anchored, UnityEngine.Events.UnityAction action, float width = 132, float height = 44)
        {
            var rect = Panel(parent, "Button", new Color(0.72f, 0.28f, 0.32f));
            rect.anchorMin = new Vector2(0, 1);
            rect.anchorMax = new Vector2(0, 1);
            rect.pivot = new Vector2(0, 1);
            rect.anchoredPosition = anchored;
            rect.sizeDelta = new Vector2(width, height);
            var button = rect.gameObject.AddComponent<Button>();
            button.onClick.AddListener(action);
            var text = Label(rect, label, 17, TextAnchor.MiddleCenter);
            Anchor(text.rectTransform, 0, 0, 1, 1, 4, 4, -4, -4);
            return button;
        }

        private static void Anchor(RectTransform rect, float minX, float minY, float maxX, float maxY, float left, float bottom, float right, float top)
        {
            rect.anchorMin = new Vector2(minX, minY);
            rect.anchorMax = new Vector2(maxX, maxY);
            rect.offsetMin = new Vector2(left, bottom);
            rect.offsetMax = new Vector2(right, top);
        }

        private static string Stars(int count)
        {
            return new string('★', Mathf.Clamp(count, 1, 5));
        }
    }
}
