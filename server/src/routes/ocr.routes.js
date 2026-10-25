const express = require('express');
const router = express.Router();
const geminiService = require('../services/geminiService');

// Analyze medical report using OCR and Gemini
router.post('/analyze-report', async (req, res) => {
  try {
    const { userId, image, fileName, fileType = 'image' } = req.body;

    if (!userId || !image) {
      return res.status(400).json({ error: 'Missing userId or image data' });
    }

    // Create a prompt for Gemini to analyze the medical report
    const analysisPrompt = `You are a medical report analyzer. A user has uploaded a medical report ${fileType === 'pdf' ? '(PDF)' : '(image)'} for analysis.

Please analyze this medical report and provide:
1. A clear, easy-to-understand summary of what the report shows
2. Key findings from the report (list as bullet points)
3. Recommendations based on the findings (list as bullet points)

Format your response as JSON with these exact keys:
{
  "summary": "A 2-3 sentence easy-to-understand summary of the report",
  "keyFindings": ["finding 1", "finding 2", "finding 3"],
  "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"]
}

Important:
- Use simple, non-medical language that a patient can understand
- Focus on what the numbers/results mean in practical terms
- If you cannot read the document clearly, say so in the summary
- Always recommend consulting with a healthcare provider for medical advice
- Keep the summary concise but informative`;

    // Determine MIME type based on file type
    const mimeType = fileType === 'pdf' ? 'application/pdf' : 'image/jpeg';

    // Send to Gemini with vision capability
    const response = await geminiService.analyzeDocument(image, analysisPrompt, mimeType);

    // Parse the response as JSON
    let analysisResult;
    try {
      // Extract JSON from the response (in case there's extra text)
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        analysisResult = JSON.parse(jsonMatch[0]);
      } else {
        // If no JSON found, create a structured response from the text
        analysisResult = {
          summary: response,
          keyFindings: [],
          recommendations: [
            'Please consult with your healthcare provider for personalized medical advice.',
          ],
        };
      }
    } catch (parseError) {
      // If JSON parsing fails, return the response as summary
      analysisResult = {
        summary: response,
        keyFindings: [],
        recommendations: [
          'Please consult with your healthcare provider for personalized medical advice.',
        ],
      };
    }

    res.status(200).json(analysisResult);
  } catch (error) {
    console.error('Error analyzing medical report:', error);
    res.status(500).json({
      error: 'Failed to analyze medical report',
      message: error.message,
    });
  }
});

module.exports = router;
