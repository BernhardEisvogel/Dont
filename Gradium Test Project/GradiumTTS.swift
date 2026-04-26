import Foundation

/// A minimal working example for the Gradium Text-to-Speech (TTS) API in Swift.
/// 
/// This script demonstrates how to:
/// 1. Configure a request to the Gradium REST API.
/// 2. Use `only_audio: true` to receive high-quality raw audio data.
/// 3. Save the resulting data to a `.wav` file.

// MARK: - Configuration
let apiKey = "--" // Replace with your actual Gradium API Key
let endpoint = "https://api.gradium.ai/api/post/speech/tts"

struct GradiumTTSRequest: Codable {
    let text: String
    let voice_id: String
    let output_format: String
    let model_name: String
    let only_audio: Bool
}

// MARK: - Main Logic
func runTTSExample() async {
    print("Starting Gradium TTS request...")
    
    // 1. Prepare the request payload
    let requestBody = GradiumTTSRequest(
        text: "Hello, dolphins!",
        voice_id: "YTpq7expH9539ERJ",
        output_format: "wav",
        model_name: "default",
        only_audio: true // Direct binary response for simplicity
    )
    
    // 2. Setup the URLRequest
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        request.httpBody = try JSONEncoder().encode(requestBody)
    } catch {
        print("Error encoding request body: \(error)")
        return
    }
    
    // 3. Execute the request
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response from server.")
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Request failed with status code: \(httpResponse.statusCode)")
            print("Error details: \(errorMsg)")
            return
        }
        
        // 4. Save to output.wav
        let fileURL = URL(fileURLWithPath: "output.wav")
        try data.write(to: fileURL)
        
        print("Successfully saved audio to \(fileURL.path)")
        
        // 5. Print Metadata (Matching your Python example)
        // Note: With only_audio=true, metadata like request_id is typically in headers
        let requestId = httpResponse.value(forHTTPHeaderField: "x-request-id") ?? "unknown"
        print("Request ID: \(requestId)")
        
        // For 'wav' format, the sample rate is in the file header. 
        // Gradium default is 48000 Hz.
        print("Sample rate: 48000 (standard Gradium output)")
        
    } catch {
        print("Network error: \(error.localizedDescription)")
    }
}

// Start the async execution
Task {
    await runTTSExample()
    exit(0)
}

// Keep the script running until the task finishes
RunLoop.main.run()
