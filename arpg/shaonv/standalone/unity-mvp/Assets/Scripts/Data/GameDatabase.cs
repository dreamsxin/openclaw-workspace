using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace Shaonv.Data
{
    public sealed class GameDatabase
    {
        public readonly List<HeroRecord> Heroes;
        public readonly List<GachaPoolRecord> Pools;

        private GameDatabase(List<HeroRecord> heroes, List<GachaPoolRecord> pools)
        {
            Heroes = heroes;
            Pools = pools;
        }

        public static GameDatabase Load()
        {
            var heroList = ReadJson<HeroList>("heroes_mvp.json") ?? new HeroList();
            var poolList = ReadJson<GachaPoolList>("gacha_pools_mvp.json") ?? new GachaPoolList();
            var heroes = heroList.heroes;
            var pools = poolList.pools;
            return new GameDatabase(heroes, pools);
        }

        public HeroRecord HeroById(int id)
        {
            return Heroes.FirstOrDefault(hero => hero.id == id) ?? Heroes.FirstOrDefault();
        }

        public GachaPoolRecord PoolById(string id)
        {
            return Pools.FirstOrDefault(pool => pool.id == id) ?? Pools.FirstOrDefault();
        }

        public Sprite LoadHeroSprite(HeroRecord hero)
        {
            if (hero == null || string.IsNullOrWhiteSpace(hero.artResource))
            {
                return null;
            }

            var texture = Resources.Load<Texture2D>(hero.artResource);
            if (texture == null)
            {
                return null;
            }

            return Sprite.Create(
                texture,
                new Rect(0, 0, texture.width, texture.height),
                new Vector2(0.5f, 0.5f),
                100f);
        }

        private static T ReadJson<T>(string fileName)
        {
            var path = Path.Combine(Application.streamingAssetsPath, "data", fileName);
            if (!File.Exists(path))
            {
                Debug.LogWarning($"Missing StreamingAssets data file: {path}");
                return default;
            }
            var json = File.ReadAllText(path);
            return JsonUtility.FromJson<T>(json);
        }
    }
}
