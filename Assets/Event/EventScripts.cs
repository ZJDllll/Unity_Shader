using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EventScripts : MonoBehaviour
{

    public UnityEvent selfEvent;
    public UnityEvent<int> intEvent;
    // Start is called before the first frame update
    void Start()
    {
        selfEvent.AddListener(FirstFun);
        intEvent.AddListener(TwoFun);
    }

    // Update is called once per frame
    void Update()
    {
        
    }



    public void OnBtnClick()
    {
        Debug.Log("��ť���");
        selfEvent?.Invoke();
        intEvent?.Invoke(2);
        //FirstFun();
    }


    public void FirstFun()
    {
        Debug.Log("��һ������");
    }

    public void TwoFun(int id)
    {
        Debug.Log("�ڶ�������");
    }
}
