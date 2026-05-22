using System;
using System.Collections.Generic;
using System.Linq;
using Shaonv.Data;

namespace Shaonv.Gacha
{
    public sealed class GachaService
    {
        private readonly GameDatabase database;
        private readonly SaveData save;
        private readonly Random rng = new Random();

        public GachaService(GameDatabase database, SaveData save)
        {
            this.database = database;
            this.save = save;
        }

        public List<DrawResult> Draw(string poolId, int count)
        {
            var pool = database.PoolById(poolId);
            var totalCost = count * Math.Max(1, pool.ticketCost);
            if (save.tickets < totalCost)
            {
                return new List<DrawResult>();
            }

            save.tickets -= totalCost;
            var results = new List<DrawResult>();
            for (var i = 0; i < count; i++)
            {
                results.Add(DrawOne(pool));
            }

            save.history.Insert(0, new HistoryEntry
            {
                time = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                poolName = pool.name,
                resultText = string.Join("、", results.Select(result => result.hero.name + (result.isNew ? "(NEW)" : string.Empty)))
            });
            if (save.history.Count > 30)
            {
                save.history.RemoveRange(30, save.history.Count - 30);
            }

            save.Persist();
            return results;
        }

        private DrawResult DrawOne(GachaPoolRecord pool)
        {
            var pity = save.GetPity(pool.id) + 1;
            var forced = pity >= Math.Max(1, pool.pityLimit);
            var roll = rng.NextDouble();
            var rarity = 2;
            if (forced || roll < 0.02)
            {
                rarity = 4;
                pity = 0;
            }
            else if (roll < 0.14)
            {
                rarity = 3;
            }

            save.SetPity(pool.id, pity);

            var candidates = database.Heroes
                .Where(hero => rarity == 4 ? hero.rarity == 4 || pool.featuredHeroIds.Contains(hero.id) : hero.rarity == rarity)
                .ToList();

            if (candidates.Count == 0)
            {
                candidates = database.Heroes.ToList();
            }

            var featured = candidates.Where(hero => pool.featuredHeroIds.Contains(hero.id)).ToList();
            var list = rarity >= 3 && featured.Count > 0 && rng.NextDouble() < 0.55 ? featured : candidates;
            var hero = list[rng.Next(list.Count)];
            var isNew = save.AddHeroCopy(hero.id);
            return new DrawResult { hero = hero, rolledRarity = Math.Max(rarity, hero.rarity), isNew = isNew };
        }
    }
}
