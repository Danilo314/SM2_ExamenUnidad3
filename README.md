SM2_ExamenUnidad3
Implementar un flujo de trabajo (workflow) automatizado en GitHub Actions para realizar análisis de calidad sobre tu proyecto móvil, integrando prácticas de DevOps.
El informe debe estar realizado en el propio README.md del proyecto y debe contener lo siguiente:
Nombre del curso: Solucciones Moviles II 
Fecha: 18/11/2025 
Nombres completos del estudiante: Brian Danilo Chite Quispe 
URL del repositorio SM2_ExamenUnidad3 en GitHub: https://github.com/Danilo314/SM2_ExamenUnidad3


📌 Objetivo del examen
Implementar un flujo de trabajo automatizado con GitHub Actions para validar la calidad del proyecto móvil mediante análisis estático y pruebas unitarias.

📁 Estructura del proyecto

Se creó el repositorio SM2_ExamenUnidad3, en el cual se integró el proyecto móvil desarrollado durante el curso.
Dentro del repositorio se generaron las carpetas necesarias para GitHub Actions:

SM2_ExamenUnidad3/
 ├─ lib/
 ├─ test/
 │   └─ main_test.dart
 ├─ .github/
 │   └─ workflows/
 │       └─ quality-check.yml
 └─ README.md

 ⚙️ Workflow: quality-check.yml

Se configuró un workflow que se ejecuta automáticamente al realizar un push o pull request hacia la rama main.

Este archivo incluye:
Instalación de Flutter
Obtención de dependencias
Ejecución de flutter analyze
Ejecución de flutter test
