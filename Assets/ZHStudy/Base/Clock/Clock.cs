using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Clock : MonoBehaviour
{
    public Transform hoursTransform;
    public Transform minutesTransform;
    public Transform secondsTransform;

    public bool continuous;

    private const float degreesPerHour = 30f;
    private const float degreesPerMinutes = 6f;
    private const float degreesPerSeconds = 6f;
    private void Update()
    {
        if (continuous)
        {
            UpdateContinuous();
        }
        else
        {
            UpdateDiscrete();
        }
    }

    void UpdateDiscrete()
    {
        DateTime time = DateTime.Now;
        hoursTransform.rotation = Quaternion.Euler(0f, time.Hour * degreesPerHour, 0f);
        minutesTransform.rotation = Quaternion.Euler(0f, time.Minute * degreesPerMinutes, 0f);
        secondsTransform.rotation = Quaternion.Euler(0f, time.Second * degreesPerSeconds, 0f);
    }

    void UpdateContinuous()
    {
        TimeSpan time = DateTime.Now.TimeOfDay;
        hoursTransform.rotation = Quaternion.Euler(0f, (float)time.TotalHours * degreesPerHour, 0f);
        minutesTransform.rotation = Quaternion.Euler(0f, (float)time.TotalMinutes * degreesPerMinutes, 0f);
        secondsTransform.rotation = Quaternion.Euler(0f, (float)time.TotalSeconds * degreesPerSeconds, 0f);
    }
}
