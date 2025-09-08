# 🌱 DERM-AI: Edge-Powered Skin Disease Classification & Anomaly Detection

DERM-AI is a **semi-supervised, edge-computing AI system** that transforms smartphones into intelligent dermatology assistants.  
Built with **MobileNetV2** and **GAN-based anomaly detection**, DERM-AI provides **offline, privacy-preserving, real-time skin disease classification** — enabling accessible healthcare for everyone, everywhere.

---

## 📌 Features

✅ **High Accuracy:**

- 99% classification accuracy on four common conditions: **Acne, Ringworm, Nail Fungus, Athlete’s Foot**

✅ **Anomaly Detection:**

- GAN-based system with **75.7% F1-score**, flags rare/unknown conditions for further consultation

✅ **Edge AI Deployment:**

- INT8 quantization reduces model size by **90%**
- Runs **fully offline** on-device, preserving privacy

✅ **Cross-Platform Support:**

- Built with **Flutter + TFLite** for smooth performance
- Android ready (iOS support planned)

✅ **Privacy & Security:**

- All data stays **on-device**
- Secure authentication flow for user safety

---

## 🏗️ Tech Stack

| Layer                        | Tools & Frameworks                        |
| ---------------------------- | ----------------------------------------- |
| **ML Model**                 | Python, TensorFlow, MobileNetV2, GANomaly |
| **Preprocessing & Training** | NumPy, Pandas, Matplotlib, Scikit-learn   |
| **Deployment**               | TensorFlow Lite (INT8 Quantization)       |
| **Mobile App**               | Flutter, Dart, Android Studio             |
| **Security**                 | Firebase Auth (Optional)                  |

---

## 📂 Project Structure

```bash
DERM-AI/
│
├── notebooks/              # Jupyter notebooks for training & evaluation
├── app/                    # Flutter mobile application
└── README.md
```
