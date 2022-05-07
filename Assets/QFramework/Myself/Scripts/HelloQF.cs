using UnityEngine;
using QFramework;

namespace QFramework.Example
{
    public class HelloQF : MonoBehaviour
    {
        // Start is called before the first frame update
        void Start()
        {
            Log.I("打印，如此简单！");
            "或者如此方便".LogInfo();
        }

    }
}