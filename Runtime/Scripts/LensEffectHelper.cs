using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;

#if UNITY_EDITOR
using UnityEditor;
#endif


namespace SimulFactory.LensEffectShader.Runtime.Scripts
{
    [AttributeUsage(AttributeTargets.All, Inherited = true)]
    public class ReadOnlyAttribute : PropertyAttribute
    {
    }

#if UNITY_EDITOR
    [CustomPropertyDrawer(typeof(ReadOnlyAttribute))]
    public class ReadOnlyDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            EditorGUI.BeginDisabledGroup(true);
            EditorGUI.PropertyField(position, property, label, true);
            EditorGUI.EndDisabledGroup();
        }
    }
#endif

    [RequireComponent(typeof(Image))]
    public class LensEffectHelper : MonoBehaviour
    {
        [ReadOnly] public Image image;
        public float animTime;

        private Material tempMat;

        private void Awake()
        {
            tempMat = new Material(image.material);
            image.material = tempMat;

            Deactivate(0f);

            SetScreenSize();
        }

        private void OnValidate()
        {
            image = this.GetComponent<Image>();

            tempMat = new Material(image.material);
            image.material = tempMat;

            SetScreenSize();
        }

        private void SetScreenSize()
        {
            image.material.SetFloat("_ScreenWidth", Screen.width);
            image.material.SetFloat("_ScreenHeight", Screen.height);
        }

        public void Deactivate(float animTime)
        {
            SetLens(image.material.GetFloat("_LensMaxSize"), animTime);
        }

        public void SetLens(float targetSize, float animTime)
        {
            StopAllCoroutines();
            if (animTime > 0)
            {
                StartCoroutine(LensEffect(targetSize));
            }
            else
            {
                SetLensSize(targetSize);
            }
        }

        private void SetLensSize(float size)
        {
            image.material.SetFloat("_LensSize", size);
        }

        public void SetGradientSize(float size)
        {
            image.material.SetFloat("_LensGradientSize", size);
        }

        private IEnumerator LensEffect(float targetSize)
        {
            float elapsed = 0f;

            while (elapsed < animTime)
            {
                elapsed += Time.deltaTime;
                SetLensSize(Mathf.Lerp(image.material.GetFloat("_LensSize"), targetSize, elapsed / animTime));
                yield return null;
            }

            SetLensSize(targetSize);
        }
    }
}
