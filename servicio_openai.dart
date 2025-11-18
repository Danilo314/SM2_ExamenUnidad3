import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ServicioOpenAI {
  // 🧩 Coloca tu API Key de OpenAI aquí
  static const _apiKey = "TU_OPENAI_API_KEY_ACA";
  static const _apiUrl = "https://api.openai.com/v1/responses";
  static String get apiKey => _apiKey;

  /// ✅ Verifica si la imagen contiene una mascota (perro, gato u otro animal doméstico)
  static Future<bool> contieneMascota(File imagen) async {
    try {
      final bytes = await imagen.readAsBytes();
      final base64 = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4.1-mini",
          "input": [
            {
              "role": "user",
              "content": [
                {
                  "type": "input_text",
                  "text":
                      "Responde solo 'si' o 'no': ¿esta imagen contiene una mascota (perro, gato u otro animal doméstico)?",
                },
                {
                  "type": "input_image",
                  "image_url": "data:image/jpeg;base64,$base64",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final texto = data["output"][0]["content"][0]["text"]
            .toString()
            .toLowerCase()
            .trim();

        return texto.contains("sí") ||
            texto.contains("si") ||
            texto.contains("yes");
      } else {
        print("❌ Error OpenAI: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error validando imagen con OpenAI: $e");
      return false;
    }
  }
}
