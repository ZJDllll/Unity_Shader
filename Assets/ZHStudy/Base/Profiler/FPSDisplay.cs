using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Studay
{
    [RequireComponent(typeof(FPSCounter))]
    public class FPSDisplay : MonoBehaviour
    {
        public Text highestFPSLabel;
        public Text averageFPSLabel;
        public Text lowestFPSLabel;
        [SerializeField]
        private FPSCounter.FPSColor[] coloring;
        FPSCounter fPSCounter;
        private void Awake()
        {
            fPSCounter = GetComponent<FPSCounter>();
        }

        private void Update()
        {

            Display(highestFPSLabel, fPSCounter.HighestFPS);
            Display(averageFPSLabel, fPSCounter.AverageFPS);
            Display(lowestFPSLabel, fPSCounter.LowestFPS);
        }

        void Display(Text label, int fps)
        {
            label.text = Mathf.Clamp(fps, 0, 999).ToString();
            for (int i = 0; i < coloring.Length; i++)
            {
                if (fps >= coloring[i].minimumFPS)
                {
                    label.color = coloring[i].color;
                    break;
                }
            }
        }
    }
}
