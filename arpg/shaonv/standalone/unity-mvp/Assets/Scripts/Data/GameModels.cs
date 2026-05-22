using System;
using System.Collections.Generic;

namespace Shaonv.Data
{
    [Serializable]
    public sealed class HeroRecord
    {
        public int id;
        public string name;
        public int rarity;
        public string spine;
        public string artResource;
    }

    [Serializable]
    public sealed class HeroList
    {
        public List<HeroRecord> heroes = new List<HeroRecord>();
    }

    [Serializable]
    public sealed class GachaPoolRecord
    {
        public string id;
        public string name;
        public int ticketCost;
        public int pityLimit;
        public List<int> featuredHeroIds = new List<int>();
    }

    [Serializable]
    public sealed class GachaPoolList
    {
        public List<GachaPoolRecord> pools = new List<GachaPoolRecord>();
    }

    public sealed class DrawResult
    {
        public HeroRecord hero;
        public int rolledRarity;
        public bool isNew;
    }
}
