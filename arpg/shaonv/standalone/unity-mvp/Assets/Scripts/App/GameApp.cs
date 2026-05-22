using Shaonv.Data;
using Shaonv.Gacha;
using Shaonv.UI;
using UnityEngine;

namespace Shaonv.App
{
    public sealed class GameApp : MonoBehaviour
    {
        private GameDatabase database;
        private SaveData save;
        private GachaService gacha;

        private void Awake()
        {
            Application.targetFrameRate = 60;
            database = GameDatabase.Load();
            save = SaveData.Load();
            gacha = new GachaService(database, save);

            var view = gameObject.AddComponent<MainUiController>();
            view.Initialize(database, save, gacha);
        }

        private void OnApplicationPause(bool pauseStatus)
        {
            if (pauseStatus)
            {
                save?.Persist();
            }
        }

        private void OnApplicationQuit()
        {
            save?.Persist();
        }
    }
}
