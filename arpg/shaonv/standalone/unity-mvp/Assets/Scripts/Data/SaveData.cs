using System;
using System.Collections.Generic;
using UnityEngine;

namespace Shaonv.Data
{
    [Serializable]
    public sealed class OwnedHero
    {
        public int heroId;
        public int copies;
    }

    [Serializable]
    public sealed class PoolPity
    {
        public string poolId;
        public int value;
    }

    [Serializable]
    public sealed class HistoryEntry
    {
        public string time;
        public string poolName;
        public string resultText;
    }

    [Serializable]
    public sealed class SaveData
    {
        private const string SaveKey = "shaonv-unity-mvp-save";

        public int tickets = 120;
        public int gems = 16800;
        public int selectedHeroId = 240065;
        public string activePoolId = "advanced";
        public List<OwnedHero> ownedHeroes = new List<OwnedHero>();
        public List<PoolPity> pity = new List<PoolPity>();
        public List<HistoryEntry> history = new List<HistoryEntry>();

        public static SaveData Load()
        {
            var raw = PlayerPrefs.GetString(SaveKey, string.Empty);
            if (string.IsNullOrWhiteSpace(raw))
            {
                return new SaveData();
            }

            try
            {
                return JsonUtility.FromJson<SaveData>(raw) ?? new SaveData();
            }
            catch
            {
                return new SaveData();
            }
        }

        public void Persist()
        {
            PlayerPrefs.SetString(SaveKey, JsonUtility.ToJson(this));
            PlayerPrefs.Save();
        }

        public int CopiesOf(int heroId)
        {
            return ownedHeroes.Find(hero => hero.heroId == heroId)?.copies ?? 0;
        }

        public bool AddHeroCopy(int heroId)
        {
            var owned = ownedHeroes.Find(hero => hero.heroId == heroId);
            if (owned == null)
            {
                ownedHeroes.Add(new OwnedHero { heroId = heroId, copies = 1 });
                return true;
            }

            owned.copies += 1;
            return false;
        }

        public int GetPity(string poolId)
        {
            return pity.Find(item => item.poolId == poolId)?.value ?? 0;
        }

        public void SetPity(string poolId, int value)
        {
            var item = pity.Find(entry => entry.poolId == poolId);
            if (item == null)
            {
                pity.Add(new PoolPity { poolId = poolId, value = value });
                return;
            }

            item.value = value;
        }
    }
}
